import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passguard/frontend/providers/idle_timeout_provider.dart';
import 'package:passguard/frontend/providers/settings_provider.dart';

class AppWithIdleTimeout extends StatefulWidget {
  final Widget child;

  const AppWithIdleTimeout({required this.child, Key? key}) : super(key: key);

  @override
  State<AppWithIdleTimeout> createState() => _AppWithIdleTimeoutState();
}

class _AppWithIdleTimeoutState extends State<AppWithIdleTimeout> {
  IdleTimeoutProvider? _idleTimeoutProvider; // Make it nullable

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeProvider(); // Initialize provider here
      }
    });
  }

  void _initializeProvider() {
    _idleTimeoutProvider = Provider.of<IdleTimeoutProvider>(context, listen: false);
    _idleTimeoutProvider!.startTracking(context); // Use null assertion after check
  }

  @override
  void dispose() {
    _idleTimeoutProvider?.stopTracking(); // Safely call stopTracking
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        _idleTimeoutProvider?.syncIdleTimeout(); // Call syncIdleTimeout safely

        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            _idleTimeoutProvider?.resetOnInteraction(); //Safely call resetOnInteraction
          },
          onPointerMove: (_) {
            _idleTimeoutProvider?.resetOnInteraction();//Safely call resetOnInteraction
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// class AppWithIdleTimeout extends StatefulWidget {
//   final Widget child;

//   const AppWithIdleTimeout({required this.child, Key? key}) : super(key: key);

//   @override
//   State<AppWithIdleTimeout> createState() => _AppWithIdleTimeoutState();
// }

// class _AppWithIdleTimeoutState extends State<AppWithIdleTimeout> {
//   late IdleTimeoutProvider _idleTimeoutProvider;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         _idleTimeoutProvider = Provider.of<IdleTimeoutProvider>(context, listen: false);
//         _idleTimeoutProvider.startTracking(context);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     // No need to dispose the provider directly
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Listener(
//       behavior: HitTestBehavior.translucent,
//       onPointerDown: (_) {
//         _idleTimeoutProvider.resetOnInteraction();
//       },
//       onPointerMove: (_) {
//         _idleTimeoutProvider.resetOnInteraction();
//       },
//       child: widget.child,
//     );
//   }
// }
