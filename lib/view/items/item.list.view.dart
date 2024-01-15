import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:inventory_frontend/data/item/item.service.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/item/search.fields.dart';
import 'package:inventory_frontend/view/items/item.search.widget.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';

  final toForceToRefreshIemListProvider = StateProvider<Unit>(
    (ref) => unit,
  );

class ItemListView extends ConsumerStatefulWidget {
  final bool isToSelectItemVariation;
  const ItemListView({super.key, required this.isToSelectItemVariation});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ItemListViewState();
}

class _ItemListViewState extends ConsumerState<ItemListView> {
  final PagingController<int, Item> _pagingController = PagingController(firstPageKey: 0);
  final _lastStockItemIdProvider = StateProvider<Option<String>>(
    (ref) => const None(),
  );



  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Option<String>>(
      searchItemByNameProvider,
      (_, state) {
        ref.read(_lastStockItemIdProvider.notifier).state = const None();
        _pagingController.refresh();
      },
    );

        ref.listen<Unit>(
      toForceToRefreshIemListProvider,
      (_, state) {
        ref.read(_lastStockItemIdProvider.notifier).state = const None();
        _pagingController.refresh();
      },
    );

    ref.watch(toForceToRefreshIemListProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(_lastStockItemIdProvider.notifier).state = const None();
        _pagingController.refresh();
      },
      child: PagedListView<int, Item>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Item>(itemBuilder: (context, item, index) {
          return _getListTitle(item, context);
        }),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    // final textToSearch = searchText != null && searchText.length > 2 ? searchText : null;
    final searchField = ItemSearchField(
        itemName: ref.read(searchItemByNameProvider).toNullable(),
        startingAfterItemId: ref.read(_lastStockItemIdProvider).toNullable());
    final itemListResponseOrError = await ref.read(itemServiceProvider).list(itemSearchField: searchField);

    // final itemListResponseOrError = await ref.read(itemListControllerProvider.notifier).list(
    //     startingAfterItemId: ref.read(_lastStockItemIdProvider).toNullable(),
    //     searchText: ref.read(searchItemByNameProvider).toNullable());

    if (itemListResponseOrError.isLeft()) {
      _pagingController.error = "Having error";
      return;
    }
    final itemListResponse = itemListResponseOrError.toIterable().first;
    final itemList = itemListResponse.data;

    if (itemList.isNotEmpty) {
      ref.read(_lastStockItemIdProvider.notifier).state = Some(itemList.last.id!);
    } else {
      log("item list is empty");
    }

    if (itemListResponse.hasMore) {
      final nextPageKey = pageKey + itemList.length;
      _pagingController.appendPage(itemList, nextPageKey);
    } else {
      _pagingController.appendLastPage(itemList);
    }
  }

  ListTile _getListTitle(Item item, BuildContext context) {
    return ListTile(
      title: Text(item.name),
      onTap: () {
        if (widget.isToSelectItemVariation) {
          final router = GoRouter.of(context);
          final uri = router.routeInformationProvider.value.uri;

          log("item list ${uri.path}");

          if (uri.path.contains('stock_in')) {
            context.goNamed(
              AppRoute.selectItemForStockIn.name,
              pathParameters: {'id': item.id!},
            );
          } else if (uri.path.contains('stock_out')) {
            context.goNamed(
              AppRoute.selectItemForStockOut.name,
              pathParameters: {'id': item.id!},
            );
          } else if (uri.path.contains('stock_adjust')) {
            context.goNamed(
              AppRoute.selectItemForStockAdjust.name,
              pathParameters: {'id': item.id!},
            );
          } else if (uri.path.contains('purchase_order')) {
            context.goNamed(
              AppRoute.selectItemForPurchaseOrder.name,
              pathParameters: {'id': item.id!},
            );
          } else {
            context.goNamed(
              AppRoute.selectItemForSaleOrder.name,
              pathParameters: {'id': item.id!},
            );
          }
        } else {
          context.goNamed(
            AppRoute.viewItem.name,
            pathParameters: {'id': item.id!},
          );
        }
      },
    );
  }
}

