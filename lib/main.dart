import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'package:plataforma_compras/views/home.view.dart';
import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/models/cart.model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Cart>(
      create: (context) => Cart(),
      child: MaterialApp (
        title: 'Comprando',
        theme: _TanteLadenTheme,
        home: MyHomePage(title: 'Plataforma de Compras'),
        debugShowCheckedModeBanner: true,
      ),
    );
  }
}

final ThemeData _TanteLadenTheme = _buildTanteLadenTheme();

ThemeData _buildTanteLadenTheme(){
  final ThemeData base = ThemeData.from(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.amber,
      primaryColorDark: tanteLadenAmber500,
      accentColor: tanteLadenOrange900,
      cardColor: tanteLadenBackgroundWhite,
      //backgroundColor: tanteLadenSurfaceWhite,
      backgroundColor: tanteLadenBackgroundWhite,
      errorColor: tanteLadenErrorRed
    ),
  );
  return base.copyWith(
    accentColor: tanteLadenOrange900,
    primaryColor: tanteLadenAmber500,
    primaryIconTheme: base.primaryIconTheme.copyWith(
      color: tanteLadenBrown500
    ),
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: tanteLadenOrange900,
      colorScheme: base.colorScheme.copyWith(
        secondary: tanteLadenOrange200,
      )
    ),
    buttonBarTheme: base.buttonBarTheme.copyWith(
      buttonTextTheme: ButtonTextTheme.accent
    ),
    scaffoldBackgroundColor: tanteLadenBackgroundWhite,
    cardColor: tanteLadenBackgroundWhite,
    textSelectionColor: tanteLadenAmber100,
    errorColor: tanteLadenErrorRed,
  );
}
