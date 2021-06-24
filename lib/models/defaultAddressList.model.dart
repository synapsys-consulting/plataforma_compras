import 'package:flutter/foundation.dart';

import 'package:plataforma_compras/models/address.model.dart';

class DefaultAddressList extends ChangeNotifier {
  /// Internal, private state of the Warehouse. Stores the ids of each item.
  final List<Address> _items = [];

  List<Address> get items => _items;

  void add (Address item) {
    this._items.clear();
    final itemAddress = new Address (
      addrId: item.addrId,
      streetName: item.streetName,
      streetNumber: item.streetNumber,
      flatDoor: item.flatDoor,
      postalCode: item.postalCode,
      locality: item.locality,
      province: item.province,
      country: item.country,
      state: item.state,
      optional: item.optional,
      district: item.district,
      suburb: item.suburb,
      statusId: item.statusId
    );
    _items.add(itemAddress);
    notifyListeners();
  }
  Address  getItem (int index) {
    return _items[index];
  }
  int get numItems => this._items.length;

  void clearDefaultAddressList () {
    this._items.clear();
    notifyListeners();
  }
}