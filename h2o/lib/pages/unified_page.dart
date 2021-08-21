import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UnifiedPage extends StatelessWidget {
  final Widget child;

  UnifiedPage({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Container(
        color: Theme.of(context).canvasColor,
        child: SafeArea(child: this.child),
      ),
    );
  }
}
