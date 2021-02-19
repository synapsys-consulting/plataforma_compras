import 'package:flutter/material.dart';


import 'package:plataforma_compras/models/productAvail.model.dart';

class Catalog {
  List<ProductAvail> _items = [];

  List<ProductAvail> get items => _items;
  void add (ProductAvail item){
    _items.add(item);
  }
  void remove (ProductAvail item){
    this._items.remove(item);
  }

}