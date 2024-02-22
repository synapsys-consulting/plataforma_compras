import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/models/purchase.model.dart';
import 'package:plataforma_compras/models/purchaseStatus.model.dart';
import 'package:plataforma_compras/controllers/purchase.controller.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/views/purchaseDetail.view.dart';
import 'package:plataforma_compras/utils/showSnackBar.dart';
import 'package:plataforma_compras/utils/pleaseWaitWidget.dart';

class PurchaseView extends StatelessWidget {
  final int userId;
  final int partnerId;
  final String userRole;
  PurchaseView(this.userId, this.partnerId, this.userRole);

  final PurchaseController _controller = new PurchaseController ();
  @override
  Widget build (BuildContext context) {
    return Scaffold (
      appBar: AppBar (
        elevation: 0.0,
        leading: IconButton(
          icon: Image.asset('assets/images/leftArrow.png'),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
      ),
      body: FutureBuilder <List<Purchase>> (
        future: _controller.getPurchasesByUserId(userId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new ResponsiveWidget (
              largeScreen: _LargeScreen (snapshot.data!, this.userId, this.partnerId, this.userRole),
              mediumScreen: _MediumScreen(snapshot.data!, this.userId, this.partnerId, this.userRole),
              smallScreen: _SmallScreen (snapshot.data!, this.userId, this.partnerId, this.userRole),
            );
          } else if (snapshot.hasError) {
            return Center (
              child: Column (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error. ${snapshot.error}')
                  ]
              ),
            );
          } else {
            return Center (
              child: SizedBox (
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
  final List<Purchase> itemsPurchase;
  final int userId;
  final int partnerId;
  final String userRole;
  _SmallScreen(this.itemsPurchase, this.userId, this.partnerId, this.userRole);

  _SmallScreenState createState() => _SmallScreenState();
}
class _SmallScreenState extends State<_SmallScreen> {
  bool _pleaseWait = false;
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));

  _showPleaseWait(bool b) {
    setState(() {
      _pleaseWait = b;
    });
  }
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Widget tmpBuilder = ListView.builder (
        itemCount: widget.itemsPurchase.length,
        itemBuilder: (BuildContext context, int index) {
          return Card (
              elevation: 4.0,
              child: ListTile (
                leading: Column (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text (
                      DateFormat('dd', 'es_ES').format(widget.itemsPurchase[index].orderDate),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    Text (
                      DateFormat('MMM', 'es_ES').format(widget.itemsPurchase[index].orderDate),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    Text (
                      DateFormat('yyyy', 'es_ES').format(widget.itemsPurchase[index].orderDate),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                title: Text (
                  widget.itemsPurchase[index].showName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    fontFamily: 'SF Pro Display',
                    fontStyle: FontStyle.normal,
                    color: Colors.black,
                  ),
                ),
                subtitle: Row (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded (
                      child: Column (
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: 'Pedido: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: widget.itemsPurchase[index].orderId.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                                text: 'Estado: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: widget.itemsPurchase[index].allStatus,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                          RichText (
                            text: TextSpan (
                                text: 'Items: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan (
                                      text: widget.itemsPurchase[index].items.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded (
                      child: Column (
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: 'Importe: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].totalBeforeDiscountWithoutTax/MULTIPLYING_FACTOR).toString())),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                                text: 'Modificación: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: widget.itemsPurchase[index].discountAmount/MULTIPLYING_FACTOR > 0 ? '+' + new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].discountAmount/MULTIPLYING_FACTOR).toString())) : new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].discountAmount/MULTIPLYING_FACTOR).toString())),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                                text: 'Subtotal: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].totalAfterDiscountWithoutTax/MULTIPLYING_FACTOR).toString())),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                                text: 'IVA: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].taxAmount/MULTIPLYING_FACTOR).toString())),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                                text: 'Total: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].totalAmount/MULTIPLYING_FACTOR).toString())),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                trailing: Column (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded (
                      child: (widget.itemsPurchase[index].numStatus == 1 && widget.itemsPurchase[index].possibleStatusToTransitionTo.length > 0 && widget.itemsPurchase[index].possibleStatusToTransitionTo[0].priority == 1 && widget.partnerId != DEFAULT_PARTNER_ID) ? IconButton (
                        padding: const EdgeInsets.all(5.0),
                        icon: Image.asset(
                          'assets/images/logoPlay.png',
                          fit: BoxFit.scaleDown,
                        ),
                        onPressed: () async {
                          try {
                            debugPrint ('Estoy en el onPressed');
                            _showPleaseWait(true);
                            final Uri url = Uri.parse('$SERVER_IP/purchaseStateTransition/' + widget.itemsPurchase[index].orderId.toString() + '/' + widget.itemsPurchase[index].providerName);
                            final http.Response res = await http.put (
                                url,
                                headers: <String, String>{
                                  'Content-Type': 'application/json; charset=UTF-8',
                                  //'Authorization': jwt
                                },
                                body: jsonEncode(<String, String>{
                                  'user_id': widget.userId.toString(),
                                  'next_state': widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).destinationStateId, // Always exists at least the next state if this icon has appeared
                                })
                            ).timeout(TIMEOUT);
                            if (res.statusCode == 200) {
                              _showPleaseWait(false);
                              debugPrint ('The Rest API has responsed.');
                              final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['nextStatesToTransitionTo'].cast<Map<String, dynamic>>();
                              debugPrint ('Entre medias de la api RESPONSE.');
                              final List<PurchaseStatus> resultListProducts = resultListJson.map<PurchaseStatus>((json) => PurchaseStatus.fromJson(json)).toList();
                              setState(() {
                                widget.itemsPurchase[index].allStatus = widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).statusName;
                                widget.itemsPurchase[index].possibleStatusToTransitionTo = resultListProducts;
                              });
                            } else {
                              _showPleaseWait(false);
                              ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'], error: true);
                            }
                          } catch (e) {
                            _showPleaseWait(false);
                            ShowSnackBar.showSnackBar(context, e.toString(), error: true);
                          }
                        },
                      ) : Container(width: 20, height: 20, padding: EdgeInsets.zero),
                    ),
                    Expanded (
                      child: (widget.itemsPurchase[index].numStatus == 1 && widget.itemsPurchase[index].possibleStatusToTransitionTo.length > 0 && widget.partnerId != DEFAULT_PARTNER_ID) ? PopupMenuButton (
                          icon: Icon (Icons.more_horiz, color: Colors.black,),
                          itemBuilder: (BuildContext context) =>
                              widget.itemsPurchase[index].possibleStatusToTransitionTo.map((e) {
                                return PopupMenuItem (
                                  child: Center(child: Text(e.statusName),),
                                  value: e,
                                );
                              }).toList(),
                          onSelected: (PurchaseStatus result) async {
                            try {
                              debugPrint ('Estoy en el onSelected');
                              _showPleaseWait(true);
                              final Uri url = Uri.parse ('$SERVER_IP/purchaseStateTransition/' + widget.itemsPurchase[index].orderId.toString() + '/' + widget.itemsPurchase[index].providerName);
                              final http.Response res = await http.put (
                                  url,
                                  headers: <String, String>{
                                    'Content-Type': 'application/json; charset=UTF-8',
                                    //'Authorization': jwt
                                  },
                                  body: jsonEncode(<String, String>{
                                    'user_id': widget.userId.toString(),
                                    'next_state': result.destinationStateId,
                                  })
                              ).timeout(TIMEOUT);
                              if (res.statusCode == 200) {
                                _showPleaseWait(false);
                                debugPrint ('The Rest API has responsed.');
                                final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['nextStatesToTransitionTo'].cast<Map<String, dynamic>>();
                                debugPrint ('Entre medias de la api RESPONSE.');
                                final List<PurchaseStatus> resultListProducts = resultListJson.map<PurchaseStatus>((json) => PurchaseStatus.fromJson(json)).toList();
                                setState(() {
                                  widget.itemsPurchase[index].allStatus = result.statusName;
                                  widget.itemsPurchase[index].possibleStatusToTransitionTo = resultListProducts;
                                });
                              } else {
                                _showPleaseWait(false);
                                ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'], error: true);
                              }
                            } catch (e) {
                              _showPleaseWait(false);
                              ShowSnackBar.showSnackBar(context, e.toString(), error: true);
                            }
                          },
                      ) : Container (
                        padding: EdgeInsets.zero,
                        width: 20,
                        height: 20,
                      ),
                    )
                  ],
                ),
                onTap: () async {
                  debugPrint('El partenerId del usuario es: ' + widget.partnerId.toString());
                  final bool purchaseDetailStateChanged = await Navigator.push (context, MaterialPageRoute (
                      builder: (context) => PurchaseDetailView (widget.userId, widget.itemsPurchase[index], widget.partnerId, widget.userRole)
                  ));
                  if (purchaseDetailStateChanged) {
                    // I load the data again
                    widget.itemsPurchase.clear();
                    final PurchaseController controller = new PurchaseController ();
                    final newPurchaseList = await controller.getPurchasesByUserId (widget.userId);
                    if (newPurchaseList.length  > 0) {

                    }
                    newPurchaseList.forEach((element) {
                      widget.itemsPurchase.add(element);
                    });
                    setState(() {

                    });
                  }
                },
              )
          );
        }
    );
    return SafeArea (
      child: _pleaseWait ? Stack (
        key: ObjectKey ("stack"),
        alignment: AlignmentDirectional.center,
        children: [tmpBuilder, _pleaseWaitWidget],
      ) : Stack (
        key: ObjectKey ("stack"),
        children: [tmpBuilder],
      )
    );
  }
}
class _MediumScreen extends StatefulWidget {
  final List<Purchase> itemsPurchase;
  final int userId;
  final int partnerId;
  final String userRole;
  _MediumScreen(this.itemsPurchase, this.userId, this.partnerId, this.userRole);

