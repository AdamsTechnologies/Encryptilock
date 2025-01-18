class AppWithIdleTimeout extends StatefulWidget {
  final Widget child;

  const AppWithIdleTimeout({required this.child, Key? key}) : super(key: key);

  @override
  State<AppWithIdleTimeout> createState() => _AppWithIdleTimeoutState();
}

class _AppWithIdleTimeoutState extends State<AppWithIdleTimeout> {
  late IdleTimeoutService _idleTimeoutService;

  @override
  void initState() {
    super.initState();
    _idleTimeoutService = IdleTimeoutService(context: context);
    _idleTimeoutService.start();
  }

  @override
  void dispose() {
    _idleTimeoutService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _idleTimeoutService.resetOnInteraction,
      onPanDown: (_) => _idleTimeoutService.resetOnInteraction(),
      onKey: (_) => _idleTimeoutService.resetOnInteraction(),
      child: widget.child,
    );
  }
}