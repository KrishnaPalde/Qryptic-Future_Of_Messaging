import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({Key? key, required this.value, required this.onChanged})
      : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    if (widget.value) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.value
                      ? Colors.blueAccent.withOpacity(0.6)
                      : Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
              gradient: LinearGradient(
                colors: widget.value
                    ? [Colors.blueAccent, Colors.cyan]
                    : [Colors.grey.shade800, Colors.grey.shade900],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: _animation.value * 30,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: widget.value
                              ? Colors.blueAccent.withOpacity(0.8)
                              : Colors.grey.shade500,
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
