import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show NumberFormat hide TextDirection;

import 'package:plataforma_compras/models/productAvail.model.dart';
import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/utils/sizes.dart';
import 'package:plataforma_compras/models/cart.model.dart';
import 'package:plataforma_compras/controllers/product.controller.dart';

class ProductView extends StatelessWidget {
  final ProductAvail currentProduct;
  ProductView(this.currentProduct);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Image.asset('assets/images/leftArrow.png'),
          onPressed: (){
            Navigator.pop(context);
          }
        ),
        title: Text(
          currentProduct.product_name,
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 16.0,
            fontWeight: FontWeight.w500
          ),
          textAlign: TextAlign.left,
        ),
      ),
      body: ResponsiveWidget(
        smallScreen: _SmallScreen(currentProduct),
        largeScreen: _LargeScreen(currentProduct),
      ),
    );
  }
}
class _SmallScreen extends StatefulWidget {
  final ProductAvail currentProduct;
  _SmallScreen(this.currentProduct);
  _SmallScreenState createState() => _SmallScreenState(this.currentProduct);
}

class _SmallScreenState extends State<_SmallScreen> {
  final ProductAvail currentProduct;
  _SmallScreenState(this.currentProduct);

  // private variables
  ProductController _productController = new ProductController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (context.read<Cart>().numItems > 0) {
      var cart = context.read<Cart>();
      cart.items.forEach((element) { if (element.product_id == currentProduct.product_id) _productController.numUnits = element.avail;});
    }
  }
  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            var cart = context.read<Cart>();
            print('El alto de la pantalla es: ' + constraints.maxHeight.toString());
            print('El ancho de la pantalla es: ' + constraints.maxWidth.toString());
            return ListView(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: constraints.maxWidth,
                      child: AspectRatio(
                        aspectRatio: 3.0 / 2.0,
                        child: CachedNetworkImage(
                            placeholder: (context, url) => CircularProgressIndicator(),
                            imageUrl: SERVER_IP + '/image/products/burger_king.png',
                            fit: BoxFit.fitWidth
                        ),
                      ),
                    )
                  ],
                ),
                //SizedBox(height: 20.0),
                SizedBox (height: constraints.maxHeight * HeightInDpis_20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Image.asset('assets/images/00002.png'),
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                            new NumberFormat.currency(locale:'en_US', symbol: '€', decimalDigits:2).format(double.parse(currentProduct.product_price.toString())),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 40.0,
                              fontFamily: 'SF Pro Display',
                            ),
                            textAlign: TextAlign.start
                        ),
                      ),
                      Text(
                          currentProduct.brand,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 32.0,
                            fontFamily: 'SF Pro Display',
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF36B0F8),
                          ),
                          textAlign: TextAlign.start

                      )
                    ],
                  ),
                ),
                //SizedBox(height: 4.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 24.0),
                      width: constraints.maxWidth,
                      child: Text(
                        currentProduct.product_name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 24.0,
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
                //SizedBox(height: 2.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 24.0),
                      width: constraints.maxWidth,
                      child: Text(
                        currentProduct.product_description,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 24.0,
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
                //SizedBox(height: 2.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_2),
                //SizedBox(height: 2.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 24.0),
                      width: constraints.maxWidth,
                      child: Text(
                        currentProduct.brand,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 24.0,
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
                //SizedBox(height: 16.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_16),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 17),
                  child: Center(
                      child: Text(
                        currentProduct.remark,
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
                      )
                  ),
                ),
                //SizedBox(height: 16.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_16),
                Center(
                  child: Text(
                    'Cantidad',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 24.0,
                      fontFamily: 'SF Pro Display',
                      fontStyle: FontStyle.normal,
                      color: Color(0xFF6C6D77),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                        onPressed: () {
                          if (_productController.numUnits > 1){
                            setState(() {
                              _productController.decrement();
                            });
                            //var cart = context.read<Cart>();
                            cart.remove (currentProduct);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration (
                              color: tanteLadenBackgroundWhite,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: tanteLadenButtonBorderGray,
                                  width: 1
                              )
                          ),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            alignment: Alignment.center,
                            child: Text(
                              '-',
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 24.0,
                                  fontFamily: 'SF Pro Display',
                                  fontStyle: FontStyle.normal,
                                  color: tanteLadenButtonBorderGray
                              ),
                            ),
                          ),
                        )
                    ),
                    Padding(
                      //padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      padding: const EdgeInsets.only(left: WithInDpis_20, right: WithInDpis_20),
                      child: Text(
                        _productController.numUnits.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24.0,
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    FlatButton(
                        onPressed: () {
                          setState(() {
                            _productController.increment();
                          });
                          //var cart = context.read<Cart>();
                          cart.add(currentProduct);
                          debugPrint ('El importe es: ' + cart.totalPrice.toString());
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            color: tanteLadenBackgroundWhite,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF6C6D77),
                              width: 1,
                            ),
                          ),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            alignment: Alignment.center,
                            child: Text(
                              '+',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 24.0,
                                fontFamily: 'SF Pro Display',
                                fontStyle: FontStyle.normal,
                                color: tanteLadenButtonBorderGray,
                              ),
                            ),
                          ),
                        )
                    )
                  ],
                ),
                //SizedBox(height: 35.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_35),
                //SizedBox(height: 60.0,)
                SizedBox(height: constraints.maxHeight * HeightInDpis_60,)
              ],
            );
          },
        )
    );
  }
}
class _LargeScreen extends StatefulWidget {
  final ProductAvail currentProduct;
  _LargeScreen(this.currentProduct);
  _LargeScreenState createState() => _LargeScreenState (this.currentProduct);
}
class _LargeScreenState extends State<_LargeScreen> {
  final ProductAvail currentProduct;
  _LargeScreenState(this.currentProduct);

