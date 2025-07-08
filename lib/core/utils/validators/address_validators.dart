/// Validators for address and location fields
class AddressValidators {
  /// Validates postal/zip code format
  static String? validatePostalCode(String? value, {String country = 'US'}) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }

    // Different regex patterns for different countries
    RegExp? regex;
    switch (country) {
      case 'US':
        regex = RegExp(r'^\d{5}(-\d{4})?$');
        break;
      case 'CA':
        regex = RegExp(r'^[A-Za-z]\d[A-Za-z] ?\d[A-Za-z]\d$');
        break;
      case 'UK':
        regex = RegExp(
          r'^[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}$',
          caseSensitive: false,
        );
        break;
      default:
        // Default basic validation
        if (value.length < 3) {
          return 'Please enter a valid postal code';
        }
        return null;
    }

    if (!regex.hasMatch(value)) {
      return 'Please enter a valid postal code';
    }

    return null;
  }

  /// Validates street address
  static String? validateStreetAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Street address is required';
    }

    if (value.length < 3) {
      return 'Please enter a valid street address';
    }

    return null;
  }

  /// Validates city name
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }

    if (value.length < 2) {
      return 'Please enter a valid city name';
    }

    return null;
  }

  /// Validates state/province
  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'State/Province is required';
    }

    return null;
  }

  /// Validates country
  static String? validateCountry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Country is required';
    }

    return null;
  }
}
