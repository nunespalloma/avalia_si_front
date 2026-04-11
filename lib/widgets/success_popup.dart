import 'dart:async';
import 'package:flutter/material.dart';

void showTopMessageBanner(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;
  Timer? timer;

  void removeBanner() {
    timer?.cancel();
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  }

  final topPadding = MediaQuery.of(context).padding.top;

  overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: topPadding + 12,
        left: 24,
        right: 24,
        child: Center(
          child: _TopMessageBanner(
            message: message,
            duration: duration,
            onClose: removeBanner,
          ),
        ),
      );
    },
  );

  overlay.insert(overlayEntry);

  timer = Timer(duration, removeBanner);
}

class _TopMessageBanner extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback onClose;

  const _TopMessageBanner({
    required this.message,
    required this.duration,
    required this.onClose,
  });

  @override
  State<_TopMessageBanner> createState() => _TopMessageBannerState();
}

class _TopMessageBannerState extends State<_TopMessageBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 3,
                      width: 320 * (1 - _progressController.value),
                      color: Colors.white70,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}