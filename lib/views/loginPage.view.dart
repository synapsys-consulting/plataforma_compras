import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/utils/pleaseWaitWidget.dart';
import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/utils/showSnackBar.dart';

class LoginPageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton (
          icon: Image.asset('assets/images/leftArrow.png'),
          onPressed: () {
            Navigator.pop (context);
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
        smallScreen: _SmallScreenView (),
        largeScreen: _LargeScreenView(),
      ),
    );
  }
}

class _SmallScreenView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
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
  }
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
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
              child: Form (
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
                      validator: (String value) {
                        Pattern pattern =
                            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                            r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                            r"{0,253}[a-zA-Z0-9])?)*$";
                        RegExp regexp = new RegExp(pattern);
                        if (!regexp.hasMatch(value) || value == null) {
                          return 'Introduce un email válido';
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: 40.0,),
                    Container(
                      child: GestureDetector (
                        onTap: () async {
                          if (_formKey.currentState.validate()) {
                            final Uri url = Uri.parse('$SERVER_IP/loginWithoutPass');
                            final http.Response res = await http.get (
                                url,
                                headers: <String, String>{
                                  'Content-Type': 'application/json; charset=UTF-8',
                                  //'Authorization': jwt
                                }
                            );
                            if (res.statusCode == 200) {
                              /// Sign in

                            } else if (res.statusCode == 404) {
                              /// Sign up
                            } else {
                              /// Error

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
                    ),
                  ],
                ),
              )
            )
          ],
        ),
      )
    );
  }
}

class _LargeScreenView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
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
  Widget build(BuildContext context) {
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
                  child: Form (
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
                            suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _email.clear();
                                }
                            ),
                          ),
                        ),
                        SizedBox(height: 40.0,),
                        Container(
                          child: GestureDetector (
                            onTap: () async {

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
                        ),
                      ],
                    ),
                  )
              )
            ],
          ),
        )
    );
  }
}
