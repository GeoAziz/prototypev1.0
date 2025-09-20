class ProviderOnboardingStep {
  final String title;
  final String description;
  bool isCompleted;

  ProviderOnboardingStep({
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
}
