import 'package:flutter/material.dart';

class ResizablePanel extends StatefulWidget {
  final Widget child;
  final double initialWidth;
  final double minWidth;
  final double maxWidth;

  const ResizablePanel({
    super.key,
    required this.child,
    required this.initialWidth,
    this.minWidth = 100,
    this.maxWidth = 500,
  });

  @override
  State<ResizablePanel> createState() => _ResizablePanelState();
}

class _ResizablePanelState extends State<ResizablePanel> {
  late double _width;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: _width,
          child: widget.child,
        ),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _width += details.delta.dx;
              if (_width < widget.minWidth) _width = widget.minWidth;
              if (_width > widget.maxWidth) _width = widget.maxWidth;
            });
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: Container(
              width: 10,
              height: double.infinity,
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Container(
                  width: 2,
                  height: 30,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
