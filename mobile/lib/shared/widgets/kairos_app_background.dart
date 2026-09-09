import 'package:flutter/material.dart';
import '../../../app/theme/kairos_theme.dart';

class KairosAppBackground extends StatelessWidget {
  final Widget child;
  final double overlayOpacity;

  const KairosAppBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/app_bg.png',
          fit: BoxFit.cover,
        ),
        child,
      ],
    );
  }
}
