import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/models/addressGeoLocation.dart';
import 'package:plataforma_compras/utils/showSnackBar.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/models/cart.model.dart';
import 'package:plataforma_compras/models/catalog.model.dart';
import 'package:plataforma_compras/utils/displayDialog.dart';
import 'package:plataforma_compras/utils/pleaseWaitWidget.dart';

class DetailAddressView extends StatefulWidget {
  DetailAddressView({Key key, this.address, this.personeId}) : super(key: key);
  final AddressGeoLocation address;
  final String personeId;
  @override
  State<StatefulWidget> createState() {
    return _DetailAddressViewState();
  }
}
class _DetailAddressViewState extends State<DetailAddressView> {
  AddressGeoLocation _addressOut;
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
    _pleaseWait = false;
    _addressOut = new AddressGeoLocation();
  }
  @override
  void dispose() {
    super.dispose();
  }
  _badStatusCode(http.Response response) {
    debugPrint("Bad status code ${response.statusCode} returned from server.");
    debugPrint("Response body ${response.body} returned from server.");
    throw Exception(
        'Bad status code ${response.statusCode} returned from server.');
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
                'product_description': e.productDescription,
                'product_type': e.productType,
                'brand': e.brand,
                'num_images': e.numImages,
                'num_videos': e.numVideos,
                'purchased': e.purchased,
                'product_price': e.productPrice,
                'persone_id': e.personeId,
                'persone_name': e.personeName,
                'tax_id': e.taxId,
                'tax_apply': e.taxApply
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
  Widget build(BuildContext context) {
    final Widget tmpBuilder = Container(
      alignment: Alignment.center,
      child: TextButton(
        child: Text (
          'Guardar',
          style: TextStyle (
            fontFamily: 'SF Pro Display',
            fontSize: 16.0,
            fontWeight: FontWeight.w900,
            color: tanteLadenIconBrown,
          ),
          textAlign: TextAlign.right,
        ),
        onPressed: () async {
          try {
            _showPleaseWait (true);
            final Uri url = Uri.parse('$SERVER_IP/saveLogisticAddress');
            final http.Response res = await http.post (
                url,
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                  //'Authorization': jwt
                },
                body: jsonEncode(<String, String>{
                  'street_name': _addressOut.streetName,
                  'street_number': _addressOut.streetNumber,
                  'flat_door': _addressOut.flatDoor,
                  'postal_code': _addressOut.postalCode,
                  'locality': _addressOut.locality,
                  'country': _addressOut.country,
                  'optional': _addressOut.optional,
                  'persone_id': widget.personeId
                })
            ).timeout(TIMEOUT);
            if (res.statusCode == 200) {
              var widgetImage = Image.asset ('assets/images/infoMessage.png');
              final String messageInfo = "Vas a llevar a cabo la tramitación de tu compra.";
              debugPrint('Before the displayDialogAcceptCancel');
              final bool responseUser = await DisplayDialog.displayDialogConfirmCancel(context, widgetImage, 'Tramitar pedido', messageInfo);
              debugPrint('After the displayDialogAcceptCancel');
              if (responseUser) {
                var cart = context.read<Cart>();
                final String message = await _processPurchase(cart);
                debugPrint ('the returned message is:' + message);
                _showPleaseWait(false);
                await DisplayDialog.displayDialog (context, widgetImage, 'Compra realizada', message);
                cart.clearCart();
                var catalog = context.read<Catalog>();
                catalog.clearCatalog();
                Navigator.popUntil(context, ModalRoute.withName('/'));
                //Navigator.pop(context);
                //Navigator.pop(context);
                //Navigator.pop(context);
                //Navigator.pop(context);
                //Navigator.pop(context);
              }
            } else {
              _showPleaseWait (false);
            }
          } catch (e) {
            _showPleaseWait (false);
            ShowSnackBar.showSnackBar(context, e, error: true);
          }
        },
      ),
    );
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton (
            icon: Image.asset('assets/images/logoCross.png'),
            onPressed: () {
              Navigator.pop(context);
            }
        ),
        title: Text (
          'Detalles dirección',
          style: TextStyle (
              fontFamily: 'SF Pro Display',
              fontSize: 20.0,
              fontWeight: FontWeight.w300,
              color: tanteLadenIconBrown
          ),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          _pleaseWait ?
          Stack (
            key:  ObjectKey("stack"),
            alignment: AlignmentDirectional.center,
            children: [tmpBuilder, _pleaseWaitWidget],
          ) :
          Stack (key:  ObjectKey("stack"), children: [tmpBuilder],)
        ],
      ),
      body: ResponsiveWidget (
        smallScreen: _SmallScreenView (address: widget.address, personeId: widget.personeId, addressOut: _addressOut),
        largeScreen: _LargeScreenView (address: widget.address, personeId:  widget.personeId, addressOut: _addressOut),
      ),
    );
  }
}
class _SmallScreenView extends StatefulWidget {
  _SmallScreenView ({Key key, @required this.address, @required this.personeId, @required this.addressOut}) : super(key: key);
  final AddressGeoLocation address;
  final String personeId;
  final AddressGeoLocation addressOut;