  _MediumScreenState createState() => _MediumScreenState();
}
class _MediumScreenState extends State<_MediumScreen> {
  bool _pleaseWait = false;
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));

  _showPleaseWait(bool b) {
    setState(() {
      _pleaseWait = b;
    });
  }
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Widget tmpBuilder = ListView.builder (
        itemCount: widget.itemsPurchase.length,
        itemBuilder: (BuildContext context, int index) {
          return Card (
              elevation: 4.0,
              child: ListTile (
                leading: Column (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text (
                      DateFormat('dd', 'es_ES').format(widget.itemsPurchase[index].orderDate),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    Text (
                      DateFormat('MMM', 'es_ES').format(widget.itemsPurchase[index].orderDate),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    Text (
                      DateFormat('yyyy', 'es_ES').format(widget.itemsPurchase[index].orderDate),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                title: Text (
                  widget.itemsPurchase[index].showName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    fontFamily: 'SF Pro Display',
                    fontStyle: FontStyle.normal,
                    color: Colors.black,
                  ),
                ),
                subtitle: Row (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded (
                      child: Column (
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: 'Pedido: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: widget.itemsPurchase[index].orderId.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                                text: 'Estado: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: widget.itemsPurchase[index].allStatus,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                          RichText (
                            text: TextSpan (
                                text: 'Items: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan (
                                      text: widget.itemsPurchase[index].items.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded (
                      child: Column (
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: 'Importe: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].totalBeforeDiscountWithoutTax/MULTIPLYING_FACTOR).toString())),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                                text: 'Modificación: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: widget.itemsPurchase[index].discountAmount/MULTIPLYING_FACTOR > 0 ? '+' + new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].discountAmount/MULTIPLYING_FACTOR).toString())) : new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].discountAmount/MULTIPLYING_FACTOR).toString())),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                                text: 'Subtotal: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].totalAfterDiscountWithoutTax/MULTIPLYING_FACTOR).toString())),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                                text: 'IVA: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].taxAmount/MULTIPLYING_FACTOR).toString())),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                                text: 'Total: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].totalAmount/MULTIPLYING_FACTOR).toString())),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ]
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                trailing: Column (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded (
                      child: (widget.itemsPurchase[index].numStatus == 1 && widget.itemsPurchase[index].possibleStatusToTransitionTo.length > 0 && widget.itemsPurchase[index].possibleStatusToTransitionTo[0].priority == 1 && widget.partnerId != DEFAULT_PARTNER_ID) ? IconButton (
                        padding: const EdgeInsets.all(5.0),
                        icon: Image.asset(
                          'assets/images/logoPlay.png',
                          fit: BoxFit.scaleDown,
                        ),
                        onPressed: () async {
                          try {
                            debugPrint ('Estoy en el onPressed');
                            _showPleaseWait(true);
                            final Uri url = Uri.parse('$SERVER_IP/purchaseStateTransition/' + widget.itemsPurchase[index].orderId.toString() + '/' + widget.itemsPurchase[index].providerName);
                            final http.Response res = await http.put (
                                url,
                                headers: <String, String>{
                                  'Content-Type': 'application/json; charset=UTF-8',
                                  //'Authorization': jwt
                                },
                                body: jsonEncode(<String, String>{
                                  'user_id': widget.userId.toString(),
                                  'next_state': widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).destinationStateId, // Always exists at least the next state if this icon has appeared
                                })
                            ).timeout(TIMEOUT);
                            if (res.statusCode == 200) {
                              _showPleaseWait(false);
                              debugPrint ('The Rest API has responsed.');
                              final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['nextStatesToTransitionTo'].cast<Map<String, dynamic>>();
                              debugPrint ('Entre medias de la api RESPONSE.');
                              final List<PurchaseStatus> resultListProducts = resultListJson.map<PurchaseStatus>((json) => PurchaseStatus.fromJson(json)).toList();
                              setState(() {
                                widget.itemsPurchase[index].allStatus = widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).statusName;
                                widget.itemsPurchase[index].possibleStatusToTransitionTo = resultListProducts;
                              });
                            } else {
                              _showPleaseWait(false);
                              ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'], error: true);
                            }
                          } catch (e) {
                            _showPleaseWait(false);
                            ShowSnackBar.showSnackBar(context, e.toString(), error: true);
                          }
                        },
                      ) : Container(width: 20, height: 20, padding: EdgeInsets.zero),
                    ),
                    Expanded (
                      child: (widget.itemsPurchase[index].numStatus == 1 && widget.itemsPurchase[index].possibleStatusToTransitionTo.length > 0 && widget.partnerId != DEFAULT_PARTNER_ID) ? PopupMenuButton (
                        icon: Icon (Icons.more_horiz, color: Colors.black,),
                        itemBuilder: (BuildContext context) =>
                            widget.itemsPurchase[index].possibleStatusToTransitionTo.map((e) {
                              return PopupMenuItem (
                                child: Center(child: Text(e.statusName),),
                                value: e,
                              );
                            }).toList(),
                        onSelected: (PurchaseStatus result) async {
                          try {
                            debugPrint ('Estoy en el onSelected');
                            _showPleaseWait(true);
                            final Uri url = Uri.parse ('$SERVER_IP/purchaseStateTransition/' + widget.itemsPurchase[index].orderId.toString() + '/' + widget.itemsPurchase[index].providerName);
                            final http.Response res = await http.put (
                                url,
                                headers: <String, String>{
                                  'Content-Type': 'application/json; charset=UTF-8',
                                  //'Authorization': jwt
                                },
                                body: jsonEncode(<String, String>{
                                  'user_id': widget.userId.toString(),
                                  'next_state': result.destinationStateId,
                                })
                            ).timeout(TIMEOUT);
                            if (res.statusCode == 200) {
                              _showPleaseWait(false);
                              debugPrint ('The Rest API has responsed.');
                              final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['nextStatesToTransitionTo'].cast<Map<String, dynamic>>();
                              debugPrint ('Entre medias de la api RESPONSE.');
                              final List<PurchaseStatus> resultListProducts = resultListJson.map<PurchaseStatus>((json) => PurchaseStatus.fromJson(json)).toList();
                              setState(() {
                                widget.itemsPurchase[index].allStatus = result.statusName;
                                widget.itemsPurchase[index].possibleStatusToTransitionTo = resultListProducts;
                              });
                            } else {
                              _showPleaseWait(false);
                              ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'], error: true);
                            }
                          } catch (e) {
                            _showPleaseWait(false);
                            ShowSnackBar.showSnackBar(context, e.toString(), error: true);
                          }
                        },
                      ) : Container (
                        padding: EdgeInsets.zero,
                        width: 20,
                        height: 20,
                      ),
                    )
                  ],
                ),
                onTap: () async {
                  debugPrint('El partenerId del usuario es: ' + widget.partnerId.toString());
                  final bool purchaseDetailStateChanged = await Navigator.push (context, MaterialPageRoute (
                      builder: (context) => PurchaseDetailView (widget.userId, widget.itemsPurchase[index], widget.partnerId, widget.userRole)
                  ));
                  if (purchaseDetailStateChanged) {
                    // I load the data again
                    widget.itemsPurchase.clear();
                    final PurchaseController controller = new PurchaseController ();
                    final newPurchaseList = await controller.getPurchasesByUserId (widget.userId);
                    if (newPurchaseList.length  > 0) {

                    }
                    newPurchaseList.forEach((element) {
                      widget.itemsPurchase.add(element);
                    });
                    setState(() {

                    });
                  }
                },
              )
          );
        }
    );
    return SafeArea (
        child: _pleaseWait ? Stack (
          key: ObjectKey ("stack"),
          alignment: AlignmentDirectional.center,
          children: [tmpBuilder, _pleaseWaitWidget],
        ) : Stack (
          key: ObjectKey ("stack"),
          children: [tmpBuilder],
        )
    );
  }
}
class _LargeScreen extends StatefulWidget {
  final List<Purchase> itemsPurchase;
  final int userId;
  final int partnerId;
  final String userRole;
  _LargeScreen(this.itemsPurchase, this.userId, this.partnerId, this.userRole);

