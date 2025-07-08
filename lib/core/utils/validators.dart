import 'package:fairsplit/core/utils/validators/index.dart';

/// Main validator class that provides access to all validator modules
class Validators {
  /// Authentication validators
  static final auth = AuthValidators();

  /// General form validators
  static final form = FormValidators;

  /// Address and location validators
  static final address = AddressValidators;

  /// Shopping-related validators
  static final shopping = ShoppingValidators;

  // Authentication validators
  static String? validateEmail(String? value) =>
      AuthValidators.validateEmail(value);
  static String? validatePassword(String? value) =>
      AuthValidators.validatePassword(value);
  static String? validatePasswordStrength(String? value) =>
      AuthValidators.validatePasswordStrength(value);
  static String? validatePasswordMatch(String? value, String password) =>
      AuthValidators.validatePasswordMatch(value, password);

  // Form validators
  static String? validateRequired(
    String? value, {
    String fieldName = 'Field',
  }) => FormValidators.validateRequired(value, fieldName: fieldName);
  static String? validateNumber(String? value, {String fieldName = 'Field'}) =>
      FormValidators.validateNumber(value, fieldName: fieldName);
  static String? validatePhone(String? value) =>
      FormValidators.validatePhone(value);
  static String? validateMinLength(
    String? value,
    int minLength, {
    String fieldName = 'Field',
  }) =>
      FormValidators.validateMinLength(value, minLength, fieldName: fieldName);
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String fieldName = 'Field',
  }) =>
      FormValidators.validateMaxLength(value, maxLength, fieldName: fieldName);

  // Address validators
  static String? validatePostalCode(String? value, {String country = 'US'}) =>
      AddressValidators.validatePostalCode(value, country: country);
  static String? validateStreetAddress(String? value) =>
      AddressValidators.validateStreetAddress(value);
  static String? validateCity(String? value) =>
      AddressValidators.validateCity(value);
  static String? validateState(String? value) =>
      AddressValidators.validateState(value);
  static String? validateCountry(String? value) =>
      AddressValidators.validateCountry(value);

  // Shopping validators
  static String? validateItemName(String? value) =>
      ShoppingValidators.validateItemName(value);
  static String? validatePrice(String? value) =>
      ShoppingValidators.validatePrice(value);
  static String? validateQuantity(String? value) =>
      ShoppingValidators.validateQuantity(value);
  static String? validateListName(String? value) =>
      ShoppingValidators.validateListName(value);
  static String? validateCategory(String? value) =>
      ShoppingValidators.validateCategory(value);
}
