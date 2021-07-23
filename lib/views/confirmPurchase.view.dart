import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat hide TextDirection;
import 'package:plataforma_compras/models/productAvail.model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/utils/pleaseWaitWidget.dart';
import 'package:plataforma_compras/models/address.model.dart';
import 'package:plataforma_compras/utils/displayDialog.dart';
import 'package:plataforma_compras/models/cart.model.dart';
import 'package:plataforma_compras/utils/showSnackBar.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/models/catalog.model.dart';
import 'package:plataforma_compras/views/addPhone.view.dart';

class ConfirmPurchaseView extends StatelessWidget {
  ConfirmPurchaseView(this.resultListAddress, this.phoneNumber, this.userId);
  final List<Address> resultListAddress;
  final String phoneNumber;
  final String userId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
        elevation: 0.0,
        leading: IconButton (
            icon: Image.asset('assets/images/leftArrow.png'),
            onPressed: () {
              Navigator.pop(context);
            }
        ),
        title: Text (
          'Confirmar pedido',
          style: TextStyle (
              fontFamily: 'SF Pro Display',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: tanteLadenIconBrown
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: ResponsiveWidget(
        smallScreen: _SmallScreenView (resultListAddress, phoneNumber, userId),
        largeScreen: _LargeScreenView (resultListAddress, phoneNumber, userId),
      ),
    );
  }
}
class _SmallScreenView extends StatefulWidget {
  _SmallScreenView(this.resultListAddress, this.phoneNumber, this.userId);
  final List<Address> resultListAddress;
  final String phoneNumber;
  final String userId;
  @override
  _SmallScreenViewState createState() => _SmallScreenViewState();
}
class _SmallScreenViewState extends State<_SmallScreenView> {
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));
  bool _pleaseWait;
  String _phoneNumber;

  _badStatusCode(http.Response response) {
    debugPrint("Bad status code ${response.statusCode} returned from server.");
    debugPrint("Response body ${response.body} returned from server.");
    throw Exception(
        'Bad status code ${response.statusCode} returned from server.');
  }
  _showPleaseWait(bool b) {
    setState(() {
      _pleaseWait = b;
    });
  }
  Future<String> _processPurchase (Cart cartPurchased) async {
    String message = '';
    try {
      final List<ProductAvail> productAvailListToSave = [];
      cartPurchased.items.forEach((element) {
        if (element.getIndexElementAmongQuantity() == -1) {
          final item = new ProductAvail(
              productId: element.productId,
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
          productAvailListToSave.add(item);
        } else {
          var index = element.getIndexElementAmongQuantity();
          final item = new ProductAvail(
              productId: element.items[index].productId,
              productName: element.items[index].productName,
              productNameLong: element.items[index].productNameLong,
              productDescription: element.items[index].productDescription,
              productType: element.items[index].productType,
              brand: element.items[index].brand,
              numImages: element.items[index].numImages,
              numVideos: element.items[index].numVideos,
              purchased: element.purchased,   // The quantity purchased is in the father product field
              productPrice: element.items[index].productPrice,
              totalBeforeDiscount: element.items[index].totalBeforeDiscount,
              taxAmount: element.items[index].taxAmount,
              personeId: element.items[index].personeId,
              personeName: element.items[index].personeName,
              businessName: element.items[index].businessName,
              email: element.items[index].email,
              taxId: element.items[index].taxId,
              taxApply: element.items[index].taxApply,
              productPriceDiscounted: element.items[index].productPriceDiscounted,
              totalAmount: element.items[index].totalAmount,
              discountAmount: element.items[index].discountAmount,
              idUnit: element.items[index].idUnit,
              remark: element.items[index].remark,
              minQuantitySell: element.items[index].minQuantitySell,
              partnerId: element.items[index].partnerId,
              partnerName: element.items[index].partnerName,
              quantityMinPrice: element.items[index].quantityMinPrice,
              quantityMaxPrice: element.items[index].quantityMaxPrice,
              productCategoryId: element.items[index].productCategoryId,
              rn: element.items[index].rn
          );
          productAvailListToSave.add(item);
        }
      });
      final Uri url = Uri.parse('$SERVER_IP/savePurchasedProducts');
      final http.Response res = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'purchased_products': productAvailListToSave.map<Map<String, dynamic>>((e) {
              return {
                'product_id': e.productId,
                'product_name': e.productName,
                'product_name_long': e.productNameLong,
                'product_description': e.productDescription,
                'product_type': e.productType,
                'brand': e.brand,
                'num_images': e.numImages,
                'num_videos': e.numVideos,
                'purchased': e.purchased,
                'product_price': e.productPrice,
                'total_before_discount': e.totalBeforeDiscount,
                'total_amount': e.totalAmount,
                'discount_amount': e.discountAmount,
                'tax_amount': e.taxAmount,
                'persone_id': e.personeId,
                'persone_name': e.personeName,
                'email': e.email,
                'tax_id': e.taxId,
                'tax_apply': e.taxApply,
                'partner_id': e.partnerId,
                'partner_name': e.partnerName
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
        _badStatusCode(res);
      }
      return message;
    } catch (e) {
      throw Exception(e);
    }
  }
  @override
  void initState() {
    super.initState();
    _pleaseWait = false;
    _phoneNumber = widget.phoneNumber;
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build (BuildContext context) {
    var cart = context.read<Cart>();
    final Widget tmpBuilder = GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 80.0),
        alignment: Alignment.center,
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
            )
        ),
        child: const Text(
          'Tramitar pedido',
          style: TextStyle(
              fontSize: 24.0,
              color: tanteLadenBackgroundWhite
          ),
        ),
        height: 64.0,
      ),
      onTap: () async {
        try {
          debugPrint ('Comienzo el tramitar pedido');
          _showPleaseWait(true);
          final String message = await _processPurchase(cart);
          _showPleaseWait(false);
          var widgetImage = Image.asset ('assets/images/infoMessage.png');
          await DisplayDialog.displayDialog (context, widgetImage, 'Compra realizada', message);
          cart.removeCart();
          var catalog = context.read<Catalog>();
          catalog.clearCatalog();
          Navigator.popUntil(context, ModalRoute.withName('/'));
        } catch (e) {
          debugPrint ('Me he ido por el error en el Tramitar pedido');
          _showPleaseWait(false);
          ShowSnackBar.showSnackBar(context, e.toString(), error: true);
        }
      },
    );
    return SafeArea (
      child: ListView (
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        children: <Widget> [
          SizedBox(height: 10.0),
          Card(
            elevation: 8.0,
            child: ListTile (
              leading: IconButton(
                icon: Image.asset('assets/images/logoDelibery.png'),
                onPressed: null,
              ),
              title: Text (
                'Entrega',
                style: TextStyle (
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  fontFamily: 'SF Pro Display',
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
              ),
              subtitle: Container(
                padding: EdgeInsets.all(0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.resultListAddress[0].streetName + ', ' + widget.resultListAddress[0].streetNumber,
                      style: TextStyle (
                        fontWeight: FontWeight.w300,
                        fontSize: 16.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      widget.resultListAddress[0].flatDoor,
                      style: TextStyle (
                        fontWeight: FontWeight.w300,
                        fontSize: 16.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      widget.resultListAddress[0].postalCode + ' ' + widget.resultListAddress[0].locality,
                      style: TextStyle (
                        fontWeight: FontWeight.w300,
                        fontSize: 16.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      widget.resultListAddress[0].optional,
                      style: TextStyle (
                        fontWeight: FontWeight.w300,
                        fontSize: 16.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              )
            ),
          ),
          SizedBox(height: 5.0,),
          Card(
            elevation: 8.0,
            child: ListTile (
              leading: IconButton(
                icon: Image.asset('assets/images/logoPhone.png'),
                onPressed: null,
              ),
              title: ((widget.phoneNumber ?? '') == 'null') ?   // Come 'null' from shared_preferences and from backend if there no is a value
              Text(
                'Añadir teléfono',
                style: TextStyle (
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  fontFamily: 'SF Pro Display',
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
              ) :
              Text(
                'Teléfono',
                style: TextStyle (
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  fontFamily: 'SF Pro Display',
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
              ),
              subtitle: ((_phoneNumber ?? '') == 'null') ?  // Come 'null' from shared_preferences and from backend if there no is a value
              Text(
                '',
                style: TextStyle (
                  fontWeight: FontWeight.w300,
                  fontSize: 16.0,
                  fontFamily: 'SF Pro Display',
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
              ):
              Text(
                _phoneNumber ?? '',
                style: TextStyle (
                  fontWeight: FontWeight.w300,
                  fontSize: 16.0,
                  fontFamily: 'SF Pro Display',
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
              ),
              trailing: ((_phoneNumber ?? '') == 'null') ?  // Come 'null' from shared_preferences and from backend if there no is a value
              IconButton (
                icon: Image.asset('assets/images/logoPlus.png'),
                onPressed: () async {
                  var retorno = await Navigator.push (
                      context,
                      MaterialPageRoute (
                          builder: (context) => (AddPhone(_phoneNumber, widget.userId))
                      )
                  );
                  setState(() {
                    _phoneNumber = retorno;
                  });
                },
              ) :
              TextButton(
                child: Text(
                  'Editar',
                  style: TextStyle (
                    fontWeight: FontWeight.w500,
                    fontSize: 20.0,
                    fontFamily: 'SF Pro Display',
                    fontStyle: FontStyle.normal,
                    color: Colors.brown,
                  ),
                ),
                onPressed: () async {
                  var retorno = await Navigator.push (
                      context,
                      MaterialPageRoute (
                          builder: (context) => (AddPhone(widget.phoneNumber, widget.userId))
                      )
                  );
                  setState(() {
                    _phoneNumber = retorno;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 5.0,),
          Card(
            elevation: 8.0,
            child: ListTile(
              leading: IconButton(
                icon: Image.asset('assets/images/logoPaymentMethod.png'),
                onPressed: null,
              ),
              title: Text(
                'Forma de pago',
                style: TextStyle (
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  fontFamily: 'SF Pro Display',
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                'Diferido',
                style: TextStyle (
                  fontWeight: FontWeight.w300,
                  fontSize: 16.0,
                  fontFamily: 'SF Pro Display',
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Text (
                      'Total aproximado ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: tanteLadenOnPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Image.asset('assets/images/logoInfo.png'),
                      iconSize: 6.0,
                      onPressed: () {
                        var widgetImage = Image.asset('assets/images/weightMessage.png');
                        var message = 'En los productos al peso, el importe se ajustará a la cantidad servida. El cobro del importe final se realizará tras la presentación de tu pedido.';
                        DisplayDialog.displayDialog (context, widgetImage, 'Total aproximado', message);
                      },
                    )
                  ],
                )
              ),
              Expanded(
                flex: 1,
                child: Text(
                  new NumberFormat.currency(locale:'es_ES', symbol: '€', decimalDigits:2).format((cart.totalPrice/MULTIPLYING_FACTOR)),
                  style: TextStyle (
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    fontFamily: 'SF Pro Display',
                    fontStyle: FontStyle.normal,
                    color: tanteLadenOnPrimary,
                  ),
                  textAlign: TextAlign.right,
                )
              )
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                    children: [
                      Text(
                        'IVA incluido ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  )
              ),
              Expanded(
                flex: 1,
                child: Text(
                  new NumberFormat.currency(locale:'es_ES', symbol: '€', decimalDigits:2).format((cart.totalTax/MULTIPLYING_FACTOR)),
                  style: TextStyle (
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    fontFamily: 'SF Pro Display',
                    fontStyle: FontStyle.normal,
                    color: Colors.black45,
                  ),
                  textAlign: TextAlign.right,
                )
              )
            ],
          ),
          SizedBox(height: 60.0,),
          _pleaseWait ?
          Stack (
            key:  ObjectKey("stack"),
            alignment: AlignmentDirectional.center,
            children: [tmpBuilder, _pleaseWaitWidget],
          ) :
          Stack (key:  ObjectKey("stack"), children: [tmpBuilder],)
        ],
      )
    );
  }
}
class _LargeScreenView extends StatefulWidget {
  _LargeScreenView(this.resultListAddress, this.phoneNumber, this.userId);
  final List<Address> resultListAddress;
  final String phoneNumber;
  final String userId;
  @override
  _LargeScreenViewState createState() => _LargeScreenViewState();
}

class _LargeScreenViewState extends State<_LargeScreenView> {
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));
  bool _pleaseWait;
  String _phoneNumber;

  _badStatusCode(http.Response response) {
    debugPrint("Bad status code ${response.statusCode} returned from server.");
    debugPrint("Response body ${response.body} returned from server.");
    throw Exception(
        'Bad status code ${response.statusCode} returned from server.');
  }
  _showPleaseWait(bool b) {
    setState(() {
      _pleaseWait = b;
    });
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
                'product_name_long': e.productNameLong,
                'product_description': e.productDescription,
                'product_type': e.productType,
                'brand': e.brand,
                'num_images': e.numImages,
                'num_videos': e.numVideos,
                'purchased': e.purchased,
                'product_price': e.productPrice,
                'total_before_discount': e.totalBeforeDiscount,
                'total_amount': e.totalAmount,
                'discount_amount': e.discountAmount,
                'tax_amount': e.taxAmount,
                'persone_id': e.personeId,
                'persone_name': e.personeName,
                'email': e.email,
                'tax_id': e.taxId,
                'tax_apply': e.taxApply,
                'partner_id': e.partnerId,
                'partner_name': e.partnerName
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
        _badStatusCode(res);
      }
      return message;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _pleaseWait = false;
    _phoneNumber = widget.phoneNumber;
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var cart = context.read<Cart>();
    final Widget tmpBuilder = GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 80.0),
        alignment: Alignment.center,
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
            )
        ),
        child: const Text(
          'Tramitar pedido',
          style: TextStyle(
              fontSize: 24.0,
              color: tanteLadenBackgroundWhite
          ),
        ),
        height: 64.0,
      ),
      onTap: () async {
        try {
          debugPrint ('Comienzo el tramitar pedido');
          _showPleaseWait(true);
          final String message = await _processPurchase(cart);
          _showPleaseWait(false);
          var widgetImage = Image.asset ('assets/images/infoMessage.png');
          await DisplayDialog.displayDialog (context, widgetImage, 'Compra realizada', message);
          cart.removeCart();
          var catalog = context.read<Catalog>();
          catalog.clearCatalog();
          Navigator.popUntil(context, ModalRoute.withName('/'));
        } catch (e) {
          _showPleaseWait(false);
          ShowSnackBar.showSnackBar(context, e.toString(), error: true);
        }
      },
    );
    return SafeArea (
      child: Row (
        children: [
          Flexible(
            flex: 1,
            child: Container ()
          ),
          Flexible(
            flex: 2,
            child: ListView (
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              children: <Widget> [
                SizedBox(height: 10.0),
                Card(
                  elevation: 8.0,
                  child: ListTile (
                      leading: IconButton(
                        icon: Image.asset('assets/images/logoDelibery.png'),
                        onPressed: null,
                      ),
                      title: Text (
                        'Entrega',
                        style: TextStyle (
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Container(
                        padding: EdgeInsets.all(0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.resultListAddress[0].streetName + ', ' + widget.resultListAddress[0].streetNumber,
                              style: TextStyle (
                                fontWeight: FontWeight.w300,
                                fontSize: 16.0,
                                fontFamily: 'SF Pro Display',
                                fontStyle: FontStyle.normal,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              widget.resultListAddress[0].flatDoor,
                              style: TextStyle (
                                fontWeight: FontWeight.w300,
                                fontSize: 16.0,
                                fontFamily: 'SF Pro Display',
                                fontStyle: FontStyle.normal,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              widget.resultListAddress[0].postalCode + ' ' + widget.resultListAddress[0].locality,
                              style: TextStyle (
                                fontWeight: FontWeight.w300,
                                fontSize: 16.0,
                                fontFamily: 'SF Pro Display',
                                fontStyle: FontStyle.normal,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              widget.resultListAddress[0].optional,
                              style: TextStyle (
                                fontWeight: FontWeight.w300,
                                fontSize: 16.0,
                                fontFamily: 'SF Pro Display',
                                fontStyle: FontStyle.normal,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                ),
                SizedBox(height: 5.0,),
                Card(
                  elevation: 8.0,
                  child: ListTile (
                    leading: IconButton(
                      icon: Image.asset('assets/images/logoPhone.png'),
                      onPressed: null,
                    ),
                    title: ((_phoneNumber ?? '') == 'null') ?   // Come 'null' from shared_preferences and from backend if there no is a value
                    Text(
                      'Añadir teléfono',
                      style: TextStyle (
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                    ) :
                    Text(
                      'Teléfono',
                      style: TextStyle (
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: ((_phoneNumber ?? '') == 'null') ?  // Come 'null' from shared_preferences and from backend if there no is a value
                    Text(
                      '',
                      style: TextStyle (
                        fontWeight: FontWeight.w300,
                        fontSize: 16.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                    ):
                    Text(
                      _phoneNumber ?? '',
                      style: TextStyle (
                        fontWeight: FontWeight.w300,
                        fontSize: 16.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                    ),
                    trailing: ((_phoneNumber ?? '') == 'null') ?  // Come 'null' from shared_preferences and from backend if there no is a value
                    IconButton (
                      icon: Image.asset('assets/images/logoPlus.png'),
                      onPressed: () async {
                        var retorno = await Navigator.push (
                            context,
                            MaterialPageRoute (
                                builder: (context) => (AddPhone(_phoneNumber, widget.userId))
                            )
                        );
                        setState(() {
                          _phoneNumber = retorno;
                        });
                      },
                    ) :
                    TextButton(
                      child: Text(
                        'Editar',
                        style: TextStyle (
                          fontWeight: FontWeight.w500,
                          fontSize: 20.0,
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          color: Colors.brown,
                        ),
                      ),
                      onPressed: () async {
                        var retorno = await Navigator.push (
                            context,
                            MaterialPageRoute (
                                builder: (context) => (AddPhone(_phoneNumber, widget.userId))
                            )
                        );
                        setState(() {
                          _phoneNumber = retorno;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 5.0,),
                Card(
                  elevation: 8.0,
                  child: ListTile(
                    leading: IconButton(
                      icon: Image.asset('assets/images/logoPaymentMethod.png'),
                      onPressed: null,
                    ),
                    title: Text(
                      'Forma de pago',
                      style: TextStyle (
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      'Diferido',
                      style: TextStyle (
                        fontWeight: FontWeight.w300,
                        fontSize: 16.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0,),
                Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Text (
                              'Total aproximado ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                fontFamily: 'SF Pro Display',
                                fontStyle: FontStyle.normal,
                                color: tanteLadenOnPrimary,
                              ),
                            ),
                            IconButton(
                              icon: Image.asset('assets/images/logoInfo.png'),
                              iconSize: 6.0,
                              onPressed: () {
                                var widgetImage = Image.asset('assets/images/weightMessage.png');
                                var message = 'En los productos al peso, el importe se ajustará a la cantidad servida. El cobro del importe final se realizará tras la presentación de tu pedido.';
                                DisplayDialog.displayDialog (context, widgetImage, 'Total aproximado', message);
                              },
                            )
                          ],
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Text(
                          new NumberFormat.currency(locale:'es_ES', symbol: '€', decimalDigits:2).format((cart.totalPrice/MULTIPLYING_FACTOR)),
                          style: TextStyle (
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            fontFamily: 'SF Pro Display',
                            fontStyle: FontStyle.normal,
                            color: tanteLadenOnPrimary,
                          ),
                          textAlign: TextAlign.right,
                        )
                    )
                  ],
                ),
                SizedBox(height: 5.0,),
                Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Text(
                              'IVA incluido ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                fontFamily: 'SF Pro Display',
                                fontStyle: FontStyle.normal,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Text(
                          new NumberFormat.currency(locale:'es_ES', symbol: '€', decimalDigits:2).format((cart.totalTax/MULTIPLYING_FACTOR)),
                          style: TextStyle (
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            fontFamily: 'SF Pro Display',
                            fontStyle: FontStyle.normal,
                            color: Colors.black45,
                          ),
                          textAlign: TextAlign.right,
                        )
                    )
                  ],
                ),
                SizedBox(height: 60.0,),
                _pleaseWait ?
                Stack (
                  key:  ObjectKey("stack"),
                  alignment: AlignmentDirectional.center,
                  children: [tmpBuilder, _pleaseWaitWidget],
                ) :
                Stack (key:  ObjectKey("stack"), children: [tmpBuilder],)
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Container ()
          )
        ],
      ),
    );
  }
}