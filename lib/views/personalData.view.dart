
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/views/updateNameSurnameUser.view.dart';
import 'package:plataforma_compras/views/updateEmail.view.dart';
import 'package:plataforma_compras/views/updatePassword.view.dart';

class PersonalData extends StatelessWidget {
  final String token;
  PersonalData (this.token);
  @override
  Widget build (BuildContext context) {
    return Scaffold (
      appBar: AppBar (
        elevation: 0.0,
        leading: IconButton (
          icon: Image.asset ('assets/images/leftArrow.png'),
          onPressed: () {
            //Navigator.pop (context);
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
      ),
      body: new ResponsiveWidget(
        smallScreen: new _SmallScreenView(token),
        largeScreen: new _LargeScreenView(token),
      ),
    );
  }
}
class _SmallScreenView extends StatefulWidget {
  final String token;
  _SmallScreenView(this.token);
  @override
  _SmallScreenViewState createState() {
    return _SmallScreenViewState();
  }
}
class _SmallScreenViewState extends State<_SmallScreenView> {
  String _firstNameLastName;
  String _firstName;
  String _lastName;
  int _userId;
  String _email;
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> payload;
    payload = json.decode(
        utf8.decode(
            base64.decode (base64.normalize(widget.token.split(".")[1]))
        )
    );
    _firstName = payload['user_firstname'];
    _lastName = payload['user_lastname'];
    _firstNameLastName = _firstName + ' ' + _lastName;
    _userId = payload['user_id'];
    _email = payload['email'];
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return SafeArea (
        child: ListView (
          padding: EdgeInsets.all(15.0),
          children: [
            Text (
              'Datos personales',
              style: TextStyle (
                  fontFamily: 'SF Pro Display',
                  fontSize: 24,
                  fontWeight: FontWeight.bold
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Nombre',
                style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                ),
              ),
              subtitle: Text (
                _firstNameLastName,
                style: TextStyle (
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.normal
                ),
              ),
              onTap: () async {
                final String firstNameLastNameOut = await Navigator.push(context, MaterialPageRoute(
                    builder: (context) => UpdateNameSurnameUser (_firstName, _lastName, _userId)
                ));
                debugPrint ('He vuelto de UpdateNameSurnameUser');
                debugPrint ('El valor devuelto es: ' + firstNameLastNameOut);
                setState(() {
                  _firstNameLastName = firstNameLastNameOut;
                });
              },
            ),
            Divider(),
            ListTile (
              title: Text (
                'Email',
                style: TextStyle (
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                ),
              ),
              subtitle: Text (
                _email,
                style: TextStyle (
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.normal
                ),
              ),
              onTap: () async {
                final String email = await Navigator.push (context, MaterialPageRoute(
                    builder: (context) => UpdateEmail (_email, _userId)
                ));
                debugPrint ('He vuelto de UpdateEmail');
                debugPrint ('El valor devuelto es: ' + email);
                setState(() {
                  _email = email;
                });
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'Contraseña',
                style: TextStyle (
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                ),
              ),
              subtitle: Text (
                'Configura tu contraseña',
                style: TextStyle (
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.normal
                ),
              ),
              onTap: () async {
                final String email = await Navigator.push (context, MaterialPageRoute(
                    builder: (context) => UpdatePassword (_userId)
                ));
                debugPrint ('He vuelto de UpdateEmail');
                debugPrint ('El valor devuelto es: ' + email);
                setState(() {
                  _email = email;
                });
              },
            )
          ],
        )
    );
  }
}

class _LargeScreenView extends StatefulWidget {
  final String token;
  _LargeScreenView(this.token);
  @override
  _LargeScreenViewState createState() {
    return _LargeScreenViewState();
  }
}
class _LargeScreenViewState extends State<_LargeScreenView> {
  String _firstNameLastName;
  String _firstName;
  String _lastName;
  int _userId;
  String _email;
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> payload;
    payload = json.decode(
        utf8.decode(
            base64.decode (base64.normalize(widget.token.split(".")[1]))
        )
    );
    _firstName = payload['user_firstname'];
    _lastName = payload['user_lastname'];
    _firstNameLastName = _firstName + ' ' + _lastName;
    _userId = payload['user_id'];
    _email = payload['email'];
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea (
        child: ListView (
          padding: EdgeInsets.all(15.0),
          children: [
            Text (
              'Datos personales',
              style: TextStyle (
                  fontFamily: 'SF Pro Display',
                  fontSize: 24,
                  fontWeight: FontWeight.bold
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Nombre',
                style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                ),
              ),
              subtitle: Text (
                _firstNameLastName,
                style: TextStyle (
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.normal
                ),
              ),
              onTap: () async {
                final String firstNameLastNameOut = await Navigator.push(context, MaterialPageRoute(
                    builder: (context) => UpdateNameSurnameUser (_firstName, _lastName, _userId)
                ));
                debugPrint ('He vuelto de UpdateNameSurnameUser');
                debugPrint ('El valor devuelto es: ' + firstNameLastNameOut);
                setState(() {
                  _firstNameLastName = firstNameLastNameOut;
                });
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'Email',
                style: TextStyle (
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                ),
              ),
              subtitle: Text (
                _email,
                style: TextStyle (
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.normal
                ),
              ),
              onTap: () async {
                final String email = await Navigator.push (context, MaterialPageRoute(
                    builder: (context) => UpdateEmail (_email, _userId)
                ));
                debugPrint ('He vuelto de UpdateEmail');
                debugPrint ('El valor devuelto es: ' + email);
                setState(() {
                  _email = email;
                });
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'Contraseña',
                style: TextStyle (
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                ),
              ),
              subtitle: Text (
                'Configura tu contraseña',
                style: TextStyle (
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.normal
                ),
              ),
            )
          ],
        )
    );
  }
}