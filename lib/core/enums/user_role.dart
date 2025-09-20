enum UserRole {
  client,
  provider;

  String get displayName {
    switch (this) {
      case UserRole.client:
        return 'Client';
      case UserRole.provider:
        return 'Service Provider';
    }
  }

  String get description {
    switch (this) {
      case UserRole.client:
        return 'I want to find and book services';
      case UserRole.provider:
        return 'I want to offer my services';
    }
  }
}
