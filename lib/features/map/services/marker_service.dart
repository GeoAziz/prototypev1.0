import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/models/provider.dart';
import '../../../core/theme/app_colors.dart';

class MarkerService {
  static const double MARKER_SIZE = 80;
  static const int CLUSTER_ZOOM_LEVEL = 14;

  // Cache for marker icons to avoid regenerating them
  final Map<String, BitmapDescriptor> _markerIconCache = {};

  Future<BitmapDescriptor> createCustomMarkerIcon(Provider provider) async {
    // Check cache first
    final cacheKey = 'provider_${provider.id}';
    if (_markerIconCache.containsKey(cacheKey)) {
      return _markerIconCache[cacheKey]!;
    }

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = AppColors.primary;

    // Draw circular background
    canvas.drawCircle(
      const Offset(MARKER_SIZE / 2, MARKER_SIZE / 2),
      MARKER_SIZE / 2,
      paint,
    );

    // Draw provider image if available
    if (provider.profileImageUrl != null) {
      try {
        final imageData = await NetworkAssetBundle(
          Uri.parse(provider.profileImageUrl!),
        ).load(provider.profileImageUrl!);
        final codec = await ui.instantiateImageCodec(
          imageData.buffer.asUint8List(),
          targetHeight: (MARKER_SIZE - 10).toInt(),
          targetWidth: (MARKER_SIZE - 10).toInt(),
        );
        final frame = await codec.getNextFrame();
        canvas.drawImage(frame.image, Offset(5, 5), paint);
      } catch (e) {
        print('Error loading provider image for marker: $e');
        // Draw fallback icon
        _drawFallbackIcon(canvas);
      }
    } else {
      _drawFallbackIcon(canvas);
    }

    // Convert canvas to image
    final image = await pictureRecorder.endRecording().toImage(
      MARKER_SIZE.toInt(),
      MARKER_SIZE.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    // Create and cache the marker icon
    final markerIcon = BitmapDescriptor.fromBytes(bytes);
    _markerIconCache[cacheKey] = markerIcon;

    return markerIcon;
  }

  void _drawFallbackIcon(Canvas canvas) {
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw a simple person icon
    canvas.drawCircle(
      Offset(MARKER_SIZE / 2, MARKER_SIZE / 3),
      MARKER_SIZE / 6,
      iconPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        MARKER_SIZE / 3,
        MARKER_SIZE / 2,
        MARKER_SIZE / 3,
        MARKER_SIZE / 3,
      ),
      iconPaint,
    );
  }

  Future<BitmapDescriptor> createClusterMarkerIcon(int count) async {
    final cacheKey = 'cluster_$count';
    if (_markerIconCache.containsKey(cacheKey)) {
      return _markerIconCache[cacheKey]!;
    }

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    // Draw cluster circle
    canvas.drawCircle(
      const Offset(MARKER_SIZE / 2, MARKER_SIZE / 2),
      MARKER_SIZE / 2,
      paint,
    );

    // Draw count text
    final textPainter = TextPainter(
      text: TextSpan(
        text: count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (MARKER_SIZE - textPainter.width) / 2,
        (MARKER_SIZE - textPainter.height) / 2,
      ),
    );

    final image = await pictureRecorder.endRecording().toImage(
      MARKER_SIZE.toInt(),
      MARKER_SIZE.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final markerIcon = BitmapDescriptor.fromBytes(bytes);
    _markerIconCache[cacheKey] = markerIcon;

    return markerIcon;
  }

  List<Marker> createClusteredMarkers(
    List<Provider> providers,
    double currentZoom,
    Function(Provider) onMarkerTap,
  ) {
    if (currentZoom >= CLUSTER_ZOOM_LEVEL) {
      // Show individual markers when zoomed in
      return providers.map((provider) {
        return Marker(
          markerId: MarkerId(provider.id),
          position: LatLng(
            provider.location!.latitude,
            provider.location!.longitude,
          ),
          onTap: () => onMarkerTap(provider),
          icon:
              _markerIconCache['provider_${provider.id}'] ??
              BitmapDescriptor.defaultMarker,
        );
      }).toList();
    } else {
      // Create clusters when zoomed out
      final clusters = _createClusters(providers);
      return clusters.map((cluster) {
        final isCluster = cluster.providers.length > 1;
        if (isCluster) {
          return Marker(
            markerId: MarkerId(
              'cluster_${cluster.center.latitude}_${cluster.center.longitude}',
            ),
            position: cluster.center,
            icon:
                _markerIconCache['cluster_${cluster.providers.length}'] ??
                BitmapDescriptor.defaultMarker,
            onTap: () {
              // Show bottom sheet with list of providers in cluster
              // This will be implemented in the MapScreen
            },
          );
        } else {
          final provider = cluster.providers.first;
          return Marker(
            markerId: MarkerId(provider.id),
            position: LatLng(
              provider.location!.latitude,
              provider.location!.longitude,
            ),
            onTap: () => onMarkerTap(provider),
            icon:
                _markerIconCache['provider_${provider.id}'] ??
                BitmapDescriptor.defaultMarker,
          );
        }
      }).toList();
    }
  }

  List<Cluster> _createClusters(List<Provider> providers) {
    const gridSize = 0.01; // About 1km at equator
    final clusters = <Cluster>[];
    final processedCoordinates = <String>{};

    for (final provider in providers) {
      if (provider.location == null) continue;

      // Create grid cell ID
      final cellLat =
          (provider.location!.latitude / gridSize).floor() * gridSize;
      final cellLng =
          (provider.location!.longitude / gridSize).floor() * gridSize;
      final cellId = '${cellLat}_$cellLng';

      if (processedCoordinates.contains(cellId)) {
        // Add to existing cluster
        final cluster = clusters.firstWhere(
          (c) => c.id == cellId,
          orElse: () => Cluster(
            center: LatLng(cellLat + gridSize / 2, cellLng + gridSize / 2),
            providers: [],
            id: cellId,
          ),
        );
        cluster.providers.add(provider);
        if (!clusters.contains(cluster)) {
          clusters.add(cluster);
        }
      } else {
        // Create new cluster
        processedCoordinates.add(cellId);
        clusters.add(
          Cluster(
            center: LatLng(cellLat + gridSize / 2, cellLng + gridSize / 2),
            providers: [provider],
            id: cellId,
          ),
        );
      }
    }

    return clusters;
  }

  void clearCache() {
    _markerIconCache.clear();
  }
}

class Cluster {
  final LatLng center;
  final List<Provider> providers;
  final String id;

  Cluster({required this.center, required this.providers, required this.id});
}
