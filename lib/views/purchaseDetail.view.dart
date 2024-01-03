import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show NumberFormat hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';


import 'package:plataforma_compras/models/purchase.model.dart';
import 'package:plataforma_compras/models/purchaseLine.model.dart';
import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/utils/showSnackBar.dart';
import 'package:plataforma_compras/utils/pleaseWaitWidget.dart';
import 'package:plataforma_compras/models/purchaseStatus.model.dart';
import 'package:plataforma_compras/controllers/purchaseDetail.controller.dart';
import 'package:plataforma_compras/views/purchaseDetailModify.view.dart';

class _StateChanged {
  bool changed;
  _StateChanged(this.changed);
}
class PurchaseDetailView extends StatefulWidget {

  final int userId;
  final Purchase father;
  final int partnerId;
  final String userRole;

  PurchaseDetailView(this.userId, this.father, this.partnerId, this.userRole);

  @override
  PurchaseDetailViewState createState() {
    return PurchaseDetailViewState();
  }
}
class PurchaseDetailViewState extends State<PurchaseDetailView> {
  final PurchaseDetailController _controller = new PurchaseDetailController();
  _StateChanged _stateChangedAttr = new _StateChanged(false);
  List<PurchaseLine> itemsPurchase;   // (20220517) Angel Ruiz. I need the purchased product to share them
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _stateChangedAttr.changed = false;
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build (BuildContext context) {
    return Scaffold (
      appBar: AppBar (
        elevation: 0.0,
        leading: IconButton (
          icon: Image.asset('assets/images/leftArrow.png'),
          onPressed: () {
            Navigator.pop(context, _stateChangedAttr.changed);
          },
        ),
        title: Row(
          children: [
            Expanded (
              child: Text (
                  'Pedido: ' + widget.father.orderId.toString(),
              )
            ),
            Expanded (
              child: Text (
                widget.father.showName,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              )
            )
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Image.asset('assets/images/logoWhatsapp.png'),
            onPressed: () async {
              if (itemsPurchase.isNotEmpty) {
                final SharedPreferences prefs = await _prefs;
                final String token = prefs.get ('token') ?? "";
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
                String textToShare = "Pedido de " + fullName + ":\n\n" + "PRODUCT_ID|UNIDADES|DESCRIPCION\n";
                itemsPurchase.forEach((element) {
                  textToShare = textToShare + element.productId.toString() + "|" +
                      (element.newQuantity != -1 ? element.newQuantity.toString() + "(" + element.items.toString() + ")" : element.items.toString()) +
                      (element.newQuantity != -1 ? (element.newQuantity > 1 ? " " + element.idUnit + "s." : element.idUnit + ".") : element.items > 1 ? " " + element.idUnit + "s." : element.idUnit + ".") +
                      "|" + element.productName + "\n";
                });
                Share.share(
                    textToShare,
                    subject: "Pedido de " + fullName + ".",
                    sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size
                );
              }
            }
          )
        ],
      ),
      body: FutureBuilder <List<PurchaseLine>> (
          future: _controller.getPurchaseLinesByOrderId (widget.userId, widget.father.orderId, widget.father.providerName),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              itemsPurchase = snapshot.data; // (20220517) Angel Ruiz. I need these data to share them
              return new ResponsiveWidget (
                smallScreen: _SmallScreen (widget.father, snapshot.data, widget.userId, this._stateChangedAttr, widget.partnerId, widget.userRole),
                largeScreen: _LargeScreen (widget.father, snapshot.data, widget.userId, this._stateChangedAttr, widget.partnerId, widget.userRole),
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
  final Purchase father;
  final List<PurchaseLine> itemsPurchase;
  final int userId;
  final _StateChanged stateChanged;
  final int partnerId;
  final String userRole;
  _SmallScreen (this.father, this.itemsPurchase, this.userId, this.stateChanged, this.partnerId, this.userRole);

  _SmallScreenState createState() => _SmallScreenState();
}
class _SmallScreenState extends State<_SmallScreen> {
  bool _pleaseWait = false;
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget (key: ObjectKey("pleaseWaitWidget"));

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
            leading: Container (
              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
              child: AspectRatio (
                aspectRatio: 3.0 / 2.0,
                child: CachedNetworkImage (
                  placeholder: (context, url) => CircularProgressIndicator(),
                  imageUrl: SERVER_IP + IMAGES_DIRECTORY + widget.itemsPurchase[index].productCode.toString() + '_0.gif',
                  fit: BoxFit.scaleDown,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            title: Text (
              widget.itemsPurchase[index].productName,
              style: TextStyle (
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
            subtitle: Row (
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column (
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText (
                        text: TextSpan(
                            text: 'Estado: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: widget.itemsPurchase[index].allStatus,
                                  style: TextStyle (
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                            ]
                        ),
                      ),
                      RichText (
                        text: TextSpan (
                            text: 'Items: ',
                            style: TextStyle (
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            children: <TextSpan>[
                              TextSpan (
                                  text: widget.itemsPurchase[index].newQuantity != -1
                                      ? widget.itemsPurchase[index].newQuantity.toString()
                                      + ' (' + widget.itemsPurchase[index].items.toString() + ')'
                                      : widget.itemsPurchase[index].items.toString(),
                                  // -1 means that there is a null in the field NEW_QUANTITY of the table KRC_PURCHASE
                                  style: TextStyle (
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                              TextSpan(
                                text: widget.itemsPurchase[index].newQuantity != -1
                                    ? widget.itemsPurchase[index].newQuantity > 1 ? ' ' + widget.itemsPurchase[index].idUnit.toString() + 's.' : ' ' + widget.itemsPurchase[index].idUnit.toString() + '.'
                                    : widget.itemsPurchase[index].items > 1 ? ' ' + widget.itemsPurchase[index].idUnit.toString() + 's.' : ' ' + widget.itemsPurchase[index].idUnit.toString() + '.',
                                style: TextStyle (
                                    fontWeight: FontWeight.bold
                                )
                              )
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
                              fontSize: 12,
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
                              fontSize: 12,
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
                              fontSize: 12,
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
                              fontSize: 12,
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
                              fontSize: 12,
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
                  child: (widget.itemsPurchase[index].possibleStatusToTransitionTo.length > 0 && widget.itemsPurchase[index].possibleStatusToTransitionTo[0].priority == 1 && widget.partnerId != DEFAULT_PARTNER_ID) ? IconButton (
                    padding: const EdgeInsets.all(5.0),
                    icon: Image.asset (
                      'assets/images/logoPlay.png',
                      fit: BoxFit.scaleDown,
                    ),
                    onPressed: () async {
                      try {
                        debugPrint ('Estoy en el onPressed');
                        _showPleaseWait(true);
                        final Uri url = Uri.parse('$SERVER_IP/purchaseLineStateTransition/' + widget.itemsPurchase[index].orderId.toString() + '/' + widget.itemsPurchase[index].providerName);
                        final http.Response res = await http.put (
                            url,
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                              //'Authorization': jwt
                            },
                            body: jsonEncode(<String, String> {
                              'user_id': widget.userId.toString(),
                              'next_state': widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).destinationStateId, // Always exists at least the next state if this icon has appeared
                              'product_id': widget.itemsPurchase[index].productId.toString()
                            })
                        ).timeout(TIMEOUT);
                        if (res.statusCode == 200) {
                          _showPleaseWait(false);
                          debugPrint ('The Rest API has responsed.');
                          final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['nextStatesToTransitionTo'].cast<Map<String, dynamic>>();
                          debugPrint ('Entre medias de la api RESPONSE.');
                          final List<PurchaseStatus> resultListNextStatus = resultListJson.map<PurchaseStatus>((json) => PurchaseStatus.fromJson(json)).toList();
                          setState(() {
                            widget.itemsPurchase[index].allStatus = widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).statusName;
                            widget.itemsPurchase[index].statusId = widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).destinationStateId;
                            widget.itemsPurchase[index].banPrice = widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).banPrice;
                            widget.itemsPurchase[index].banQuantity = widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).banQuantity;
                            widget.itemsPurchase[index].possibleStatusToTransitionTo = resultListNextStatus;
                          });
                          // process the possibility that the status of the item father could have changed
                          final List<Map<String, dynamic>> resultListJsonFather = json.decode(res.body)['nextStatesToTransitionToItemFather'].cast<Map<String, dynamic>>();
                          final List<PurchaseStatus> resultListNextStatusFather = resultListJsonFather.map<PurchaseStatus>((json) => PurchaseStatus.fromJson(json)).toList();
                          final String statusIdOfTheItemFather = json.decode(res.body)['statusIdOfTheItemFather'].toString(); // status_id of the father item since the father item status could have been changed because have changed the item products of the item father
                          final String statusNameOfTheItemFather = json.decode(res.body)['statusNameOfTheItemFather'].toString(); // status_name of the father item since the father item status could have been changed because have changed the item products of the item father
                          final int numStatusOfTheItemFather = int.parse(json.decode(res.body)['numStatusOfTheItemFather'].toString()); // num_status of the father item since the father item status could have been changed because have changed the item products of the item father
                          widget.father.numStatus = numStatusOfTheItemFather;
                          widget.father.allStatus = statusNameOfTheItemFather;
                          widget.father.statusId = statusIdOfTheItemFather;
                          widget.father.possibleStatusToTransitionTo.clear();
                          widget.father.possibleStatusToTransitionTo = resultListNextStatusFather;
                          widget.stateChanged.changed = true;
                        } else {
                          _showPleaseWait(false);
                          widget.stateChanged.changed = false;
                          ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'], error: true);
                        }
                      } catch (e) {
                        _showPleaseWait(false);
                        widget.stateChanged.changed = false;
                        ShowSnackBar.showSnackBar(context, e.toString(), error: true);
                      }
                    },
                  ) : Container(padding: EdgeInsets.zero, width: 20, height: 20),
                ),
                Expanded (
                  child: (widget.itemsPurchase[index].possibleStatusToTransitionTo.length > 0 && widget.partnerId != DEFAULT_PARTNER_ID) ? PopupMenuButton (
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
                          debugPrint ('El valor de result.banPrice es: ' + result.banPrice);
                          debugPrint ('El valor de result.banQuantity es: ' + result.banQuantity);
                          _showPleaseWait(true);
                          final Uri url = Uri.parse ('$SERVER_IP/purchaseLineStateTransition/' + widget.itemsPurchase[index].orderId.toString() + '/' + widget.itemsPurchase[index].providerName);
                          final http.Response res = await http.put (
                              url,
                              headers: <String, String>{
                                'Content-Type': 'application/json; charset=UTF-8',
                                //'Authorization': jwt
                              },
                              body: jsonEncode(<String, String>{
                                'user_id': widget.userId.toString(),
                                'next_state': result.destinationStateId,
                                'product_id': widget.itemsPurchase[index].productId.toString()
                              })
                          ).timeout(TIMEOUT);
                          if (res.statusCode == 200) {
                            _showPleaseWait(false);
                            debugPrint ('The Rest API has responsed.');
                            final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['nextStatesToTransitionTo'].cast<Map<String, dynamic>>();
                            debugPrint ('Entre medias de la api RESPONSE.');
                            final List<PurchaseStatus> resultListProducts = resultListJson.map<PurchaseStatus>((json) => PurchaseStatus.fromJson(json)).toList();
                            setState (() {
                              widget.itemsPurchase[index].allStatus = result.statusName;
                              widget.itemsPurchase[index].statusId = result.destinationStateId;
                              widget.itemsPurchase[index].banPrice = result.banPrice;
                              widget.itemsPurchase[index].banQuantity = result.banQuantity;
                              widget.itemsPurchase[index].possibleStatusToTransitionTo = resultListProducts;
                            });
                            debugPrint ('El valor de banPrice es: ' + widget.itemsPurchase[index].banPrice);
                            debugPrint ('El valor de banQuantity es: ' + widget.itemsPurchase[index].banQuantity);
                            // process the possibility that the status of the item father could have changed
                            final List<Map<String, dynamic>> resultListJsonFather = json.decode(res.body)['nextStatesToTransitionToItemFather'].cast<Map<String, dynamic>>();
                            final List<PurchaseStatus> resultListNextStatusFather = resultListJsonFather.map<PurchaseStatus>((json) => PurchaseStatus.fromJson(json)).toList();
                            final String statusIdOfTheItemFather = json.decode(res.body)['statusIdOfTheItemFather'].toString(); // status_id of the father item since the father item status could have been changed because have changed the item products of the item father
                            final String statusNameOfTheItemFather = json.decode(res.body)['statusNameOfTheItemFather'].toString(); // status_name of the father item since the father item status could have been changed because have changed the item products of the item father
                            final int numStatusOfTheItemFather = int.parse(json.decode(res.body)['numStatusOfTheItemFather'].toString()); // num_status of the father item since the father item status could have been changed because have changed the item products of the item father
                            widget.father.numStatus = numStatusOfTheItemFather;
                            widget.father.allStatus = statusNameOfTheItemFather;
                            widget.father.statusId = statusIdOfTheItemFather;
                            widget.father.possibleStatusToTransitionTo.clear();
                            widget.father.possibleStatusToTransitionTo = resultListNextStatusFather;
                            widget.stateChanged.changed = true;
                          } else {
                            _showPleaseWait(false);
                            widget.stateChanged.changed = false;
                            ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'], error: true);
                          }
                        } catch (e) {
                          _showPleaseWait(false);
                          widget.stateChanged.changed = false;
                          ShowSnackBar.showSnackBar(context, e.toString(), error: true);
                        }
                      }
                  ) : Container (padding: EdgeInsets.zero, width: 20, height: 20),
                )
              ],
            ),
            onTap: () async {
              if (widget.itemsPurchase[index].banQuantity == "SI" || widget.itemsPurchase[index].banPrice == "SI") {
                final bool purchaseDetailStateChanged = await Navigator.push(context, MaterialPageRoute(
                    builder: (context) => PurchaseDetailModifyView (widget.userId, widget.father, widget.partnerId, widget.itemsPurchase[index], widget.userRole)
                ));
                debugPrint ("El valor de purchaseDetailStateChanged es: " + purchaseDetailStateChanged.toString());
                if (purchaseDetailStateChanged) {
                  setState(() {
                    debugPrint (" Estoy dentro de setState. El valor de purchaseDetailStateChanged es: " + purchaseDetailStateChanged.toString());
                    debugPrint ("Sigo dentro del setState. El valor de widget.itemsPurchase[index]" + widget.itemsPurchase[index].newQuantity.toString());
                  });
                }
              }
            },
          ),
        );
      }
    );
    return SafeArea (
      child: _pleaseWait ? Stack(
        key: ObjectKey ("stack"),
        alignment: AlignmentDirectional.center,
        children: [tmpBuilder, _pleaseWaitWidget],
      ) : Stack (
        key: ObjectKey ("stack"),
        children: [tmpBuilder],
      ),
    );
  }
}
class _LargeScreen extends StatefulWidget {
  final Purchase father;
  final List<PurchaseLine> itemsPurchase;
  final int userId;
  final _StateChanged stateChanged;
  final int partnerId;
  final String userRole;
  _LargeScreen (this.father, this.itemsPurchase, this.userId, this.stateChanged, this.partnerId, this.userRole);

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
              leading: Container(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                child: AspectRatio(
                  aspectRatio: 3.0 / 2.0,
                  child: CachedNetworkImage(
                    placeholder: (context, url) => CircularProgressIndicator(),
                    imageUrl: SERVER_IP + IMAGES_DIRECTORY + widget.itemsPurchase[index].productCode.toString() + '_0.gif',
                    fit: BoxFit.scaleDown,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              title: Text (
                widget.itemsPurchase[index].productName,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 26.0,
                  fontFamily: 'SF Pro Display',
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                softWrap: false,
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
                        RichText (
                          text: TextSpan(
                              text: 'Items: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                              children: <TextSpan>[
                                TextSpan (
                                    text: widget.itemsPurchase[index].newQuantity != -1
                                        ? widget.itemsPurchase[index].newQuantity.toString()
                                        + ' (' + widget.itemsPurchase[index].items.toString() + ')'
                                        : widget.itemsPurchase[index].items.toString(),
                                    // -1 means that there is a null in the field NEW_QUANTITY of the table KRC_PURCHASE
                                    style: TextStyle (
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                                TextSpan(
                                    text: widget.itemsPurchase[index].newQuantity != -1
                                        ? widget.itemsPurchase[index].newQuantity > 1 ? ' ' + widget.itemsPurchase[index].idUnit.toString() + 's.' : ' ' + widget.itemsPurchase[index].idUnit.toString() + '.'
                                        : widget.itemsPurchase[index].items > 1 ? ' ' + widget.itemsPurchase[index].idUnit.toString() + 's.' : ' ' + widget.itemsPurchase[index].idUnit.toString() + '.',
                                    style: TextStyle (
                                        fontWeight: FontWeight.bold
                                    )
                                )
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
                    child: (widget.itemsPurchase[index].possibleStatusToTransitionTo.length > 0 && widget.itemsPurchase[index].possibleStatusToTransitionTo[0].priority == 1 && widget.partnerId != DEFAULT_PARTNER_ID) ? IconButton (
                      padding: const EdgeInsets.all(5.0),
                      icon: Image.asset(
                        'assets/images/logoPlay.png',
                        fit: BoxFit.scaleDown,
                      ),
                      onPressed: () async {
                        try {
                          debugPrint ('Estoy en el onPressed');
                          _showPleaseWait(true);
                          final Uri url = Uri.parse('$SERVER_IP/purchaseLineStateTransition/' + widget.itemsPurchase[index].orderId.toString() + '/' + widget.itemsPurchase[index].providerName);
                          final http.Response res = await http.put (
                              url,
                              headers: <String, String>{
                                'Content-Type': 'application/json; charset=UTF-8',
                                //'Authorization': jwt
                              },
                              body: jsonEncode(<String, String>{
                                'user_id': widget.userId.toString(),
                                'next_state': widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).destinationStateId, // Always exists at least the next state if this icon has appeared
                                'product_id': widget.itemsPurchase[index].productId.toString()
                              })
                          ).timeout(TIMEOUT);
                          if (res.statusCode == 200) {
                            _showPleaseWait(false);
                            debugPrint ('The Rest API has responsed.');
                            final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['nextStatesToTransitionTo'].cast<Map<String, dynamic>>();
                            debugPrint ('Entre medias de la api RESPONSE.');
                            final List<PurchaseStatus> resultListNextStatus = resultListJson.map<PurchaseStatus>((json) => PurchaseStatus.fromJson(json)).toList();
                            setState(() {
                              widget.itemsPurchase[index].allStatus = widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).statusName;
                              widget.itemsPurchase[index].statusId = widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).destinationStateId;
                              widget.itemsPurchase[index].banPrice = widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).banPrice;
                              widget.itemsPurchase[index].banQuantity = widget.itemsPurchase[index].possibleStatusToTransitionTo.elementAt(0).banQuantity;
                              widget.itemsPurchase[index].possibleStatusToTransitionTo = resultListNextStatus;
                            });
                            // process the possibility that the status of the item father could have changed
                            final List<Map<String, dynamic>> resultListJsonFather = json.decode(res.body)['nextStatesToTransitionToItemFather'].cast<Map<String, dynamic>>();
                            final List<PurchaseStatus> resultListNextStatusFather = resultListJsonFather.map<PurchaseStatus>((json) => PurchaseStatus.fromJson(json)).toList();
                            final String statusIdOfTheItemFather = json.decode(res.body)['statusIdOfTheItemFather'].toString(); // status_id of the father item since the father item status could have been changed because have changed the item products of the item father
                            final String statusNameOfTheItemFather = json.decode(res.body)['statusNameOfTheItemFather'].toString(); // status_name of the father item since the father item status could have been changed because have changed the item products of the item father
                            final int numStatusOfTheItemFather = int.parse(json.decode(res.body)['numStatusOfTheItemFather'].toString()); // num_status of the father item since the father item status could have been changed because have changed the item products of the item father
                            widget.father.numStatus = numStatusOfTheItemFather;
                            widget.father.allStatus = statusNameOfTheItemFather;
                            widget.father.statusId = statusIdOfTheItemFather;
                            widget.father.possibleStatusToTransitionTo.clear();
                            widget.father.possibleStatusToTransitionTo = resultListNextStatusFather;
                            widget.stateChanged.changed = true;
                          } else {
                            _showPleaseWait(false);
                            widget.stateChanged.changed = false;
                            ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'], error: true);
                          }
                        } catch (e) {
                          _showPleaseWait(false);
                          widget.stateChanged.changed = false;
                          ShowSnackBar.showSnackBar(context, e.toString(), error: true);
                        }
                      },
                    ) : Container(padding: EdgeInsets.zero, width: 20, height: 20),
                  ),
                  Expanded (
                    child: (widget.itemsPurchase[index].possibleStatusToTransitionTo.length > 0 && widget.partnerId != DEFAULT_PARTNER_ID) ? PopupMenuButton (
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
                            final Uri url = Uri.parse ('$SERVER_IP/purchaseLineStateTransition/' + widget.itemsPurchase[index].orderId.toString() + '/' + widget.itemsPurchase[index].providerName);
                            final http.Response res = await http.put (
                                url,
                                headers: <String, String>{
                                  'Content-Type': 'application/json; charset=UTF-8',
                                  //'Authorization': jwt
                                },
                                body: jsonEncode(<String, String>{
                                  'user_id': widget.userId.toString(),
                                  'next_state': result.destinationStateId,
                                  'product_id': widget.itemsPurchase[index].productId.toString()
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
                                widget.itemsPurchase[index].statusId = result.destinationStateId;
                                widget.itemsPurchase[index].banPrice = result.banPrice;
                                widget.itemsPurchase[index].banQuantity = result.banQuantity;
                                widget.itemsPurchase[index].possibleStatusToTransitionTo = resultListProducts;
                              });
                              // process the possibility that the status of the item father could have changed
                              final List<Map<String, dynamic>> resultListJsonFather = json.decode(res.body)['nextStatesToTransitionToItemFather'].cast<Map<String, dynamic>>();
                              final List<PurchaseStatus> resultListNextStatusFather = resultListJsonFather.map<PurchaseStatus>((json) => PurchaseStatus.fromJson(json)).toList();
                              final String statusIdOfTheItemFather = json.decode(res.body)['statusIdOfTheItemFather'].toString(); // status_id of the father item since the father item status could have been changed because have changed the item products of the item father
                              final String statusNameOfTheItemFather = json.decode(res.body)['statusNameOfTheItemFather'].toString(); // status_name of the father item since the father item status could have been changed because have changed the item products of the item father
                              final int numStatusOfTheItemFather = int.parse(json.decode(res.body)['numStatusOfTheItemFather'].toString()); // num_status of the father item since the father item status could have been changed because have changed the item products of the item father
                              widget.father.numStatus = numStatusOfTheItemFather;
                              widget.father.allStatus = statusNameOfTheItemFather;
                              widget.father.statusId = statusIdOfTheItemFather;
                              widget.father.possibleStatusToTransitionTo.clear();
                              widget.father.possibleStatusToTransitionTo = resultListNextStatusFather;
                              widget.stateChanged.changed = true;
                            } else {
                              _showPleaseWait(false);
                              widget.stateChanged.changed = false;
                              ShowSnackBar.showSnackBar(context, json.decode(res.body)['message'], error: true);
                            }
                          } catch (e) {
                            _showPleaseWait(false);
                            widget.stateChanged.changed = false;
                            ShowSnackBar.showSnackBar(context, e.toString(), error: true);
                          }
                        },
                    ) : Container (padding: EdgeInsets.zero, width: 20, height: 20),
                  )
                ],
              ),
              onTap: () async {
                final bool purchaseDetailStateChanged = await Navigator.push(context, MaterialPageRoute(
                    builder: (context) => PurchaseDetailModifyView (widget.userId, widget.father, widget.partnerId, widget.itemsPurchase[index], widget.userRole)
                ));
                if (purchaseDetailStateChanged) {
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
      ),
    );
  }
}