import 'dart:ui';

import 'package:flutter/material.dart';

class BackgroundEffect extends StatelessWidget {
  const BackgroundEffect({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: ClipRect(
        child: Stack(
          children: [
            // Subtle gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.03),
                    colorScheme.surface.withOpacity(0.01),
                    colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Frosted glass effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                color: colorScheme.surface.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
