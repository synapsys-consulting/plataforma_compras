import 'package:flutter/material.dart';

import 'package:plataforma_compras/utils/colors.util.dart';

class UserManagement extends StatelessWidget {
  final String name;
  UserManagement(this.name);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        leading: IconButton (
          icon: Image.asset('assets/images/leftArrow.png'),
          onPressed: () {
            Navigator.pop (context);
          },
        ),
        title: new Text(
          this.name,
          style: new TextStyle(
            fontSize: 24.0,
            color: tanteLadenOnPrimary
          ),
        ),
      ),
    );
  }
}