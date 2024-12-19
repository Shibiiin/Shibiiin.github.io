import 'package:flutter/material.dart';

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends Object> extends State<Dock<T>> {
  late List<T> _items = widget.items.toList();
  T? _draggingItem;
  T? _hoveredItem;
  bool _isDraggingOut = false;

  @override
  Widget build(BuildContext context) {
    final containerWidth = MediaQuery.sizeOf(context).width;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _buildDraggableItems(containerWidth),
      ),
    );
  }

  List<Widget> _buildDraggableItems(double containerWidth) {
    return List.generate(_items.length, (index) {
      final item = _items[index];
      final isHovered = _hoveredItem == item;

      return DragTarget<T>(
        onWillAccept: (data) {
          setState(() {
            _hoveredItem = item; // Set hovered item
            _isDraggingOut = false;
          });
          return true;
        },
        onLeave: (data) {
          setState(() {
            _hoveredItem = null; // Reset hovered item
          });
        },
        onAccept: (data) {
          setState(() {
            _items.remove(data); // Remove from old position
            _items.insert(index, data); // Insert into new position
            _hoveredItem = null;
            _draggingItem = null;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            height: isHovered ? 80 : 70,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: isHovered
                ? EdgeInsets.only(
                    left: isHovered
                        ? containerWidth * 0.025
                        : containerWidth * 0.05,
                    right: isHovered
                        ? containerWidth * 0.025
                        : containerWidth * 0.05,
                  )
                : const EdgeInsets.symmetric(horizontal: 4),
            child: LongPressDraggable<T>(
              data: item,
              onDragStarted: () {
                setState(() {
                  _draggingItem = item;
                  _isDraggingOut = false;
                });
              },
              onDraggableCanceled: (velocity, offset) {
                setState(() {
                  _draggingItem = null;
                  _isDraggingOut = false;
                });
              },
              onDragEnd: (details) {
                if (!_isDraggingOut) return;

                setState(() {
                  _items.remove(item);
                  _draggingItem = null;
                  _isDraggingOut = false;
                });
              },
              feedback: Opacity(
                opacity: 0.7,
                child: Material(
                  color: Colors.transparent,
                  child: widget.builder(item),
                ),
              ),
              childWhenDragging: _isDraggingOut
                  ? const SizedBox.shrink()
                  : Container(
                      width: 0,
                      height: 0,
                      color: Colors.transparent,
                    ),
              child: MouseRegion(
                onHover: (_) {
                  setState(() {
                    _hoveredItem = item;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _hoveredItem = null;
                  });
                },
                child: widget.builder(item),
              ),
            ),
          );
        },
      );
    });
  }
}