  // private variables
  ProductController _productController = new ProductController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (context.read<Cart>().numItems > 0) {
      var cart = context.read<Cart>();
      cart.items.forEach((element) { if (element.product_id == currentProduct.product_id) _productController.numUnits = element.avail;});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            print('El alto de la pantalla es: ' + constraints.maxHeight.toString());
            print('El ancho de la pantalla es: ' + constraints.maxWidth.toString());
            return ListView(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(flex: 1,),
                    Flexible(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.center,
                        width: constraints.maxWidth,
                        padding: EdgeInsets.only(top: 10.0),
                        child: AspectRatio(
                          aspectRatio: 3.0 / 2.0,
                          child: CachedNetworkImage(
                              placeholder: (context, url) => CircularProgressIndicator(),
                              imageUrl: SERVER_IP + '/image/products/burger_king.png',
                              fit: BoxFit.fitWidth
                          ),
                        ),
                      ),
                    ),
                    Spacer(flex: 1)
                  ],
                ),
                //SizedBox(height: 20.0),
                SizedBox (height: constraints.maxHeight * HeightInDpis_20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Image.asset('assets/images/00002.png'),
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                            new NumberFormat.currency(locale:'en_US', symbol: '€', decimalDigits:2).format(double.parse(currentProduct.product_price.toString())),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 40.0,
                              fontFamily: 'SF Pro Display',
                            ),
                            textAlign: TextAlign.start
                        ),
                      ),
                      Text(
                          currentProduct.brand,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 32.0,
                            fontFamily: 'SF Pro Display',
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF36B0F8),
                          ),
                          textAlign: TextAlign.start

                      )
                    ],
                  ),
                ),
                //SizedBox(height: 4.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 24.0),
                      width: constraints.maxWidth,
                      child: Text(
                        currentProduct.product_name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 24.0,
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
                //SizedBox(height: 2.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 24.0),
                      width: constraints.maxWidth,
                      child: Text(
                        currentProduct.product_description,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 24.0,
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
                //SizedBox(height: 2.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_2),
                //SizedBox(height: 2.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 24.0),
                      width: constraints.maxWidth,
                      child: Text(
                        currentProduct.brand,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 24.0,
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
                //SizedBox(height: 16.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_16),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 17),
                  child: Center(
                      child: Text(
                        currentProduct.remark,
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
                      )
                  ),
                ),
                //SizedBox(height: 16.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_16),
                Center(
                  child: Text(
                    'Cantidad',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 24.0,
                      fontFamily: 'SF Pro Display',
                      fontStyle: FontStyle.normal,
                      color: Color(0xFF6C6D77),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                        onPressed: () {
                          if (_productController.numUnits > 1){
                            setState(() {
                              _productController.decrement();
                            });
                            var cart = context.read<Cart>();
                            cart.remove(currentProduct);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration (
                              color: tanteLadenBackgroundWhite,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: tanteLadenButtonBorderGray,
                                  width: 1
                              )
                          ),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            alignment: Alignment.center,
                            child: Text(
                              '-',
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 24.0,
                                  fontFamily: 'SF Pro Display',
                                  fontStyle: FontStyle.normal,
                                  color: tanteLadenButtonBorderGray
                              ),
                            ),
                          ),
                        )
                    ),
                    Padding(
                      //padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      padding: const EdgeInsets.only(left: WithInDpis_20, right: WithInDpis_20),
                      child: Text(
                        _productController.numUnits.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24.0,
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    FlatButton(
                        onPressed: () {
                          setState(() {
                            _productController.increment();
                          });
                          var cart = context.read<Cart>();
                          cart.add(currentProduct);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            color: tanteLadenBackgroundWhite,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF6C6D77),
                              width: 1,
                            ),
                          ),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            alignment: Alignment.center,
                            child: Text(
                              '+',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 24.0,
                                fontFamily: 'SF Pro Display',
                                fontStyle: FontStyle.normal,
                                color: tanteLadenButtonBorderGray,
                              ),
                            ),
                          ),
                        )
                    )
                  ],
                ),
                //SizedBox(height: 35.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_35),
                //SizedBox(height: 60.0,)
                SizedBox(height: constraints.maxHeight * HeightInDpis_60,)
              ],
            );
          },
        )
    );

  }
}
class DetailWidget extends StatefulWidget {
  final ProductAvail currentProduct;
  DetailWidget(this.currentProduct);

