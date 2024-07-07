import 'package:flutter/material.dart';

class TouchOutsideToDismissKeyboard extends StatelessWidget {
  final Widget child;

  const TouchOutsideToDismissKeyboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: child,
    );
  }
}
