// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_stream_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availabilityStreamHash() =>
    r'7f4848b49b2816e7cbd0da6ded95931b76829f84';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [availabilityStream].
@ProviderFor(availabilityStream)
const availabilityStreamProvider = AvailabilityStreamFamily();

/// See also [availabilityStream].
class AvailabilityStreamFamily extends Family<AsyncValue<Availability>> {
  /// See also [availabilityStream].
  const AvailabilityStreamFamily();

  /// See also [availabilityStream].
  AvailabilityStreamProvider call(String providerId) {
    return AvailabilityStreamProvider(providerId);
  }

  @override
  AvailabilityStreamProvider getProviderOverride(
    covariant AvailabilityStreamProvider provider,
  ) {
    return call(provider.providerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'availabilityStreamProvider';
}

/// See also [availabilityStream].
class AvailabilityStreamProvider
    extends AutoDisposeStreamProvider<Availability> {
  /// See also [availabilityStream].
  AvailabilityStreamProvider(String providerId)
    : this._internal(
        (ref) => availabilityStream(ref as AvailabilityStreamRef, providerId),
        from: availabilityStreamProvider,
        name: r'availabilityStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$availabilityStreamHash,
        dependencies: AvailabilityStreamFamily._dependencies,
        allTransitiveDependencies:
            AvailabilityStreamFamily._allTransitiveDependencies,
        providerId: providerId,
      );

  AvailabilityStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.providerId,
  }) : super.internal();

  final String providerId;

  @override
  Override overrideWith(
    Stream<Availability> Function(AvailabilityStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AvailabilityStreamProvider._internal(
        (ref) => create(ref as AvailabilityStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        providerId: providerId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Availability> createElement() {
    return _AvailabilityStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailabilityStreamProvider &&
        other.providerId == providerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, providerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AvailabilityStreamRef on AutoDisposeStreamProviderRef<Availability> {
  /// The parameter `providerId` of this provider.
  String get providerId;
}

class _AvailabilityStreamProviderElement
    extends AutoDisposeStreamProviderElement<Availability>
    with AvailabilityStreamRef {
  _AvailabilityStreamProviderElement(super.provider);

  @override
  String get providerId => (origin as AvailabilityStreamProvider).providerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
