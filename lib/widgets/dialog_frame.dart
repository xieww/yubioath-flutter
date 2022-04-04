import 'package:flutter/material.dart';

class DialogFrame extends StatelessWidget {
  final Widget child;
  const DialogFrame({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        // Shows Snackbars above modal
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTap: () {}, // Block onTap of parent gesture detector
            child: child,
          ),
        ),
      );
}
