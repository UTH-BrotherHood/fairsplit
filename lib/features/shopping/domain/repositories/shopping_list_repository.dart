import 'package:fairsplit/features/shopping/domain/entities/shopping_list.dart';

abstract class ShoppingListRepository {
  Future<ShoppingListsResponse> getShoppingLists(String groupId);
  Future<ShoppingListResponse> getShoppingListDetail(String listId);
  Future<ShoppingListResponse> createShoppingList(
    String groupId,
    CreateShoppingListRequest request,
  );
  Future<ShoppingListResponse> updateShoppingList(
    String listId,
    UpdateShoppingListRequest request,
  );
  Future<void> deleteShoppingList(String listId);
  Future<ShoppingItemsResponse> addItemsToList(
    String listId,
    AddItemsToListRequest request,
  );
  Future<ShoppingItemResponse> updateItem(
    String listId,
    String itemId,
    UpdateShoppingItemRequest request,
  );
  Future<void> deleteItem(String listId, String itemId);
  Future<void> markItemAsPurchased(String listId, String itemId);
  Future<void> markListAsCompleted(String listId);
  Future<void> markListAsArchived(String listId);
}
