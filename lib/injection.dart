import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:fairsplit/features/expenses/data/datasources/bill_remote_datasource.dart';
import 'package:fairsplit/features/expenses/data/repositories/bill_repository_impl.dart';
import 'package:fairsplit/features/expenses/domain/repositories/bill_repository.dart';
import 'package:fairsplit/features/expenses/domain/entities/bill.dart';
import 'package:fairsplit/features/expenses/presentation/viewmodels/bill_view_model.dart';
import 'package:fairsplit/features/expenses/presentation/view_models/bill_detail_view_model.dart';
import 'package:fairsplit/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:fairsplit/features/groups/data/repositories/group_repository_impl.dart';
import 'package:fairsplit/features/groups/domain/repositories/group_repository.dart';
import 'package:fairsplit/features/groups/domain/entities/group.dart';
import 'package:fairsplit/features/groups/presentation/viewmodels/group_view_model.dart';

final selectedPageProvider = StateProvider<int>((ref) => 0);

// HTTP Client Provider
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

// Bill Data Sources
final billRemoteDataSourceProvider = Provider<BillRemoteDataSource>((ref) {
  return BillRemoteDataSourceImpl(client: ref.read(httpClientProvider));
});

// Bill Repository
final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepositoryImpl(
    remoteDataSource: ref.read(billRemoteDataSourceProvider),
  );
});

// Bill ViewModels
final billsViewModelProvider =
    StateNotifierProvider<BillsViewModel, AsyncValue<List<Bill>>>((ref) {
      return BillsViewModel(repository: ref.read(billRepositoryProvider));
    });

final billDetailViewModelProvider =
    StateNotifierProvider<BillDetailNotifier, BillDetailState>((ref) {
      return BillDetailNotifier(ref.watch(billRepositoryProvider));
    });

final billPaymentsViewModelProvider =
    StateNotifierProvider<BillPaymentsViewModel, AsyncValue<List<Payment>>>((
      ref,
    ) {
      return BillPaymentsViewModel(
        repository: ref.read(billRepositoryProvider),
      );
    });

// Group Data Sources
final groupRemoteDataSourceProvider = Provider<GroupRemoteDataSource>((ref) {
  return GroupRemoteDataSourceImpl(client: ref.read(httpClientProvider));
});

// Group Repository
final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepositoryImpl(ref.read(groupRemoteDataSourceProvider));
});

// Group ViewModels
final groupViewModelProvider =
    StateNotifierProvider<GroupViewModel, AsyncValue<GroupsResponse>>((ref) {
      return GroupViewModel(repository: ref.read(groupRepositoryProvider));
    });
