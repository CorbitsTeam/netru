import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollHideAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ScrollController scrollController;
  final PreferredSizeWidget child;

  const ScrollHideAppBar({
    super.key,
    required this.scrollController,
    required this.child,
  });

  @override
  Size get preferredSize => child.preferredSize;

  @override
  State<ScrollHideAppBar> createState() => _ScrollHideAppBarState();
}

class _ScrollHideAppBarState extends State<ScrollHideAppBar> {
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      final direction = widget.scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse && isVisible) {
        setState(() => isVisible = false);
      } else if (direction == ScrollDirection.forward && !isVisible) {
        setState(() => isVisible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isVisible ? widget.child.preferredSize.height : 0,
      child: Wrap(children: [widget.child]),
    );
  }
}