// class ItemListView extends ConsumerWidget {
//   final bool isToSelectItemVariation;
//   ItemListView({required this.isToSelectItemVariation, super.key});
//   final ScrollController scrollController = ScrollController();

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.listen<AsyncValue>(
//       itemListControllerProvider,
//       (_, state) => state.showAlertDialogOnError(context),
//     );

//     scrollController.addListener(() {
//       // final maxScroll = scrollController.position.maxScrollExtent;
//       // final currentScroll = scrollController.position.pixels;
//       // final delta = MediaQuery.of(context).size.width * 0.20;
//       // if (maxScroll - currentScroll <= delta) {
//       //   log("time to calll");
//       // }

//          if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
//            log("time to calll");
//       // User has reached the bottom, load more data
//       // context.read(dataProvider.notifier).refresh();
//     }
//     });

//     final asyncItemList = ref.watch(itemListControllerProvider);

//     return asyncItemList.when(
//         data: (data) {
//           return ListView.builder(
//             controller: scrollController,
//             itemCount: data.length + 1,
//             itemBuilder: (context, index) {
//               if (index < data.length) {
//                 // Display your data item
//                 return ListTile(
//                   title: Text(data[index].toString()),
//                 );
//               } else {
//                 // Loading indicator
//                 return const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Center(
//                       child: CircularProgressIndicator(),
//                     ));
//               }
//             },
//             // slivers: data
//             //     .map((e) => ListTile(
//             //           title: Text(e.name),
//             //           onTap: () {
//             //             if (isToSelectItemVariation) {
//             //               final router = GoRouter.of(context);
//             //               final uri = router.routeInformationProvider.value.uri;

//             //               log("item list ${uri.path}");

//             //               if (uri.path.contains('stock_in')) {
//             //                 context.goNamed(
//             //                   AppRoute.selectItemForStockIn.name,
//             //                   pathParameters: {'id': e.id!},
//             //                 );
//             //               } else if (uri.path.contains('stock_out')) {
//             //                 context.goNamed(
//             //                   AppRoute.selectItemForStockOut.name,
//             //                   pathParameters: {'id': e.id!},
//             //                 );
//             //               } else if (uri.path.contains('stock_adjust')) {
//             //                 context.goNamed(
//             //                   AppRoute.selectItemForStockAdjust.name,
//             //                   pathParameters: {'id': e.id!},
//             //                 );
//             //               } else if (uri.path.contains('purchase_order')) {
//             //                 context.goNamed(
//             //                   AppRoute.selectItemForPurchaseOrder.name,
//             //                   pathParameters: {'id': e.id!},
//             //                 );
//             //               } else {
//             //                 context.goNamed(
//             //                   AppRoute.selectItemForSaleOrder.name,
//             //                   pathParameters: {'id': e.id!},
//             //                 );
//             //               }
//             //             } else {
//             //               context.goNamed(
//             //                 AppRoute.viewItem.name,
//             //                 pathParameters: {'id': e.id!},
//             //               );
//             //             }
//             //           },
//             //         ))
//             //     .toList()
//           );
//         },
//         error: (Object error, StackTrace stackTrace) => Text('Error: $error'),
//         loading: () => const Center(child: CircularProgressIndicator()));
//   }
// }

// class ItemListView extends ConsumerStatefulWidget {
//   const ItemListView({super.key, required this.isToSelectItemVariation});
//   final bool isToSelectItemVariation;
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _ItemListViewState();
// }

// class _ItemListViewState extends ConsumerState<ItemListView> {
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_scrollListener);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_scrollListener);
//     super.dispose();
//   }

//   void _scrollListener() {
//     // if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
//     // log("time to call this");
//     // User has reached the bottom, load more data
//     // context.read(dataProvider.notifier).refresh();

//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.position.pixels;
//     final delta = MediaQuery.of(context).size.width * 0.20;
//     if (maxScroll - currentScroll <= delta) {
//       log("time to calll");
//     }
//     log("calling? even");
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dataAsyncValue = ref.watch(itemListControllerProvider);

//     return dataAsyncValue.when(
//       loading: () => const CircularProgressIndicator(),
//       error: (error, stackTrace) => Text('Error: $error'),
//       data: (data) {
//         return CustomScrollView(
//           controller: _scrollController,
//           // itemCount: data.length,
//           // itemBuilder: (context, index) {
//           //   if (index < data.length) {
//           //     // Display your data item
//           //     return Padding(
//           //       padding: const EdgeInsets.all(80.0),
//           //       child: ListTile(
//           //         title: Text(data[index].name),
//           //       ),
//           //     );
//           //   } else {
//           //     // Loading indicator
//           //     return const Padding(
//           //       padding: EdgeInsets.all(8.0),
//           //       child: Center(
//           //         child: CircularProgressIndicator(),
//           //       ),
//           //     );
//           //   }
//           // },
//         );
//       },
//     );

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Infinite Scroll Pagination'),
//       ),
//       body: Consumer(
//         builder: (context, watch, child) {
//           final dataAsyncValue = ref.watch(itemListControllerProvider);

//           return dataAsyncValue.when(
//             loading: () => const CircularProgressIndicator(),
//             error: (error, stackTrace) => Text('Error: $error'),
//             data: (data) {
//               return ListView.builder(
//                 controller: _scrollController,
//                 itemCount: data.length,
//                 itemBuilder: (context, index) {
//                   if (index < data.length) {
//                     // Display your data item
//                     return ListTile(
//                       title: Text(data[index].name),
//                     );
//                   } else {
//                     // Loading indicator
//                     return const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     );
//                   }
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
