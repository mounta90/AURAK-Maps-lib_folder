import 'package:flutter/material.dart';

class RoundedIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData iconName;
  final Color fillColor;
  final Color iconColor;

  const RoundedIconButton({
    super.key,
    required this.iconName,
    required this.onPressed,
    required this.fillColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.0),
      child: Material(
        color: fillColor,
        child: IconButton(
          // iconSize: 32,
          onPressed: onPressed,
          disabledColor: Colors.grey,
          icon: Icon(
            size: 32,
            iconName,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
