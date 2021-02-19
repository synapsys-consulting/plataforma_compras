import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart' show NumberFormat hide TextDirection;
import 'package:intl/date_symbol_data_local.dart';


import 'package:plataforma_compras/models/productAvail.model.dart';
import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/models/cart.model.dart';
import 'package:plataforma_compras/views/cart.view.dart';
import 'package:plataforma_compras/views/product.view.dart';
import 'package:plataforma_compras/utils/colors.util.dart';

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
  int _counter = 0;

  Future<List<ProductAvail>> itemsProductsAvailable;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemsProductsAvailable = _getProductsAvailable();
  }
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
  // Private method which get the available products from the database
  Future<List<ProductAvail>> _getProductsAvailable () async {
    //final String url = "$SERVER_IP/getProducts";
    final String url = "$SERVER_IP/getProductsAvail";

    print ('The string is: ' + url);
    final http.Response res = await http.get (
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          //'Authorization': jwt
        }
    );
    debugPrint('After the http call.');
    if (res.statusCode == 200){
      debugPrint ('The Rest API has responsed.');
      final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['products'].cast<Map<String, dynamic>>();
      debugPrint ('Entre medias de la api RESPONSE.');
      final List<ProductAvail> resultListProducts = resultListJson.map<ProductAvail>((json) => ProductAvail.fromJson(json)).toList();
      debugPrint ('Antes de terminar de responder la API.');
      return resultListProducts;
    } else {
      final List<ProductAvail> resultListProducts = [];
      return resultListProducts;
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
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        leading: Builder(
            builder: (BuildContext context) {
              return Container (
                alignment: Alignment.centerRight,
                child: IconButton(
                  //icon: Image.asset('assets/images/cart_fill_round.png'),
                  icon: Image.asset('assets/images/logoPantallaInicioAmber.png'),
                ),
              );
            }
        ),
        title: SizedBox(
          height: kToolbarHeight,
          child: Row (
            children: [
              Flexible(
                flex: 1,
                child: IconButton(
                  icon: Image.asset('assets/images/search_left.png'),
                  onPressed: null
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
                child: IconButton(
                  icon: Image.asset('assets/images/shopping_cart.png'),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => CartView()
                    ));
                  }
                ),
              )
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Image.asset('assets/images/profile.png'),
            tooltip: 'Perfil',
            onPressed: null
          )
        ],
        elevation: 0.0,
      ),
      body: FutureBuilder <List<ProductAvail>>(
          future: itemsProductsAvailable,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<ProductAvail>listProductsAvail = snapshot.data;
              debugPrint('Estamos en el Portrait.');
              return new ResponsiveWidget(
                largeScreen: _LargeScreen(listProductsAvail),
                smallScreen: _SmallScreen(listProductsAvail),
              );
            } else if (snapshot.hasError) {
              return Center(
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
  _SmallScreen (
    this.listProductsAvail,
  );
  final List<ProductAvail> listProductsAvail;

  _SmallScreenState createState() => _SmallScreenState();

}
class _SmallScreenState extends State<_SmallScreen> {
  @override
  Widget build(BuildContext context) {
    bool visible = true;
    return SafeArea(
      child: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: GridView.builder(
              itemCount: widget.listProductsAvail.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 200.0 / 303.0
              ),
              itemBuilder: (BuildContext context, int index) {
                var cart = context.watch<Cart>();
                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 0,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0)
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints){
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
                                    imageUrl: SERVER_IP + '/image/products/burger_king.png',
                                    fit: BoxFit.fitWidth,
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
                                      new NumberFormat.currency(locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse(widget.listProductsAvail[index].product_price.toString())),
                                      //new NumberFormat.currency(symbol: '€', decimalDigits:2).format(double.parse(listProductsAvail[index].product_price.toString())),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24.0,
                                        fontFamily: 'SF Pro Display',
                                      ),
                                      textAlign: TextAlign.start
                                  ),
                                ),
                                Text(
                                    widget.listProductsAvail[index].brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16.0,
                                      fontFamily: 'SF Pro Display',
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF36B0F8),
                                    ),
                                    textAlign: TextAlign.start

                                )
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
                                  widget.listProductsAvail[index].product_name,
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
                                width: constraints.maxWidth,
                                child: Text(
                                  widget.listProductsAvail[index].product_description,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12.0,
                                    fontFamily: 'SF Pro Display',
                                    fontStyle: FontStyle.normal,
                                    color: Color(0xFF36B0F8),
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
                                width: constraints.maxWidth,
                                child: Text(
                                  widget.listProductsAvail[index].brand,
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
                          SizedBox(height: 14.0),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                            child: Expanded(
                                child: Visibility(
                                  visible: visible,
                                  child: FlatButton(
                                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                      onPressed: () {

                                        //var cart = context.read<Cart>();
                                        //cart.add(listProductsAvail[index]);

                                        Navigator.push (
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ProductView(widget.listProductsAvail[index])
                                            )
                                        );
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
                                            color: tanteLadenBackgroundWhite,
                                          ),
                                          child: Text (
                                            'Comprar',
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
                                              (widget.listProductsAvail[index].avail > 1) ? widget.listProductsAvail[index].avail.toString() + ' uds.' : widget.listProductsAvail[index].avail.toString() + ' ud.',
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
                                                    visible: (widget.listProductsAvail[index].avail > 1) ? true : false,
                                                    child: FlatButton(
                                                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                                      child: Container (
                                                        alignment: Alignment.center,
                                                        decoration: BoxDecoration (
                                                          shape: BoxShape.rectangle,
                                                          borderRadius: BorderRadius.circular(18.0),
                                                          //color: colorFondo,
                                                          color: tanteLadenAmber500,
                                                        ),
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
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          cart.remove(cart.getItem(index));
                                                        });
                                                      },
                                                    ),
                                                    replacement: FlatButton(
                                                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                                      child: Container (
                                                        alignment: Alignment.center,
                                                        decoration: BoxDecoration (
                                                          shape: BoxShape.rectangle,
                                                          borderRadius: BorderRadius.circular(18.0),
                                                          //color: colorFondo,
                                                          color: tanteLadenAmber500,
                                                        ),
                                                        child: Container (
                                                          alignment: Alignment.center,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.rectangle,
                                                            borderRadius: BorderRadius.circular(18.0),
                                                            color: tanteLadenAmber500,
                                                          ),
                                                          padding: EdgeInsets.symmetric(vertical: 2.0),
                                                          child: IconButton(
                                                              icon: Image.asset('assets/images/logoDelete.png'),
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
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
                                                  child: FlatButton(
                                                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                                    child: Container (
                                                      //padding: EdgeInsets.all(3.0),
                                                      alignment: Alignment.center,
                                                      decoration: BoxDecoration (
                                                        shape: BoxShape.rectangle,
                                                        borderRadius: BorderRadius.circular(18.0),
                                                        //color: colorFondo,
                                                        color: tanteLadenAmber500,
                                                      ),
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
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
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
                                )
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
class _LargeScreen extends StatelessWidget {
  _LargeScreen(
    this.listProductsAvail
  );
  final List<ProductAvail> listProductsAvail;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: GridView.builder(
                    itemCount: listProductsAvail.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
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
                            debugPrint('HOME.VIEW. PRIMERA VEZ. Estoy dentro de la pantalla grande. El ancho de Card es: ' + constraints.maxWidth.toString());
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
                                          imageUrl: SERVER_IP + '/image/products/burger_king.png',
                                          fit: BoxFit.fitWidth,
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
                                            new NumberFormat.currency(locale:'en_US', symbol: '\$', decimalDigits:2).format(double.parse(listProductsAvail[index].product_price.toString())),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 24.0,
                                              fontFamily: 'SF Pro Display',
                                            ),
                                            textAlign: TextAlign.start
                                        ),
                                      ),
                                      Text(
                                          listProductsAvail[index].brand,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16.0,
                                            fontFamily: 'SF Pro Display',
                                            fontStyle: FontStyle.italic,
                                            color: Color(0xFF36B0F8),
                                          ),
                                          textAlign: TextAlign.start

                                      )
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
                                        listProductsAvail[index].product_name,
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
                                      width: constraints.maxWidth,
                                      child: Text(
                                        listProductsAvail[index].product_description,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 12.0,
                                          fontFamily: 'SF Pro Display',
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xFF36B0F8),
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
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15.0),
                                      child: Text(
                                          listProductsAvail[index].brand,
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
                                SizedBox(height: 14.0),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                                  child: FlatButton(
                                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                      onPressed: () {
                                        //var cart = context.read<Cart>();
                                        //cart.add(listProductsAvail[index]);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ProductView(listProductsAvail[index])
                                            )
                                        );
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
                                            'Comprar',
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
          ),
        ],
      ),
    );
    //return returnValue;
  }
}

