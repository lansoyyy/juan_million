import 'package:flutter/material.dart';

// Global key to access the navigator context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<bool?> showToast(String msg, {BuildContext? context}) async {
  // Use a custom overlay for all platforms to avoid web compatibility issues
  return _showCustomToast(msg, context: context);
}

Future<bool?> _showCustomToast(String msg, {BuildContext? context}) async {
  // Get the current context
  final currentContext = context ?? _getContext();
  if (currentContext == null) return false;

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
            color: Colors.red,
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
              const Icon(Icons.error_outline, color: Colors.white),
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
