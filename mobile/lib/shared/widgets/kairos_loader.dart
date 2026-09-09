import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class KairosLoader extends StatelessWidget {
  final double? size;

  const KairosLoader({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/loading.json',
      width: size ?? 80.0,
      height: size ?? 80.0,
      fit: BoxFit.contain,
    );
  }
}
