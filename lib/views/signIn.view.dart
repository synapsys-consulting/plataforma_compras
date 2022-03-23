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
import 'package:plataforma_compras/models/address.model.dart';
import 'package:plataforma_compras/models/cart.model.dart';
import 'package:plataforma_compras/views/confirmPurchase.view.dart';
import 'package:plataforma_compras/models/productAvail.model.dart';
import 'package:plataforma_compras/models/catalog.model.dart';
import 'package:plataforma_compras/models/multiPricesProductAvail.model.dart';

class SigInView extends StatelessWidget {
  SigInView (this.email, this.reason);
  final String email;
  final int reason;   //  1 the call comes from the drawer. 2 the call comes from cart.view.dart
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
        smallScreen: _SmallScreenView (this.email, this.reason),
        largeScreen: _LargeScreenView (this.email, this.reason),
      ),
    );
  }
}

class _SmallScreenView extends StatefulWidget {
  _SmallScreenView(this.email, this.fromWhereCalledIs);
  final String email;
  final int fromWhereCalledIs;   //  1 the call comes from the drawer. 2 the call comes from cart.view.dart

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

  @override
  Widget build (BuildContext context) {
    final Widget tmpBuilder = Container(
      child: Consumer<Cart>(
        builder: (context, cart, child) {
          return GestureDetector (
            onTap: () async {
              debugPrint ('El valor de _email.text es: ' + widget.email);
              var catalog = context.read<Catalog>();
              if (_formKey.currentState.validate()) {
                try {
                  _showPleaseWait(true);
                  final Uri url = Uri.parse ('$SERVER_IP/login');
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
                    prefs.setString ('token', token);
                    // See if there is an address for this user
                    Map<String, dynamic> payload;
                    payload = json.decode(
                        utf8.decode(
                            base64.decode(base64.normalize(token.split(".")[1]))
                        )
                    );
                    debugPrint('El valor de partner_id es: ' + payload['partner_id'].toString());
                    // partner_id = 1 is the partner_id for the default partner,
                    // that is, without organization
                    if (payload['partner_id'] != DEFAULT_PARTNER_ID) {
                      // RELOAD THE PRODUCTS which THE USER CAN BUY
                      final Uri url = Uri.parse('$SERVER_IP/getProductsAvailWithPartnerId/' + payload['partner_id'].toString());
                      final http.Response resProducts = await http.get (
                          url,
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                            //'Authorization': jwt
                          }
                      );
                      debugPrint('After the http call.');
                      debugPrint('COMENTARIO INTRODUCIDO DE MANERA RECIENTE.');
                      if (resProducts.statusCode == 200) {
                        debugPrint ('The Rest API has responsed.');
                        final List<Map<String, dynamic>> resultListJson = json.decode(resProducts.body)['products'].cast<Map<String, dynamic>>();
                        debugPrint ('Entre medias de la api RESPONSE.');
                        final List<ProductAvail> resultListProducts = resultListJson.map<ProductAvail>((json) => ProductAvail.fromJson(json)).toList();
                        debugPrint ('Después de guardar los ProductAvail.');
                        final List<MultiPricesProductAvail> resultListMultiPriceProducts = [];
                        int tmpProductCategoryIdPrevious;
                        String tmpPersonNamePrevious;
                        resultListProducts.forEach((element) {
                          //debugPrint ('El producto que cargo es: ' + element.productName);
                          //debugPrint ('El producto_code que cargo es: ' + element.productCode.toString());
                          if (element.productCategoryId != tmpProductCategoryIdPrevious && element.personeName != tmpPersonNamePrevious && element.rn == 1) {
                            // Change the productCategoryId and the rn = 1, so start a new MultiPriceProductAvail
                            debugPrint ('El product_description retornado desde el API es: ' + element.productName);
                            tmpProductCategoryIdPrevious = element.productCategoryId;
                            tmpPersonNamePrevious = element.personeName;
                            final item = new MultiPricesProductAvail(
                                productId: element.productId,
                                productCode: element.productCode,
                                productName: element.productName,
                                productNameLong: element.productNameLong,
                                productDescription: element.productDescription,
                                productType: element.productType,
                                brand: element.brand,
                                numImages: element.numImages,
                                numVideos: element.numVideos,
                                purchased: element.purchased,
                                productPrice: element.productPrice,
                                totalBeforeDiscount: element.totalBeforeDiscount,
                                taxAmount: element.taxAmount,
                                personeId: element.personeId,
                                personeName: element.personeName,
                                businessName: element.businessName,
                                email: element.email,
                                taxId: element.taxId,
                                taxApply: element.taxApply,
                                productPriceDiscounted: element.productPriceDiscounted,
                                totalAmount: element.totalAmount,
                                discountAmount: element.discountAmount,
                                idUnit: element.idUnit,
                                remark: element.remark,
                                minQuantitySell: element.minQuantitySell,
                                partnerId: element.partnerId,
                                partnerName: element.partnerName,
                                quantityMinPrice: element.quantityMinPrice,
                                quantityMaxPrice: element.quantityMaxPrice,
                                productCategoryId: element.productCategoryId,
                                rn: element.rn
                            );
                            resultListMultiPriceProducts.add(item);
                          } else if (element.productCategoryId == tmpProductCategoryIdPrevious && element.personeName == tmpPersonNamePrevious && element.rn > 1) {
                            // The same ProductCategoryId and the same PersoneName, so it is another price of the same MultiPriceProductAvail
                            tmpProductCategoryIdPrevious = element.productCategoryId;
                            tmpPersonNamePrevious = element.personeName;
                            resultListMultiPriceProducts.last.add(element);
                          } else {
                            // We consider tis case imposible, but if it is, we consider it as a new MultiPriceProductAvail
                            tmpProductCategoryIdPrevious = element.productCategoryId;
                            tmpPersonNamePrevious = element.personeName;
                            final item = new MultiPricesProductAvail(
                                productId: element.productId,
                                productCode: element.productCode,
                                productName: element.productName,
                                productNameLong: element.productNameLong,
                                productDescription: element.productDescription,
                                productType: element.productType,
                                brand: element.brand,
                                numImages: element.numImages,
                                numVideos: element.numVideos,
                                purchased: element.purchased,
                                productPrice: element.productPrice,
                                totalBeforeDiscount: element.totalBeforeDiscount,
                                taxAmount: element.taxAmount,
                                personeId: element.personeId,
                                personeName: element.personeName,
                                businessName: element.businessName,
                                email: element.email,
                                taxId: element.taxId,
                                taxApply: element.taxApply,
                                productPriceDiscounted: element.productPriceDiscounted,
                                totalAmount: element.totalAmount,
                                discountAmount: element.discountAmount,
                                idUnit: element.idUnit,
                                remark: element.remark,
                                minQuantitySell: element.minQuantitySell,
                                partnerId: element.partnerId,
                                partnerName: element.partnerName,
                                quantityMinPrice: element.quantityMinPrice,
                                quantityMaxPrice: element.quantityMaxPrice,
                                productCategoryId: element.productCategoryId,
                                rn: element.rn
                            );
                            resultListMultiPriceProducts.add(item);
                          }
                        });
                        debugPrint ('Entre medias de la api RESPONSE.');
                        cart.removeCart();
                        catalog.removeCatalog();
                        resultListMultiPriceProducts.forEach((element) {
                          catalog.add(element);
                        });
                        debugPrint ('Antes de terminar de responder la API.');
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                      }
                    } else {
                      if (widget.fromWhereCalledIs == COME_FROM_ANOTHER) {
                        // COME_FROM_ANOTHER = 2
                        // COME_FROM_DRAWER = 1
                        //  1 the call comes from the drawer. 2 the call comes from cart.view.dart
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
                            _showPleaseWait(false);
                            Navigator.push (
                                context,
                                MaterialPageRoute (
                                    builder: (context) => (ConfirmPurchaseView(resultListAddress, payload['phone_number'].toString(), payload['user_id'].toString()))
                                )
                            );
                          } else {
                            // if not exists address
                            _showPleaseWait(false);
                            Navigator.push (
                                context,
                                MaterialPageRoute (
                                    builder: (context) => (AddAddressView(payload['persone_id'].toString(), payload['user_id'].toString()))
                                )
                            );
                          }
                        } else if (resAddress.statusCode == 404) {
                          // if not exists address
                          _showPleaseWait(false);
                          Navigator.push (
                              context,
                              MaterialPageRoute (
                                  builder: (context) => (AddAddressView(payload['persone_id'].toString(), payload['user_id'].toString()))
                              )
                          );
                        } else {
                          _showPleaseWait(false);
                          ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'].toString());
                        }
                      } else {
                        // 1 the call comes from the drawer. 2 the call comes from cart.view.dart
                        // The call comes from the drawer.
                        // const COME_FROM_ANOTHER = 2
                        // const COME_FROM_DRAWER = 1
                        Navigator.popUntil(context, ModalRoute.withName('/'));  // come from the drawer
                      }
                    }
                  } else if (res.statusCode == 404) {
                    // User doesn't exists in the system
                    _showPleaseWait(false);
                    // Sign up
                    Navigator.push (
                        context,
                        MaterialPageRoute(
                            builder: (context) => (SignUpView(widget.email, widget.fromWhereCalledIs))
                        )
                    );
                  } else if (res.statusCode == 403) {
                    // User doesn't exist in the system
                    _showPleaseWait(false);
                    // Sign up
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            (SignUpView(
                                widget.email, widget.fromWhereCalledIs))
                        )
                    );
                  } else if (res.statusCode == 402) {
                    // Password is not right
                    _showPleaseWait(false);
                    ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'].toString());
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
  _LargeScreenView(this.email, this.fromWhereCalledIs);
  final String email;
  final int fromWhereCalledIs;   //  1 the call comes from the drawer. 2 the call comes from cart.view.dart
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
  @override
  Widget build(BuildContext context) {
    final Widget tmpBuilder = Container(
      child: Consumer<Cart>(
          builder: (context, cart, child) {
            return GestureDetector (
              onTap: () async {
                debugPrint ('El valor de _email.text es: ' + widget.email);
                var catalog = context.read<Catalog>();
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
                      // partner_id = 1 is the partner_id for the default partner,
                      // that is, without organization
                      if (payload['partner_id'] != DEFAULT_PARTNER_ID) {
                        // RELOAD THE PRODUCTS which THE USER CAN BUY
                        final Uri url = Uri.parse('$SERVER_IP/getProductsAvailWithPartnerId/' + payload['partner_id'].toString());
                        final http.Response resProducts = await http.get (
                            url,
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                              //'Authorization': jwt
                            }
                        );
                        debugPrint('After the http call.');
                        if (resProducts.statusCode == 200) {
                          debugPrint ('The Rest API has responsed.');
                          final List<Map<String, dynamic>> resultListJson = json.decode(resProducts.body)['products'].cast<Map<String, dynamic>>();
                          debugPrint ('Entre medias de la api RESPONSE.');
                          final List<ProductAvail> resultListProducts = resultListJson.map<ProductAvail>((json) => ProductAvail.fromJson(json)).toList();
                          final List<MultiPricesProductAvail> resultListMultiPriceProducts = [];
                          int tmpProductCategoryIdPrevious;
                          String tmpPersonNamePrevious;
                          resultListProducts.forEach((element) {
                            if (element.productCategoryId != tmpProductCategoryIdPrevious && element.personeName != tmpPersonNamePrevious && element.rn == 1) {
                              // Change the productCategoryId and the rn = 1, so start a new MultiPriceProductAvail
                              debugPrint ('El product_description retornado desde el API es: ' + element.productName);
                              tmpProductCategoryIdPrevious = element.productCategoryId;
                              tmpPersonNamePrevious = element.personeName;
                              final item = new MultiPricesProductAvail(
                                  productId: element.productId,
                                  productCode: element.productCode,
                                  productName: element.productName,
                                  productNameLong: element.productNameLong,
                                  productDescription: element.productDescription,
                                  productType: element.productType,
                                  brand: element.brand,
                                  numImages: element.numImages,
                                  numVideos: element.numVideos,
                                  purchased: element.purchased,
                                  productPrice: element.productPrice,
                                  totalBeforeDiscount: element.totalBeforeDiscount,
                                  taxAmount: element.taxAmount,
                                  personeId: element.personeId,
                                  personeName: element.personeName,
                                  businessName: element.businessName,
                                  email: element.email,
                                  taxId: element.taxId,
                                  taxApply: element.taxApply,
                                  productPriceDiscounted: element.productPriceDiscounted,
                                  totalAmount: element.totalAmount,
                                  discountAmount: element.discountAmount,
                                  idUnit: element.idUnit,
                                  remark: element.remark,
                                  minQuantitySell: element.minQuantitySell,
                                  partnerId: element.partnerId,
                                  partnerName: element.partnerName,
                                  quantityMinPrice: element.quantityMinPrice,
                                  quantityMaxPrice: element.quantityMaxPrice,
                                  productCategoryId: element.productCategoryId,
                                  rn: element.rn
                              );
                              resultListMultiPriceProducts.add(item);
                            } else if (element.productCategoryId == tmpProductCategoryIdPrevious && element.personeName == tmpPersonNamePrevious && element.rn > 1) {
                              // The same ProductCategoryId and the same PersoneName, so it is another price of the same MultiPriceProductAvail
                              tmpProductCategoryIdPrevious = element.productCategoryId;
                              tmpPersonNamePrevious = element.personeName;
                              resultListMultiPriceProducts.last.add(element);
                            } else {
                              // We consider this case impossible, but if it is, we consider it as a new MultiPriceProductAvail
                              tmpProductCategoryIdPrevious = element.productCategoryId;
                              tmpPersonNamePrevious = element.personeName;
                              final item = new MultiPricesProductAvail(
                                  productId: element.productId,
                                  productCode: element.productCode,
                                  productName: element.productName,
                                  productNameLong: element.productNameLong,
                                  productDescription: element.productDescription,
                                  productType: element.productType,
                                  brand: element.brand,
                                  numImages: element.numImages,
                                  numVideos: element.numVideos,
                                  purchased: element.purchased,
                                  productPrice: element.productPrice,
                                  totalBeforeDiscount: element.totalBeforeDiscount,
                                  taxAmount: element.taxAmount,
                                  personeId: element.personeId,
                                  personeName: element.personeName,
                                  businessName: element.businessName,
                                  email: element.email,
                                  taxId: element.taxId,
                                  taxApply: element.taxApply,
                                  productPriceDiscounted: element.productPriceDiscounted,
                                  totalAmount: element.totalAmount,
                                  discountAmount: element.discountAmount,
                                  idUnit: element.idUnit,
                                  remark: element.remark,
                                  minQuantitySell: element.minQuantitySell,
                                  partnerId: element.partnerId,
                                  partnerName: element.partnerName,
                                  quantityMinPrice: element.quantityMinPrice,
                                  quantityMaxPrice: element.quantityMaxPrice,
                                  productCategoryId: element.productCategoryId,
                                  rn: element.rn
                              );
                              resultListMultiPriceProducts.add(item);
                            }
                          });
                          debugPrint ('Entre medias de la api RESPONSE.');
                          cart.removeCart();
                          catalog.removeCatalog();
                          resultListMultiPriceProducts.forEach((element) {
                            catalog.add(element);
                          });
                          debugPrint ('Antes de terminar de responder la API.');
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                        }
                      } else {
                        if (widget.fromWhereCalledIs == COME_FROM_ANOTHER) {
                          // COME_FROM_ANOTHER = 2
                          // COME_FROM_DRAWER = 1
                          //  1 the call comes from the drawer. 2 the call comes from cart.view.dart
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
                              _showPleaseWait(false);
                              Navigator.push (
                                  context,
                                  MaterialPageRoute (
                                      builder: (context) => (ConfirmPurchaseView(resultListAddress, payload['phone_number'].toString(), payload['user_id'].toString()))
                                  )
                              );
                            } else {
                              // if not exists address
                              _showPleaseWait(false);
                              Navigator.push (
                                  context,
                                  MaterialPageRoute (
                                      builder: (context) => (AddAddressView(payload['persone_id'].toString(), payload['user_id'].toString()))
                                  )
                              );
                            }
                          } else if (resAddress.statusCode == 404) {
                            // if not exists address
                            _showPleaseWait(false);
                            Navigator.push (
                                context,
                                MaterialPageRoute (
                                    builder: (context) => (AddAddressView(payload['persone_id'].toString(), payload['user_id'].toString()))
                                )
                            );
                          } else {
                            _showPleaseWait(false);
                            ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'].toString());
                          }
                        } else {
                          // 1 the call comes from the drawer. 2 the call comes from cart.view.dart
                          // The call comes from the drawer.
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                        }
                      }
                    } else if (res.statusCode == 404) {
                      // User doesn't exists in the system
                      _showPleaseWait(false);
                      // Sign up
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              (SignUpView(
                                  widget.email, widget.fromWhereCalledIs))
                          )
                      );
                    } else if (res.statusCode == 403) {
                      // User doesn't exist in the system
                      _showPleaseWait(false);
                      // Sign up
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              (SignUpView(
                                  widget.email, widget.fromWhereCalledIs))
                          )
                      );
                    } else if (res.statusCode == 402) {
                      // Password is not right
                      _showPleaseWait(false);
                      ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'].toString());
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
                  Flexible(
                    flex: 1,
                    child: Container()
                  )
                ],
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