import 'package:flutter/material.dart';

class LoadingOverlay {
  static final ValueNotifier<bool> loading = ValueNotifier(false);

  static Widget wrap(Widget child) {
    return ValueListenableBuilder<bool>(
      valueListenable: loading,
      builder: (context, value, _) {
        return Stack(
          children: [
            child,

            if (value)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}