  _LargeScreenState createState() => _LargeScreenState();
}
class _LargeScreenState extends State<_LargeScreen>{
  bool _pleaseWait = false;
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));

  _showPleaseWait(bool b) {
    setState(() {
      _pleaseWait = b;
    });
  }
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build (BuildContext context) {
    Widget tmpBuilder = ListView.builder (
        itemCount: widget.itemsPurchase.length,
        itemBuilder: (BuildContext context, int index) {
          return Card (
            elevation: 4.0,
            child: ListTile (
              leading: Column (
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text (
                    DateFormat('dd', 'es_ES').format(widget.itemsPurchase[index].orderDate),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  Text (
                    DateFormat('MMM', 'es_ES').format(widget.itemsPurchase[index].orderDate),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  Text (
                    DateFormat('yyyy', 'es_ES').format(widget.itemsPurchase[index].orderDate),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              title: Text (
                widget.itemsPurchase[index].showName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26.0,
                  fontFamily: 'SF Pro Display',
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
              ),
              subtitle: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                              text: 'Pedido: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: widget.itemsPurchase[index].orderId.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                              ]
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'Estado: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: widget.itemsPurchase[index].allStatus,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                              ]
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'Items: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                              children: <TextSpan>[
                                TextSpan (
                                    text: widget.itemsPurchase[index].items.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                              ]
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                              text: 'Importe: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].totalBeforeDiscountWithoutTax/MULTIPLYING_FACTOR).toString())),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                              ]
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'Modificación: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: widget.itemsPurchase[index].discountAmount/MULTIPLYING_FACTOR > 0 ? new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].discountAmount/MULTIPLYING_FACTOR).toString())) : new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].discountAmount/MULTIPLYING_FACTOR).toString())),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                              ]
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'Subtotal: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].totalAfterDiscountWithoutTax/MULTIPLYING_FACTOR).toString())),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                              ]
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'IVA: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].taxAmount/MULTIPLYING_FACTOR).toString())),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                              ]
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                              text: 'Total: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                              children: <TextSpan>[
                                TextSpan (
                                    text: new NumberFormat.currency (locale:'es_ES', symbol: '€', decimalDigits:2).format(double.parse((widget.itemsPurchase[index].totalAmount/MULTIPLYING_FACTOR).toString())),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                              ]
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              trailing: Column (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded (
                    child: (widget.itemsPurchase[index].numStatus == 1 && widget.itemsPurchase[index].possibleStatusToTransitionTo.length > 0 && widget.itemsPurchase[index].possibleStatusToTransitionTo[0].priority == 1 && widget.partnerId != DEFAULT_PARTNER_ID) ? IconButton (
                      //iconSize: 7,
                      padding: const EdgeInsetsDirectional.all(5.0),
                      icon: Image.asset(
                        'assets/images/logoPlay.png',
                        //height: 7,
                        //width: 6,
                        //scale: 1,
                        fit: BoxFit.scaleDown,
                      ),
                      onPressed: () async {
                        try {
                          debugPrint ('Estoy en el onPressed');
                          _showPleaseWait(true);
                          final Uri url = Uri.parse('$SERVER_IP/purchaseStateTransition/' + widget.itemsPurchase[index].orderId.toString() + '/' + widget.itemsPurchase[index].providerName);
                          final http.Response res = await http.put (
                              url,
                              headers: <String, String>{
                                'Content-Type': 'application/json; charset=UTF-8',
                                //'Authorization': jwt
                              },
                              body: jsonEncode(<String, String>{
                                'user_id': widget.userId.toString(),
                                'next_state': widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).destinationStateId, // Always exists at least the next state if this icon has appeared
                              })
                          ).timeout(TIMEOUT);
                          if (res.statusCode == 200) {
                            _showPleaseWait(false);
                            debugPrint ('The Rest API has responsed.');
                            final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['nextStatesToTransitionTo'].cast<Map<String, dynamic>>();
                            debugPrint ('Entre medias de la api RESPONSE.');
                            final List<PurchaseStatus> resultListProducts = resultListJson.map<PurchaseStatus>((json) => PurchaseStatus.fromJson(json)).toList();
                            setState(() {
                              widget.itemsPurchase[index].allStatus = widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).statusName;
                              widget.itemsPurchase[index].possibleStatusToTransitionTo = resultListProducts;
                            });
                          } else {
                            _showPleaseWait(false);
                            ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'], error: true);
                          }
                        } catch (e) {
                          _showPleaseWait(false);
                          ShowSnackBar.showSnackBar(context, e.toString(), error: true);
                        }
                      },
                    ) : Container(width: 20, height: 20, padding: EdgeInsets.zero),
                  ),
                  Expanded (
                    child: (widget.itemsPurchase[index].numStatus == 1 && widget.itemsPurchase[index].possibleStatusToTransitionTo.length > 0 && widget.partnerId != DEFAULT_PARTNER_ID) ? PopupMenuButton(
                        icon: Icon(Icons.more_horiz, color: Colors.black,),
                        itemBuilder: (BuildContext context) =>
                            widget.itemsPurchase[index].possibleStatusToTransitionTo.map((e) {
                              return PopupMenuItem (
                                child: Center(child: Text(e.statusName),),
                                value: e,
                              );
                            }).toList(),
                      onSelected: (PurchaseStatus result) async {
                        try {
                          debugPrint ('Estoy en el onSelected');
                          _showPleaseWait(true);
                          final Uri url = Uri.parse ('$SERVER_IP/purchaseStateTransition/' + widget.itemsPurchase[index].orderId.toString() + '/' + widget.itemsPurchase[index].providerName);
                          final http.Response res = await http.put (
                              url,
                              headers: <String, String>{
                                'Content-Type': 'application/json; charset=UTF-8',
                                //'Authorization': jwt
                              },
                              body: jsonEncode(<String, String>{
                                'user_id': widget.userId.toString(),
                                'next_state': result.destinationStateId,
                              })
                          ).timeout(TIMEOUT);
                          if (res.statusCode == 200) {
                            _showPleaseWait(false);
                            debugPrint ('The Rest API has responsed.');
                            final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['nextStatesToTransitionTo'].cast<Map<String, dynamic>>();
                            debugPrint ('Entre medias de la api RESPONSE.');
                            final List<PurchaseStatus> resultListProducts = resultListJson.map<PurchaseStatus>((json) => PurchaseStatus.fromJson(json)).toList();
                            setState(() {
                              widget.itemsPurchase[index].allStatus = result.statusName;
                              widget.itemsPurchase[index].possibleStatusToTransitionTo = resultListProducts;
                            });
                          } else {
                            _showPleaseWait(false);
                            ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'], error: true);
                          }
                        } catch (e) {
                          _showPleaseWait(false);
                          ShowSnackBar.showSnackBar(context, e.toString(), error: true);
                        }
                      },
                    ) : Container(
                      padding: EdgeInsets.zero,
                      width: 20.0,
                      height: 20.0,
                    ),
                  )
                ],
              ),
              onTap: () async {
                final bool purchaseDetailStateChanged = await Navigator.push(context, MaterialPageRoute(
                    builder: (context) => PurchaseDetailView (widget.userId, widget.itemsPurchase[index], widget.partnerId, widget.userRole)
                ));
                if (purchaseDetailStateChanged) {
                  // I load the data again
                  widget.itemsPurchase.clear();
                  final PurchaseController controller = new PurchaseController ();

                  final newPurchaseList = await controller.getPurchasesByUserId (widget.userId);
                  if (newPurchaseList.length  > 0) {

                  }
                  newPurchaseList.forEach((element) {
                    widget.itemsPurchase.add(element);
                  });
                  setState(() {

                  });
                }
              },
            ),
          );
        }
    );
    return SafeArea (
      child: _pleaseWait ? Stack (
        key: ObjectKey ("stack"),
        alignment: AlignmentDirectional.center,
        children: [tmpBuilder, _pleaseWaitWidget],
      ) : Stack (
        key: ObjectKey ("stack"),
        children: [tmpBuilder],
      )
    );
  }
}