import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teams_clone/extras/user_provider.dart';
import '../extras/universal_variables.dart';

class UserCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: UnivVars.separatorColor,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              getInitials(userProvider.getUser.name),
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: UnivVars.lightBlueColor,
                fontSize: 16,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: UnivVars.onlineDotColor,
                shape: BoxShape.circle,
                border: Border.all(color: UnivVars.blackColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getInitials(String name) =>
      name.split(' ')[0][0] + name.split(' ')[1][0];
}
