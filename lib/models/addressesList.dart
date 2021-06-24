import 'package:flutter/foundation.dart';

import 'package:plataforma_compras/models/address.model.dart';

class AddressesList extends ChangeNotifier {
  /// Internal, private state of the Warehouse. Stores the ids of each item.
  final List<Address> _items = [];

  List<Address> get items => _items;

  void add (Address item) {
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
  void remove (Address item) {
    bool founded = false;
    int indexTmp;
    if (this._items.length > 0) {
      for (int j = 0; j < this._items.length; j++) {
        if (this._items[j].addrId == item.addrId) {
          founded = true;
          indexTmp = j;
        }
      }
      if (founded) {
        this.items.removeAt(indexTmp);
      }
    }
    notifyListeners();
  }
  Address getItem (int index) {
    return _items[index];
  }
  void clearAddressList () {
    this._items.clear();
    notifyListeners();
  }
  int get numItems => this._items.length;
}