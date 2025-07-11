import 'package:fairsplit/features/shopping/domain/entities/shopping_list.dart';
import 'package:fairsplit/features/shopping/domain/repositories/shopping_list_repository.dart';
import 'package:fairsplit/features/shopping/data/datasources/shopping_list_remote_datasource.dart';

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  final ShoppingListRemoteDataSource remoteDataSource;

  ShoppingListRepositoryImpl(this.remoteDataSource);

  @override
  Future<ShoppingListsResponse> getShoppingLists(String groupId) async {
    return await remoteDataSource.getShoppingLists(groupId);
  }

  @override
  Future<ShoppingListResponse> getShoppingListDetail(String listId) async {
    return await remoteDataSource.getShoppingListDetail(listId);
  }

  @override
  Future<ShoppingListResponse> createShoppingList(
    String groupId,
    CreateShoppingListRequest request,
  ) async {
    return await remoteDataSource.createShoppingList(groupId, request);
  }

  @override
  Future<ShoppingListResponse> updateShoppingList(
    String listId,
    UpdateShoppingListRequest request,
  ) async {
    return await remoteDataSource.updateShoppingList(listId, request);
  }

  @override
  Future<void> deleteShoppingList(String listId) async {
    await remoteDataSource.deleteShoppingList(listId);
  }

  @override
  Future<ShoppingItemsResponse> addItemsToList(
    String listId,
    AddItemsToListRequest request,
  ) async {
    return await remoteDataSource.addItemsToList(listId, request);
  }

  @override
  Future<ShoppingItemResponse> updateItem(
    String listId,
    String itemId,
    UpdateShoppingItemRequest request,
  ) async {
    return await remoteDataSource.updateItem(listId, itemId, request);
  }

  @override
  Future<void> deleteItem(String listId, String itemId) async {
    await remoteDataSource.deleteItem(listId, itemId);
  }

  @override
  Future<void> markItemAsPurchased(String listId, String itemId) async {
    await remoteDataSource.markItemAsPurchased(listId, itemId);
  }

  @override
  Future<void> markListAsCompleted(String listId) async {
    await remoteDataSource.markListAsCompleted(listId);
  }

  @override
  Future<void> markListAsArchived(String listId) async {
    await remoteDataSource.markListAsArchived(listId);
  }
}
