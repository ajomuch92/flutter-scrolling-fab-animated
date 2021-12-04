library flutter_scrolling_fab_animated;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

/// Widget to animate the button when scroll down
class ScrollingFabAnimated extends StatefulWidget {
  /// Function to use when press the button
  final GestureTapCallback? onPress;

  /// Double value to set the button elevation
  final double? elevation;

  /// Double value to set the button width
  final double? width;

  /// Double value to set the button height
  final double? height;

  /// Value to set the duration for animation
  final Duration? duration;

  /// Widget to use as button icon
  final Widget? icon;

  /// Widget to use as button text when button is expanded
  final Widget? text;

  /// Value to set the curve for animation
  final Curve? curve;

  /// ScrollController to use to determine when user is on top or not
  final ScrollController? scrollController;

  /// Double value to set the boundary value when scroll animation is triggered
  final double? limitIndicator;

  /// Color to set the button background color
  final Color? color;

  /// Value to indicate if animate or not the icon
  final bool? animateIcon;

  ScrollingFabAnimated(
      {Key? key,
      required this.icon,
      required this.text,
      required this.onPress,
      required this.scrollController,
      this.elevation = 5.0,
      this.width = 120.0,
      this.height = 60.0,
      this.duration = const Duration(milliseconds: 250),
      this.curve,
      this.limitIndicator = 10.0,
      this.color = Colors.blueAccent,
      this.animateIcon = true})
      : super(key: key);

  @override
  _ScrollingFabAnimatedState createState() => _ScrollingFabAnimatedState();
}

class _ScrollingFabAnimatedState extends State<ScrollingFabAnimated>
    with SingleTickerProviderStateMixin {
  /// Boolean value to indicate when scroll view is on top
  bool _onTop = true;

  /// Value to indicate when to show the child widget
  bool _visibleText = false;

  /// Controller for icon animation
  AnimationController? _animationController;

  _ScrollingFabAnimatedState() {
    _animationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
      reverseDuration: Duration(milliseconds: 250),
      animationBehavior: AnimationBehavior.normal,
      lowerBound: 0,
      upperBound: 120,
    );
  }

  @override
  void initState() {
    super.initState();
    _handleScroll();
  }

  @override
  void dispose() {
    widget.scrollController!.removeListener(() {});
    _animationController!.dispose();
    super.dispose();
  }

  /// Function to add listener for scroll
  void _handleScroll() {
    ScrollController _scrollController = widget.scrollController!;
    _scrollController.addListener(() {
      print(_scrollController.position.userScrollDirection);
      if (_scrollController.position.pixels > widget.limitIndicator! &&
          _scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
        if (widget.animateIcon!) _animationController!.forward();
        setState(() {
          _onTop = false;
        });
      } else if (_scrollController.position.pixels <= widget.limitIndicator! &&
          _scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
        if (widget.animateIcon!) _animationController!.reverse();
        setState(() {
          _onTop = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPress,
      child: Card(
        elevation: widget.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(widget.height! / 2)),
        ),
        child: AnimatedContainer(
          curve: widget.curve ?? Curves.easeInOut,
          duration: widget.duration!,
          height: widget.height,
          width: _onTop ? widget.width : widget.height,
          onEnd: () {
            setState(() {
              _visibleText = !_visibleText;
            });
          },
          decoration: BoxDecoration(
              color: widget.color,
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.height! / 2))),
          child: Row(
            mainAxisAlignment: _onTop
                ? MainAxisAlignment.spaceEvenly
                : MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                  child: widget.icon!,
                  animation: _animationController!,
                  builder: (BuildContext context, Widget? _widget) {
                    return new Transform.rotate(
                      angle: (_animationController!.value * 3 * math.pi) / 180,
                      child: _widget!,
                    );
                  }),
              ...(_onTop
                  ? [
                      AnimatedOpacity(
                        opacity: !_visibleText ? 1 : 0,
                        duration: Duration(milliseconds: 100),
                        child: widget.text!,
                      )
                    ]
                  : []),
            ],
          ),
        ),
      ),
    );
  }
}
