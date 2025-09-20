class CurrencyConfig {
  static const Map<String, String> currencyCodes = {
    'KE': 'KES', // Kenya Shillings
    'UG': 'UGX', // Uganda Shillings
    'TZ': 'TZS', // Tanzania Shillings
    'US': 'USD', // US Dollars (default)
    // Add more countries as needed
  };

  static const Map<String, String> currencySymbols = {
    'KES': 'KSh',
    'UGX': 'USh',
    'TZS': 'TSh',
    'USD': '\$',
    // Add more currencies as needed
  };

  static String getCurrencyCode(String countryCode) {
    return currencyCodes[countryCode] ?? 'USD'; // Default to USD
  }

  static String getCurrencySymbol(String currencyCode) {
    return currencySymbols[currencyCode] ?? '\$'; // Default to $
  }
}
