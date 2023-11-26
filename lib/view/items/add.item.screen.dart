import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/view/routing/app.router.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ItemVariation? itemVariation = await context.pushNamed(AppRoute.addItemVariation.name);
          if (itemVariation != null) {
            log(itemVariation.name);
          }
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Add Items"),
        actions: [
          IconButton(
              onPressed: () async {
                // if (_validateAndSaveForm()) {
                //   if (currency.isNone()) {
                //     showAlertDialog(
                //         context: context,
                //         title: "Currency",
                //         defaultActionText: "OK",
                //         content: "Please select a currency.");
                //     return;
                //   }
                //   if (location.isNone()) {
                //     showAlertDialog(
                //         context: context,
                //         title: "Timezone",
                //         defaultActionText: "OK",
                //         content: "Please select a timezone.");
                //     return;
                //   }

                //   final success = await ref.read(teamListControllerProvider.notifier).submit(
                //       teamName: teamName.toNullable()!,
                //       location: location.toIterable().first,
                //       currency: currency.toIterable().first);

                //   if (success && context.mounted) {
                //     context.goNamed(AppRoute.dashboard.name);
                //   }
                // }
              },
              icon: const Icon(Icons.check)),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Item Name *',
              hintText: 'Enter your username',
              suffixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Unit *',
              hintText: 'Enter your username',
              suffixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          // Card(
          //   elevation: 5,
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Column(children: [
          //       const Text("Sales Information"),
          //       TextFormField(
          //         decoration: const InputDecoration(
          //           labelText: 'Purchase Price*',
          //           hintText: 'Enter your username',
          //           suffixIcon: Icon(Icons.person),
          //         ),
          //         validator: (value) {
          //           if (value == null || value.isEmpty) {
          //             return 'Please enter your username';
          //           }
          //           return null;
          //         },
          //       ),
          //       const SizedBox(height: 8),
          //       TextFormField(
          //         decoration: const InputDecoration(
          //           labelText: 'Selling Price *',
          //           hintText: 'Enter your username',
          //           suffixIcon: Icon(Icons.person),
          //         ),
          //         validator: (value) {
          //           if (value == null || value.isEmpty) {
          //             return 'Please enter your username';
          //           }
          //           return null;
          //         },
          //       ),
          //     ]),
          //   ),
          // ),
          //      Card(
          //   elevation: 5,
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Column(children: [
          //       const Text("Inventory Information"),
          //       TextFormField(
          //         decoration: const InputDecoration(
          //           labelText: 'Current Stock Level',
          //           hintText: 'Enter your username',
          //           suffixIcon: Icon(Icons.person),
          //         ),
          //         validator: (value) {
          //           if (value == null || value.isEmpty) {
          //             return 'Please enter your username';
          //           }
          //           return null;
          //         },
          //       ),
          //       const SizedBox(height: 8),
          //       TextFormField(
          //         decoration: const InputDecoration(
          //           labelText: 'Reorder Stock Level',
          //           hintText: 'Enter your username',
          //           suffixIcon: Icon(Icons.person),
          //         ),
          //         validator: (value) {
          //           if (value == null || value.isEmpty) {
          //             return 'Please enter your username';
          //           }
          //           return null;
          //         },
          //       ),
          //     ]),
          //   ),
          // )
        ],
      )),
    );
  }
}

// class AddItemScreen extends ConsumerWidget {
//   const AddItemScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//          final ItemVariation? itemVariation = await context.pushNamed(AppRoute.addItemVariation.name);
//          if (itemVariation != null){
//      log(itemVariation.name);
//          }
    
//         },
//         child: const Icon(Icons.add),
//       ),
//       appBar: AppBar(title: const Text("Add Items"), actions: [
//             IconButton(
//                 onPressed: () async {
//                   // if (_validateAndSaveForm()) {
//                   //   if (currency.isNone()) {
//                   //     showAlertDialog(
//                   //         context: context,
//                   //         title: "Currency",
//                   //         defaultActionText: "OK",
//                   //         content: "Please select a currency.");
//                   //     return;
//                   //   }
//                   //   if (location.isNone()) {
//                   //     showAlertDialog(
//                   //         context: context,
//                   //         title: "Timezone",
//                   //         defaultActionText: "OK",
//                   //         content: "Please select a timezone.");
//                   //     return;
//                   //   }

//                   //   final success = await ref.read(teamListControllerProvider.notifier).submit(
//                   //       teamName: teamName.toNullable()!,
//                   //       location: location.toIterable().first,
//                   //       currency: currency.toIterable().first);

//                   //   if (success && context.mounted) {
//                   //     context.goNamed(AppRoute.dashboard.name);
//                   //   }
//                   // }
//                 },
//                 icon: const Icon(Icons.check)),
//       ],),
//       body: SingleChildScrollView(
//           child: Column(
//         children: [
//           TextFormField(
//             decoration: const InputDecoration(
//               labelText: 'Item Name *',
//               hintText: 'Enter your username',
//               suffixIcon: Icon(Icons.person),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your username';
//               }
//               return null;
//             },
//           ),
//           TextFormField(
//             decoration: const InputDecoration(
//               labelText: 'Unit *',
//               hintText: 'Enter your username',
//               suffixIcon: Icon(Icons.person),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your username';
//               }
//               return null;
//             },
//           ),
//           // Card(
//           //   elevation: 5,
//           //   child: Padding(
//           //     padding: const EdgeInsets.all(8.0),
//           //     child: Column(children: [
//           //       const Text("Sales Information"),
//           //       TextFormField(
//           //         decoration: const InputDecoration(
//           //           labelText: 'Purchase Price*',
//           //           hintText: 'Enter your username',
//           //           suffixIcon: Icon(Icons.person),
//           //         ),
//           //         validator: (value) {
//           //           if (value == null || value.isEmpty) {
//           //             return 'Please enter your username';
//           //           }
//           //           return null;
//           //         },
//           //       ),
//           //       const SizedBox(height: 8),
//           //       TextFormField(
//           //         decoration: const InputDecoration(
//           //           labelText: 'Selling Price *',
//           //           hintText: 'Enter your username',
//           //           suffixIcon: Icon(Icons.person),
//           //         ),
//           //         validator: (value) {
//           //           if (value == null || value.isEmpty) {
//           //             return 'Please enter your username';
//           //           }
//           //           return null;
//           //         },
//           //       ),
//           //     ]),
//           //   ),
//           // ),
//           //      Card(
//           //   elevation: 5,
//           //   child: Padding(
//           //     padding: const EdgeInsets.all(8.0),
//           //     child: Column(children: [
//           //       const Text("Inventory Information"),
//           //       TextFormField(
//           //         decoration: const InputDecoration(
//           //           labelText: 'Current Stock Level',
//           //           hintText: 'Enter your username',
//           //           suffixIcon: Icon(Icons.person),
//           //         ),
//           //         validator: (value) {
//           //           if (value == null || value.isEmpty) {
//           //             return 'Please enter your username';
//           //           }
//           //           return null;
//           //         },
//           //       ),
//           //       const SizedBox(height: 8),
//           //       TextFormField(
//           //         decoration: const InputDecoration(
//           //           labelText: 'Reorder Stock Level',
//           //           hintText: 'Enter your username',
//           //           suffixIcon: Icon(Icons.person),
//           //         ),
//           //         validator: (value) {
//           //           if (value == null || value.isEmpty) {
//           //             return 'Please enter your username';
//           //           }
//           //           return null;
//           //         },
//           //       ),
//           //     ]),
//           //   ),
//           // )
//         ],
//       )),
//     );
//   }
// }
