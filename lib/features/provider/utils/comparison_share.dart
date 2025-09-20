import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../models/comparison_model.dart';

class ComparisonShare {
  static Future<void> shareComparison(
    BuildContext context,
    GlobalKey screenshotKey,
    ComparisonResult comparison,
  ) async {
    try {
      // Capture the comparison view as an image
      final image = await _captureWidget(screenshotKey);
      if (image == null) {
        throw Exception('Failed to capture comparison view');
      }

      // Get temporary directory to save the image
      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/comparison_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);

      // Save the image
      await imageFile.writeAsBytes(image);

      // Generate text summary
      final summary = _generateComparisonSummary(comparison);

      // Share both the image and text
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: summary,
        subject: 'Service Provider Comparison',
      );

      // Clean up temporary file
      await imageFile.delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing comparison: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<Uint8List?> _captureWidget(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturing widget: $e');
      return null;
    }
  }

  static String _generateComparisonSummary(ComparisonResult comparison) {
    final buffer = StringBuffer();
    buffer.writeln('Service Provider Comparison\n');

    // Add provider rankings
    buffer.writeln('Provider Rankings:');
    for (var i = 0; i < comparison.rankedItems.length; i++) {
      final item = comparison.rankedItems[i];
      final score = comparison.scores[item.provider.id] ?? 0.0;
      buffer.writeln(
        '${i + 1}. ${item.provider.name} - Score: ${(score * 100).toStringAsFixed(1)}%',
      );
    }
    buffer.writeln();

    // Add highlights
    buffer.writeln('Provider Highlights:');
    for (final item in comparison.rankedItems) {
      buffer.writeln('\n${item.provider.name}:');
      final highlights = comparison.highlights[item.provider.id] ?? [];
      for (final highlight in highlights) {
        buffer.writeln('• $highlight');
      }
    }
    buffer.writeln();

    // Add key metrics
    buffer.writeln('Key Metrics:');
    for (final item in comparison.rankedItems) {
      buffer.writeln('\n${item.provider.name}:');
      buffer.writeln('• Rating: ${item.rating.toStringAsFixed(1)} ★');
      buffer.writeln('• Completed Projects: ${item.completedProjects}');
      buffer.writeln(
        '• Response Rate: ${item.responseRate.toStringAsFixed(1)}%',
      );
      buffer.writeln('• Booking Rate: ${item.bookingRate.toStringAsFixed(1)}%');
    }

    return buffer.toString();
  }
}
