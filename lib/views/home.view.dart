import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:plataforma_compras/views/catalogManagement.view.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart' show NumberFormat hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plataforma_compras/models/catalog.model.dart';
import 'package:plataforma_compras/models/multiPricesProductAvail.model.dart';
import 'package:plataforma_compras/models/productAvail.model.dart';
import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/models/cart.model.dart';
import 'package:plataforma_compras/views/cart.view.dart';
import 'package:plataforma_compras/views/menu.view.dart';
import 'package:plataforma_compras/views/purchase.view.dart';
import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/views/product.view.dart';
import 'package:plataforma_compras/views/lookingForProducts.view.dart';
import 'package:plataforma_compras/utils/pleaseWaitWidget.dart';
import 'package:plataforma_compras/views/login.view.dart';
import 'package:plataforma_compras/utils/showSnackBar.dart';
import 'package:plataforma_compras/views/personalData.view.dart';
import 'package:plataforma_compras/views/manageAddresses.view.dart';
import 'package:plataforma_compras/utils/displayDialog.dart';
import 'package:plataforma_compras/utils/multiPriceListElement.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future<List<MultiPricesProductAvail>> itemsProductsAvailable;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _isUserLogged = false;
  String _name = '';
  bool _pleaseWait = false;
  String _token = '';
  String _roleId = '';
  String _role = '';

  _showPleaseWait(bool b) {
    setState(() {
      _pleaseWait = b;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isUserLogged = false;
    _name = '';
    _token = '';
    itemsProductsAvailable = _getProductsAvailable();
  }
  // Private method which get the available products from the database
  Future<List<MultiPricesProductAvail>> _getProductsAvailable () async {
    final SharedPreferences prefs = await _prefs;
    final String token = prefs.get ('token') ?? '';
    if (token == '') {
      final Uri url = Uri.parse('$SERVER_IP/getProductsAvailWithOutPartnerId');
      debugPrint('La URL con la que llamo al inicio de todo es: ' + '$SERVER_IP/getProductsAvailWithOutPartnerId');
      debugPrint('La URL con la que llamo al inicio de todo es: ' + url.host + url.path);
      final http.Response res = await http.get (
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            //'Authorization': jwt
          }
      );
      debugPrint('After the http call.');
      if (res.statusCode == 200) {
        debugPrint ('The Rest API has responsed.');
        final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['products'].cast<Map<String, dynamic>>();
        debugPrint ('Entre medias de la api RESPONSE.');
        final List<ProductAvail> resultListProducts = resultListJson.map<ProductAvail>((json) => ProductAvail.fromJson(json)).toList();
        final List<MultiPricesProductAvail> resultListMultiPriceProducts = [];
        int tmpProductCategoryIdPrevious;
        String tmpPersonNamePrevious;
        resultListProducts.forEach((element) {
          //debugPrint ('El producto que cargo es: ' + element.productName);
          //debugPrint ('El producto_code que cargo es: ' + element.productCode.toString());
          if (element.productCategoryId != tmpProductCategoryIdPrevious && element.personeName != tmpPersonNamePrevious && element.rn == 1) {
            // Change the productCategoryId and the rn = 1, so start a new MultiPriceProductAvail
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
            //Provider.of<Catalog>(context, listen: false).add(element);
          } else if (element.productCategoryId == tmpProductCategoryIdPrevious && element.personeName == tmpPersonNamePrevious && element.rn > 1) {
            // The same ProductCategoryId and the same PersoneName, so it is another price of the same MultiPriceProductAvail
            tmpProductCategoryIdPrevious = element.productCategoryId;
            tmpPersonNamePrevious = element.personeName;
            resultListMultiPriceProducts.last.add(element);
            //Provider.of<Catalog>(context, listen: false).addChildrenToFatherElement(tmpProductIdFather, element);
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
            //Provider.of<Catalog>(context, listen: false).add(element);
          }
        });
        resultListMultiPriceProducts.forEach((element) {
          Provider.of<Catalog>(context, listen: false).add(element);
        });
        debugPrint ('Antes de terminar de responder la API.');
        return resultListMultiPriceProducts;
      } else {
        final List<MultiPricesProductAvail> resultListProducts = [];
        return resultListProducts;
      }
    } else {
      Map<String, dynamic> payload;
      payload = json.decode(
          utf8.decode(
              base64.decode (base64.normalize(token.split(".")[1]))
          )
      );
      debugPrint('El partner_id es: ' + payload['partner_id'].toString());
      debugPrint('La URL con la que llamo al inicio de todo es: ' + '$SERVER_IP/getProductsAvailWithPartnerId/' + payload['partner_id'].toString());

      final Uri url = Uri.parse('$SERVER_IP/getProductsAvailWithPartnerId/' + payload['partner_id'].toString());
      debugPrint('La URL con la que llamo al inicio de todo es: ' + url.host + url.path);

      final http.Response res = await http.get (
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            //'Authorization': jwt
          }
      );
      debugPrint('After the http call.');
      if (res.statusCode == 200) {
        debugPrint ('The Rest API has responsed.');
        final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['products'].cast<Map<String, dynamic>>();
        debugPrint ('Entre medias de la api RESPONSE.');
        debugPrint ('Aquí estoy yo');
        final List<ProductAvail> resultListProducts = resultListJson.map<ProductAvail>((json) => ProductAvail.fromJson(json)).toList();
        final List<MultiPricesProductAvail> resultListMultiPriceProducts = [];
        int tmpProductCategoryIdPrevious;
        String tmpPersonNamePrevious;
        resultListProducts.forEach((element) {
          //debugPrint ('El producto que cargo es: ' + element.productName);
          //debugPrint ('El producto_code que cargo es: ' + element.productCode.toString());
          if (element.productCategoryId != tmpProductCategoryIdPrevious && element.personeName != tmpPersonNamePrevious && element.rn == 1) {
            // Change the productCategoryId and the rn = 1, so start a new MultiPriceProductAvail
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
        debugPrint ('Después del estoy aquí');
        resultListMultiPriceProducts.forEach((element) {
          Provider.of<Catalog>(context, listen: false).add(element);
        });
        debugPrint ('Antes de terminar de responder la API.');
        //return resultListProducts;
        return resultListMultiPriceProducts;
      } else {
        final List<MultiPricesProductAvail> resultListProducts = [];
        return resultListProducts;
      }
    }
  }
  Drawer _createEndDrawer (BuildContext context, bool isUserLogged, String name) {
    var catalog = context.watch<Catalog>();
    var cart = context.read<Cart>();

    if (isUserLogged) {
      if (_role == "SELLER") {
        // The user role lets change the product catalog
        // There is another one menu option
        return new MenuView (
          child: ListView (
            padding: EdgeInsets.zero,
            children: [
              ListTile (
                title: SafeArea (
                  child: Text (
                      name,
                      style: TextStyle (
                          fontSize: 24.0,
                          color: tanteLadenIconBrown,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.bold
                      )
                  ),
                ),
              ),
              Divider(),
              ListTile (
                leading: IconButton(
                  icon: Image.asset ('assets/images/logoPersonalData.png'),
                  onPressed: null,
                ),
                title: Text(
                  'Datos personales',
                  style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => PersonalData(_token)
                  ));
                },
              ),
              Divider(),
              ListTile (
                leading: IconButton (
                    icon: Image.asset ('assets/images/logoDirections.png'),
                    onPressed: null
                ),
                title: Text (
                  'Direcciones',
                  style: TextStyle (
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
                onTap: () {
                  Map<String, dynamic> payload;
                  payload = json.decode(
                      utf8.decode(
                          base64.decode (base64.normalize(_token.split(".")[1]))
                      )
                  );
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ManageAddresses(payload['persone_id'].toString(), payload['user_id'].toString())
                  ));
                },
              ),
              Divider(),
              ListTile (
                leading: IconButton (
                  icon: Image.asset ('assets/images/logoPaymentMethod1.png'),
                  onPressed: null,
                ),
                title: Text(
                  'Métodos de pago',
                  style: TextStyle (
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
              ),
              Divider(),
              ListTile (
                leading: IconButton (
                  icon: Image.asset ('assets/images/logoMyPurchases.png'),
                  onPressed: null,
                ),
                title: Text(
                  'Mis pedidos',
                  style: TextStyle (
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
                onTap: () {
                  Map<String, dynamic> payload;
                  payload = json.decode(
                      utf8.decode(
                          base64.decode (base64.normalize(_token.split(".")[1]))
                      )
                  );
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => PurchaseView(payload['user_id'], payload['partner_id'], payload['role'])
                  ));
                },
              ),
              Divider(),
              ListTile (
                leading: IconButton (
                  icon: Image.asset('assets/images/logoHelp.png'),
                  onPressed: null,
                ),
                title: Text (
                  'Catalogo',
                  style: TextStyle (
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => CatalogManagement()
                  ));
                },
              ),
              Divider(),
              ListTile (
                leading: IconButton (
                  icon: Image.asset ('assets/images/logoHelp.png'),
                  onPressed: null,
                ),
                title: Text(
                  'Ayuda',
                  style: TextStyle (
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
              ),
              Divider(),
              ListTile (
                leading: IconButton (
                  icon: Image.asset ('assets/images/logoInformation.png'),
                  onPressed: null,
                ),
                title: Text (
                  'Información',
                  style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
              ),
              Divider(),
              ListTile (
                leading: IconButton (
                  icon: Image.asset ('assets/images/logoExit.png'),
                  onPressed: null,
                ),
                title: Text (
                  'Salir',
                  style: TextStyle (
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
                onTap: () async {
                  try {
                    debugPrint('Estoy en el salir.');
                    //debugPrint('Después de watch y read.');
                    final SharedPreferences prefs = await _prefs;
                    prefs.setString ('token', '');
                    final Uri url = Uri.parse('$SERVER_IP/getProductsAvailWithOutPartnerId');
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
                      debugPrint ('Entre medias de la api RESPONSE.');
                      //Provider.of<Catalog>(context, listen: false).clearCatalog();
                      catalog.removeCatalog();
                      resultListProducts.forEach((element) {
                        //debugPrint ('El producto que cargo es: ' + element.productName);
                        //debugPrint ('El producto_code que cargo es: ' + element.productCode.toString());
                        if (element.productCategoryId != tmpProductCategoryIdPrevious && element.personeName != tmpPersonNamePrevious && element.rn == 1) {
                          // Change the productCategoryId and the rn = 1, so start a new MultiPriceProductAvail
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
                          //Provider.of<Catalog>(context, listen: false).add(element);
                        } else if (element.productCategoryId == tmpProductCategoryIdPrevious && element.personeName == tmpPersonNamePrevious && element.rn > 1) {
                          // The same ProductCategoryId and the same PersoneName, so it is another price of the same MultiPriceProductAvail
                          tmpProductCategoryIdPrevious = element.productCategoryId;
                          tmpPersonNamePrevious = element.personeName;
                          resultListMultiPriceProducts.last.add(element);
                          //Provider.of<Catalog>(context, listen: false).addChildrenToFatherElement(tmpProductIdFather, element);
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
                          //Provider.of<Catalog>(context, listen: false).add(element);
                        }
                      });
                      resultListMultiPriceProducts.forEach((element) {
                        Provider.of<Catalog>(context, listen: false).add(element);
                      });
                      debugPrint ('Antes de terminar de responder la API.');
                      if (cart.numItems > 0) {
                        //Add the elements which are in the cart to the catalog
                        debugPrint('El numero de items es:' + cart.numItems.toString());
                        cart.items.forEach((element) {
                          debugPrint('El valor de product_name es: ' + element.productName);
                          if (element.partnerId != DEFAULT_PARTNER_ID) {
                            cart.remove(element);
                          }
                        });
                      }
                      debugPrint ('Despues de terminar de responder la API.');
                    }
                    Navigator.pop(context);
                  } catch (err) {
                    Navigator.pop(context);
                  }
                },
              ),
              Divider(),
            ],
          ),
        );
      } else {
        // BUYER, PRO_DELIBERY, KRR_DELIBERY
        return new MenuView (
          child: ListView (
            padding: EdgeInsets.zero,
            children: [
              ListTile (
                title: SafeArea (
                  child: Text (
                      name,
                      style: TextStyle (
                          fontSize: 24.0,
                          color: tanteLadenIconBrown,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.bold
                      )
                  ),
                ),
              ),
              Divider(),
              ListTile (
                leading: IconButton(
                  icon: Image.asset ('assets/images/logoPersonalData.png'),
                  onPressed: null,
                ),
                title: Text(
                  'Datos personales',
                  style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => PersonalData(_token)
                  ));
                },
              ),
              Divider(),
              ListTile (
                leading: IconButton (
                    icon: Image.asset ('assets/images/logoDirections.png'),
                    onPressed: null
                ),
                title: Text (
                  'Direcciones',
                  style: TextStyle (
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
                onTap: () {
                  Map<String, dynamic> payload;
                  payload = json.decode(
                      utf8.decode(
                          base64.decode (base64.normalize(_token.split(".")[1]))
                      )
                  );
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ManageAddresses(payload['persone_id'].toString(), payload['user_id'].toString())
                  ));
                },
              ),
              Divider(),
              ListTile (
                leading: IconButton (
                  icon: Image.asset ('assets/images/logoPaymentMethod1.png'),
                  onPressed: null,
                ),
                title: Text(
                  'Métodos de pago',
                  style: TextStyle (
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
              ),
              Divider(),
              ListTile (
                leading: IconButton (
                  icon: Image.asset ('assets/images/logoMyPurchases.png'),
                  onPressed: null,
                ),
                title: Text(
                  'Mis pedidos',
                  style: TextStyle (
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
                onTap: () {
                  Map<String, dynamic> payload;
                  payload = json.decode(
                      utf8.decode(
                          base64.decode (base64.normalize(_token.split(".")[1]))
                      )
                  );
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => PurchaseView(payload['user_id'], payload['partner_id'], payload['role'])
                  ));
                },
              ),
              Divider(),
              ListTile (
                leading: IconButton (
                  icon: Image.asset('assets/images/logoUpCatalog.png'),
                  onPressed: null,
                ),
                title: Text (
                  'Catalogo',
                  style: TextStyle (
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => CatalogManagement()
                  ));
                },
              ),
              Divider(),
              ListTile (
                leading: IconButton (
                  icon: Image.asset ('assets/images/logoHelp.png'),
                  onPressed: null,
                ),
                title: Text(
                  'Ayuda',
                  style: TextStyle (
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
              ),
              Divider(),
              ListTile (
                leading: IconButton (
                  icon: Image.asset ('assets/images/logoInformation.png'),
                  onPressed: null,
                ),
                title: Text (
                  'Información',
                  style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
              ),
              Divider(),
              ListTile (
                leading: IconButton (
                  icon: Image.asset ('assets/images/logoExit.png'),
                  onPressed: null,
                ),
                title: Text (
                  'Salir',
                  style: TextStyle (
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.normal
                  ),
                ),
                onTap: () async {
                  try {
                    debugPrint('Estoy en el salir.');
                    //debugPrint('Después de watch y read.');
                    final SharedPreferences prefs = await _prefs;
                    prefs.setString ('token', '');
                    final Uri url = Uri.parse('$SERVER_IP/getProductsAvailWithOutPartnerId');
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
                      debugPrint ('Entre medias de la api RESPONSE.');
                      //Provider.of<Catalog>(context, listen: false).clearCatalog();
                      catalog.removeCatalog();
                      resultListProducts.forEach((element) {
                        //debugPrint ('El producto que cargo es: ' + element.productName);
                        //debugPrint ('El producto_code que cargo es: ' + element.productCode.toString());
                        if (element.productCategoryId != tmpProductCategoryIdPrevious && element.personeName != tmpPersonNamePrevious && element.rn == 1) {
                          // Change the productCategoryId and the rn = 1, so start a new MultiPriceProductAvail
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
                          //Provider.of<Catalog>(context, listen: false).add(element);
                        } else if (element.productCategoryId == tmpProductCategoryIdPrevious && element.personeName == tmpPersonNamePrevious && element.rn > 1) {
                          // The same ProductCategoryId and the same PersoneName, so it is another price of the same MultiPriceProductAvail
                          tmpProductCategoryIdPrevious = element.productCategoryId;
                          tmpPersonNamePrevious = element.personeName;
                          resultListMultiPriceProducts.last.add(element);
                          //Provider.of<Catalog>(context, listen: false).addChildrenToFatherElement(tmpProductIdFather, element);
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
                          //Provider.of<Catalog>(context, listen: false).add(element);
                        }
                      });
                      resultListMultiPriceProducts.forEach((element) {
                        Provider.of<Catalog>(context, listen: false).add(element);
                      });
                      debugPrint ('Antes de terminar de responder la API.');
                      if (cart.numItems > 0) {
                        //Add the elements which are in the cart to the catalog
                        debugPrint('El numero de items es:' + cart.numItems.toString());
                        cart.items.forEach((element) {
                          debugPrint('El valor de product_name es: ' + element.productName);
                          if (element.partnerId != DEFAULT_PARTNER_ID) {
                            cart.remove(element);
                          }
                        });
                      }
                      debugPrint ('Despues de terminar de responder la API.');
                    }
                    Navigator.pop(context);
                  } catch (err) {
                    Navigator.pop(context);
                  }
                },
              ),
              Divider(),
            ],
          ),
        );
      }
    } else {
      return new MenuView (
        child: ListView (
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              title: SafeArea (
                child: Text('Invitado',
                  style: TextStyle (
                      fontSize: 24.0,
                      color: tanteLadenIconBrown,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.bold
                  ),
                ),
              )
            ),
            Divider(),
            SizedBox(height: 50.0),
            Padding(
              padding: const EdgeInsets.symmetric (horizontal: 15.0),
              child: Center(
                child: Text (
                  'Identifícate',
                  style: TextStyle (
                      fontSize: 20.0,
                      color: tanteLadenOnPrimary,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            SizedBox (height: 10.0,),
            Padding (
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Center(
                child: Text(
                  'Para poder comprar, necesitas una cuenta, así podrás comprar más rápido y también te podremos dar un mejor servicio.',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.normal,
                    color: tanteLadenOnPrimary,
                  ),
                  textAlign: TextAlign.justify,
                  maxLines: 4,
                  softWrap: true,
                ),
              ),
            ),
            SizedBox (height: 20.0,),
            Padding (
              padding: const EdgeInsets.all(15.0),
              child: GestureDetector(
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
                    'Identifícate',
                    style: TextStyle(
                        fontSize: 18.0,
                        color: tanteLadenBackgroundWhite
                    ),
                  ),
                  height: 64.0,
                ),
                onTap: () {
                  Navigator.push (
                      context,
                      MaterialPageRoute (
                          builder: (context) => (LoginView(COME_FROM_DRAWER))   //  1 the call comes from the drawer. 2 the call comes from cart.view.dart
                      )
                  );
                },
              ),
            ),
            SizedBox (height: 20.0,),
            Divider(),
            ListTile (
              leading: IconButton (
                icon: Image.asset ('assets/images/logoHelp.png'),
                onPressed: null,
              ),
              title: Text(
                'Ayuda',
                style: TextStyle (
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.normal
                ),
              ),
            ),
            Divider(),
            ListTile (
              leading: IconButton (
                icon: Image.asset ('assets/images/logoInformation.png'),
                onPressed: null,
              ),
              title: Text (
                'Información',
                style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.normal
                ),
              ),
            ),
            Divider(),
          ],
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    Widget tmpBuilder = IconButton (
      icon: Image.asset ('assets/images/profile.png'),
      tooltip: 'Perfil',
      onPressed: () async {
        try {
          _showPleaseWait(true);
          final SharedPreferences prefs = await _prefs;
          final String token = prefs.get ('token') ?? '';
          debugPrint ('El token es: ' + token);
          if (token == '') {
            _isUserLogged = false;
            _name = '';
            _token = '';
          } else {
            Map<String, dynamic> payload;
            payload = json.decode(
                utf8.decode(
                    base64.decode (base64.normalize(token.split(".")[1]))
                )
            );
            _token = token;
            _isUserLogged = true;
            _name = payload['user_firstname'] + ' ' + payload['user_lastname'];
            _roleId = payload['rid'];
            _role = payload['role'];
          }
          _showPleaseWait(false);

          _scaffoldKey.currentState.openEndDrawer();
        } catch (e) {
          ShowSnackBar.showSnackBar(context, e, error: true);
        }
      }
    );
    return Scaffold (
      key: _scaffoldKey,
      appBar: AppBar (
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        leading: Builder (
            builder: (BuildContext context) {
              return Container (
                alignment: Alignment.centerRight,
                child: IconButton(
                  //icon: Image.asset('assets/images/cart_fill_round.png'),
                  icon: Image.asset('assets/images/logoPantallaInicioAmber.png'),
                  onPressed: null,
                ),
              );
            }
        ),
        title: SizedBox (
          height: kToolbarHeight,
          child: Row (
            children: [
              Flexible(
                flex: 1,
                child: IconButton(
                  icon: Image.asset('assets/images/search_left.png'),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => LookingForProducts()
                    ));
                  }
                ),
              ),
              Spacer(),
              Flexible(
                flex: 1,
                child: IconButton(
                  icon: Image.asset('assets/images/love.png'),
                  onPressed: null
                ),
              ),
              Flexible(
                flex: 1,
                child: Consumer <Cart>(
                  builder: (context, cart, child) => cart.numItems > 0 ?
                  Stack (
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        alignment: AlignmentDirectional.center,
                        child: Text(
                          cart.numItems.toString(),
                          style: TextStyle (
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.white,
                              fontSize: 10.0,
                              fontFamily: 'SF Pro Display',
                              fontStyle: FontStyle.normal,
                              color: Colors.black
                          ),
                        ),
                      ),
                      Container(
                        child: IconButton(
                            icon: Image.asset('assets/images/shopping_cart.png'),
                            onPressed: () async {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => CartView()
                              ));
                            }
                        ),
                      )
                    ],
                  ):
                  Stack (
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        alignment: AlignmentDirectional.center,
                        child: IconButton(
                            icon: Image.asset('assets/images/shopping_cart.png'),
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => CartView()
                              ));
                            }
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        actions: <Widget>[
          _pleaseWait
          ? Stack (
            key:  ObjectKey("stack"),
            alignment: AlignmentDirectional.center,
            children: [tmpBuilder, _pleaseWaitWidget],
          )
          : Stack(key:  ObjectKey("stack"), children: [tmpBuilder])
        ],
        elevation: 0.0,
      ),
      endDrawer: _createEndDrawer (context, _isUserLogged,_name),
      body: FutureBuilder <List<MultiPricesProductAvail>> (
          future: itemsProductsAvailable,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //final List<ProductAvail>listProductsAvail = snapshot.data;
              return new ResponsiveWidget(
                largeScreen: _LargeScreen(),
                smallScreen: _SmallScreen(),
              );
            } else if (snapshot.hasError) {
              return Center (
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error. ${snapshot.error}')
                    ]
                ),
              );
            } else {
              return Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                ),
              );
            }
          }
      ),
    );
  }
}
class _SmallScreen extends StatefulWidget {
  _SmallScreenState createState() => _SmallScreenState();
}
class _SmallScreenState extends State<_SmallScreen> {

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var catalog = context.watch<Catalog>();
    var cart = context.read<Cart>();
    return SafeArea (
      child: Padding (
          padding: const EdgeInsets.only(top: 5.0),
          child: GridView.builder (
              itemCount: catalog.numItems,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 200.0 / 303.0
              ),
              itemBuilder: (BuildContext context, int index) {
                return Card (
                  clipBehavior: Clip.antiAlias,
                  elevation: 0,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0)
                  ),
                  child: LayoutBuilder (
                    builder: (context, constraints) {
                      return Column (
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row (
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector (
                                onTap: () {
                                  Navigator.push (
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProductView(catalog.items[index])
                                      )
                                  );
                                },
                                child: Container(
                                  //padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 0.0),
                                  alignment: Alignment.center,
                                  width: constraints.maxWidth,
                                  child: AspectRatio(
                                    aspectRatio: 3.0 / 2.0,
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => CircularProgressIndicator(),
                                      imageUrl: SERVER_IP + IMAGES_DIRECTORY + catalog.items[index].productCode.toString() + '_0.gif',
                                      fit: BoxFit.scaleDown,
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Container (
                            padding: const EdgeInsets.fromLTRB (15.0, 0.0, 0.0, 0.0),
                            child: Row (
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container (
                                  child: Image.asset('assets/images/00001.png'),
                                  padding: EdgeInsets.only(right: 8.0),
                                ),
                                Container (
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text.rich (
                                    TextSpan (
                                      text: new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((catalog.items[index].totalAmountAccordingQuantity/MULTIPLYING_FACTOR).toString())),
                                        style: TextStyle (
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24.0,
                                          fontFamily: 'SF Pro Display',
                                        ),
                                        //textAlign: TextAlign.start
                                      children: <TextSpan>[
                                        TextSpan (
                                          text: catalog.items[index].totalAmountAccordingQuantity == catalog.items[index].totalAmount
                                              ? ''
                                              : ' (' + new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((catalog.items[index].totalAmount/MULTIPLYING_FACTOR).toString())) + ')',
                                          style: TextStyle (
                                            fontWeight: FontWeight.w300,
                                            fontSize: 11.0,
                                            fontFamily: 'SF Pro Display',
                                            color: Color(0xFF6C6D77),
                                          ),
                                        )
                                      ]
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                catalog.items[index].quantityMaxPrice != QUANTITY_MAX_PRICE ? Container (
                                  padding: EdgeInsets.zero,
                                  width: 20.0,
                                  height: 20.0,
                                  child: IconButton (
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.zero,
                                    icon: Image.asset (
                                      'assets/images/logoInfo.png',
                                      //fit: BoxFit.fill,
                                      width: 20.0,
                                      height: 20.0,
                                    ),
                                    iconSize: 20.0,
                                    onPressed: () {
                                      final List<MultiPriceListElement> listMultiPriceListElement = [];
                                      if (catalog.items[index].quantityMaxPrice != QUANTITY_MAX_PRICE) {
                                        // There is multiprice for this product
                                        final item = new MultiPriceListElement(catalog.items[index].quantityMinPrice, catalog.items[index].quantityMaxPrice, catalog.items[index].totalAmount);
                                        listMultiPriceListElement.add(item);
                                        catalog.items[index].items.where((element) => element.partnerId != 1)
                                            .forEach((element) {
                                          final item = new MultiPriceListElement(element.quantityMinPrice, element.quantityMaxPrice, element.totalAmount);
                                          listMultiPriceListElement.add(item);
                                        });
                                      }
                                      DisplayDialog.displayInformationAsATable (context, 'Descuentos por cantidad comprada:', listMultiPriceListElement);
                                    },
                                  ),
                                ) : Container()
                              ],
                            ),
                          ),
                          Row (
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container (
                                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                                width: constraints.maxWidth,
                                child: Text (
                                  catalog.items[index].productName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.0,
                                    fontFamily: 'SF Pro Display',
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              )
                            ],
                          ),
                          Row (
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container (
                                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                                child: Text (
                                  catalog.items[index].businessName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12.0,
                                    fontFamily: 'SF Pro Display',
                                    fontStyle: FontStyle.normal,
                                    color: Color(0xFF6C6D77),
                                  ),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              )
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                            child: Visibility(
                              visible : catalog.items[index].purchased == 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Text (
                                            'Unids. mín. venta: ' +  catalog.items[index].minQuantitySell.toString() + ' ' + ((catalog.items[index].minQuantitySell > 1) ? catalog.items[index].idUnit.toString() + 's.' : catalog.items[index].idUnit.toString() + '.'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 11.0,
                                              fontFamily: 'SF Pro Display',
                                              fontStyle: FontStyle.normal,
                                              color: Color(0xFF6C6D77),
                                            ),
                                            textAlign: TextAlign.start
                                        ),
                                      )
                                    ],
                                  ),
                                  TextButton (
                                      onPressed: () {
                                        setState(() {
                                          catalog.add(catalog.getItem(index));
                                          cart.add(catalog.getItem(index));
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.all(2.0),
                                        decoration: BoxDecoration (
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(4.0),
                                            color: tanteLadenBrown500,
                                            gradient: LinearGradient(
                                              colors: <Color>[
                                                Color (0xFF833C26),
                                                Color (0xFF9A541F),
                                                Color (0xFFF9B806),
                                                Color (0XFFFFC107),
                                              ],
                                            )
                                        ),
                                        child: Container(
                                          //padding: EdgeInsets.all(3.0),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.circular(4.0),
                                              //color: colorFondo,
                                              color: tanteLadenBackgroundWhite
                                          ),
                                          child: Text (
                                            'Añadir',
                                            style: TextStyle (
                                              fontFamily: 'SF Pro Display',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          //height: 38,
                                        ),
                                        height: 40,
                                      )
                                  ),
                                ],
                              ),
                              replacement: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: Text(
                                          (catalog.items[index].purchased > 1) ? catalog.items[index].purchased.toString() + ' ' + catalog.items[index].idUnit + 's.' : catalog.items[index].purchased.toString() + ' ' + catalog.items[index].idUnit + '.',
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
                                      Container(
                                        child: Row (
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Visibility(
                                                visible: (catalog.items[index].purchased > 1) ? true : false,
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
                                                      if (catalog.items[index].purchased > 1) {
                                                        cart.remove(catalog.items[index]);
                                                        catalog.remove(catalog.items[index]);
                                                      }
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
                                                      onPressed: null,
                                                      icon: Image.asset(
                                                        'assets/images/logoDeleteKlein.png',
                                                        fit: BoxFit.fill,
                                                      ),
                                                      iconSize: 20.0,
                                                      padding: EdgeInsets.all(8.0),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      cart.remove(catalog.items[index]);
                                                      catalog.remove(catalog.items[index]);
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
                                                    cart.add(catalog.items[index]);
                                                    catalog.add(catalog.items[index]);
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
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }
          )
      ),
    );
  }
}
class _LargeScreen extends StatefulWidget {
  //_LargeScreen(
  //  this.listProductsAvail
  //);
  //final List<ProductAvail> listProductsAvail;
  _LargeScreenState createState() => _LargeScreenState();

}
class _LargeScreenState extends State<_LargeScreen> {

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var catalog = context.watch<Catalog>();
    var cart = context.read<Cart>();
    return SafeArea(
      child: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: GridView.builder(
              itemCount: catalog.numItems,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 200.0 / 281.0
              ),
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 0.0,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0)
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row (
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push (
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProductView(catalog.items[index])
                                      )
                                  );
                                },
                                child: Container(
                                  //padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 0.0),
                                  alignment: Alignment.center,
                                  width: constraints.maxWidth,
                                  child: AspectRatio(
                                    aspectRatio: 3.0 / 2.0,
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => CircularProgressIndicator(),
                                      imageUrl: SERVER_IP + IMAGES_DIRECTORY + catalog.items[index].productCode.toString() + '_0.gif',
                                      fit: BoxFit.scaleDown,
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container (
                                  child: Image.asset('assets/images/00001.png'),
                                  padding: EdgeInsets.only(right: 8.0),
                                ),
                                Container (
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text.rich (
                                    TextSpan (
                                        text: new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((catalog.items[index].totalAmountAccordingQuantity/MULTIPLYING_FACTOR).toString())),
                                        style: TextStyle (
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24.0,
                                          fontFamily: 'SF Pro Display',
                                        ),
                                        //textAlign: TextAlign.start
                                        children: <TextSpan>[
                                          TextSpan (
                                            text: catalog.items[index].totalAmountAccordingQuantity == catalog.items[index].totalAmount
                                                ? ''
                                                : ' (' + new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((catalog.items[index].totalAmount/MULTIPLYING_FACTOR).toString())) + ')',
                                            style: TextStyle (
                                              fontWeight: FontWeight.w300,
                                              fontSize: 11.0,
                                              fontFamily: 'SF Pro Display',
                                              color: Color(0xFF6C6D77),
                                            ),
                                          )
                                        ]
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                catalog.items[index].quantityMaxPrice != QUANTITY_MAX_PRICE ? Container(
                                  padding: EdgeInsets.zero,
                                  width: 20.0,
                                  height: 20.0,
                                  child: IconButton (
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.zero,
                                    icon: Image.asset (
                                      'assets/images/logoInfo.png',
                                      //fit: BoxFit.fill,
                                      width: 20.0,
                                      height: 20.0,
                                    ),
                                    iconSize: 20.0,
                                    onPressed: () {
                                      final List<MultiPriceListElement> listMultiPriceListElement = [];
                                      if (catalog.items[index].quantityMaxPrice != QUANTITY_MAX_PRICE) {
                                        // There is multi-price for this product
                                        final item = new MultiPriceListElement(catalog.items[index].quantityMinPrice, catalog.items[index].quantityMaxPrice, catalog.items[index].totalAmount);
                                        listMultiPriceListElement.add(item);
                                        catalog.items[index].items.where((element) => element.partnerId != 1)
                                            .forEach((element) {
                                          final item = new MultiPriceListElement(element.quantityMinPrice, element.quantityMaxPrice, element.totalAmount);
                                          listMultiPriceListElement.add(item);
                                        });
                                      }
                                      DisplayDialog.displayInformationAsATable (context, 'Descuentos por cantidad comprada:', listMultiPriceListElement);
                                    },
                                  ),
                                ) : Container()
                              ],
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                                width: constraints.maxWidth,
                                child: Text(
                                  catalog.items[index].productName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16.0,
                                    fontFamily: 'SF Pro Display',
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 2.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                                child: Text(
                                  catalog.items[index].businessName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12.0,
                                    fontFamily: 'SF Pro Display',
                                    fontStyle: FontStyle.normal,
                                    color: Color(0xFF6C6D77),
                                  ),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 2.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                                child: Text(
                                    'Unidades mínimas de venta: ' + catalog.items[index].minQuantitySell.toString() + ' ' + ((catalog.items[index].minQuantitySell > 1) ? catalog.items[index].idUnit.toString() + 's.' : catalog.items[index].idUnit.toString() + '.'),
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                            child: Visibility(
                              visible : catalog.items[index].purchased == 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          catalog.add(catalog.getItem(index));
                                          cart.add(catalog.getItem(index));
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(2.0),
                                        decoration: BoxDecoration (
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(4.0),
                                            color: tanteLadenBrown500,
                                            gradient: LinearGradient(
                                              colors: <Color>[
                                                Color (0xFF833C26),
                                                Color (0xFF9A541F),
                                                Color (0xFFF9B806),
                                                Color (0XFFFFC107),
                                              ],
                                            )
                                        ),
                                        child: Container(
                                          //padding: EdgeInsets.all(3.0),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.circular(4.0),
                                              //color: colorFondo,
                                              color: tanteLadenBackgroundWhite
                                          ),
                                          child: Text (
                                            'Añadir',
                                            style: TextStyle (
                                              fontFamily: 'SF Pro Display',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          //height: 38,
                                        ),
                                        height: 40,
                                      )
                                  ),
                                ],
                              ),
                              replacement: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: Text(
                                          (catalog.items[index].purchased > 1) ? catalog.items[index].purchased.toString() + ' ' + catalog.items[index].idUnit + 's.' : catalog.items[index].purchased.toString() + ' ' + catalog.items[index].idUnit + '.',
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
                                      Container(
                                        child: Row (
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Visibility(
                                                visible: (catalog.items[index].purchased > 1) ? true : false,
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
                                                      if (catalog.items[index].purchased > 1) {
                                                        cart.remove(catalog.items[index]);
                                                        catalog.remove(catalog.items[index]);
                                                      }
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
                                                    child: IconButton(
                                                      onPressed: null,
                                                      icon: Image.asset('assets/images/logoDeleteKlein.png'),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      cart.remove(catalog.items[index]);
                                                      catalog.remove(catalog.items[index]);
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
                                                    cart.add(catalog.items[index]);
                                                    catalog.add(catalog.items[index]);
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
                            ),
                          ),
                          //SizedBox(height: 15.0),
                        ],
                      );
                    },
                  ),
                );
              }
          )
      ),
    );
  }
}

