import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable Icon Widget
/// 
/// This widget handles both SVG and PNG icons with consistent styling
class AppIconWidget extends StatelessWidget {
  final String iconPath;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const AppIconWidget({
    super.key,
    required this.iconPath,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the icon is SVG or PNG
    if (iconPath.endsWith('.svg')) {
      return SvgPicture.asset(
        iconPath,
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        fit: fit,
      );
    } else {
      // Handle PNG or other image formats
      return Image.asset(
        iconPath,
        width: width,
        height: height,
        color: color,
        fit: fit,
      );
    }
  }
}

/// Icon Button Widget with App Icons
class AppIconButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onPressed;
  final double? iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.iconPath,
    required this.onPressed,
    this.iconSize = 24,
    this.iconColor,
    this.backgroundColor,
    this.padding,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onPressed,
      icon: AppIconWidget(
        iconPath: iconPath,
        width: iconSize,
        height: iconSize,
        color: iconColor,
      ),
      padding: padding ?? const EdgeInsets.all(8.0),
      style: backgroundColor != null
          ? IconButton.styleFrom(
              backgroundColor: backgroundColor,
            )
          : null,
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

