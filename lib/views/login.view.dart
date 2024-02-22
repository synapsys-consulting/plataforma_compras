import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/utils/pleaseWaitWidget.dart';
import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/utils/showSnackBar.dart';
import 'package:plataforma_compras/views/signIn.view.dart';
import 'package:plataforma_compras/views/signUp.view.dart';

class LoginView extends StatelessWidget {
  final int reason;           //  1 the call comes from the drawer. 2 the call comes from cart.view.dart
  LoginView (this.reason);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton (
          icon: Image.asset('assets/images/leftArrow.png'),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: Image.asset ('assets/images/logoQuestion.png'),
              onPressed: null
          )
        ],
      ),
      body: ResponsiveWidget (
        smallScreen: _SmallScreenView (this.reason),
        mediumScreen: _MediumScreenView(this.reason),
        largeScreen: _LargeScreenView (this.reason),
      ),
    );
  }
}

class _SmallScreenView extends StatefulWidget {
  final int reason;           //  1 the call comes from the drawer. 2 the call comes from cart.view.dart
  _SmallScreenView (this.reason);
  @override
  _SmallScreenViewState createState() {
    return _SmallScreenViewState();
  }

}
class _SmallScreenViewState extends State<_SmallScreenView> {
  bool _pleaseWait = false;
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();