  @override
  _SmallScreenViewState createState() => _SmallScreenViewState();
}
class _SmallScreenViewState extends State<_SmallScreenView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _streetNameController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _flatDoorController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _optionalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _streetNameController.text = widget.address.streetName;
    _streetNumberController.text = widget.address.streetNumber;
    _flatDoorController.text = widget.address.flatDoor;
    _postalCodeController.text = widget.address.postalCode;
    _localityController.text = widget.address.locality;
    _countryController.text = widget.address.country;
    widget.addressOut.streetName = widget.address.streetName;
    widget.addressOut.streetNumber = widget.address.streetNumber;
    widget.addressOut.flatDoor = widget.address.flatDoor;
    widget.addressOut.postalCode = widget.address.postalCode;
    widget.addressOut.locality = widget.address.locality;
    widget.addressOut.country = widget.address.country;
    _streetNameController.addListener (_onStreetNameChanged);
    _streetNumberController.addListener(_onStreetNumberChanged);
    _flatDoorController.addListener(_onFlatDoorChanged);
    _postalCodeController.addListener(_onPostalCodeChanged);
    _localityController.addListener(_onLocalityChanged);
    _countryController.addListener(_onCountryChanged);
    _optionalController.addListener(_onOptionalChanged);
  }
  @override
  void dispose() {
    _streetNameController.removeListener(_onStreetNameChanged);
    _streetNameController.dispose();
    _streetNumberController.removeListener(_onStreetNumberChanged);
    _streetNumberController.dispose();
    _flatDoorController.removeListener(_onFlatDoorChanged);
    _flatDoorController.dispose();
    _postalCodeController.removeListener(_onPostalCodeChanged);
    _postalCodeController.dispose();
    _localityController.removeListener(_onLocalityChanged);
    _localityController.dispose();
    _countryController.removeListener(_onCountryChanged);
    _countryController.dispose();
    _optionalController.removeListener(_onOptionalChanged);
    _optionalController.dispose();
    super.dispose();
  }

  _onStreetNameChanged(){
    widget.addressOut.streetName = _streetNameController.text;
  }
  _onStreetNumberChanged(){
    widget.addressOut.streetName = _streetNumberController.text;
  }
  _onFlatDoorChanged() {
    widget.addressOut.flatDoor = _flatDoorController.text;
  }
  _onPostalCodeChanged() {
    widget.addressOut.postalCode = _postalCodeController.text;
  }
  _onLocalityChanged() {
    widget.addressOut.locality = _localityController.text;
  }
  _onCountryChanged() {
    widget.addressOut.country = _countryController.text;
  }
  _onOptionalChanged() {
    widget.addressOut.optional = _optionalController.text;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Form(
            key: _formKey,
            child: ListView (
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: TextFormField(
                        decoration: const InputDecoration (
                          labelText: 'Calle',
                          labelStyle: TextStyle (
                            color: tanteLadenIconBrown,
                          ),
                        ),
                        controller: _streetNameController,
                        validator: (String value) {
                          if (value == null) {
                            return 'Introduce una calle';
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 15.0,),
                    Flexible(
                        flex: 1,
                        child: TextFormField (
                          decoration: const InputDecoration (
                            labelText: 'Número',
                            labelStyle: TextStyle (
                              color: tanteLadenIconBrown,
                            ),
                          ),
                          controller: _streetNumberController,
                          validator: (String value) {
                            if (value == null) {
                              return 'Introduce un número';
                            } else {
                              return null;
                            }
                          },
                        )
                    )
                  ],
                ),
                Row(
                  children: [
                    Flexible (
                        flex: 4,
                        child: TextFormField (
                          decoration: const InputDecoration (
                            labelText: 'Piso, Puerta, ...',
                            labelStyle: TextStyle (
                              color: tanteLadenIconBrown,
                            ),
                          ),
                          controller: _flatDoorController,
                        )
                    ),
                    SizedBox(width: 15.0,),
                    Flexible (
                        flex: 2,
                        child: TextFormField (
                          decoration: const InputDecoration (
                            labelText: 'Cód. Postal',
                            labelStyle: TextStyle (
                              color: tanteLadenIconBrown,
                            ),
                          ),
                          controller: _postalCodeController,
                          validator: (String value) {
                            if (value == null) {
                              return 'Introduce un número postal';
                            } else {
                              return null;
                            }
                          },
                        )
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                        flex: 4,
                        child: TextFormField (
                          decoration: const InputDecoration (
                            labelText: 'Ciudad',
                            labelStyle: TextStyle (
                              color: tanteLadenIconBrown,
                            ),
                          ),
                          controller: _localityController,
                        )
                    ),
                    SizedBox(width: 15.0,),
                    Flexible(
                        flex: 4,
                        child: TextFormField (
                          decoration: const InputDecoration (
                            labelText: 'País',
                            labelStyle: TextStyle (
                              color: tanteLadenIconBrown,
                            ),
                          ),
                          controller: _countryController,
                          validator: (String value) {
                            if (value == null) {
                              return 'Introduce un país';
                            } else {
                              return null;
                            }
                          },
                        )
                    )
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                        flex: 1,
                        child: TextFormField (
                          decoration: const InputDecoration (
                            labelText: 'Observaciones',
                            labelStyle: TextStyle (
                              color: tanteLadenIconBrown,
                            ),
                          ),
                          controller: _optionalController,
                        )
                    )
                  ],
                )
              ],
            )
        )
    );
  }
}
class _LargeScreenView extends StatefulWidget {
  _LargeScreenView ({Key key, @required this.address, @required this.personeId, @required this.addressOut}) : super(key: key);
  final AddressGeoLocation address;
  final String personeId;
  final AddressGeoLocation addressOut;

