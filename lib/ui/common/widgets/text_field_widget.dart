import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final void Function(String?)? onChanged;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final String? hintText;
  final Widget? prefixWidget;
  final IconData? prefixIcon;
  final Color? fillColor;
  final TextInputType textInputType;
  final bool obscureText;
  final bool onlyUnderlineBorder;
  final bool enableMultiLine;
  final bool isReadOnly;
  final double borderRadius;
  final Widget? suffixWidget;
  final String? initialValue;
  final TextStyle? hintStyle;
  final TextEditingController? controller;
  const TextFieldWidget(
      {super.key,
      this.onChanged,
      this.onTap,
      this.prefixIcon,
      this.prefixWidget,
      this.initialValue,
      this.isReadOnly = false,
      this.textInputType = TextInputType.name,
      this.hintStyle,
      this.hintText = "",
      this.obscureText = false,
      this.onlyUnderlineBorder = false,
      this.enableMultiLine = false,
      this.borderRadius = kdRoundedRadius,
      this.fillColor,
      this.validator,
      this.suffixWidget,
      this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        initialValue: controller != null ? null : initialValue,
        controller: controller,
        readOnly: isReadOnly,
        onChanged: onChanged,
        validator: validator,
        autofocus: false,
        obscureText: obscureText,
        onTap: onTap,
        style: hintStyle ?? kfBodyMedium(context),
        keyboardType: textInputType,
        maxLines: enableMultiLine ? null : 1,
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle,
            border: onlyUnderlineBorder
                ? UnderlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(borderRadius),
                    ),
                    borderSide: BorderSide(
                        width: 2, color: Theme.of(context).primaryColor))
                : UnderlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(borderRadius),
                    ),
                    borderSide: const BorderSide(width: 5),
                  ),
            enabledBorder: onlyUnderlineBorder
                ? UnderlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(borderRadius),
                    ),
                    borderSide: BorderSide(
                        width: 2, color: Theme.of(context).primaryColor))
                : OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(borderRadius),
                    ),
                    borderSide: BorderSide.none),
            focusedBorder: onlyUnderlineBorder
                ? UnderlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(borderRadius),
                    ),
                    borderSide: BorderSide(
                        width: 2, color: Theme.of(context).primaryColor))
                : OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(borderRadius),
                    ),
                    borderSide: BorderSide.none,
                  ),
            filled: true,
            fillColor: kcPrimary(context).withOpacity(0.1),
            prefix: prefixWidget,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                  ),
            suffixIcon: suffixWidget));
  }
}
