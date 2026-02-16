import 'package:flutter/material.dart';

// Global key to access the navigator context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<bool?> showToast(String msg,
    {BuildContext? context, ToastType type = ToastType.success}) async {
  // Use a custom overlay for all platforms to avoid web compatibility issues
  return _showCustomToast(msg, context: context, type: type);
}

enum ToastType { success, error, warning }

Future<bool?> _showCustomToast(String msg,
    {BuildContext? context, ToastType type = ToastType.success}) async {
  // Get the current context
  final currentContext = context ?? _getContext();
  if (currentContext == null) return false;

  final lowerMsg = msg.toLowerCase();
  final bool isError = type == ToastType.error ||
      lowerMsg.contains('error') ||
      lowerMsg.contains('failed') ||
      lowerMsg.contains('cannot') ||
      lowerMsg.contains("can't") ||
      lowerMsg.contains('wrong') ||
      lowerMsg.contains('invalid') ||
      lowerMsg.contains('insufficient') ||
      lowerMsg.contains('not enough') ||
      lowerMsg.contains('unauthorized') ||
      lowerMsg.contains('denied');

  final bool isWarning = type == ToastType.warning ||
      lowerMsg.contains('limit') ||
      lowerMsg.contains('maximum') ||
      lowerMsg.contains('reached');

  Color getBackgroundColor() {
    if (isError) return Colors.red;
    if (isWarning) return Colors.orange;
    return const Color(0xFF4CAF50);
  }

  IconData getIcon() {
    if (isError) return Icons.error_outline;
    if (isWarning) return Icons.warning_amber_rounded;
    return Icons.check_circle_outline;
  }

  // Create an overlay entry
  final overlay = Overlay.of(currentContext);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50,
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: getBackgroundColor(),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                getIcon(),
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => overlayEntry.remove(),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Auto remove after 3 seconds
  Future.delayed(const Duration(seconds: 3), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });

  return true;
}

// This is a workaround to get the current context
BuildContext? _getContext() {
  // Use the navigator key to get the current context
  return navigatorKey.currentContext;
}
