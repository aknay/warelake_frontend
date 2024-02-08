// import 'package:billsible/domain/valueobject.dart';
// import 'package:warelake/domain/valueobject.dart';

// class AccountUpdateRequest {
//   final String? name;
//   final String? description;
//   final MilliAmount? initialMilliAmount;

//   AccountUpdateRequest({
//     this.name,
//     this.initialMilliAmount,
//     this.description,
//   });

//   factory AccountUpdateRequest.create({
//     Amount? initialBalance,
//     String? name,
//     String? description,
//   }) {
//     if (initialBalance != null && initialBalance < 0) {
//       assert(false, "amount cannot be negative");
//     }
//     final milliAmout = initialBalance == null ? null : (initialBalance * 1000).toInt();

//     return AccountUpdateRequest(initialMilliAmount: milliAmout, description: description, name: name);
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['name'] = name;
//     data['initial_balance'] = initialMilliAmount;
//     data['description'] = description;
//     return data;
//   }
// }
