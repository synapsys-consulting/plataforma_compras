import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart' show NumberFormat hide TextDirection;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/models/cart.model.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/utils/displayDialog.dart';
import 'package:plataforma_compras/utils/pleaseWaitWidget.dart';
import 'package:plataforma_compras/views/login.view.dart';
import 'package:plataforma_compras/utils/showSnackBar.dart';
import 'package:plataforma_compras/models/address.model.dart';
import 'package:plataforma_compras/models/catalog.model.dart';
import 'package:plataforma_compras/views/addAddress.view.dart';
import 'package:plataforma_compras/views/confirmPurchase.view.dart';
import 'package:plataforma_compras/utils/multiPriceListElement.dart';


class CartView extends StatefulWidget {
  @override
  _CartViewState createState() {
    return _CartViewState();
  }
}
class _CartViewState extends State<CartView> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Image.asset('assets/images/leftArrow.png'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Image.asset('assets/images/logoWhatsapp.png'),
            onPressed: () async {
              final SharedPreferences prefs = await _prefs;
              final String token = prefs.get ('token').toString();
              String fullName;
              if (token != "") {
                Map<String, dynamic> payload;
                payload = json.decode(
                    utf8.decode(
                        base64.decode (base64.normalize(token.split(".")[1]))
                    )
                );
                fullName = payload['partner_name'];
              } else {
                fullName = "usuario no autenticado en el sistema";
              }
              final box = context.findRenderObject() as RenderBox;
              var cart = Provider.of<Cart>(context, listen: false);
              String textToShare = "Pedido de " + fullName + ":\n\n" + "PRODUCT_ID|UNIDADES|DESCRIPCION\n";
              if (cart.numItems > 0) {
                cart.items.forEach((element) {
                  textToShare = textToShare + element.productId.toString() + "|" +element.purchased.toString() + (element.purchased > 1 ? " " + element.idUnit + "s." : " " + element.idUnit + ".") + "|" + element.productName + "\n";
                });
                Share.share(
                  textToShare,
                  subject: "Pedido de " + fullName + ".",
                  sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size
                );
              }
            },
          )
        ],
      ),
      body: ResponsiveWidget(
        smallScreen: _SmallScreen(),
        mediumScreen: _MediumScreen(),
        largeScreen: _LargeScreen(),
      ),
      bottomNavigationBar: _BottonNavigatorBar(),
    );
  }
}

