import 'package:flutter/material.dart';
import 'package:teams_clone/extras/universal_variables.dart';

class CustomTile extends StatelessWidget {
  final Widget title, subtitle, leading, trailing, icon;
  final EdgeInsets margin;
  final bool isMini;
  final Function onTap, onLongPress;

  CustomTile({
    @required this.title,
    @required this.subtitle,
    @required this.leading,
    this.trailing,
    this.icon,
    this.margin = const EdgeInsets.all(0),
    this.isMini = true,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: UnivVars.separatorColor)),
        ),
        margin: margin,
        padding: EdgeInsets.symmetric(horizontal: isMini ? 10 : 0),
        child: Row(
          children: [
            SizedBox(width: 10),
            leading,
            SizedBox(width: 5),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: isMini ? 10 : 15),
                padding: EdgeInsets.symmetric(vertical: isMini ? 3 : 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        SizedBox(height: 5),
                        Row(children: [icon ?? Container(), subtitle]),
                      ],
                    ),
                    trailing ?? Container(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
