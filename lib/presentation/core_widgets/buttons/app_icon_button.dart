import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? iconColor;
  final double? iconSize;

  const AppIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.iconColor = Colors.black,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F5F5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        iconSize: iconSize,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }
}