class _HomeWidget extends StatelessWidget {
  _HomeWidget (
      this.listProductsAvail,
      );
  final List<ProductAvail> listProductsAvail;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: GridView.builder(
              itemCount: listProductsAvail.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 200.0 / 303.0
              ),
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 0,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0)
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints){
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
                                    imageUrl: SERVER_IP + '/image/products/burger_king.png',
                                    fit: BoxFit.fitWidth,
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
                                      new NumberFormat.currency(locale:'en_US', symbol: '€', decimalDigits:2).format(double.parse(listProductsAvail[index].product_price.toString())),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24.0,
                                        fontFamily: 'SF Pro Display',
                                      ),
                                      textAlign: TextAlign.start
                                  ),
                                ),
                                Text(
                                    listProductsAvail[index].brand,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16.0,
                                      fontFamily: 'SF Pro Display',
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF36B0F8),
                                    ),
                                    textAlign: TextAlign.start

                                )
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
                                  listProductsAvail[index].product_name,
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
                                width: constraints.maxWidth,
                                child: Text(
                                  listProductsAvail[index].product_description,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12.0,
                                    fontFamily: 'SF Pro Display',
                                    fontStyle: FontStyle.normal,
                                    color: Color(0xFF36B0F8),
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
                                width: constraints.maxWidth,
                                child: Text(
                                  listProductsAvail[index].brand,
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
                          SizedBox(height: 14.0),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                            child: FlatButton(
                                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                onPressed: () {
                                  //var cart = context.read<Cart>();
                                  //cart.add(listProductsAvail[index]);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProductView(listProductsAvail[index])
                                      )
                                  );
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
                                      color: tanteLadenBackgroundWhite,
                                    ),
                                    child: Text (
                                      'Comprar',
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
