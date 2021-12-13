import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';


import 'package:plataforma_compras/views/home.view.dart';
import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/models/cart.model.dart';
import 'package:plataforma_compras/models/catalog.model.dart';
import 'package:plataforma_compras/models/defaultAddressList.model.dart';
import 'package:plataforma_compras/models/addressesList.model.dart';


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        //final isValidHost = host == "52.55.223.20";     // PRODUCTION
        final isValidHost = host == "192.168.2.106";  // DEVELOPMENT
        //final isValidHost = host == "192.168.18.100";
        //final isValidHost = host == "192.168.1.134";
        return isValidHost;
      };
  }
}
void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //return ChangeNotifierProvider<Cart>(
    //  create: (context) => Cart(),
    //  child: MaterialApp (
    //    title: 'Comprando',
    //    theme: _tanteLadenTheme,
    //    home: MyHomePage(title: 'Plataforma de Compras'),
    //    debugShowCheckedModeBanner: true,
    //  ),
    //);
    return MultiProvider (
      providers: [
        ChangeNotifierProvider<Cart>(
          create: (context) => Cart(),
        ),
        ChangeNotifierProvider<Catalog>(
          create: (context) => Catalog()
        ),
        ChangeNotifierProvider<DefaultAddressList>(
          create: (context) => DefaultAddressList()
        ),
        ChangeNotifierProvider<AddressesList>(
          create: (context) => AddressesList()
        )
      ],
      child: MaterialApp (
        title: 'Comprando',
        theme: _tanteLadenTheme,
        home: MyHomePage(title: 'Plataforma de Compras'),
        debugShowCheckedModeBanner: true,
      ),
    );
  }
}

final ThemeData _tanteLadenTheme = _buildTanteLadenTheme();

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
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: tanteLadenOnPrimary,
      selectionColor: tanteLadenAmber100,
      selectionHandleColor: tanteLadenAmber100
    ),
    errorColor: tanteLadenErrorRed,
  );
}
