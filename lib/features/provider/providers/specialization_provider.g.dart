// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'specialization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredSpecializationsHash() =>
    r'4ee53fe61fdc9d5f8689c21250e468471de6932e';

/// See also [filteredSpecializations].
@ProviderFor(filteredSpecializations)
final filteredSpecializationsProvider =
    AutoDisposeFutureProvider<List<SpecializationModel>>.internal(
      filteredSpecializations,
      name: r'filteredSpecializationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredSpecializationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredSpecializationsRef =
    AutoDisposeFutureProviderRef<List<SpecializationModel>>;
String _$specializationStateHash() =>
    r'3eca6ccb5ce6d9ea592ba8ce11bf6343fd20eaa4';

/// See also [SpecializationState].
@ProviderFor(SpecializationState)
final specializationStateProvider =
    AutoDisposeAsyncNotifierProvider<
      SpecializationState,
      List<SpecializationModel>
    >.internal(
      SpecializationState.new,
      name: r'specializationStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$specializationStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SpecializationState =
    AutoDisposeAsyncNotifier<List<SpecializationModel>>;
String _$specializationFilterHash() =>
    r'e259a0a839e08d1d4f422a19a59e6a8ee0d283a3';

/// See also [SpecializationFilter].
@ProviderFor(SpecializationFilter)
final specializationFilterProvider =
    AutoDisposeNotifierProvider<SpecializationFilter, String?>.internal(
      SpecializationFilter.new,
      name: r'specializationFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$specializationFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SpecializationFilter = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