  _showPleaseWait(bool b) {
    setState(() {
      _pleaseWait = b;
    });
  }
  @override
  void initState() {
    super.initState();
    _pleaseWait = false;
  }
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final Widget tmpBuilder = Container (
      child: GestureDetector (
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            try {
              _showPleaseWait(true);
              final Uri url = Uri.parse('$SERVER_IP/loginWithoutPass');
              final http.Response res = await http.post (
                  url,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    //'Authorization': jwt
                  },
                  body: jsonEncode(<String, String>{
                    'user_name': _email.text
                  })
              );
              _showPleaseWait(false);
              if (res.statusCode == 200) {
                // Sign in
                debugPrint ('El valor de _email.text es: ' + _email.text);
                debugPrint ('El valor de res.body[user_name] es: ' + json.decode(res.body)['user_name'].toString());
                Navigator.push (
                    context,
                    MaterialPageRoute (
                        builder: (context) => (SigInView(_email.text, widget.reason))
                    )
                );
              } else if (res.statusCode == 404) {
                // Sign up
                debugPrint ('El valor de _email.text es: ' + _email.text);
                debugPrint ('El valor de res.body[user_name] es: ' + json.decode(res.body)['user_name'].toString());
                Navigator.push (
                    context,
                    MaterialPageRoute (
                        builder: (context) => (SignUpView(_email.text, widget.reason))  //  1 the call comes from the drawer. 2 the call comes from cart.view.dart
                    )
                );
              } else {
                // Error
                ShowSnackBar.showSnackBar (context, json.decode(res.body)['message'].toString());
              }
            } catch (e) {
              ShowSnackBar.showSnackBar(context, e.toString(), error: true);
            }
          }
        },
        child: Container (
          height: 64.0,
          decoration: BoxDecoration (
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8.0),
              gradient: LinearGradient(
                  colors: <Color>[
                    Color (0xFF833C26),
                    //Color (0XFF863F25),
                    //Color (0xFF8E4723),
                    Color (0xFF9A541F),
                    //Color (0xFFB16D1A),
                    //Color (0xFFDE9C0D),
                    Color (0xFFF9B806),
                    Color (0XFFFFC107),
                  ]
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    offset: Offset (5,5),
                    blurRadius: 10
                )
              ]
          ),
          child: Center (
            child: const Text (
              'Entrar',
              style: TextStyle(
                  fontSize: 24.0,
                  color: tanteLadenBackgroundWhite
              ),
            ),
          ),
        ),
      ),
    );
    return SafeArea(
      child: Center(
        child: ListView(
          padding: EdgeInsets.all(20.0),
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text (
                    'Identifícate',
                    style: TextStyle (
                      fontWeight: FontWeight.w900,
                      fontSize: 36.0,
                      fontFamily: 'SF Pro Display',
                      fontStyle: FontStyle.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox (height: 30.0,),
            Container (
              padding: EdgeInsets.zero,
              child: Center (
                child: Text (
                  'Introduce tu email para continuar con tu pedido.',
                  style: TextStyle (
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                    fontFamily: 'SF Pro Display',
                    fontStyle: FontStyle.normal,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.justify,
                  maxLines: 2,
                  softWrap: true
                ),
              ),
            ),
            SizedBox (height: 20.0,),
            Form (
              autovalidateMode: AutovalidateMode.always,
              key: _formKey,
              child: Column (
                children: [
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration (
                      labelText: 'Email',
                      labelStyle: TextStyle (
                        color: tanteLadenIconBrown,
                      ),
                      suffixIcon: IconButton (
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _email.clear();
                        }
                      ),
                    ),
                    validator: (String? value) {
                      Pattern pattern =
                          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                          r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                          r"{0,253}[a-zA-Z0-9])?)*$";
                      RegExp regexp = new RegExp(pattern.toString());
                      if (!regexp.hasMatch(value ?? "") || value == null) {
                        return 'Introduce un email válido';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(height: 40.0,),
                  _pleaseWait
                  ? Stack (
                    key:  ObjectKey("stack"),
                    alignment: AlignmentDirectional.center,
                    children: [tmpBuilder, _pleaseWaitWidget],
                  )
                  : Stack (key:  ObjectKey("stack"), children: [tmpBuilder],)
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
class _MediumScreenView extends StatefulWidget {
  final int reason;           //  1 the call comes from the drawer. 2 the call comes from cart.view.dart
  _MediumScreenView (this.reason);
  @override
  _MediumScreenViewState createState() {
    return _MediumScreenViewState();
  }
}
class _MediumScreenViewState extends State<_MediumScreenView> {
  bool _pleaseWait = false;
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();

  _showPleaseWait(bool b) {
    setState(() {
      _pleaseWait = b;
    });
  }
  @override
  void initState() {
    super.initState();
    _pleaseWait = false;
  }
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final Widget tmpBuilder = Container (
      child: GestureDetector (
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            try {
              _showPleaseWait(true);
              final Uri url = Uri.parse('$SERVER_IP/loginWithoutPass');
              final http.Response res = await http.post (
                  url,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    //'Authorization': jwt
                  },
                  body: jsonEncode(<String, String>{
                    'user_name': _email.text
                  })
              );
              _showPleaseWait(false);
              if (res.statusCode == 200) {
                // Sign in
                debugPrint ('El valor de _email.text es: ' + _email.text);
                debugPrint ('El valor de res.body[user_name] es: ' + json.decode(res.body)['user_name'].toString());
                Navigator.push (
                    context,
                    MaterialPageRoute (
                        builder: (context) => (SigInView(_email.text, widget.reason))
                    )
                );
              } else if (res.statusCode == 404) {
                // Sign up
                debugPrint ('El valor de _email.text es: ' + _email.text);
                debugPrint ('El valor de res.body[user_name] es: ' + json.decode(res.body)['user_name'].toString());
                Navigator.push (
                    context,
                    MaterialPageRoute (
                        builder: (context) => (SignUpView(_email.text, widget.reason))  //  1 the call comes from the drawer. 2 the call comes from cart.view.dart
                    )
                );
              } else {
                // Error
                ShowSnackBar.showSnackBar (context, json.decode(res.body)['message'].toString());
              }
            } catch (e) {
              ShowSnackBar.showSnackBar(context, e.toString(), error: true);
            }
          }
        },
        child: Container (
          height: 64.0,
          decoration: BoxDecoration (
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8.0),
              gradient: LinearGradient(
                  colors: <Color>[
                    Color (0xFF833C26),
                    //Color (0XFF863F25),
                    //Color (0xFF8E4723),
                    Color (0xFF9A541F),
                    //Color (0xFFB16D1A),
                    //Color (0xFFDE9C0D),
                    Color (0xFFF9B806),
                    Color (0XFFFFC107),
                  ]
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    offset: Offset (5,5),
                    blurRadius: 10
                )
              ]
          ),
          child: Center (
            child: const Text (
              'Entrar',
              style: TextStyle(
                  fontSize: 24.0,
                  color: tanteLadenBackgroundWhite
              ),
            ),
          ),
        ),
      ),
    );
    return SafeArea(
        child: Center(
          child: ListView(
            padding: EdgeInsets.all(20.0),
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text (
                      'Identifícate',
                      style: TextStyle (
                        fontWeight: FontWeight.w900,
                        fontSize: 36.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox (height: 30.0,),
              Container (
                padding: EdgeInsets.zero,
                child: Center (
                  child: Text (
                      'Introduce tu email para continuar con tu pedido.',
                      style: TextStyle (
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.justify,
                      maxLines: 2,
                      softWrap: true
                  ),
                ),
              ),
              SizedBox (height: 20.0,),
              Form (
                autovalidateMode: AutovalidateMode.always,
                key: _formKey,
                child: Column (
                  children: [
                    TextFormField(
                      controller: _email,
                      decoration: InputDecoration (
                        labelText: 'Email',
                        labelStyle: TextStyle (
                          color: tanteLadenIconBrown,
                        ),
                        suffixIcon: IconButton (
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _email.clear();
                            }
                        ),
                      ),
                      validator: (String? value) {
                        Pattern pattern =
                            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                            r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                            r"{0,253}[a-zA-Z0-9])?)*$";
                        RegExp regexp = new RegExp(pattern.toString());
                        if (!regexp.hasMatch(value ?? "") || value == null) {
                          return 'Introduce un email válido';
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: 40.0,),
                    _pleaseWait
                        ? Stack (
                      key:  ObjectKey("stack"),
                      alignment: AlignmentDirectional.center,
                      children: [tmpBuilder, _pleaseWaitWidget],
                    )
                        : Stack (key:  ObjectKey("stack"), children: [tmpBuilder],)
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}
class _LargeScreenView extends StatefulWidget {
  final int reason;           //  1 the call comes from the drawer. 2 the call comes from cart.view.dart
  _LargeScreenView (this.reason);
  @override
  _LargeScreenViewState createState() {
    return _LargeScreenViewState();
  }
}
class _LargeScreenViewState extends State<_LargeScreenView> {
  bool _pleaseWait = false;
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();

  _showPleaseWait(bool b) {
    setState(() {
      _pleaseWait = b;
    });
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }
  @override
  Widget build (BuildContext context) {
    final Widget tmpBuilder = Container(
      child: GestureDetector (
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            try {
              debugPrint ('El valor de _email.text es: ' + _email.text);
              _showPleaseWait(true);
              final Uri url = Uri.parse('$SERVER_IP/loginWithoutPass');
              final http.Response res = await http.post (
                  url,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    //'Authorization': jwt
                  },
                  body: jsonEncode(<String, String>{
                    'user_name': _email.text
                  })
              );
              _showPleaseWait(false);
              if (res.statusCode == 200) {
                debugPrint ('El valor de _email.text es: ' + _email.text);
                // Sign in
                Navigator.push (
                    context,
                    MaterialPageRoute(
                        builder: (context) => (SigInView(_email.text, widget.reason))
                    )
                );
              } else if (res.statusCode == 404) {
                debugPrint ('El valor de _email.text es: ' + _email.text);
                // Sign up
                Navigator.push (
                    context,
                    MaterialPageRoute(
                        builder: (context) => (SignUpView(_email.text, widget.reason))   //  1 the call comes from the drawer. 2 the call comes from cart.view.dart
                    )
                );
              } else {
                // Error
                ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'].toString());
              }
            } catch (e) {
              ShowSnackBar.showSnackBar(context, e.toString(), error: true);
            }
          }
        },
        child: Container (
          height: 64.0,
          decoration: BoxDecoration (
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8.0),
              gradient: LinearGradient(
                  colors: <Color>[
                    Color (0xFF833C26),
                    //Color (0XFF863F25),
                    //Color (0xFF8E4723),
                    Color (0xFF9A541F),
                    //Color (0xFFB16D1A),
                    //Color (0xFFDE9C0D),
                    Color (0xFFF9B806),
                    Color (0XFFFFC107),
                  ]
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    offset: Offset (5,5),
                    blurRadius: 10
                )
              ]
          ),
          child: Center (
            child: const Text (
              'Entrar',
              style: TextStyle(
                  fontSize: 24.0,
                  color: tanteLadenBackgroundWhite
              ),
            ),
          ),
        ),
      ),
    );
    return SafeArea(
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Container(),
            ),
            Flexible(
              flex: 2,
              child: Column(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Container()
                  ),
                  Flexible(
                    flex: 4,
                    child: ListView(
                      padding: EdgeInsets.all(20.0),
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container (
                              alignment: Alignment.centerLeft,
                              child: Text (
                                'Identifícate',
                                style: TextStyle (
                                  fontWeight: FontWeight.w900,
                                  fontSize: 36.0,
                                  fontFamily: 'SF Pro Display',
                                  fontStyle: FontStyle.normal,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.0,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text (
                                'Introduce tu email para continuar con tu pedido.',
                                style: TextStyle (
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.0,
                                  fontFamily: 'SF Pro Display',
                                  fontStyle: FontStyle.normal,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            )
                          ],
                        ),
                        SizedBox (height: 20.0,),
                        Form (
                          autovalidateMode: AutovalidateMode.always,
                          key: _formKey,
                          child: Column (
                            children: [
                              TextFormField(
                                controller: _email,
                                decoration: InputDecoration (
                                  labelText: 'Email',
                                  labelStyle: TextStyle (
                                    color: tanteLadenIconBrown,
                                  ),
                                  suffixIcon: IconButton (
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        _email.clear();
                                      }
                                  ),
                                ),
                                validator: (String? value) {
                                  Pattern pattern =
                                      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                      r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                      r"{0,253}[a-zA-Z0-9])?)*$";
                                  RegExp regexp = new RegExp(pattern.toString());
                                  if (!regexp.hasMatch(value ?? "") || value == null) {
                                    return 'Introduce un email válido';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              SizedBox(height: 40.0,),
                              _pleaseWait
                                  ? Stack(
                                    key:  ObjectKey("stack"),
                                    alignment: AlignmentDirectional.center,
                                    children: [tmpBuilder, _pleaseWaitWidget],
                                  )
                                  : Stack (key:  ObjectKey("stack"), children: [tmpBuilder],)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container()
                  )
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(),
            )
          ],
        )
    );
  }
}