  //DetailWidgetState createState() => DetailWidgetState(this.currentProduct);
  DetailWidgetState createState() => DetailWidgetState();
}
class DetailWidgetState extends State<DetailWidget> {
  //final ProductAvail currentProduct;
  //DetailWidgetState(this.currentProduct);
  DetailWidgetState();

  // private variables
  ProductController _productController = new ProductController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (context.read<Cart>().numItems > 0) {
      var cart = context.read<Cart>();
      cart.items.forEach((element) { if (element.product_id == widget.currentProduct.product_id) _productController.numUnits = element.avail;});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child : LayoutBuilder(
          builder: (context, constraints) {
            var cart = context.read<Cart>();
            debugPrint('PRODUCT.VIEW. El alto de la pantalla es: ' + constraints.maxHeight.toString());
            debugPrint('PRODUCT.VIEW. El ancho de la pantalla es: ' + constraints.maxWidth.toString());
            //debugPrint('El valor del item es: ' + this.currentProduct.product_name);
            debugPrint('El valor del item es: ' + widget.currentProduct.product_name);
            return ListView(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: constraints.maxWidth,
                      child: AspectRatio(
                        aspectRatio: 3.0 / 2.0,
                        child: CachedNetworkImage(
                            placeholder: (context, url) => CircularProgressIndicator(),
                            imageUrl: SERVER_IP + '/image/products/burger_king.png',
                            fit: BoxFit.fitWidth
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox (height: constraints.maxHeight * HeightInDpis_20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Image.asset('assets/images/00002.png'),
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                            new NumberFormat.currency(locale:'en_US', symbol: '€', decimalDigits:2).format(double.parse(widget.currentProduct.product_price.toString())),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 40.0,
                              fontFamily: 'SF Pro Display',
                            ),
                            textAlign: TextAlign.start
                        ),
                      ),
                      Text(
                          widget.currentProduct.brand,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 32.0,
                            fontFamily: 'SF Pro Display',
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF36B0F8),
                          ),
                          textAlign: TextAlign.start

                      )
                    ],
                  ),
                ),
                //SizedBox(height: 4.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 24.0),
                      width: constraints.maxWidth,
                      child: Text(
                        widget.currentProduct.product_name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 24.0,
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
                //SizedBox(height: 2.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 24.0),
                      width: constraints.maxWidth,
                      child: Text(
                        widget.currentProduct.product_description,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 24.0,
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
                //SizedBox(height: 2.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_2),
                //SizedBox(height: 2.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 24.0),
                      width: constraints.maxWidth,
                      child: Text(
                        widget.currentProduct.brand,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 24.0,
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
                //SizedBox(height: 16.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_16),
                //SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 17),
                  child: Center(
                      child: Text(
                        widget.currentProduct.remark,
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
                      )
                  ),
                ),
                //SizedBox(height: 16.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_16),
                Center(
                  child: Text(
                    'Cantidad',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 24.0,
                      fontFamily: 'SF Pro Display',
                      fontStyle: FontStyle.normal,
                      color: Color(0xFF6C6D77),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                        onPressed: () {
                          if (_productController.numUnits > 1){
                            setState(() {
                              _productController.decrement();
                            });
                            cart.remove(widget.currentProduct);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration (
                              color: tanteLadenBackgroundWhite,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: tanteLadenButtonBorderGray,
                                  width: 1
                              )
                          ),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            alignment: Alignment.center,
                            child: Text(
                              '-',
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 24.0,
                                  fontFamily: 'SF Pro Display',
                                  fontStyle: FontStyle.normal,
                                  color: tanteLadenButtonBorderGray
                              ),
                            ),
                          ),
                        )
                    ),
                    Padding(
                      //padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      padding: const EdgeInsets.only(left: WithInDpis_20, right: WithInDpis_20),
                      child: Text(
                        _productController.numUnits.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24.0,
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    FlatButton(
                        onPressed: () {
                          setState(() {
                            _productController.increment();
                          });
                          cart.add(widget.currentProduct);
                          debugPrint ('El importe es: ' + cart.totalPrice.toString());
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            color: tanteLadenBackgroundWhite,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF6C6D77),
                              width: 1,
                            ),
                          ),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            alignment: Alignment.center,
                            child: Text(
                              '+',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 24.0,
                                fontFamily: 'SF Pro Display',
                                fontStyle: FontStyle.normal,
                                color: tanteLadenButtonBorderGray,
                              ),
                            ),
                          ),
                        )
                    )
                  ],
                ),
                //SizedBox(height: 35.0),
                SizedBox(height: constraints.maxHeight * HeightInDpis_35),
                //SizedBox(height: 60.0,)
                SizedBox(height: constraints.maxHeight * HeightInDpis_60,),
              ],
            );
          },
        )
    );
  }

}