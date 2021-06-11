import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/utils/showSnackBar.dart';
import 'package:plataforma_compras/utils/pleaseWaitWidget.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/utils/responsiveWidget.dart';

class _NameSurname {
  String name;
  String surNames;
}
class UpdateNameSurnameUser extends StatefulWidget {
  final String firstName;
  final String lastName;
  final int userId;
  UpdateNameSurnameUser (this.firstName, this.lastName, this.userId);

  @override
  _UpdateNameSurnameUserState createState() {
    return _UpdateNameSurnameUserState();
  }
}
class _UpdateNameSurnameUserState extends State<UpdateNameSurnameUser> {
  bool _pleaseWait = false;
  _NameSurname _nameSurnameOut = new _NameSurname();
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));
  String _firstNameIn;  // Save the name that come as the input parameter
  String _lastNameIn; // Save the surname that come as the input parameter
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  _showPleaseWait(bool b) {
    setState(() {
      _pleaseWait = b;
    });
  }
  @override
  void initState() {
    super.initState();
    _pleaseWait = false;
    _firstNameIn = widget.firstName;    // Save the value that come as the input parameter
    _lastNameIn = widget.lastName;      // Save the value that come as the input parameter
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final Widget tmpBuilder = Container(
      alignment: Alignment.center,
      child: TextButton(
        child: Text (
          'Guardar',
          style: TextStyle (
            fontFamily: 'SF Pro Display',
            fontSize: 16.0,
            fontWeight: FontWeight.w900,
            color: tanteLadenIconBrown,
          ),
          textAlign: TextAlign.right,
        ),
        onPressed: () async {
          try {
            debugPrint ('He pinchado en el Guardar');
            _showPleaseWait (true);
            final Uri url = Uri.parse('$SERVER_IP/updateUserWithPersoneId/' + widget.userId.toString());
            final http.Response res = await http.put (
                url,
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                  //'Authorization': jwt
                },
                body: jsonEncode (<String, String>{
                  'user_lastname': _nameSurnameOut.surNames,
                  'user_firstname': _nameSurnameOut.name,
                  'gethash': 'true'
                })
            ).timeout (TIMEOUT);
            if (res.statusCode == 200) {
              _showPleaseWait(false);
              final String token = json.decode(res.body)['token'].toString();
              final SharedPreferences prefs = await _prefs;
              prefs.setString('token', token);
              Navigator.popUntil(context, ModalRoute.withName('/'));
            } else {
              _showPleaseWait (false);
            }
          } catch (e) {
            _showPleaseWait (false);
            debugPrint ('El error es: ' + e.toString());
            ShowSnackBar.showSnackBar(context, e, error: true);
          }
        },
      ),
    );
    return Scaffold(
      appBar: AppBar (
        elevation: 0.0,
        leading: IconButton (
          icon: Image.asset('assets/images/leftArrow.png'),
          onPressed: () {
            Navigator.pop (context, _firstNameIn + ' ' + _lastNameIn);
          },
        ),
        title: Text(
          'Cambiar nombre',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20.0,
            fontWeight: FontWeight.w300,
            color: tanteLadenIconBrown
          ),
        ),
        actions: <Widget>[
          _pleaseWait ?
          Stack (
            key:  ObjectKey("stack"),
            alignment: AlignmentDirectional.center,
            children: [tmpBuilder, _pleaseWaitWidget],
          ) :
          Stack (key:  ObjectKey("stack"), children: [tmpBuilder],)
        ],
      ),
      body: ResponsiveWidget (
        smallScreen: _SmallScreenView (widget.firstName, widget.lastName, _nameSurnameOut),
      ),
    );
  }
}
class _SmallScreenView extends StatefulWidget {
  _SmallScreenView (this.name, this.surNames, this.nameSurnameOut);
  final String name;
  final String surNames;
  final _NameSurname nameSurnameOut;

  @override
  _SmallScreenViewState createState() {
    return _SmallScreenViewState();
  }
}
class _SmallScreenViewState extends State<_SmallScreenView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surNamesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.name == 'null') {
      _nameController.text = '';
    } else {
      _nameController.text = widget.name;
    }
    if (widget.surNames == 'null') {
      _surNamesController.text = '';
    } else {
      _surNamesController.text = widget.surNames;
    }
    widget.nameSurnameOut.name = _nameController.text;
    widget.nameSurnameOut.surNames = _surNamesController.text;
  }
  _onNameChanged(){
    debugPrint ('Antes de la asignación');
    widget.nameSurnameOut.name = _nameController.text;
    debugPrint ('Después de la asignación');
  }
  _onSurnamesChanged(){
    widget.nameSurnameOut.surNames = _surNamesController.text;
  }
  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _surNamesController.removeListener(_onSurnamesChanged);
    _surNamesController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ListView(
          padding: EdgeInsets.all(20.0),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text (
                    'Nombre',
                    style: TextStyle (
                      fontWeight: FontWeight.w900,
                      fontSize: 20.0,
                      fontFamily: 'SF Pro Display',
                      fontStyle: FontStyle.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox (height: 15.0),
            Text(
              'Indícanos tu nombre y apellidos para localizarte en relación a tu pedido.',
              style: TextStyle(
                fontSize: 16.0,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.normal,
                color: tanteLadenOnPrimary,
              ),
              textAlign: TextAlign.justify,
              maxLines: 2,
              softWrap: true,
            ),
            SizedBox(height: 20.0),
            Form(
                autovalidateMode: AutovalidateMode.always,
                key: _formKey,
                child: Column (
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration (
                        labelText: 'Nombre',
                        labelStyle: TextStyle (
                          color: tanteLadenIconBrown,
                        ),
                        suffixIcon: IconButton (
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _nameController.clear();
                            }
                        ),
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Introduce un nombre válido';
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox (height: 15.0,),
                    TextFormField(
                      controller: _surNamesController,
                      decoration: InputDecoration (
                        labelText: 'Apellidos',
                        labelStyle: TextStyle (
                          color: tanteLadenIconBrown,
                        ),
                        suffixIcon: IconButton (
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _surNamesController.clear();
                            }
                        ),
                      ),
                      validator: (String value) {
                        if (value == null) {
                          return 'Introduce apellidos válidos';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                )
            ),
          ],
        ),
      )
    );
  }
}
