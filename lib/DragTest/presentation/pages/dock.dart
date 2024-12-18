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
  late final List<T> _items = widget.items.toList();

  T? _draggingItem;
  T? _hoveredItem;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return SingleChildScrollView(
      child: Container(
        width: w * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.red.withOpacity(0.4),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: _buildDraggableItems(),
        ),
      ),
    );
  }

  List<Widget> _buildDraggableItems() {
    final w = MediaQuery.sizeOf(context).width;
    bool isHover = false;
    return List.generate(_items.length, (index) {
      final item = _items[index];
      final isHovered = _hoveredItem == item;

      return AnimatedContainer(
        height: 130,
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.only(
            top: (isHover) ? 25 : 30, bottom: !(isHover) ? 25 : 30),
        child: InkWell(
          onHover: (value) {
            print("Value $value");
            setState(() {
              isHover = value;
            });
          },
          child: DragTarget<T>(
            onWillAccept: (data) {
              setState(() {
                _hoveredItem = item;
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
                padding: isHovered
                    ? EdgeInsets.only(left: w * 0.08, right: w * 0.05)
                    : const EdgeInsets.symmetric(horizontal: 4),
                child: LongPressDraggable<T>(
                  data: item,
                  onDragStarted: () {
                    setState(() {
                      _draggingItem = item;
                      print("Dragged $_draggingItem");
                    });
                  },
                  onDraggableCanceled: (velocity, offset) {
                    setState(() {
                      _draggingItem = null;
                      print("Dragged cancelled$_draggingItem");
                    });
                  },
                  onDragEnd: (details) {
                    if (details.wasAccepted == false) {
                      setState(() {
                        _items.remove(item);
                        _draggingItem = null;
                      });
                      print("Removed $item");
                    }
                  },
                  feedback: Opacity(
                    opacity: 0.7,
                    child: Material(
                      color: Colors.transparent,
                      child: widget.builder(item),
                    ),
                  ),
                  childWhenDragging: const SizedBox(
                    width: 48,
                    height: 48,
                  ),
                  child: widget.builder(item),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
