import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passguard/frontend/providers/idle_timeout_provider.dart';

class AppWithIdleTimeout extends StatefulWidget {
  final Widget child;

  const AppWithIdleTimeout({required this.child, Key? key}) : super(key: key);

  @override
  State<AppWithIdleTimeout> createState() => _AppWithIdleTimeoutState();
}

class _AppWithIdleTimeoutState extends State<AppWithIdleTimeout> {
  late IdleTimeoutProvider _idleTimeoutProvider;

  @override
  void initState() {
    super.initState();
    // Retrieve and store the IdleTimeoutProvider reference
    _idleTimeoutProvider = Provider.of<IdleTimeoutProvider>(context, listen: false);
    _idleTimeoutProvider.startTracking(context);
  }

  @override
  void dispose() {
    // Use the stored reference instead of context to stop tracking
    _idleTimeoutProvider.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _idleTimeoutProvider.resetOnInteraction(),
      onPanDown: (_) => _idleTimeoutProvider.resetOnInteraction(),
      child: widget.child,
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:passguard/frontend/providers/idle_timeout_provider.dart';

// class AppWithIdleTimeout extends StatefulWidget {
//   final Widget child;

//   const AppWithIdleTimeout({required this.child, Key? key}) : super(key: key);

//   @override
//   State<AppWithIdleTimeout> createState() => _AppWithIdleTimeoutState();
// }

// class _AppWithIdleTimeoutState extends State<AppWithIdleTimeout> {
//   @override
//   void initState() {
//     super.initState();
//     // Start idle tracking when the widget is initialized.
//     Provider.of<IdleTimeoutProvider>(context, listen: false).startTracking(context);
//   }

//   @override
//   void dispose() {
//     // Stop idle tracking when the widget is disposed.
//     Provider.of<IdleTimeoutProvider>(context, listen: false).stopTracking();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onTap: () => Provider.of<IdleTimeoutProvider>(context, listen: false).resetOnInteraction(),
//       onPanDown: (_) => Provider.of<IdleTimeoutProvider>(context, listen: false).resetOnInteraction(),
//       child: widget.child,
//     );
//   }
// }