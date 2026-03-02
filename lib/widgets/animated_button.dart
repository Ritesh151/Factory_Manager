import 'package:flutter/material.dart';

/// Gradient button with hover glow and ripple. Supports loading state.
class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.gradient,
    this.loading = false,
  }) : super(key: key);

  final VoidCallback onPressed;
  final Widget child;
  final Gradient? gradient;
  final bool loading;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = widget.gradient ??
        LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: _hovering ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_hovering
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.primary)
                  .withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.loading ? null : widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: widget.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      )
                    : widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
