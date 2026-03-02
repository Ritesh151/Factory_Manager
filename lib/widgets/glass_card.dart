import 'dart:ui';

import 'package:flutter/material.dart';

/// A reusable glassmorphic card with blur, gradient, shadow and hover effects.
class GlassCard extends StatefulWidget {
  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.width,
    this.height,
  }) : super(key: key);

  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: widget.width,
        height: widget.height,
        transform: _hovering ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.02),
            ],
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 20),
              blurRadius: 40,
              color: Colors.black.withOpacity(_hovering ? 0.5 : 0.3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(16),
              color: Colors.white.withOpacity(0.1),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  void _setHover(bool value) {
    if (_hovering != value) {
      setState(() => _hovering = value);
    }
  }
}
