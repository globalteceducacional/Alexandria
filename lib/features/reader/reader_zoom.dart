import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

/// Estado de zoom reutilizável no modo rolagem (pinça, Ctrl+scroll, botões).
mixin ReaderZoomStateMixin<T extends StatefulWidget> on State<T> {
  static const double minZoom = 1.0;
  static const double maxZoom = 4.0;

  double zoom = 1.0;
  double _pinchBaseZoom = 1.0;
  DateTime _lastWheelZoom = DateTime.fromMillisecondsSinceEpoch(0);

  /// True enquanto Ctrl/Cmd está pressionado — pausa a rolagem no scroll.
  bool zoomModifierHeld = false;

  void initZoomKeyboardListener() {
    HardwareKeyboard.instance.addHandler(_onHardwareKey);
    zoomModifierHeld = readerZoomModifierPressed();
  }

  void disposeZoomKeyboardListener() {
    HardwareKeyboard.instance.removeHandler(_onHardwareKey);
  }

  bool _onHardwareKey(KeyEvent event) {
    final held = readerZoomModifierPressed();
    if (held != zoomModifierHeld && mounted) {
      setState(() => zoomModifierHeld = held);
    }
    return false;
  }

  void setZoom(double next) {
    final clamped = next.clamp(minZoom, maxZoom);
    if ((clamped - zoom).abs() < 0.001) return;
    final previous = zoom;
    setState(() => zoom = clamped);
    onZoomChanged(previous, clamped);
  }

  /// Ajuste de scroll / cache ao mudar o zoom.
  void onZoomChanged(double previous, double next) {}

  void zoomIn() => setZoom(zoom + 0.25);
  void zoomOut() => setZoom(zoom - 0.25);
  void zoomReset() => setZoom(1.0);

  void handlePinchStart(ScaleStartDetails details) {
    _pinchBaseZoom = zoom;
  }

  void handlePinchUpdate(ScaleUpdateDetails details) {
    // Só pinça com 2+ dedos — não interfere na rolagem com 1 dedo.
    if (details.pointerCount < 2) return;
    setZoom(_pinchBaseZoom * details.scale);
  }

  /// Retorna true se o evento foi consumido como zoom (Ctrl/Cmd + scroll).
  bool handleCtrlScrollZoom(PointerScrollEvent event) {
    if (!readerZoomModifierPressed()) return false;

    final now = DateTime.now();
    if (now.difference(_lastWheelZoom) < const Duration(milliseconds: 40)) {
      return true;
    }
    _lastWheelZoom = now;

    final delta = event.scrollDelta.dy;
    if (delta == 0) return true;
    final factor = delta < 0 ? 1.08 : 1 / 1.08;
    setZoom(zoom * factor);
    return true;
  }

  /// Física de rolagem: bloqueia wheel enquanto Ctrl faz zoom.
  ScrollPhysics zoomAwarePhysics(ScrollPhysics base) {
    if (zoomModifierHeld) {
      return const NeverScrollableScrollPhysics();
    }
    return base;
  }

  Widget buildZoomButtons({double bottom = 96}) {
    return Positioned(
      left: 10,
      bottom: bottom,
      child: Material(
        color: Colors.white,
        elevation: 3,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Aumentar zoom (Ctrl + scroll)',
              visualDensity: VisualDensity.compact,
              onPressed: zoom >= maxZoom ? null : zoomIn,
              icon: const Icon(Icons.add, size: 20),
              color: AppColors.primaryDark,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '${(zoom * 100).round()}%',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMedium,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Diminuir zoom',
              visualDensity: VisualDensity.compact,
              onPressed: zoom <= minZoom ? null : zoomOut,
              icon: const Icon(Icons.remove, size: 20),
              color: AppColors.primaryDark,
            ),
            if (zoom > 1.01)
              IconButton(
                tooltip: 'Resetar zoom',
                visualDensity: VisualDensity.compact,
                onPressed: zoomReset,
                icon: const Icon(Icons.center_focus_weak, size: 18),
                color: AppColors.textMedium,
              ),
          ],
        ),
      ),
    );
  }
}

bool readerZoomModifierPressed() {
  return HardwareKeyboard.instance.isControlPressed ||
      HardwareKeyboard.instance.isMetaPressed ||
      (kIsWeb && HardwareKeyboard.instance.isControlPressed);
}
