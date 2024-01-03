import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:plataforma_compras/models/catalog.model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show NumberFormat hide TextDirection;
import 'package:carousel_slider/carousel_slider.dart';

import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/utils/sizes.dart';
import 'package:plataforma_compras/models/cart.model.dart';
import 'package:plataforma_compras/models/multiPricesProductAvail.model.dart';

class ProductView extends StatelessWidget {
  final MultiPricesProductAvail currentProduct;
  ProductView (this.currentProduct);

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
          currentProduct.productName,
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
  final MultiPricesProductAvail currentProduct;
  _SmallScreen(this.currentProduct);
  _SmallScreenState createState() => _SmallScreenState(this.currentProduct);
}

class _SmallScreenState extends State<_SmallScreen> {
  final MultiPricesProductAvail currentProduct;
  _SmallScreenState(this.currentProduct);

  // private variables
  int _current = 0; // Var to save the current carousel image

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _current = 0;
  }
  @override
  Widget build(BuildContext context) {
    debugPrint('El productId es: ' + currentProduct.productId.toString());
    debugPrint('El numero de images es: ' + currentProduct.numImages.toString());
    // Process if the product has multiprice
    final List<_MultiPriceListElement> listMultiPriceListElement = [];
    if (currentProduct.quantityMaxPrice != 999999) {
      // There is multiprice for this product
      final item = new _MultiPriceListElement(currentProduct.quantityMinPrice, currentProduct.quantityMaxPrice, currentProduct.totalAmount);
      listMultiPriceListElement.add(item);
      currentProduct.items.where((element) => element.partnerId != 1)
          .forEach((element) {
        final item = new _MultiPriceListElement(element.quantityMinPrice, element.quantityMaxPrice, element.totalAmount);
        listMultiPriceListElement.add(item);
      });
    }
    return SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            var cart = context.read<Cart>();
            var catalog = context.read<Catalog>();
            final List<String> listImagesProduct = [];
            for (var i = 0; i < currentProduct.numImages; i++){
              listImagesProduct.add(SERVER_IP + IMAGES_DIRECTORY + currentProduct.productCode.toString() + '_' + i.toString() + '.gif');
            }
            return ListView (
              children: [
                currentProduct.numImages > 1
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CarouselSlider (
                      items: listImagesProduct.map((url) => Container(
                          child: AspectRatio (
                            aspectRatio: 3.0 / 2.0,
                            child: CachedNetworkImage(
                              placeholder: (context, url) => CircularProgressIndicator(),
                              imageUrl: url,
                              fit: BoxFit.scaleDown,
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                        )
                      ).toList(),
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 2.0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        }
                      ),
                    ),
                    Row (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: listImagesProduct.map((url) {
                        int index = listImagesProduct.indexOf(url);
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _current == index
                              ? Color.fromRGBO(0, 0, 0, 0.9)
                              : Color.fromRGBO(0, 0, 0, 0.4)
                          ),
                        );
                      }).toList(),
                    )
                  ],
                )
                : Container(
                  alignment: Alignment.center,
                  width: constraints.maxWidth,
                  child: AspectRatio(
                    aspectRatio: 3.0 / 2.0,
                    child: CachedNetworkImage(
                      placeholder: (context, url) => CircularProgressIndicator(),
                      imageUrl: SERVER_IP + IMAGES_DIRECTORY + currentProduct.productCode.toString() + '_0.gif',
                      fit: BoxFit.scaleDown,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                SizedBox (height: constraints.maxHeight * HeightInDpis_2),
                Padding(
                  padding: const EdgeInsets.fromLTRB (15.0, 0.0, 15.0, 0.0),
                  child: Row (
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Image.asset ('assets/images/00002.png'),
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                      ),
                      Padding (
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                            new NumberFormat.currency(locale:'en_US', symbol: '€', decimalDigits:2).format(double.parse((currentProduct.totalAmountAccordingQuantity/MULTIPLYING_FACTOR).toString())),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 40.0,
                              fontFamily: 'SF Pro Display',
                            ),
                            textAlign: TextAlign.start
                        ),
                      ),
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
                        currentProduct.productName,
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
                        currentProduct.businessName,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container (
                      padding: const EdgeInsets.only(left: 24),
                      child: Text(
                        'Unids. mínim. venta: ' + currentProduct.minQuantitySell.toString() + ' ' + ((currentProduct.minQuantitySell > 1) ? currentProduct.idUnit.toString() + 's.' : currentProduct.idUnit.toString() + '.'),
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
                    ),
                  ],
                ),
                SizedBox(height: constraints.maxHeight * HeightInDpis_24),
                currentProduct.quantityMaxPrice != 999999 ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 24),
                      child: Text(
                        'Descuentos por cantidad comprada:',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12.0,
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          color: Color(0xFF6C6D77),
                        ),
                      ),
                    )
                  ],
                ): Container(),
                currentProduct.quantityMaxPrice != 999999 ? Row (
                  children: <Widget>[
                    Container (
                      padding: const EdgeInsets.only(left: 24),
                      child: DataTable (
                        columns: const <DataColumn>[
                          DataColumn (
                            label: Text(
                              'Unds. desde',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12.0,
                                fontFamily: 'SF Pro Display',
                                fontStyle: FontStyle.normal,
                                color: Color(0xFF6C6D77),
                              ),
                            )
                          ),
                          DataColumn (
                            label: Text(
                              'Unds. hasta',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12.0,
                                fontFamily: 'SF Pro Display',
                                fontStyle: FontStyle.normal,
                                color: Color(0xFF6C6D77),
                              ),
                            )
                          ),
                          DataColumn (
                            label: Text(
                              'Precio',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12.0,
                                fontFamily: 'SF Pro Display',
                                fontStyle: FontStyle.normal,
                                color: Color(0xFF6C6D77),
                              ),
                            )
                          ),
                        ],
                        rows: List<DataRow>.generate(listMultiPriceListElement.length, (int index) => DataRow(
                            cells: [
                               DataCell (
                                 Text (
                                   listMultiPriceListElement[index].unitsFrom.toString(),
                                   style: TextStyle(
                                     fontWeight: FontWeight.w400,
                                     fontSize: 12.0,
                                     fontFamily: 'SF Pro Display',
                                     fontStyle: FontStyle.normal,
                                     color: Color(0xFF6C6D77),
                                   ),
                                 )
                               ),
                              DataCell (
                                  Text (
                                    listMultiPriceListElement[index].unitsTo.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                      fontFamily: 'SF Pro Display',
                                      fontStyle: FontStyle.normal,
                                      color: Color(0xFF6C6D77),
                                    ),
                                  )
                              ),
                              DataCell (
                                  Text (
                                    new NumberFormat.currency(locale:'en_US', symbol: '€', decimalDigits:2).format(double.parse((listMultiPriceListElement[index].price/MULTIPLYING_FACTOR).toString())),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                      fontFamily: 'SF Pro Display',
                                      fontStyle: FontStyle.normal,
                                      color: Color(0xFF6C6D77),
                                    ),
                                  )
                              )
                            ]
                        ))
                      )
                    ),
                  ],
                ) : Container(),
                SizedBox(height: constraints.maxHeight * HeightInDpis_35),
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
                    TextButton(
                        onPressed: () {
                          if (currentProduct.purchased > 0) {
                            setState(() {
                              cart.remove (currentProduct);
                              catalog.remove(currentProduct);
                            });
                          }
                        },
                        child: Container (
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration (
                              color: tanteLadenAmber500,
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
                        currentProduct.purchased > 1 ? currentProduct.purchased.toString() + ' ' + currentProduct.idUnit.toString() + 's.' : currentProduct.purchased == 0 ? currentProduct.purchased.toString() + ' ' + currentProduct.idUnit.toString() + 's.' : currentProduct.purchased.toString() + ' ' + currentProduct.idUnit.toString() + '.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24.0,
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            cart.add(currentProduct);
                            catalog.add(currentProduct);
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            color: tanteLadenAmber500,
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
              ],
            );
          },
        )
    );
  }
}
class _LargeScreen extends StatefulWidget {
  final MultiPricesProductAvail currentProduct;
  _LargeScreen(this.currentProduct);
  _LargeScreenState createState() => _LargeScreenState (this.currentProduct);
}
class _LargeScreenState extends State<_LargeScreen> {
  final MultiPricesProductAvail currentProduct;
  _LargeScreenState(this.currentProduct);

