import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/models/addressGeoLocation.dart';
import 'package:plataforma_compras/utils/showSnackBar.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/utils/pleaseWaitWidget.dart';
import 'package:plataforma_compras/views/confirmPurchase.view.dart';
import 'package:plataforma_compras/models/address.model.dart';
import 'package:plataforma_compras/models/defaultAddressList.model.dart';
import 'package:plataforma_compras/models/addressesList.model.dart';

class DetailAddressView extends StatefulWidget {
  DetailAddressView({Key key, @required this.address, @required this.personeId, @required this.fromWhereCalledIs}) : super(key: key);
  final AddressGeoLocation address;
  final String personeId;
  final int fromWhereCalledIs;  // 2: ist called from purchase management; 1: ist called from the Drawer option
  @override
  _DetailAddressViewState createState() {
    return _DetailAddressViewState();
  }
}
class _DetailAddressViewState extends State<DetailAddressView> {
  AddressGeoLocation _addressOut;
  bool _pleaseWait = false;
  final PleaseWaitWidget _pleaseWaitWidget = PleaseWaitWidget(key: ObjectKey("pleaseWaitWidget"));
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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
  @override
  Widget build(BuildContext context) {
    var addressesList = context.read<AddressesList>();
    var defaultAddressList = context.read<DefaultAddressList>();
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
              final Map<String, dynamic> resultJson = json.decode(res.body)['address'].cast<String, dynamic>();
              final Address resultAddress = Address.fromJson(resultJson);
              final List<Address> resultListAddress = [resultAddress];
              final SharedPreferences prefs = await _prefs;
              final String token = prefs.get ('token') ?? '';
              Map<String, dynamic> payload;
              payload = json.decode(
                  utf8.decode(
                      base64.decode(base64.normalize(token.split(".")[1]))
                  )
              );
              if (defaultAddressList.numItems == 0) {
                defaultAddressList.add(resultAddress);
              } else {
                addressesList.add(resultAddress);
              }
              _showPleaseWait(false);
              if (widget.fromWhereCalledIs == COME_FROM_ANOTHER) {  // 2: ist called from purchase management; 1: ist called from the Drawer option
                //const COME_FROM_DRAWER = 1;
                // const COME_FROM_ANOTHER = 2;
                Navigator.push (
                    context,
                    MaterialPageRoute (
                        builder: (context) => (ConfirmPurchaseView(resultListAddress, payload['phone_number'].toString(), payload['user_id'].toString()))
                    )
                );
              } else {
                // 2: ist called from purchase management; 1: ist called from the Drawer option
                //const COME_FROM_DRAWER = 1;
                // const COME_FROM_ANOTHER = 2;
                //Navigator.popUntil(context, ModalRoute.withName('/'));
                Navigator.pop(context);
                Navigator.pop(context);
              }
            } else {
              _showPleaseWait (false);
            }
          } catch (e) {
            _showPleaseWait (false);
            debugPrint ('El error es: ' + e.toString());
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
    widget.addressOut.streetNumber = _streetNumberController.text;
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