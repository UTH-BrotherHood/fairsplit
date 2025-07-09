import 'package:fairsplit/features/shopping/domain/entities/shopping_list.dart';
import 'package:fairsplit/features/shopping/data/models/shopping_list_model.dart';
import 'package:fairsplit/core/constants/api_constants.dart';
import 'package:fairsplit/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class ShoppingListRemoteDataSource {
  Future<ShoppingListsResponse> getShoppingLists(String groupId);
  Future<ShoppingListResponse> getShoppingListDetail(String listId);
  Future<ShoppingItemResponse> addItemToList(
    String listId,
    CreateShoppingItemRequest request,
  );
  Future<ShoppingItemsResponse> addItemsToList(
    String listId,
    CreateShoppingItemsRequest request,
  );
  Future<ShoppingItemResponse> updateItem(
    String listId,
    String itemId,
    UpdateShoppingItemRequest request,
  );
  Future<void> deleteItem(String listId, String itemId);
  Future<void> markItemAsPurchased(String listId, String itemId);
  Future<void> markItemAsUnpurchased(String listId, String itemId);
  Future<void> markListAsArchived(String listId);
}

class ShoppingListRemoteDataSourceImpl implements ShoppingListRemoteDataSource {
  final http.Client client;

  ShoppingListRemoteDataSourceImpl({http.Client? client})
    : client = client ?? http.Client();

  @override
  Future<ShoppingListsResponse> getShoppingLists(String groupId) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/shopping-lists/groups/$groupId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final responseModel = ShoppingListsResponseModel.fromJson(jsonMap);
      return responseModel.toEntity();
    } else {
      throw Exception('Failed to fetch shopping lists: ${response.statusCode}');
    }
  }

  @override
  Future<ShoppingListResponse> getShoppingListDetail(String listId) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/shopping-lists/$listId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final responseModel = ShoppingListResponseModel.fromJson(jsonMap);
      return responseModel.toEntity();
    } else {
      throw Exception(
        'Failed to fetch shopping list details: ${response.statusCode}',
      );
    }
  }

  @override
  Future<ShoppingItemResponse> addItemToList(
    String listId,
    CreateShoppingItemRequest request,
  ) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/shopping-lists/$listId/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body);
      final responseModel = ShoppingItemResponseModel.fromJson(jsonMap);
      return responseModel.toEntity();
    } else {
      throw Exception('Failed to add item: ${response.statusCode}');
    }
  }

  @override
  Future<ShoppingItemsResponse> addItemsToList(
    String listId,
    CreateShoppingItemsRequest request,
  ) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/shopping-lists/$listId/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body);
      final responseModel = ShoppingItemsResponseModel.fromJson(jsonMap);
      return responseModel.toEntity();
    } else {
      throw Exception('Failed to add items: ${response.statusCode}');
    }
  }

  @override
  Future<ShoppingItemResponse> updateItem(
    String listId,
    String itemId,
    UpdateShoppingItemRequest request,
  ) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}/shopping-lists/$listId/items/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final responseModel = ShoppingItemResponseModel.fromJson(jsonMap);
      return responseModel.toEntity();
    } else {
      throw Exception('Failed to update item: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteItem(String listId, String itemId) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/shopping-lists/$listId/items/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete item: ${response.statusCode}');
    }
  }

  @override
  Future<void> markItemAsPurchased(String listId, String itemId) async {
    await _updateItemPurchasedStatus(listId, itemId, true);
  }

  @override
  Future<void> markItemAsUnpurchased(String listId, String itemId) async {
    await _updateItemPurchasedStatus(listId, itemId, false);
  }

  Future<void> _updateItemPurchasedStatus(
    String listId,
    String itemId,
    bool isPurchased,
  ) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}/shopping-lists/$listId/items/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'isPurchased': isPurchased}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update item purchased status: ${response.statusCode}',
      );
    }
  }

  @override
  Future<void> markListAsArchived(String listId) async {
    final accessToken = await AuthLocalDataSource().getAccessToken();

    final response = await client.patch(
      Uri.parse('${ApiConstants.baseUrl}/shopping-lists/$listId/mark-archived'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to mark list as archived: ${response.statusCode}',
      );
    }
  }
}
