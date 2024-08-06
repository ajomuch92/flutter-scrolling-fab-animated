library flutter_scrolling_fab_animated;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

/// Widget to animate the button when scroll down
class ScrollingFabAnimated extends StatefulWidget {
  /// Function to use when press the button
  final GestureTapCallback? onPress;

  /// Function to use when long press the button
  final GestureTapCallback? onLongPress;

  /// Double value to set the button elevation
  final double? elevation;

  /// Double value to set the button width
  final double? width;

  /// Double value to set the button height
  final double? height;

  /// Value to set the duration for animation
  final Duration? duration;

  /// Widget to use as button icon
  final Widget icon;

  /// Widget to use as button text when button is expanded
  final Widget text;

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

  /// Value to inverte the behavior of the animation
  final bool? inverted;

  /// Double value to set the button radius
  final double? radius;

  const ScrollingFabAnimated(
      {Key? key,
      required this.icon,
      required this.text,
      required this.onPress,
      required this.scrollController,
      this.onLongPress,
      this.elevation = 5.0,
      this.width = 120.0,
      this.height = 60.0,
      this.duration = const Duration(milliseconds: 250),
      this.curve,
      this.limitIndicator = 10.0,
      this.color,
      this.animateIcon = true,
      this.inverted = false,
      this.radius})
      : super(key: key);

  @override
  _ScrollingFabAnimatedState createState() => _ScrollingFabAnimatedState();
}

class _ScrollingFabAnimatedState extends State<ScrollingFabAnimated> {
  /// Double value for tween ending
  double _endTween = 100;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    if (widget.inverted!) {
      setState(() {
        _endTween = 0;
      });
    }
    _handleScroll();
  }

  @override
  void dispose() {
    widget.scrollController!.removeListener(() {});
    super.dispose();
  }

  /// Function to add listener for scroll
  void _handleScroll() {
    ScrollController _scrollController = widget.scrollController!;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > widget.limitIndicator! &&
          _scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
        setState(() {
          _endTween = widget.inverted! ? 100 : 0;
        });
      } else if (_scrollController.position.pixels <= widget.limitIndicator! &&
          _scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
        setState(() {
          _endTween = widget.inverted! ? 0 : 100;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: widget.elevation,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(widget.height! / 2))),
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: _endTween),
          duration: widget.duration!,
          builder: (BuildContext _, double size, Widget? child) {
            double _widthPercent = (widget.width! - widget.height!).abs() / 100;
            bool _isFull = _endTween == 100;
            double _radius = widget.radius ?? (widget.height! / 2);
            return Container(
              height: widget.height,
              width: widget.height! + _widthPercent * size,
              child: Material(
                borderRadius: BorderRadius.circular(_radius),
                color: widget.color ?? Theme.of(context).primaryColor,
                child: InkWell(
                  onTap: widget.onPress,
                  onLongPress: widget.onLongPress,
                  borderRadius: BorderRadius.circular(_radius),
                  child: Row(
                    mainAxisAlignment: _isFull
                        ? MainAxisAlignment.spaceEvenly
                        : MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Transform.rotate(
                            angle: widget.animateIcon!
                                ? (3.6 * math.pi / 180) * size
                                : 0,
                            child: widget.icon,
                          )),
                      ...(_isFull
                          ? [
                              Expanded(
                                child: AnimatedOpacity(
                                  opacity: size > 90 ? 1 : 0,
                                  duration: const Duration(milliseconds: 100),
                                  child: widget.text,
                                ),
                              )
                            ]
                          : []),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
