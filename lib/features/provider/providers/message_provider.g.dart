// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageStateHash() => r'e1f5085992ebd7646ddb45f6f0bed1c055615892';

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

abstract class _$MessageState
    extends BuildlessAutoDisposeNotifier<List<Message>> {
  late final String userId;
  late final String providerId;

  List<Message> build(String userId, String providerId);
}

/// See also [MessageState].
@ProviderFor(MessageState)
const messageStateProvider = MessageStateFamily();

/// See also [MessageState].
class MessageStateFamily extends Family<List<Message>> {
  /// See also [MessageState].
  const MessageStateFamily();

  /// See also [MessageState].
  MessageStateProvider call(String userId, String providerId) {
    return MessageStateProvider(userId, providerId);
  }

  @override
  MessageStateProvider getProviderOverride(
    covariant MessageStateProvider provider,
  ) {
    return call(provider.userId, provider.providerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageStateProvider';
}

/// See also [MessageState].
class MessageStateProvider
    extends AutoDisposeNotifierProviderImpl<MessageState, List<Message>> {
  /// See also [MessageState].
  MessageStateProvider(String userId, String providerId)
    : this._internal(
        () => MessageState()
          ..userId = userId
          ..providerId = providerId,
        from: messageStateProvider,
        name: r'messageStateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageStateHash,
        dependencies: MessageStateFamily._dependencies,
        allTransitiveDependencies:
            MessageStateFamily._allTransitiveDependencies,
        userId: userId,
        providerId: providerId,
      );

  MessageStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
    required this.providerId,
  }) : super.internal();

  final String userId;
  final String providerId;

  @override
  List<Message> runNotifierBuild(covariant MessageState notifier) {
    return notifier.build(userId, providerId);
  }

  @override
  Override overrideWith(MessageState Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessageStateProvider._internal(
        () => create()
          ..userId = userId
          ..providerId = providerId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
        providerId: providerId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<MessageState, List<Message>>
  createElement() {
    return _MessageStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageStateProvider &&
        other.userId == userId &&
        other.providerId == providerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);
    hash = _SystemHash.combine(hash, providerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageStateRef on AutoDisposeNotifierProviderRef<List<Message>> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `providerId` of this provider.
  String get providerId;
}

class _MessageStateProviderElement
    extends AutoDisposeNotifierProviderElement<MessageState, List<Message>>
    with MessageStateRef {
  _MessageStateProviderElement(super.provider);

  @override
  String get userId => (origin as MessageStateProvider).userId;
  @override
  String get providerId => (origin as MessageStateProvider).providerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