class _SmallScreen extends StatefulWidget {
  _SmallScreenState createState() => _SmallScreenState();
}
class _SmallScreenState extends State<_SmallScreen> {
  @override
  Widget build(BuildContext context) {
    var cart = context.watch<Cart>();
    var catalog = context.read<Catalog>();
    return SafeArea (
      child: LayoutBuilder (
        builder: (context, constraints) {
          if (cart.numItems > 0) {
            return ListView.builder(
                itemCount: cart.numItems,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                    decoration: BoxDecoration(
                      border: Border (
                          bottom: BorderSide(
                            color: tanteLadenBrown500,
                            width: 1.0,
                            style: BorderStyle.solid,
                          )
                      )
                    ),
                    child: Row (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                              child: AspectRatio(
                                aspectRatio: 3.0 / 2.0,
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  //imageUrl: SERVER_IP + '/image/products/burger_king.png',
                                  imageUrl: SERVER_IP + IMAGES_DIRECTORY + cart.getItem(index).productCode.toString() + '_0.gif',
                                  fit: BoxFit.scaleDown,
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                            )
                        ),
                        Expanded(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cart.getItem(index).productName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16.0,
                                      fontFamily: 'SF Pro Display',
                                      fontStyle: FontStyle.normal,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    softWrap: false,
                                  ),
                                  SizedBox(height: 2.0,),
                                  Text(
                                    cart.getItem(index).businessName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 12.0,
                                      fontFamily: 'SF Pro Display',
                                      fontStyle: FontStyle.normal,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                  SizedBox(height: 2.0),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Text(
                                            'Unids. mínim. venta: ' + cart.getItem(index).minQuantitySell.toString() + ' ' + ((cart.getItem(index).minQuantitySell > 1) ? cart.getItem(index).idUnit.toString() + 's.' : cart.getItem(index).idUnit.toString() + '.'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 10.0,
                                              fontFamily: 'SF Pro Display',
                                              fontStyle: FontStyle.normal,
                                              color: Color(0xFF6C6D77),
                                            ),
                                            textAlign: TextAlign.start
                                        ),
                                      )
                                    ],
                                  ),
                                  //SizedBox(height: 2.0),
                                  Container(
                                    child: Row (
                                      children: [
                                        Text (
                                          new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format((cart.getItem(index).totalAmountAccordingQuantity/MULTIPLYING_FACTOR)),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16.0,
                                            fontFamily: 'SF Pro Display',
                                            fontStyle: FontStyle.italic,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          softWrap: false,
                                        ),
                                        Text (
                                          '/' + cart.getItem(index).idUnit + '.',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 16.0,
                                            fontFamily: 'SF Pro Display',
                                            fontStyle: FontStyle.italic,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        cart.getItem(index).quantityMaxPrice != 999999 ? IconButton (
                                          icon: Image.asset (
                                            'assets/images/logoInfo.png',
                                            //fit: BoxFit.fill,
                                            width: 20.0,
                                            height: 20.0,
                                          ),
                                          iconSize: 20.0,
                                          onPressed: () {
                                            final List<MultiPriceListElement> listMultiPriceListElement = [];
                                            if (cart.getItem(index).quantityMaxPrice != 999999) {
                                              // There is multiprice for this product
                                              final item = new MultiPriceListElement(cart.getItem(index).quantityMinPrice, cart.getItem(index).quantityMaxPrice, cart.getItem(index).totalAmount);
                                              listMultiPriceListElement.add(item);
                                              cart.getItem(index).items.where((element) => element.partnerId != 1)
                                                  .forEach((element) {
                                                final item = new MultiPriceListElement(element.quantityMinPrice, element.quantityMaxPrice, element.totalAmount);
                                                listMultiPriceListElement.add(item);
                                              });
                                            }
                                            DisplayDialog.displayInformationAsATable (context, 'Descuentos por cantidad comprada:', listMultiPriceListElement);
                                          },
                                        ) : Container()
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ),
                        Expanded(
                            flex: 1,
                            child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: Text(
                                        (cart.getItem(index).purchased > 1) ? cart.getItem(index).purchased.toString() + ' ' + cart.getItem(index).idUnit + 's.' : cart.getItem(index).purchased.toString() + ' ' + cart.getItem(index).idUnit + '.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 24.0,
                                          fontFamily: 'SF Pro Display',
                                          fontStyle: FontStyle.normal,
                                          color: tanteLadenIconBrown,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    SizedBox(height: 5.0,),
                                    Container(
                                      child: Row (
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Visibility(
                                              visible: (cart.getItem(index).purchased > 1) ? true : false,
                                              child: TextButton(
                                                child: Container (
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.rectangle,
                                                      borderRadius: BorderRadius.circular(18.0),
                                                      color: tanteLadenAmber500,
                                                    ),
                                                    padding: EdgeInsets.symmetric(vertical: 2.0),
                                                    child: Text(
                                                      '-',
                                                      style: TextStyle(
                                                          fontFamily: 'SF Pro Display',
                                                          fontSize: 24,
                                                          fontWeight: FontWeight.w900,
                                                          color: tanteLadenIconBrown
                                                      ),
                                                    )
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    catalog.remove(cart.getItem(index));
                                                    cart.remove(cart.getItem(index));
                                                  });
                                                },
                                              ),
                                              replacement: TextButton(
                                                child: Container (
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.circular(18.0),
                                                    color: tanteLadenAmber500,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  child: IconButton(
                                                    icon: Image.asset(
                                                      'assets/images/logoDelete.png',
                                                      fit: BoxFit.fill,
                                                    ),
                                                    onPressed: null,
                                                    iconSize: 20.0,
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    catalog.remove (cart.getItem(index));
                                                    cart.remove (cart.getItem(index));
                                                  });
                                                },
                                              ),
                                            ),
                                            flex: 3,
                                          ),
                                          Expanded(
                                            child: SizedBox(
                                              width: 10.0,
                                            ),
                                            flex: 1,
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: TextButton(
                                              child: Container (
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(18.0),
                                                  //color: colorFondo,
                                                  color: tanteLadenAmber500,
                                                ),
                                                padding: EdgeInsets.symmetric(vertical: 2.0),
                                                child: Text (
                                                  '+',
                                                  style: TextStyle (
                                                    fontFamily: 'SF Pro Display',
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w900,
                                                    color: tanteLadenIconBrown,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  catalog.add(cart.getItem(index));
                                                  cart.add(cart.getItem(index));
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                            )
                        )
                      ],
                    ),
                  );
                }
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/emptyCart.png'),
                  Text(
                    'Aún no has añadido productos a tu carro',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                      fontFamily: 'SF Pro Display',
                      fontStyle: FontStyle.normal,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }
        }
      ),
    );
  }
}

