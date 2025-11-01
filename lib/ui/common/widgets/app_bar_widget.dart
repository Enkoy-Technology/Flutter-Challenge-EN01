import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:enkoy_chat/ui/common/icons.dart';
import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget> actions;
  final Function()? onBack;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Widget? leading;
  const AppBarWidget(
      {super.key,
      this.title,
      this.leading,
      this.titleWidget,
      this.actions = const [],
      this.onBack,
      this.automaticallyImplyLeading = true,
      this.centerTitle = true});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      centerTitle: centerTitle,
      backgroundColor: kcSecondary(context),
      titleSpacing: 0,
      floating: true,
      pinned: true,
      leading: leading ??
          GestureDetector(
              onTap: () {
                if (onBack != null) {
                  onBack!();
                } else if (automaticallyImplyLeading) {
                  Navigator.of(context).pop();
                }
              },
              child: Visibility(
                  visible: automaticallyImplyLeading || onBack != null,
                  child: const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(kiArrowBack),
                  ))),
      title: titleWidget ??
          Text(
            title ?? "",
            style: kfBodyMedium(context, color: kcOnPrimary(context)),
          ),
      actions: actions,
    );
  }
}