  // private variables
  int _current = 0; // Var to save the current carousel image

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _current = 0;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('El productId es: ' + currentProduct.productId.toString());
    debugPrint('El numero de images es: ' + currentProduct.numImages.toString());
    // Process if the product has multiprice
    final List<_MultiPriceListElement> listMultiPriceListElement = [];
    if (currentProduct.quantityMaxPrice != 999999) {
      // There is multiprice for this product
      final item = new _MultiPriceListElement(currentProduct.quantityMinPrice, currentProduct.quantityMaxPrice, currentProduct.totalAmount);
      listMultiPriceListElement.add(item);
      currentProduct.items.where((element) => element.partnerId != 1)
          .forEach((element) {
        final item = new _MultiPriceListElement(element.quantityMinPrice, element.quantityMaxPrice, element.totalAmount);
        listMultiPriceListElement.add(item);
      });
    }
    return SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            var cart = context.read<Cart>();
            var catalog = context.read<Catalog>();
            final List<String> listImagesProduct = [];
            for (var i = 0; i < currentProduct.numImages; i++){
              listImagesProduct.add(SERVER_IP + IMAGES_DIRECTORY + currentProduct.productCode.toString() + '_' + i.toString() + '.gif');
            }
            return ListView(
              children: [
                currentProduct.numImages > 1
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CarouselSlider (
                      items: listImagesProduct.map((url) => Container(
                        child: AspectRatio (
                          aspectRatio: 3.0 / 2.0,
                          child: CachedNetworkImage(
                            placeholder: (context, url) => CircularProgressIndicator(),
                            imageUrl: url,
                            fit: BoxFit.scaleDown,
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                      )
                      ).toList(),
                      options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: true,
                          aspectRatio: 2.0,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          }
                      ),
                    ),
                    Row (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: listImagesProduct.map((url) {
                        int index = listImagesProduct.indexOf(url);
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _current == index
                                  ? Color.fromRGBO(0, 0, 0, 0.9)
                                  : Color.fromRGBO(0, 0, 0, 0.4)
                          ),
                        );
                      }).toList(),
                    )
                  ],
                )
                    : Container(
                  alignment: Alignment.center,
                  width: constraints.maxWidth,
                  child: AspectRatio(
                    aspectRatio: 3.0 / 2.0,
                    child: CachedNetworkImage(
                      placeholder: (context, url) => CircularProgressIndicator(),
                      imageUrl: SERVER_IP + IMAGES_DIRECTORY + currentProduct.productCode.toString() + '_0.gif',
                      fit: BoxFit.scaleDown,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                //SizedBox(height: 20.0),
                SizedBox (height: constraints.maxHeight * HeightInDpis_2),
                Padding(
                  padding: const EdgeInsets.fromLTRB (15.0, 0.0, 15.0, 0.0),
                  child: Row (
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Image.asset ('assets/images/00002.png'),
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                      ),
                      Padding (
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                            new NumberFormat.currency(locale:'en_US', symbol: '€', decimalDigits:2).format(double.parse((currentProduct.totalAmountAccordingQuantity/MULTIPLYING_FACTOR).toString())),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 40.0,
                              fontFamily: 'SF Pro Display',
                            ),
                            textAlign: TextAlign.start
                        ),
                      ),
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
                        currentProduct.productName,
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
                        currentProduct.businessName,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container (
                      padding: const EdgeInsets.only(left: 24),
                      child: Text(
                        'Unids. mínim. venta: ' + currentProduct.minQuantitySell.toString() + ' ' + ((currentProduct.minQuantitySell > 1) ? currentProduct.idUnit.toString() + 's.' : currentProduct.idUnit.toString() + '.'),
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
                    ),
                  ],
                ),
                SizedBox(height: constraints.maxHeight * HeightInDpis_24),
                currentProduct.quantityMaxPrice != 999999 ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 24),
                      child: Text(
                        'Descuentos por cantidad comprada:',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12.0,
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          color: Color(0xFF6C6D77),
                        ),
                      ),
                    )
                  ],
                ): Container(),
                currentProduct.quantityMaxPrice != 999999 ? Row (
                  children: <Widget>[
                    Container (
                        padding: const EdgeInsets.only(left: 24),
                        child: DataTable (
                            columns: const <DataColumn>[
                              DataColumn (
                                  label: Text(
                                    'Unds. desde',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                      fontFamily: 'SF Pro Display',
                                      fontStyle: FontStyle.normal,
                                      color: Color(0xFF6C6D77),
                                    ),
                                  )
                              ),
                              DataColumn (
                                  label: Text(
                                    'Unds. hasta',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                      fontFamily: 'SF Pro Display',
                                      fontStyle: FontStyle.normal,
                                      color: Color(0xFF6C6D77),
                                    ),
                                  )
                              ),
                              DataColumn (
                                  label: Text(
                                    'Precio',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0,
                                      fontFamily: 'SF Pro Display',
                                      fontStyle: FontStyle.normal,
                                      color: Color(0xFF6C6D77),
                                    ),
                                  )
                              ),
                            ],
                            rows: List<DataRow>.generate(listMultiPriceListElement.length, (int index) => DataRow(
                                cells: [
                                  DataCell (
                                      Text (
                                        listMultiPriceListElement[index].unitsFrom.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.0,
                                          fontFamily: 'SF Pro Display',
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xFF6C6D77),
                                        ),
                                      )
                                  ),
                                  DataCell (
                                      Text (
                                        listMultiPriceListElement[index].unitsTo.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.0,
                                          fontFamily: 'SF Pro Display',
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xFF6C6D77),
                                        ),
                                      )
                                  ),
                                  DataCell (
                                      Text (
                                        new NumberFormat.currency(locale:'en_US', symbol: '€', decimalDigits:2).format(double.parse((listMultiPriceListElement[index].price/MULTIPLYING_FACTOR).toString())),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.0,
                                          fontFamily: 'SF Pro Display',
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xFF6C6D77),
                                        ),
                                      )
                                  )
                                ]
                            ))
                        )
                    ),
                  ],
                ) : Container(),
                SizedBox(height: constraints.maxHeight * HeightInDpis_35),
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
                    TextButton(
                        onPressed: () {
                          if (currentProduct.purchased > 0) {
                            setState(() {
                              cart.remove (currentProduct);
                              catalog.remove(currentProduct);
                            });
                          }
                        },
                        child: Container (
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration (
                              color: tanteLadenAmber500,
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
                        currentProduct.purchased > 1 ? currentProduct.purchased.toString() + ' ' + currentProduct.idUnit.toString() + 's.' : currentProduct.purchased == 0 ? currentProduct.purchased.toString() + ' ' + currentProduct.idUnit.toString() + 's.' : currentProduct.purchased.toString() + ' ' + currentProduct.idUnit.toString() + '.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24.0,
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            cart.add(currentProduct);
                            catalog.add(currentProduct);
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            color: tanteLadenAmber500,
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
              ],
            );
          },
        )
    );
  }
}

class _MultiPriceListElement {
  final double unitsFrom;
  final double unitsTo;
  final double price;
  _MultiPriceListElement(this.unitsFrom, this.unitsTo, this.price);
}