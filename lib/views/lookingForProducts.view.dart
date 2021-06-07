import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart' show NumberFormat hide TextDirection;

import 'package:plataforma_compras/models/catalog.model.dart';
import 'package:plataforma_compras/models/cart.model.dart';
import 'package:plataforma_compras/models/productAvail.model.dart';
import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';

class LookingForProducts extends StatefulWidget{
  @override
  _LookingForProductsState createState() {
    return _LookingForProductsState();
  }
}
class _LookingForProductsState extends State<LookingForProducts> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductAvail> _productList = [];
  Timer _throttle;

  @override
  void initState() {
    super.initState();
    _searchController.addListener (_onSearchChanged);
  }
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    if (_productList != null) _productList.clear();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        //automaticallyImplyLeading: false,   //if false and leading is null, leading space is given to title.
        //leading: null,
        backgroundColor: tanteLadenBackgroundWhite,
        title: _AccentColorOverride(
          color: tanteLadenOnPrimary,
          child: TextField (
            controller: _searchController,
            decoration: InputDecoration (
                prefixIcon: Icon(Icons.youtube_searched_for_outlined),
                labelText: 'Buscar producto',
                //helperText: 'Teclea el nombre de la calle que quieres buscar',
                suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _productList.clear();
                      });
                    }
                )
            ),
          ),
        ),
      ),
      body: buildBody(context)
    );
  }
  Widget buildBody (BuildContext context) {
    var catalog = context.read<Catalog>();
    var cart = context.read<Cart>();
    return LayoutBuilder(
      builder: (context, constraints) {
        return SafeArea(
            child: Padding (
                padding: const EdgeInsets.only(top: 5.0),
                child: GridView.builder (
                    itemCount: _productList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (constraints.maxWidth > 1200) ? 3 : 2,
                        childAspectRatio: (constraints.maxWidth > 1200) ? 200.0 / 281.0 : 200.0 / 303.0
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
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      //padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 0.0),
                                      alignment: Alignment.center,
                                      width: constraints.maxWidth,
                                      child: AspectRatio(
                                        aspectRatio: 3.0 / 2.0,
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) => CircularProgressIndicator(),
                                          //imageUrl: SERVER_IP + '/image/products/burger_king.png',
                                          imageUrl: SERVER_IP + IMAGES_DIRECTORY + _productList[index].productId.toString() + '_0.gif',
                                          fit: BoxFit.scaleDown,
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Image.asset('assets/images/00001.png'),
                                        padding: EdgeInsets.only(right: 8.0),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 3.0),
                                        child: Text(
                                            new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse(_productList[index].productPrice.toString())),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 24.0,
                                              fontFamily: 'SF Pro Display',
                                            ),
                                            textAlign: TextAlign.start
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row (
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container (
                                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                                      width: constraints.maxWidth,
                                      child: Text(
                                        _productList[index].productName,
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
                                Row (
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                              child: Text(
                                                  'Unid. mínim. venta: ' + catalog.items[index].minQuantitySell.toString(),
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
                                                (catalog.items[index].purchased > 1) ? catalog.items[index].purchased.toString() + ' uds.' : catalog.items[index].purchased.toString() + ' ud.',
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
            )
        );
      }
    );
  }
  _onSearchChanged() {
    if (_throttle?.isActive ?? false) _throttle.cancel();
    _throttle = Timer (const Duration(microseconds: 100), () {
      if (_searchController.text != '') {
        _getProductResults(_searchController.text);
      }
    });
  }
  void _getProductResults (String input) {
    List<ProductAvail> tempProductList = [];
    RegExp exp = RegExp (input, caseSensitive: false);
    var catalog = context.read<Catalog>();
    for (var i = 0; i < catalog.numItems; i++) {
      if (exp.hasMatch(catalog.getItem(i).productName)) {
        // Add the catalog element to the temporal list
        final itemCatalog = new ProductAvail(
          productId: catalog.getItem(i).productId,
          productName: catalog.getItem(i).productName,
          productDescription: catalog.getItem(i).productDescription,
          productType: catalog.getItem(i).productType,
          brand: catalog.getItem(i).brand,
          numImages: catalog.getItem(i).numImages,
          numVideos: catalog.getItem(i).numVideos,
          avail: catalog.getItem(i).avail,
          purchased: catalog.getItem(i).purchased,
          productPrice: catalog.getItem(i).productPrice,
          personeId: catalog.getItem(i).productId,
          personeName: catalog.getItem(i).personeName,
          businessName: catalog.getItem(i).businessName,
          email: catalog.getItem(i).email,
          taxId: catalog.getItem(i).taxId,
          taxApply: catalog.getItem(i).taxApply,
          idUnit: catalog.getItem(i).idUnit,
          remark: catalog.getItem(i).remark,
          minQuantitySell: catalog.getItem(i).minQuantitySell
        );
        tempProductList.add(itemCatalog);
      }
    }
    setState(() {
      _productList = tempProductList;
    });
  }
}
class _SmallScreen extends StatefulWidget {
  _SmallScreen(this.input, this.productList);
  final String input;
  final List<ProductAvail> productList;

  _SmallScreenState createState() => _SmallScreenState();
}
class _SmallScreenState extends State<_SmallScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductAvail> _productList = [];

  void _getProductResults (String input) {
    List<ProductAvail> tempProductList = [];
    RegExp exp = RegExp (input, caseSensitive: false);
    var catalog = context.read<Catalog>();
    for (var i = 0; i < catalog.numItems; i++) {
      if (exp.hasMatch(catalog.getItem(i).productName)) {
        tempProductList.add(catalog.getItem(i));
      }
    }
    setState(() {
      _productList = tempProductList;
    });
  }
  _onSearchChanged() {
    _getProductResults(_searchController.text);
    debugPrint ('Estoy en el _SmallScreenState. El valor de _searchController es: ' + _searchController.text);
  }
  @override
  void initState() {
    super.initState();
    _searchController.addListener (_onSearchChanged);
    _searchController.text = widget.input;
  }
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    if (_productList != null) _productList.clear();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var catalog = context.read<Catalog>();
    var cart = context.read<Cart>();
    return SafeArea(
      child: Padding (
        padding: const EdgeInsets.only(top: 5.0),
        child: GridView.builder (
          itemCount: _productList.length,
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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            //padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 0.0),
                            alignment: Alignment.center,
                            width: constraints.maxWidth,
                            child: AspectRatio(
                              aspectRatio: 3.0 / 2.0,
                              child: CachedNetworkImage(
                                placeholder: (context, url) => CircularProgressIndicator(),
                                //imageUrl: SERVER_IP + '/image/products/burger_king.png',
                                imageUrl: SERVER_IP + IMAGES_DIRECTORY + catalog.items[index].productId.toString() + '_0.gif',
                                fit: BoxFit.scaleDown,
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              child: Image.asset('assets/images/00001.png'),
                              padding: EdgeInsets.only(right: 8.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 3.0),
                              child: Text(
                                  new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse(_productList[index].productPrice.toString())),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 24.0,
                                    fontFamily: 'SF Pro Display',
                                  ),
                                  textAlign: TextAlign.start
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Row (
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container (
                            padding: EdgeInsets.only(left: 15.0, right: 15.0),
                            width: constraints.maxWidth,
                            child: Text(
                              _productList[index].productName,
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
                      SizedBox (height: 2.0),
                      Row (
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container (
                            padding: EdgeInsets.only(left: 15.0, right: 15.0),
                            width: constraints.maxWidth,
                            child: Text (
                              _productList[index].personeName,
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
                      SizedBox(height: 2.0),
                      Container(
                          padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                          child: Visibility(
                            visible: catalog.items[index].purchased == 0,
                            child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    catalog.add(catalog.getItem(index));
                                    cart.add(catalog.getItem(index));
                                  });
                                },
                                child: Container (
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
                                  child: Container (
                                    //padding: EdgeInsets.all(3.0),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(4.0),
                                      //color: colorFondo,
                                      color: tanteLadenBackgroundWhite,
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
                            replacement: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: Text(
                                        (catalog.items[index].purchased > 1) ? catalog.items[index].purchased.toString() + ' uds.' : catalog.items[index].purchased.toString() + ' ud.',
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
                                          Expanded (
                                            child: Visibility (
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
                                                      cart.remove(_productList[index]);
                                                      catalog.remove(_productList[index]);
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
                                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                                  child: IconButton(
                                                    onPressed: null,
                                                    icon: Image.asset('assets/images/logoDelete.png'),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    debugPrint('Estoy en la papelera.');
                                                    debugPrint('Los valores del elemento son:');
                                                    debugPrint('ProductId: ' + catalog.getItem(index).productId.toString());
                                                    debugPrint('ProductName: ' + catalog.getItem(index).productName);
                                                    debugPrint('Hash: ' + catalog.getItem(index).hashCode.toString());
                                                    cart.remove(_productList[index]);
                                                    catalog.remove(_productList[index]);
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
                                                  cart.add(_productList[index]);
                                                  catalog.add(_productList[index]);
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
                          )
                      ),
                    ],
                  );
                },
              ),
            );
          }
        )
      )
    );
  }
}
class _LargeScreen extends StatefulWidget {
  _LargeScreenState createState() => _LargeScreenState();
}
class _LargeScreenState extends State<_LargeScreen> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
class _AccentColorOverride extends StatelessWidget {
  const _AccentColorOverride ({Key key, this.color, this.child})
      : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(
        accentColor: color,
        brightness: Brightness.dark,
      ),
    );
  }
}