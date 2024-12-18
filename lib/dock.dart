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

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  late List<T> _items = widget.items.toList();
  T? _draggingItem; // Currently dragging item
  T? _hoveredItem; // Item being hovered
  bool _isDraggingOut = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return SingleChildScrollView(
      child: Container(
        // width: w * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.red.withOpacity(0.4),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: _buildDraggableItems(w),
        ),
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
            _hoveredItem = item;
            _isDraggingOut = false;
          });
          return true;
        },
        onLeave: (data) {
          setState(() {
            _hoveredItem = null;
          });
        },
        onAccept: (data) {
          setState(() {
            _items.remove(data);
            _items.insert(index, data);
            _hoveredItem = null;
            _draggingItem = null;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: isHovered
                ? EdgeInsets.only(
                    left: containerWidth * 0.04, right: containerWidth * 0.04)
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
              childWhenDragging: const SizedBox(
                width: 10,
                height: 10,
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
