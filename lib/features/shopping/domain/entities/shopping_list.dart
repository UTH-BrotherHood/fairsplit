class ShoppingList {
  final String id;
  final String groupId;
  final String name;
  final String description;
  final List<String> tags;
  final DateTime? dueDate;
  final String status;
  final List<ShoppingItem> items;
  final double totalEstimatedPrice;
  final double totalActualPrice;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingList({
    required this.id,
    required this.groupId,
    required this.name,
    required this.description,
    required this.tags,
    this.dueDate,
    required this.status,
    required this.items,
    required this.totalEstimatedPrice,
    required this.totalActualPrice,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  ShoppingList copyWith({
    String? id,
    String? groupId,
    String? name,
    String? description,
    List<String>? tags,
    DateTime? dueDate,
    String? status,
    List<ShoppingItem>? items,
    double? totalEstimatedPrice,
    double? totalActualPrice,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      items: items ?? this.items,
      totalEstimatedPrice: totalEstimatedPrice ?? this.totalEstimatedPrice,
      totalActualPrice: totalActualPrice ?? this.totalActualPrice,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ShoppingItem {
  final String id;
  final String name;
  final int quantity;
  final String? unit;
  final double? estimatedPrice;
  final double? actualPrice;
  final String? note;
  final String? category;
  final bool isPurchased;
  final DateTime? purchasedAt;
  final String? purchasedBy;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.unit,
    this.estimatedPrice,
    this.actualPrice,
    this.note,
    this.category,
    required this.isPurchased,
    this.purchasedAt,
    this.purchasedBy,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? unit,
    double? estimatedPrice,
    double? actualPrice,
    String? note,
    String? category,
    bool? isPurchased,
    DateTime? purchasedAt,
    String? purchasedBy,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      actualPrice: actualPrice ?? this.actualPrice,
      note: note ?? this.note,
      category: category ?? this.category,
      isPurchased: isPurchased ?? this.isPurchased,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      purchasedBy: purchasedBy ?? this.purchasedBy,
    );
  }
}

class ShoppingListsResponse {
  final String message;
  final int status;
  final List<ShoppingList> data;

  ShoppingListsResponse({
    required this.message,
    required this.status,
    required this.data,
  });
}

class ShoppingListResponse {
  final String message;
  final int status;
  final ShoppingList data;

  ShoppingListResponse({
    required this.message,
    required this.status,
    required this.data,
  });
}

class ShoppingItemResponse {
  final String message;
  final int status;
  final ShoppingItem data;

  ShoppingItemResponse({
    required this.message,
    required this.status,
    required this.data,
  });
}

class ShoppingItemsResponse {
  final String message;
  final int status;
  final List<ShoppingItem> data;

  ShoppingItemsResponse({
    required this.message,
    required this.status,
    required this.data,
  });
}

class CreateShoppingItemRequest {
  final String name;
  final int quantity;
  final String? unit;
  final double? estimatedPrice;
  final String? category;

  CreateShoppingItemRequest({
    required this.name,
    required this.quantity,
    this.unit,
    this.estimatedPrice,
    this.category,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'name': name, 'quantity': quantity};
    if (unit != null) data['unit'] = unit;
    if (estimatedPrice != null) data['estimatedPrice'] = estimatedPrice;
    if (category != null) data['category'] = category;
    return data;
  }
}

class CreateShoppingItemsRequest {
  final List<CreateShoppingItemRequest> items;

  CreateShoppingItemsRequest({required this.items});

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
  };
}

class UpdateShoppingItemRequest {
  final String? name;
  final int? quantity;
  final String? unit;
  final double? estimatedPrice;
  final String? note;
  final String? category;
  final bool? isPurchased;
  final DateTime? purchasedAt;
  final String? purchasedBy;

  UpdateShoppingItemRequest({
    this.name,
    this.quantity,
    this.unit,
    this.estimatedPrice,
    this.note,
    this.category,
    this.isPurchased,
    this.purchasedAt,
    this.purchasedBy,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (quantity != null) data['quantity'] = quantity;
    if (unit != null) data['unit'] = unit;
    if (estimatedPrice != null) data['estimatedPrice'] = estimatedPrice;
    if (note != null) data['note'] = note;
    if (category != null) data['category'] = category;
    if (isPurchased != null) data['isPurchased'] = isPurchased;
    if (purchasedAt != null)
      data['purchasedAt'] = purchasedAt!.toIso8601String();
    if (purchasedBy != null) data['purchasedBy'] = purchasedBy;
    return data;
  }
}

// Request classes for shopping list operations
class CreateShoppingListRequest {
  final String name;
  final String description;
  final List<String> tags;
  final DateTime? dueDate;

  CreateShoppingListRequest({
    required this.name,
    required this.description,
    required this.tags,
    this.dueDate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'tags': tags,
    };
    if (dueDate != null) {
      data['dueDate'] = dueDate!.toIso8601String();
    }
    return data;
  }
}

class UpdateShoppingListRequest {
  final String? name;
  final String? description;
  final List<String>? tags;
  final DateTime? dueDate;
  final String? status;

  UpdateShoppingListRequest({
    this.name,
    this.description,
    this.tags,
    this.dueDate,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (tags != null) data['tags'] = tags;
    if (dueDate != null) data['dueDate'] = dueDate!.toIso8601String();
    if (status != null) data['status'] = status;
    return data;
  }
}

class AddItemsToListRequest {
  final List<CreateShoppingItemRequest> items;

  AddItemsToListRequest({required this.items});

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
  };
}
