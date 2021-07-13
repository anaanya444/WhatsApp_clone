import 'package:flutter/material.dart';
import 'package:teams_clone/extras/universal_variables.dart';
import 'package:teams_clone/widgets/cached_image.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leading, title;
  final bool centreTitle;
  final CachedImage circleAvatar;
  final List<Widget> actions;

  CustomAppBar({
    @required this.leading,
    @required this.title,
    @required this.centreTitle,
    @required this.actions,
    this.circleAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: UnivVars.blackColor,
        border: Border(
          bottom: BorderSide(
            color: UnivVars.separatorColor,
            width: 1.4,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: UnivVars.blackColor,
        elevation: 0,
        actions: actions,
        leading: Row(children: [
          leading,
          if (circleAvatar != null) circleAvatar,
        ]),
        title: title,
        centerTitle: centreTitle,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
