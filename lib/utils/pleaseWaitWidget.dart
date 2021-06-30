import 'package:flutter/material.dart';

import 'package:plataforma_compras/utils/colors.util.dart';

class PleaseWaitWidget extends StatelessWidget {
  PleaseWaitWidget({
    Key key,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //return Container(
    //  child: Center(
    //    child: CircularProgressIndicator(),
    //  ),
    //  color: tanteLadenAmber500,
    //);
    return Container(
      child: Center(child: CircularProgressIndicator(color: tanteLadenOrange900,)),
    );
  }
}