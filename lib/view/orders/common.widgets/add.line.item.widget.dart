import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warelake/view/constants/app.sizes.dart';

class AddLineItemButton extends ConsumerWidget {
  const AddLineItemButton({super.key, required this.onPressed});
  final void Function() onPressed;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: onPressed,
      child: const Padding(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle),
            gapW4,
            Text("Add Line Item"),
          ],
        ),
      ),
    );
  }
}
