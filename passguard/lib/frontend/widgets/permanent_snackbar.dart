import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passguard/frontend/providers/snackbar_provider.dart';

class PermanentSnackBar extends StatefulWidget {
  final SnackBarProvider snackBarProvider;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const PermanentSnackBar({
    Key? key,
    required this.snackBarProvider,
    this.backgroundColor,
    this.textStyle,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.margin = const EdgeInsets.only(bottom: 20.0, right: 20.0),
  }) : super(key: key);

  @override
  _PermanentSnackBarState createState() => _PermanentSnackBarState();
}

class _PermanentSnackBarState extends State<PermanentSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    widget.snackBarProvider.addListener(_onMessageChange);
  }

  void _onMessageChange() {
    final message = widget.snackBarProvider.currentMessage;
    if (message != null) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.snackBarProvider.removeListener(_onMessageChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: widget.margin.bottom,
      right: widget.margin.right,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<SnackBarProvider>(
          builder: (context, snackBarProvider, _) {
            final message = snackBarProvider.currentMessage;
            return message != null
                ? Material(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    elevation: 6,
                    color: widget.backgroundColor ?? Theme.of(context).snackBarTheme.backgroundColor ?? Colors.black,
                    child: Padding(
                      padding: widget.padding,
                      child: Text(
                        message,
                        style: widget.textStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// class PermanentSnackBar extends StatefulWidget {
//   final Stream<String> messageStream;
//   final Duration displayDuration;
//   final Color? backgroundColor;
//   final TextStyle? textStyle;
//   final double borderRadius;
//   final EdgeInsets padding;
//   final EdgeInsets margin;

//   const PermanentSnackBar({
//     Key? key,
//     required this.messageStream,
//     this.displayDuration = const Duration(seconds: 3),
//     this.backgroundColor,
//     this.textStyle,
//     this.borderRadius = 8.0,
//     this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//     this.margin = const EdgeInsets.only(bottom: 20.0, right: 20.0),
//   }) : super(key: key);

//   @override
//   _PermanentSnackBarState createState() => _PermanentSnackBarState();
// }

// class _PermanentSnackBarState extends State<PermanentSnackBar>
//     with SingleTickerProviderStateMixin {
//   String? _currentMessage;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );

//     widget.messageStream.listen((message) {
//       _showMessage(message);
//     });
//   }

//   void _showMessage(String message) {
//     if (_currentMessage != null) {
//       _animationController.reverse().then((_) {
//         setState(() => _currentMessage = message);
//         _animationController.forward();
//         _scheduleMessageRemoval();
//       });
//     } else {
//       setState(() => _currentMessage = message);
//       _animationController.forward();
//       _scheduleMessageRemoval();
//     }
//   }

//   void _scheduleMessageRemoval() {
//     Future.delayed(widget.displayDuration, () {
//       if (_currentMessage != null) {
//         _animationController.reverse().then((_) {
//           if (mounted) setState(() => _currentMessage = null);
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       bottom: widget.margin.bottom,
//       right: widget.margin.right,
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: _currentMessage != null
//             ? Material(
//                 borderRadius: BorderRadius.circular(widget.borderRadius),
//                 elevation: 6,
//                 color: widget.backgroundColor ?? Theme.of(context).snackBarTheme.backgroundColor ?? Colors.black,
//                 child: Padding(
//                   padding: widget.padding,
//                   child: Text(
//                     _currentMessage!,
//                     style: widget.textStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
//                   ),
//                 ),
//               )
//             : const SizedBox.shrink(),
//       ),
//     );
//   }
// }