class _MediumScreen extends StatefulWidget {
  _MediumScreenState createState() => _MediumScreenState();
}
class _MediumScreenState extends State<_MediumScreen> {
  @override
  Widget build(BuildContext context) {
    var cart = context.watch<Cart>();
    var catalog = context.read<Catalog>();
    return SafeArea (
      child: LayoutBuilder (
          builder: (context, constraints) {
            if (cart.numItems > 0) {
              return ListView.builder(
                  itemCount: cart.numItems,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                      decoration: BoxDecoration(
                          border: Border (
                              bottom: BorderSide(
                                color: tanteLadenBrown500,
                                width: 1.0,
                                style: BorderStyle.solid,
                              )
                          )
                      ),
                      child: Row (
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                                child: AspectRatio(
                                  aspectRatio: 3.0 / 2.0,
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => CircularProgressIndicator(),
                                    //imageUrl: SERVER_IP + '/image/products/burger_king.png',
                                    imageUrl: SERVER_IP + IMAGES_DIRECTORY + cart.getItem(index).productCode.toString() + '_0.gif',
                                    fit: BoxFit.scaleDown,
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                ),
                              )
                          ),
                          Expanded(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cart.getItem(index).productName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16.0,
                                        fontFamily: 'SF Pro Display',
                                        fontStyle: FontStyle.normal,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      softWrap: false,
                                    ),
                                    SizedBox(height: 2.0,),
                                    Text(
                                      cart.getItem(index).businessName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 12.0,
                                        fontFamily: 'SF Pro Display',
                                        fontStyle: FontStyle.normal,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                    SizedBox(height: 2.0),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Text(
                                              'Unids. mínim. venta: ' + cart.getItem(index).minQuantitySell.toString() + ' ' + ((cart.getItem(index).minQuantitySell > 1) ? cart.getItem(index).idUnit.toString() + 's.' : cart.getItem(index).idUnit.toString() + '.'),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 10.0,
                                                fontFamily: 'SF Pro Display',
                                                fontStyle: FontStyle.normal,
                                                color: Color(0xFF6C6D77),
                                              ),
                                              textAlign: TextAlign.start
                                          ),
                                        )
                                      ],
                                    ),
                                    //SizedBox(height: 2.0),
                                    Container(
                                      child: Row (
                                        children: [
                                          Text (
                                            new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format((cart.getItem(index).totalAmountAccordingQuantity/MULTIPLYING_FACTOR)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16.0,
                                              fontFamily: 'SF Pro Display',
                                              fontStyle: FontStyle.italic,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            softWrap: false,
                                          ),
                                          Text (
                                            '/' + cart.getItem(index).idUnit + '.',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 16.0,
                                              fontFamily: 'SF Pro Display',
                                              fontStyle: FontStyle.italic,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                          cart.getItem(index).quantityMaxPrice != 999999 ? IconButton (
                                            icon: Image.asset (
                                              'assets/images/logoInfo.png',
                                              //fit: BoxFit.fill,
                                              width: 20.0,
                                              height: 20.0,
                                            ),
                                            iconSize: 20.0,
                                            onPressed: () {
                                              final List<MultiPriceListElement> listMultiPriceListElement = [];
                                              if (cart.getItem(index).quantityMaxPrice != 999999) {
                                                // There is multiprice for this product
                                                final item = new MultiPriceListElement(cart.getItem(index).quantityMinPrice, cart.getItem(index).quantityMaxPrice, cart.getItem(index).totalAmount);
                                                listMultiPriceListElement.add(item);
                                                cart.getItem(index).items.where((element) => element.partnerId != 1)
                                                    .forEach((element) {
                                                  final item = new MultiPriceListElement(element.quantityMinPrice, element.quantityMaxPrice, element.totalAmount);
                                                  listMultiPriceListElement.add(item);
                                                });
                                              }
                                              DisplayDialog.displayInformationAsATable (context, 'Descuentos por cantidad comprada:', listMultiPriceListElement);
                                            },
                                          ) : Container()
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ),
                          Expanded(
                              flex: 1,
                              child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: Text(
                                          (cart.getItem(index).purchased > 1) ? cart.getItem(index).purchased.toString() + ' ' + cart.getItem(index).idUnit + 's.' : cart.getItem(index).purchased.toString() + ' ' + cart.getItem(index).idUnit + '.',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 24.0,
                                            fontFamily: 'SF Pro Display',
                                            fontStyle: FontStyle.normal,
                                            color: tanteLadenIconBrown,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      SizedBox(height: 5.0,),
                                      Container(
                                        child: Row (
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Visibility(
                                                visible: (cart.getItem(index).purchased > 1) ? true : false,
                                                child: TextButton(
                                                  child: Container (
                                                      alignment: Alignment.center,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.rectangle,
                                                        borderRadius: BorderRadius.circular(18.0),
                                                        color: tanteLadenAmber500,
                                                      ),
                                                      padding: EdgeInsets.symmetric(vertical: 2.0),
                                                      child: Text(
                                                        '-',
                                                        style: TextStyle(
                                                            fontFamily: 'SF Pro Display',
                                                            fontSize: 24,
                                                            fontWeight: FontWeight.w900,
                                                            color: tanteLadenIconBrown
                                                        ),
                                                      )
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      catalog.remove(cart.getItem(index));
                                                      cart.remove(cart.getItem(index));
                                                    });
                                                  },
                                                ),
                                                replacement: TextButton(
                                                  child: Container (
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.rectangle,
                                                      borderRadius: BorderRadius.circular(18.0),
                                                      color: tanteLadenAmber500,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    child: IconButton(
                                                      icon: Image.asset(
                                                        'assets/images/logoDelete.png',
                                                        fit: BoxFit.fill,
                                                      ),
                                                      onPressed: null,
                                                      iconSize: 20.0,
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      catalog.remove (cart.getItem(index));
                                                      cart.remove (cart.getItem(index));
                                                    });
                                                  },
                                                ),
                                              ),
                                              flex: 3,
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                width: 10.0,
                                              ),
                                              flex: 1,
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: TextButton(
                                                child: Container (
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.circular(18.0),
                                                    //color: colorFondo,
                                                    color: tanteLadenAmber500,
                                                  ),
                                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                                  child: Text (
                                                    '+',
                                                    style: TextStyle (
                                                      fontFamily: 'SF Pro Display',
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w900,
                                                      color: tanteLadenIconBrown,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    catalog.add(cart.getItem(index));
                                                    cart.add(cart.getItem(index));
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                              )
                          )
                        ],
                      ),
                    );
                  }
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/emptyCart.png'),
                    Text(
                      'Aún no has añadido productos a tu carro',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }
          }
      ),
    );
  }
}
class _LargeScreen extends StatefulWidget {
  _LargeScreenState createState() => _LargeScreenState();
}
class _LargeScreenState extends State<_LargeScreen> {
  @override
  Widget build(BuildContext context) {
    var cart = context.watch<Cart>();
    var catalog = context.read<Catalog>();
    return SafeArea (
      child: LayoutBuilder (
          builder: (context, constraints) {
            if (cart.numItems > 0) {
              return ListView.builder(
                  itemCount: cart.numItems,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                color: tanteLadenBrown500,
                                width: 1.0,
                                style: BorderStyle.solid,
                              )
                          )
                      ),
                      child: Row (
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                                child: AspectRatio(
                                  aspectRatio: 3.0 / 2.0,
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => CircularProgressIndicator(),
                                    //imageUrl: SERVER_IP + '/image/products/burger_king.png',
                                    imageUrl: SERVER_IP + IMAGES_DIRECTORY + cart.getItem(index).productCode.toString() + '_0.gif',
                                    fit: BoxFit.scaleDown,
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                ),
                              )
                          ),
                          Expanded(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cart.getItem(index).productName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16.0,
                                        fontFamily: 'SF Pro Display',
                                        fontStyle: FontStyle.normal,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      softWrap: false,
                                    ),
                                    SizedBox(height: 2.0,),
                                    Text(
                                      cart.getItem(index).businessName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 12.0,
                                        fontFamily: 'SF Pro Display',
                                        fontStyle: FontStyle.normal,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                    SizedBox(height: 2.0),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Text(
                                              'Unids. mínim. venta: ' + cart.getItem(index).minQuantitySell.toString() + ' ' + ((cart.getItem(index).minQuantitySell > 1) ? cart.getItem(index).idUnit.toString() + 's.' : cart.getItem(index).idUnit.toString() + '.'),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12.0,
                                                fontFamily: 'SF Pro Display',
                                                fontStyle: FontStyle.normal,
                                                color: Color(0xFF6C6D77),
                                              ),
                                              textAlign: TextAlign.start
                                          ),
                                        )
                                      ],
                                    ),
                                    //SizedBox(height: 2.0),
                                    Container(
                                      child: Row (
                                        children: [
                                          Text (
                                            new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format((cart.getItem(index).totalAmountAccordingQuantity/MULTIPLYING_FACTOR)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16.0,
                                              fontFamily: 'SF Pro Display',
                                              fontStyle: FontStyle.italic,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            softWrap: false,
                                          ),
                                          Text (
                                            '/' + cart.getItem(index).idUnit + '.',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 16.0,
                                              fontFamily: 'SF Pro Display',
                                              fontStyle: FontStyle.italic,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                          cart.getItem(index).quantityMaxPrice != 999999 ? IconButton (
                                            icon: Image.asset (
                                              'assets/images/logoInfo.png',
                                              //fit: BoxFit.fill,
                                              width: 20.0,
                                              height: 20.0,
                                            ),
                                            iconSize: 20.0,
                                            onPressed: () {
                                              final List<MultiPriceListElement> listMultiPriceListElement = [];
                                              if (cart.getItem(index).quantityMaxPrice != 999999) {
                                                // There is multiprice for this product
                                                final item = new MultiPriceListElement(cart.getItem(index).quantityMinPrice, cart.getItem(index).quantityMaxPrice, cart.getItem(index).totalAmount);
                                                listMultiPriceListElement.add(item);
                                                cart.getItem(index).items.where((element) => element.partnerId != 1)
                                                    .forEach((element) {
                                                  final item = new MultiPriceListElement(element.quantityMinPrice, element.quantityMaxPrice, element.totalAmount);
                                                  listMultiPriceListElement.add(item);
                                                });
                                              }
                                              DisplayDialog.displayInformationAsATable (context, 'Descuentos por cantidad comprada:', listMultiPriceListElement);
                                            },
                                          ) : Container()
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ),
                          Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            child: Text(
                                              (cart.getItem(index).purchased > 1) ? cart.getItem(index).purchased.toString() + ' ' + cart.getItem(index).idUnit + 's.' : cart.getItem(index).purchased.toString() + ' ' + cart.getItem(index).idUnit + '.',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 24.0,
                                                fontFamily: 'SF Pro Display',
                                                fontStyle: FontStyle.normal,
                                                color: tanteLadenIconBrown,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          SizedBox(height: 5.0,),
                                          Container(
                                            child: Row (
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Visibility(
                                                    visible: (cart.getItem(index).purchased > 1) ? true : false,
                                                    child: TextButton(
                                                      child: Container (
                                                          alignment: Alignment.center,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.rectangle,
                                                            borderRadius: BorderRadius.circular(18.0),
                                                            color: tanteLadenAmber500,
                                                          ),
                                                          padding: EdgeInsets.symmetric(vertical: 2.0),
                                                          child: Text(
                                                            '-',
                                                            style: TextStyle(
                                                                fontFamily: 'SF Pro Display',
                                                                fontSize: 24,
                                                                fontWeight: FontWeight.w900,
                                                                color: tanteLadenIconBrown
                                                            ),
                                                          )
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          catalog.remove(cart.getItem(index));
                                                          cart.remove(cart.getItem(index));
                                                        });
                                                      },
                                                    ),
                                                    replacement: TextButton(
                                                      child: Container (
                                                        alignment: Alignment.center,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.rectangle,
                                                          borderRadius: BorderRadius.circular(18.0),
                                                          color: tanteLadenAmber500,
                                                        ),
                                                        padding: EdgeInsets.zero,
                                                        child: IconButton(
                                                          icon: Image.asset(
                                                            'assets/images/logoDelete.png',
                                                            fit: BoxFit.fill,
                                                          ),
                                                          onPressed: null,
                                                          iconSize: 20.0,
                                                          padding: EdgeInsets.all(8.0),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          catalog.remove(cart.getItem(index));
                                                          cart.remove(cart.getItem(index));
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  flex: 3,
                                                ),
                                                Expanded(
                                                  child: SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  flex: 1,
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: TextButton(
                                                    child: Container (
                                                      alignment: Alignment.center,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.rectangle,
                                                        borderRadius: BorderRadius.circular(18.0),
                                                        //color: colorFondo,
                                                        color: tanteLadenAmber500,
                                                      ),
                                                      padding: EdgeInsets.symmetric(vertical: 2.0),
                                                      child: Text (
                                                        '+',
                                                        style: TextStyle (
                                                          fontFamily: 'SF Pro Display',
                                                          fontSize: 24,
                                                          fontWeight: FontWeight.w900,
                                                          color: tanteLadenIconBrown,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        catalog.add(cart.getItem(index));
                                                        cart.add(cart.getItem(index));
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ]
                              )
                          )
                        ],
                      ),
                    );
                  }
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/emptyCart.png'),
                    Text(
                      'Aún no has añadido productos a tu carro',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }
          }
      ),
    );
  }
}


