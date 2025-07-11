import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/shopping/domain/entities/shopping_list.dart';
import 'package:fairsplit/features/shopping/domain/repositories/shopping_list_repository.dart';
import 'package:fairsplit/features/shopping/data/datasources/shopping_list_remote_datasource.dart';
import 'package:fairsplit/features/shopping/data/repositories/shopping_list_repository_impl.dart';
import 'package:http/http.dart' as http;

// Provider for repository
final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  final remoteDataSource = ShoppingListRemoteDataSourceImpl(
    client: http.Client(),
  );
  return ShoppingListRepositoryImpl(remoteDataSource);
});

// ViewModel for shopping lists in a group
class ShoppingListsViewModel
    extends StateNotifier<AsyncValue<List<ShoppingList>>> {
  final ShoppingListRepository repository;
  String? _currentGroupId;

  ShoppingListsViewModel({required this.repository})
    : super(const AsyncLoading());

  Future<void> getShoppingLists(String groupId) async {
    _currentGroupId = groupId;
    state = const AsyncLoading();
    try {
      final response = await repository.getShoppingLists(groupId);
      state = AsyncData(response.data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshShoppingLists() async {
    if (_currentGroupId != null) {
      await getShoppingLists(_currentGroupId!);
    }
  }

  Future<void> createShoppingList(
    String groupId,
    CreateShoppingListRequest request,
  ) async {
    try {
      await repository.createShoppingList(groupId, request);
      // Refresh the list to get updated data
      await getShoppingLists(groupId);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateShoppingList(
    String listId,
    UpdateShoppingListRequest request,
  ) async {
    try {
      await repository.updateShoppingList(listId, request);
      // Refresh the list to get updated data
      if (_currentGroupId != null) {
        await getShoppingLists(_currentGroupId!);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteShoppingList(String listId) async {
    try {
      await repository.deleteShoppingList(listId);
      // Refresh the list to get updated data
      if (_currentGroupId != null) {
        await getShoppingLists(_currentGroupId!);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

// ViewModel for a specific shopping list
class ShoppingListDetailViewModel
    extends StateNotifier<AsyncValue<ShoppingList>> {
  final ShoppingListRepository repository;
  String? _currentListId;

  ShoppingListDetailViewModel({required this.repository})
    : super(const AsyncLoading());

  Future<void> getShoppingListDetail(String listId) async {
    _currentListId = listId;
    state = const AsyncLoading();
    try {
      final response = await repository.getShoppingListDetail(listId);
      state = AsyncData(response.data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addItem(CreateShoppingItemRequest request) async {
    if (_currentListId == null) return;

    try {
      // Convert single item to AddItemsToListRequest
      final addItemsRequest = AddItemsToListRequest(items: [request]);
      await repository.addItemsToList(_currentListId!, addItemsRequest);
      // Refresh the list to get updated data
      await getShoppingListDetail(_currentListId!);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addItems(CreateShoppingItemsRequest request) async {
    if (_currentListId == null) return;

    try {
      // Convert CreateShoppingItemsRequest to AddItemsToListRequest
      final addItemsRequest = AddItemsToListRequest(items: request.items);
      await repository.addItemsToList(_currentListId!, addItemsRequest);
      // Refresh the list to get updated data
      await getShoppingListDetail(_currentListId!);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateItem(
    String itemId,
    UpdateShoppingItemRequest request,
  ) async {
    if (_currentListId == null) return;

    try {
      await repository.updateItem(_currentListId!, itemId, request);
      // Refresh the list to get updated data
      await getShoppingListDetail(_currentListId!);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteItem(String itemId) async {
    if (_currentListId == null) return;

    try {
      await repository.deleteItem(_currentListId!, itemId);
      // Refresh the list to get updated data
      await getShoppingListDetail(_currentListId!);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleItemPurchased(String itemId, bool isPurchased) async {
    if (_currentListId == null) return;

    try {
      // Show optimistic update
      await state.when(
        data: (currentList) async {
          final updatedItems = currentList.items.map((item) {
            if (item.id == itemId) {
              return item.copyWith(isPurchased: isPurchased);
            }
            return item;
          }).toList();
          final updatedList = currentList.copyWith(items: updatedItems);
          state = AsyncData(updatedList);
        },
        loading: () async {},
        error: (error, stackTrace) async {},
      );

      // Make API call
      if (isPurchased) {
        await repository.markItemAsPurchased(_currentListId!, itemId);
      } else {
        // Use updateItem to mark as unpurchased
        await repository.updateItem(
          _currentListId!,
          itemId,
          UpdateShoppingItemRequest(
            isPurchased: false,
            purchasedAt: null,
            purchasedBy: null,
          ),
        );
      }

      // Refresh the list to get updated data from server
      await getShoppingListDetail(_currentListId!);
    } catch (e, st) {
      // Revert optimistic update on error by refreshing from server
      if (_currentListId != null) {
        await getShoppingListDetail(_currentListId!);
      }
      state = AsyncError(e, st);
    }
  }

  Future<void> archiveList() async {
    if (_currentListId == null) return;

    try {
      await repository.markListAsArchived(_currentListId!);
      // Refresh the list to get updated data
      await getShoppingListDetail(_currentListId!);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshShoppingListDetail() async {
    if (_currentListId != null) {
      await getShoppingListDetail(_currentListId!);
    }
  }
}

// Providers for ViewModels
final shoppingListsViewModelProvider =
    StateNotifierProvider<
      ShoppingListsViewModel,
      AsyncValue<List<ShoppingList>>
    >((ref) {
      final repo = ref.watch(shoppingListRepositoryProvider);
      return ShoppingListsViewModel(repository: repo);
    });

final shoppingListDetailViewModelProvider =
    StateNotifierProvider<
      ShoppingListDetailViewModel,
      AsyncValue<ShoppingList>
    >((ref) {
      final repo = ref.watch(shoppingListRepositoryProvider);
      return ShoppingListDetailViewModel(repository: repo);
    });
