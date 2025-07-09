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
  Future<ShoppingItemResponse> addItemToList(
    String listId,
    CreateShoppingItemRequest request,
  ) async {
    return await remoteDataSource.addItemToList(listId, request);
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
  Future<void> markItemAsUnpurchased(String listId, String itemId) async {
    await remoteDataSource.markItemAsUnpurchased(listId, itemId);
  }

  @override
  Future<void> markListAsArchived(String listId) async {
    await remoteDataSource.markListAsArchived(listId);
  }

  @override
  Future<ShoppingItemsResponse> addItemsToList(
    String listId,
    CreateShoppingItemsRequest request,
  ) async {
    return await remoteDataSource.addItemsToList(listId, request);
  }
}