class _BottonNavigatorBar extends StatefulWidget {
  _BottonNavigatorBarState createState() => _BottonNavigatorBarState();
}
class _BottonNavigatorBarState extends State<_BottonNavigatorBar> {
  bool _pleaseWait = false;
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  _showPleaseWait(bool b) {
    setState(() {
      _pleaseWait = b;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder (
      builder: (context, constraints) {
        return SafeArea (
          child: Container(
            height: (constraints.maxWidth > 1200) ? (constraints.maxHeight ~/ 6).toDouble() : (constraints.maxHeight ~/ 8).toDouble(),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: tanteLadenBrown500
                    )
                )
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Total aproximado ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.0,
                                  fontFamily: 'SF Pro Display',
                                  fontStyle: FontStyle.normal,
                                  color: tanteLadenOnPrimary,
                                ),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                              ),
                              IconButton (
                                icon: Image.asset('assets/images/logoInfo.png'),
                                iconSize: 6.0,
                                onPressed: () {
                                  var widgetImage = Image.asset('assets/images/weightMessage.png');
                                  var message = 'En los productos al peso, el importe se ajustará a la cantidad servida. El cobro del importe final se realizará tras la presentación de tu pedido.';
                                  DisplayDialog.displayDialog (context, widgetImage, 'Total aproximado', message);
                                },
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Consumer<Cart>(
                                builder: (context, cart, child) => Container(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    new NumberFormat.currency(locale:'es_ES', symbol: '€', decimalDigits:2).format((cart.totalPrice/MULTIPLYING_FACTOR)),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 24.0,
                                      fontFamily: 'SF Pro Display',
                                    ),
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                )
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Consumer<Cart>(
                              builder: (context, cart, child) {
                                Widget tmpBuilder = GestureDetector(
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
                                      final SharedPreferences prefs = await _prefs;
                                      final String token = prefs.get ('token').toString();
                                      debugPrint ('el token es: ' + token);
                                      _showPleaseWait(false);
                                      if (token == '') {
                                        // login not yet done
                                        Navigator.push (
                                            context,
                                            MaterialPageRoute (
                                                builder: (context) => (LoginView(COME_FROM_ANOTHER))  //  1 the call comes from the drawer. 2 the call comes from cart.view.dart
                                            )
                                        );
                                      } else {
                                        // login yet done
                                        // test if the user has an address
                                        debugPrint ('Estoy en el else de login yet done');
                                        Map<String, dynamic> payload;
                                        payload = json.decode(
                                            utf8.decode(
                                                base64.decode (base64.normalize(token.split(".")[1]))
                                            )
                                        );
                                        _showPleaseWait(true);
                                        debugPrint ("El user_id es: " + payload['user_id'].toString());
                                        final Uri url = Uri.parse('$SERVER_IP/getDefaultLogisticAddress/' + payload['user_id'].toString());
                                        debugPrint ("La URL es: " + url.toString());

                                        final http.Response res = await http.get (
                                            url,
                                            headers: <String, String>{
                                              'Content-Type': 'application/json; charset=UTF-8',
                                              //'Authorization': jwt
                                            }
                                        );
                                        _showPleaseWait(false);
                                        if (res.statusCode == 200) {
                                          // if exists address
                                          // Process the order
                                          debugPrint ('OK. ');
                                          final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['data'].cast<Map<String, dynamic>>();
                                          final List<Address> resultListAddress = resultListJson.map<Address>((json) => Address.fromJson(json)).toList();
                                          if (resultListAddress.length > 0) {
                                            Navigator.push (
                                                context,
                                                MaterialPageRoute (
                                                    builder: (context) => (ConfirmPurchaseView(resultListAddress, payload['phone_number'].toString(), payload['user_id'].toString()))
                                                )
                                            );
                                          } else {
                                            // if not exists address
                                            Navigator.push (
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => (AddAddressView(payload['persone_id'].toString(), payload['user_id'].toString()))
                                                )
                                            );
                                          }
                                        } else {
                                          // Error
                                          _showPleaseWait(false);
                                          ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'].toString());
                                        }
                                      }
                                    } catch (e) {
                                      _showPleaseWait(false);
                                      ShowSnackBar.showSnackBar(context, e.toString(), error: true);
                                    }
                                  },
                                );
                                Widget bodyWidget = _pleaseWait
                                  ? Stack (
                                    key:  ObjectKey("stack"),
                                    alignment: AlignmentDirectional.center,
                                    children: [tmpBuilder, _pleaseWaitWidget],
                                  )
                                  : Stack (key:  ObjectKey("stack"), children: [tmpBuilder],);
                                return bodyWidget;
                              }
                            ),
                          ],
                        )
                    )
                ),
                SizedBox(height: 4.0,)
              ],
            ),
          ),
        );
      },
    );
  }
}
