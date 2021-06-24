import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:plataforma_compras/models/address.model.dart';
import 'package:plataforma_compras/models/addressesList.model.dart';
import 'package:plataforma_compras/models/defaultAddressList.model.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/views/address.view.dart';
import 'package:provider/provider.dart';

class ManageAddresses extends StatefulWidget {
  final String personeId;
  ManageAddresses (this.personeId);
  @override
  ManageAddressesState createState() {
    return ManageAddressesState();
  }
}
class ManageAddressesState extends State<ManageAddresses> {
  Future<List<Address>> itemsAdress;


  Future<List<Address>> _getLogisticAdresses() async {
    final Uri url = Uri.parse('$SERVER_IP/getLogisticAdresses/' + widget.personeId);
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
      final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['data'].cast<Map<String, dynamic>>();
      final List<Address> resultListAddresses = resultListJson.map<Address>((json) => Address.fromJson(json)).toList();
      Provider.of<DefaultAddressList>(context, listen: false).clearDefaultAddressList();
      Provider.of<AddressesList>(context, listen: false).clearAddressList();
      resultListAddresses.forEach((element){
        if (element.statusId == 'D') {
          Provider.of<DefaultAddressList>(context, listen: false).add(element);
        } else {
          Provider.of<AddressesList>(context, listen: false).add(element);
        }
      });
      debugPrint ('Justo antes de retornar.');
      return resultListAddresses;
    } else {
      final List<Address> resultListProducts = [];
      return resultListProducts;
    }
  }
  @override
  void initState() {
    super.initState();
    itemsAdress = _getLogisticAdresses();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton (
          icon: Image.asset ('assets/images/leftArrow.png'),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
        title: Text (
          'Direcciones',
          style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 20.0,
              fontWeight: FontWeight.w300,
              color: tanteLadenIconBrown
          ),
        ),
        actions: [
          Container(
            alignment: Alignment.center,
            child: TextButton(
              child: Text (
                'Añadir',
                style: TextStyle (
                  fontFamily: 'SF Pro Display',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w900,
                  color: tanteLadenIconBrown,
                ),
                textAlign: TextAlign.right,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => AddressView(widget.personeId, COME_FROM_DRAWER)
                  // const COME_FROM_DRAWER = 1;
                  // const COME_FROM_ANOTHER = 2;
                  // 2: ist called from purchase management; 1: ist called from the Drawer option
                ));
              },
            ),
          )
        ],
      ),
      body: FutureBuilder <List<Address>>(
        future: itemsAdress,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ResponsiveWidget(
              smallScreen: _SmallScreenView(snapshot.data, widget.personeId),
              largeScreen: _LargeScreenView(snapshot.data, widget.personeId),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column (
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text ('Error. ${snapshot.error}')
                ],
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
        },
      ),
    );
  }
}
class _SmallScreenView extends StatefulWidget {
  final List<Address> itemsAddress;
  final String personeId;
  _SmallScreenView (this.itemsAddress, this.personeId);
  @override
  _SmallScreenViewState createState() {
    return _SmallScreenViewState();
  }
}
class _SmallScreenViewState extends State<_SmallScreenView> {
  @override
  Widget build(BuildContext context) {
    var addressesList = context.watch<AddressesList>();
    var defaultAddressList = context.watch<DefaultAddressList>();
    return (defaultAddressList.numItems + addressesList.numItems > 0)
    ? SafeArea (
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox (height: 40.0),
          Flexible (
            flex: 1,
            child: Container (
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Text (
                'Dirección seleccionada',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  fontFamily: 'SF Pro Display',
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Flexible (
            flex: 2,
            child: ListView.builder (
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                itemCount: defaultAddressList.numItems,
                itemBuilder: (context, index) {
                  return Card (
                      elevation: 4.0,
                      child: ListTile (
                        leading: Image.asset (
                          'assets/images/logoDefaultAddress.png',
                          width: 20,
                        ),
                        title: Text (
                          defaultAddressList.getItem(index).streetName + ', ' + defaultAddressList.getItem(index).streetNumber,
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
                                defaultAddressList.getItem(index).flatDoor,
                                style: TextStyle (
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16.0,
                                  fontFamily: 'SF Pro Display',
                                  fontStyle: FontStyle.normal,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                defaultAddressList.getItem(index).postalCode + ' ' + defaultAddressList.getItem(index).locality,
                                style: TextStyle (
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16.0,
                                  fontFamily: 'SF Pro Display',
                                  fontStyle: FontStyle.normal,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                defaultAddressList.getItem(index).optional,
                                style: TextStyle (
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16.0,
                                  fontFamily: 'SF Pro Display',
                                  fontStyle: FontStyle.normal,
                                  color: Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  );
                }
            ),
          ),
          Flexible (
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Visibility (
                visible: addressesList.numItems > 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text (
                      'Otras direcciones',
                      style: TextStyle (
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        itemCount: addressesList.numItems,
                        itemBuilder: ( BuildContext context, int index) {
                          return Card(
                            elevation: 4.0,
                            child: ListTile(
                              leading: (addressesList.items[index].statusId != "D")
                                  ? Image.asset('assets/images/logoPlace.png')
                                  : IconButton(onPressed: null, icon: Icon(Icons.adjust)),
                              title: Text (
                                addressesList.items[index].streetName + ', ' + addressesList.items[index].streetNumber,
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
                                      addressesList.items[index].flatDoor,
                                      style: TextStyle (
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16.0,
                                        fontFamily: 'SF Pro Display',
                                        fontStyle: FontStyle.normal,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      addressesList.items[index].postalCode + ' ' + addressesList.items[index].locality,
                                      style: TextStyle (
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16.0,
                                        fontFamily: 'SF Pro Display',
                                        fontStyle: FontStyle.normal,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Text(
                                      addressesList.items[index].optional,
                                      style: TextStyle (
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16.0,
                                        fontFamily: 'SF Pro Display',
                                        fontStyle: FontStyle.normal,
                                        color: Colors.black38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      ),
                    )
                  ],
                ),
                replacement: Container (),
              )
            )
          ),
        ],
      )
    )
    : SafeArea (
      child: Center (
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/emptyAddress.png'),
            SizedBox(height: 30.0,),
            Text(
              'No hay dirección',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                fontFamily: 'SF Pro Display',
                fontStyle: FontStyle.normal,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10.0,),
            Text(
              'Añade donde quieres recibir tu pedido',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                fontFamily: 'SF Pro Display',
                fontStyle: FontStyle.normal,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.0,),
            Row(
              children: [
                Flexible(child: Container(), flex: 1,),
                Flexible(
                  flex: 2,
                  child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => AddressView(widget.personeId, COME_FROM_DRAWER)
                          // const COME_FROM_DRAWER = 1;
                          // const COME_FROM_ANOTHER = 2;
                          // 2: ist called from purchase management; 1: ist called from the Drawer option
                        ));
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
                            'Añadir dirección',
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
                Flexible(child: Container(), flex: 1,)
              ],
            ),
          ],
        ),
      )
    );
  }
}
class _LargeScreenView extends StatefulWidget {
  final List<Address> itemsAddress;
  final String personeId;
  _LargeScreenView (this.itemsAddress, this.personeId);
  @override
  _LargeScreenViewState createState() {
    return _LargeScreenViewState();
  }
}
class _LargeScreenViewState extends State<_LargeScreenView> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}