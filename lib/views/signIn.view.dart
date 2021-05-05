import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plataforma_compras/views/addAddress.view.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/utils/pleaseWaitWidget.dart';
import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/utils/showSnackBar.dart';
import 'package:plataforma_compras/views/signUp.view.dart';
import 'package:plataforma_compras/views/address.view.dart';
import 'package:plataforma_compras/models/address.model.dart';
import 'package:plataforma_compras/utils/displayDialog.dart';
import 'package:plataforma_compras/models/cart.model.dart';
import 'package:plataforma_compras/models/catalog.model.dart';

class SigInView extends StatelessWidget {
  SigInView (this.email);
  final String email;
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
        smallScreen: _SmallScreenView (this.email),
        largeScreen: _LargeScreenView (this.email),
      ),
    );
  }
}

class _SmallScreenView extends StatefulWidget {
  _SmallScreenView(this.email);
  final String email;

  @override
  _SmallScreenViewState createState() {
    return _SmallScreenViewState();
  }
}
class _SmallScreenViewState extends State<_SmallScreenView> {
  bool _pleaseWait = false;
  bool _passwordNoVisible = true;
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  _showPleaseWait(bool b) {
    setState(() {
      _pleaseWait = b;
    });
  }
  @override
  void initState() {
    super.initState();
    _passwordNoVisible = true;
    _pleaseWait = false;
  }
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }
  badStatusCode(http.Response response) {
    debugPrint("Bad status code ${response.statusCode} returned from server.");
    debugPrint("Response body ${response.body} returned from server.");
    throw Exception(
        'Bad status code ${response.statusCode} returned from server.');
  }
  Future<String> _processPurchase(Cart cartPurchased) async {
    String message = '';
    try {
      final Uri url = Uri.parse('$SERVER_IP/savePurchasedProducts');
      final http.Response res = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'purchased_products': cartPurchased.items.map<Map<String, dynamic>>((e) {
              return {
                'product_id': e.productId,
                'product_name': e.productName,
                'product_description': e.productDescription,
                'product_type': e.productType,
                'brand': e.brand,
                'num_images': e.numImages,
                'num_videos': e.numVideos,
                'purchased': e.purchased,
                'product_price': e.productPrice,
                'persone_id': e.personeId,
                'persone_name': e.personeName,
                'tax_id': e.taxId,
                'tax_apply': e.taxApply
              };
            }).toList()
          })
      ).timeout(TIMEOUT);
      if (res.statusCode == 200) {
        message = json.decode(res.body)['data'];
        debugPrint('After returning.');
        debugPrint('The message is: ' + message);
      } else {
        // If that response was not OK, throw an error.
        debugPrint('There is an error.');
        badStatusCode(res);
      }
      return message;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build (BuildContext context) {
    final Widget tmpBuilder = Container(
      child: Consumer<Cart>(
        builder: (context, cart, child) {
          return GestureDetector (
            onTap: () async {
              debugPrint ('El valor de _email.text es: ' + widget.email);
              if (_formKey.currentState.validate()) {
                try {
                  _showPleaseWait(true);
                  final Uri url = Uri.parse('$SERVER_IP/login');
                  final http.Response res = await http.post (
                      url,
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                        //'Authorization': jwt
                      },
                      body: jsonEncode(<String, String>{
                        'user_name': widget.email,
                        'password': _password.text,
                        'gethash': 'true'
                      })
                  );
                  if (res.statusCode == 200) {
                    // Sign in
                    final String token = json.decode(res.body)['token'].toString();
                    final SharedPreferences prefs = await _prefs;
                    prefs.setString('token', token);
                    // See if there is an address for this user
                    Map<String, dynamic> payload;
                    payload = json.decode(
                        utf8.decode(
                            base64.decode(base64.normalize(token.split(".")[1]))
                        )
                    );
                    final Uri urlAddress = Uri.parse('$SERVER_IP/getDefaultLogisticAddress/' + payload['user_id'].toString());
                    final http.Response resAddress = await http.get (
                        urlAddress,
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                          //'Authorization': jwt
                        }
                    );
                    if (resAddress.statusCode == 200) {
                      // exists an address for the user
                      final List<Map<String, dynamic>> resultListJson = json.decode(resAddress.body)['data'].cast<Map<String, dynamic>>();
                      final List<Address> resultListAddress = resultListJson.map<Address>((json) => Address.fromJson(json)).toList();
                      if (resultListAddress.length > 0) {
                        // if exists address
                        var widgetImage = Image.asset ('assets/images/infoMessage.png');
                        final String messageInfo = "Vas a llevar a cabo la tramitación de tu compra.";
                        debugPrint('Before the displayDialogAcceptCancel');
                        final bool responseUser = await DisplayDialog.displayDialogConfirmCancel(context, widgetImage, 'Tramitar pedido', messageInfo);
                        debugPrint('After the displayDialogAcceptCancel');
                        if (responseUser) {
                          final String message = await _processPurchase(cart);
                          debugPrint ('the returned message is:' + message);
                          _showPleaseWait(false);
                          await DisplayDialog.displayDialog (context, widgetImage, 'Compra realizada', message);
                          cart.clearCart();
                          var catalog = context.read<Catalog>();
                          catalog.clearCatalog();
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        } else {
                          _showPleaseWait(false);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      } else {
                        // if not exists address
                        _showPleaseWait(false);
                        Navigator.push (
                            context,
                            MaterialPageRoute (
                                builder: (context) => (AddressView(personeId: payload['persone_id'].toString(),))
                            )
                        );
                      }
                    } else if (resAddress.statusCode == 404) {
                      // if not exists address
                      _showPleaseWait(false);
                      Navigator.push (
                          context,
                          MaterialPageRoute (
                              builder: (context) => (AddressView(personeId: payload['persone_id'].toString(),))
                          )
                      );
                    } else {
                      _showPleaseWait(false);
                      ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'].toString());
                    }
                  } else if (res.statusCode == 404) {
                    _showPleaseWait(false);
                    // Sign up
                    Navigator.push (
                        context,
                        MaterialPageRoute(
                            builder: (context) => (SignUpView(widget.email))
                        )
                    );
                  } else {
                    // Error
                    _showPleaseWait(false);
                    ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'].toString());
                  }
                } catch (e) {
                  _showPleaseWait(false);
                  ShowSnackBar.showSnackBar(context, e, error: true);
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
                  'Continuar',
                  style: TextStyle(
                      fontSize: 24.0,
                      color: tanteLadenBackgroundWhite
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
    return SafeArea(
        child: Center(
          child: ListView(
            padding: EdgeInsets.all(20.0),
            children: <Widget>[
              Row (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text (
                      'Hola de nuevo',
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
              Row (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container (
                    alignment: Alignment.centerLeft,
                    child: Text (
                      'Introduce tu contraseña.',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _password,
                      decoration: InputDecoration (
                        labelText: 'password',
                        labelStyle: TextStyle (
                          color: tanteLadenIconBrown,
                        ),
                        suffixIcon: IconButton (
                            icon: Icon(_passwordNoVisible ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _passwordNoVisible = ! _passwordNoVisible;
                              });
                            }
                        ),
                      ),
                      validator: (String value) {
                        if (value == null) {
                          return 'Introduce una password';
                        } else {
                          return null;
                        }
                      },
                      obscureText: _passwordNoVisible,
                    ),
                    SizedBox(height: 20.0,),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(0.0),
                      child: TextButton(
                        onPressed: null,
                        child: Text(
                          'No recuerdo mi contraseña',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                            color: tanteLadenButtonBorderGray
                          ),
                          textAlign: TextAlign.left,
                        )
                      ),
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
  _LargeScreenView(this.email);
  final String email;
  @override
  _LargeScreenViewState createState() {
    return _LargeScreenViewState();
  }
}
class _LargeScreenViewState extends State<_LargeScreenView> {
  bool _pleaseWait = false;
  bool _passwordNoVisible = true;
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  _showPleaseWait(bool b) {
    setState(() {
      _pleaseWait = b;
    });
  }
  @override
  void initState() {
    super.initState();
    _passwordNoVisible = true;
    _pleaseWait = false;
  }
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }
  badStatusCode(http.Response response) {
    debugPrint("Bad status code ${response.statusCode} returned from server.");
    debugPrint("Response body ${response.body} returned from server.");
    throw Exception(
        'Bad status code ${response.statusCode} returned from server.');
  }
  Future<String> _processPurchase(Cart cartPurchased) async {
    String message = '';
    try {
      final Uri url = Uri.parse('$SERVER_IP/savePurchasedProducts');
      final http.Response res = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'purchased_products': cartPurchased.items.map<Map<String, dynamic>>((e) {
              return {
                'product_id': e.productId,
                'product_name': e.productName,
                'product_description': e.productDescription,
                'product_type': e.productType,
                'brand': e.brand,
                'num_images': e.numImages,
                'num_videos': e.numVideos,
                'purchased': e.purchased,
                'product_price': e.productPrice,
                'persone_id': e.personeId,
                'persone_name': e.personeName,
                'tax_id': e.taxId,
                'tax_apply': e.taxApply
              };
            }).toList()
          })
      ).timeout(TIMEOUT);
      if (res.statusCode == 200) {
        message = json.decode(res.body)['data'];
        debugPrint('After returning.');
        debugPrint('The message is: ' + message);
      } else {
        // If that response was not OK, throw an error.
        debugPrint('There is an error.');
        badStatusCode(res);
      }
      return message;
    } catch (e) {
      throw Exception(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    final Widget tmpBuilder = Container(
      child: Consumer<Cart>(
          builder: (context, cart, child) {
            return GestureDetector (
              onTap: () async {
                debugPrint ('El valor de _email.text es: ' + widget.email);
                if (_formKey.currentState.validate()) {
                  try {
                    _showPleaseWait(true);
                    final Uri url = Uri.parse('$SERVER_IP/login');
                    final http.Response res = await http.post (
                        url,
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                          //'Authorization': jwt
                        },
                        body: jsonEncode(<String, String>{
                          'user_name': widget.email,
                          'password': _password.text,
                          'gethash': 'true'
                        })
                    );
                    if (res.statusCode == 200) {
                      // Sign in
                      final String token = json.decode(res.body)['token'].toString();
                      final SharedPreferences prefs = await _prefs;
                      prefs.setString('token', token);
                      // See if there is an address for this user
                      Map<String, dynamic> payload;
                      payload = json.decode(
                          utf8.decode(
                              base64.decode(base64.normalize(token.split(".")[1]))
                          )
                      );
                      final Uri urlAddress = Uri.parse('$SERVER_IP/getDefaultLogisticAddress/' + payload['user_id'].toString());
                      final http.Response resAddress = await http.get (
                          urlAddress,
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                            //'Authorization': jwt
                          }
                      );
                      if (resAddress.statusCode == 200) {
                        // exists an address for the user
                        final List<Map<String, dynamic>> resultListJson = json.decode(resAddress.body)['data'].cast<Map<String, dynamic>>();
                        final List<Address> resultListAddress = resultListJson.map<Address>((json) => Address.fromJson(json)).toList();
                        if (resultListAddress.length > 0) {
                          // if exists address
                          var widgetImage = Image.asset ('assets/images/infoMessage.png');
                          final String messageInfo = "Vas a llevar a cabo la tramitación de tu compra.";
                          debugPrint('Before the displayDialogAcceptCancel');
                          final bool responseUser = await DisplayDialog.displayDialogConfirmCancel(context, widgetImage, 'Tramitar pedido', messageInfo);
                          debugPrint('After the displayDialogAcceptCancel');
                          if (responseUser) {
                            final String message = await _processPurchase(cart);
                            debugPrint ('the returned message is:' + message);
                            _showPleaseWait(false);
                            await DisplayDialog.displayDialog (context, widgetImage, 'Compra realizada', message);
                            cart.clearCart();
                            var catalog = context.read<Catalog>();
                            catalog.clearCatalog();
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          } else {
                            _showPleaseWait(false);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        } else {
                          // if not exists address
                          _showPleaseWait(false);
                          //Navigator.push (
                          //    context,
                          //    MaterialPageRoute (
                          //        builder: (context) => (AddressView(personeId: payload['persone_id'].toString(),))
                          //    )
                          //);
                          Navigator.push (
                              context,
                              MaterialPageRoute (
                                  builder: (context) => (AddAddressView(personeId: payload['persone_id'].toString(),))
                              )
                          );
                        }
                      } else if (resAddress.statusCode == 404) {
                        // if not exists address
                        _showPleaseWait(false);
                        //Navigator.push (
                        //    context,
                        //    MaterialPageRoute (
                        //        builder: (context) => (AddressView(personeId: payload['persone_id'].toString(),))
                        //    )
                        //);
                        Navigator.push (
                            context,
                            MaterialPageRoute (
                                builder: (context) => (AddAddressView(personeId: payload['persone_id'].toString(),))
                            )
                        );
                      } else {
                        _showPleaseWait(false);
                        ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'].toString());
                      }
                    } else if (res.statusCode == 404) {
                      _showPleaseWait(false);
                      // Sign up
                      Navigator.push (
                          context,
                          MaterialPageRoute(
                              builder: (context) => (SignUpView(widget.email))
                          )
                      );
                    } else {
                      // Error
                      _showPleaseWait(false);
                      ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'].toString());
                    }
                  } catch (e) {
                    _showPleaseWait(false);
                    ShowSnackBar.showSnackBar(context, e, error: true);
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
                    'Continuar',
                    style: TextStyle(
                        fontSize: 24.0,
                        color: tanteLadenBackgroundWhite
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
    return SafeArea(
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Container()
            ),
            Flexible(
              flex: 2,
              child: Center(
                child: ListView(
                  padding: EdgeInsets.all(20.0),
                  children: <Widget>[
                    Row (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text (
                            'Hola de nuevo',
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
                    Row (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container (
                          alignment: Alignment.centerLeft,
                          child: Text (
                            'Introduce tu contraseña.',
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _password,
                            decoration: InputDecoration (
                              labelText: 'password',
                              labelStyle: TextStyle (
                                color: tanteLadenIconBrown,
                              ),
                              suffixIcon: IconButton (
                                  icon: Icon(_passwordNoVisible ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _passwordNoVisible = ! _passwordNoVisible;
                                    });
                                  }
                              ),
                            ),
                            validator: (String value) {
                              if (value == null) {
                                return 'Introduce una password';
                              } else {
                                return null;
                              }
                            },
                            obscureText: _passwordNoVisible,
                          ),
                          SizedBox(height: 20.0,),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(0.0),
                            child: TextButton(
                                onPressed: null,
                                child: Text(
                                  'No recuerdo mi contraseña',
                                  style: TextStyle(
                                      fontFamily: 'SF Pro Display',
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500,
                                      color: tanteLadenButtonBorderGray
                                  ),
                                  textAlign: TextAlign.left,
                                )
                            ),
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
              ),
            ),
            Flexible(
              flex: 1,
              child: Container()
            )
          ],
        )
    );
  }
}