  @override
  _LargeScreenViewState createState() => _LargeScreenViewState();
}
class _LargeScreenViewState extends State<_LargeScreenView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _streetNameController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _flatDoorController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _optionalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _streetNameController.text = widget.address.streetName;
    _streetNumberController.text = widget.address.streetNumber;
    _flatDoorController.text = widget.address.flatDoor;
    _postalCodeController.text = widget.address.postalCode;
    _localityController.text = widget.address.locality;
    _countryController.text = widget.address.country;
    widget.addressOut.streetName = widget.address.streetName;
    widget.addressOut.streetNumber = widget.address.streetNumber;
    widget.addressOut.flatDoor = widget.address.flatDoor;
    widget.addressOut.postalCode = widget.address.postalCode;
    widget.addressOut.locality = widget.address.locality;
    widget.addressOut.country = widget.address.country;
    _streetNameController.addListener (_onStreetNameChanged);
    _streetNumberController.addListener(_onStreetNumberChanged);
    _flatDoorController.addListener(_onFlatDoorChanged);
    _postalCodeController.addListener(_onPostalCodeChanged);
    _localityController.addListener(_onLocalityChanged);
    _countryController.addListener(_onCountryChanged);
    _optionalController.addListener(_onOptionalChanged);
  }
  @override
  void dispose() {
    _streetNameController.removeListener(_onStreetNameChanged);
    _streetNameController.dispose();
    _streetNumberController.removeListener(_onStreetNumberChanged);
    _streetNumberController.dispose();
    _flatDoorController.removeListener(_onFlatDoorChanged);
    _flatDoorController.dispose();
    _postalCodeController.removeListener(_onPostalCodeChanged);
    _postalCodeController.dispose();
    _localityController.removeListener(_onLocalityChanged);
    _localityController.dispose();
    _countryController.removeListener(_onCountryChanged);
    _countryController.dispose();
    _optionalController.removeListener(_onOptionalChanged);
    _optionalController.dispose();
    super.dispose();
  }
  _onStreetNameChanged(){
    widget.addressOut.streetName = _streetNameController.text;
  }
  _onStreetNumberChanged(){
    widget.addressOut.streetName = _streetNumberController.text;
  }
  _onFlatDoorChanged() {
    widget.addressOut.flatDoor = _flatDoorController.text;
  }
  _onPostalCodeChanged() {
    widget.addressOut.postalCode = _postalCodeController.text;
  }
  _onLocalityChanged() {
    widget.addressOut.locality = _localityController.text;
  }
  _onCountryChanged() {
    widget.addressOut.country = _countryController.text;
  }
  _onOptionalChanged() {
    widget.addressOut.optional = _optionalController.text;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Form(
            key: _formKey,
            child: ListView (
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: TextFormField(
                        decoration: const InputDecoration (
                          labelText: 'Calle',
                          labelStyle: TextStyle (
                            color: tanteLadenIconBrown,
                          ),
                        ),
                        controller: _streetNameController,
                        validator: (String value) {
                          if (value == null) {
                            return 'Introduce una calle';
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 15.0,),
                    Flexible(
                        flex: 1,
                        child: TextFormField (
                          decoration: const InputDecoration (
                            labelText: 'Número',
                            labelStyle: TextStyle (
                              color: tanteLadenIconBrown,
                            ),
                          ),
                          controller: _streetNumberController,
                          validator: (String value) {
                            if (value == null) {
                              return 'Introduce un número';
                            } else {
                              return null;
                            }
                          },
                        )
                    )
                  ],
                ),
                Row(
                  children: [
                    Flexible (
                        flex: 4,
                        child: TextFormField (
                          decoration: const InputDecoration (
                            labelText: 'Piso, Puerta, ...',
                            labelStyle: TextStyle (
                              color: tanteLadenIconBrown,
                            ),
                          ),
                          controller: _flatDoorController,
                        )
                    ),
                    SizedBox(width: 15.0,),
                    Flexible (
                        flex: 2,
                        child: TextFormField (
                          decoration: const InputDecoration (
                            labelText: 'Cód. Postal',
                            labelStyle: TextStyle (
                              color: tanteLadenIconBrown,
                            ),
                          ),
                          controller: _postalCodeController,
                          validator: (String value) {
                            if (value == null) {
                              return 'Introduce un número postal';
                            } else {
                              return null;
                            }
                          },
                        )
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                        flex: 4,
                        child: TextFormField (
                          decoration: const InputDecoration (
                            labelText: 'Ciudad',
                            labelStyle: TextStyle (
                              color: tanteLadenIconBrown,
                            ),
                          ),
                          controller: _localityController,
                        )
                    ),
                    SizedBox(width: 15.0,),
                    Flexible(
                        flex: 4,
                        child: TextFormField (
                          decoration: const InputDecoration (
                            labelText: 'País',
                            labelStyle: TextStyle (
                              color: tanteLadenIconBrown,
                            ),
                          ),
                          controller: _countryController,
                          validator: (String value) {
                            if (value == null) {
                              return 'Introduce un país';
                            } else {
                              return null;
                            }
                          },
                        )
                    )
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                        flex: 1,
                        child: TextFormField (
                          decoration: const InputDecoration (
                            labelText: 'Observaciones',
                            labelStyle: TextStyle (
                              color: tanteLadenIconBrown,
                            ),
                          ),
                          controller: _optionalController,
                        )
                    )
                  ],
                )
              ],
            )
        )
    );
  }
}