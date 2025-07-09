import 'package:fairsplit/features/shopping/domain/entities/shopping_list.dart';

abstract class ShoppingListRepository {
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
