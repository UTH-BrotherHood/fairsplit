/// Validators for shopping-related forms
class ShoppingValidators {
  /// Validates product/item name
  static String? validateItemName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Item name is required';
    }

    if (value.length < 2) {
      return 'Item name must be at least 2 characters';
    }

    return null;
  }

  /// Validates price input
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    // Allow decimal prices like 10.99
    final priceRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!priceRegex.hasMatch(value)) {
      return 'Please enter a valid price';
    }

    final price = double.tryParse(value);
    if (price == null || price < 0) {
      return 'Price cannot be negative';
    }

    return null;
  }

  /// Validates quantity input
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }

    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid quantity';
    }

    if (quantity <= 0) {
      return 'Quantity must be greater than zero';
    }

    return null;
  }

  /// Validates shopping list name
  static String? validateListName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Shopping list name is required';
    }

    if (value.length < 3) {
      return 'Shopping list name must be at least 3 characters';
    }

    return null;
  }

  /// Validates category name
  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Category is required';
    }

    return null;
  }
}
