import 'package:flutter/foundation.dart';
import 'package:plataforma_compras/models/productAvail.model.dart';

class Catalog with ChangeNotifier {
  /// Internal, private state of the Warehouse. Stores the ids of each item.
  final List<ProductAvail> _items = [];

  List<ProductAvail> get items => _items;

  void add (ProductAvail item) {
    bool founded = false;
    if (this._items.length > 0) {
      this.items.forEach((element) {
        if (element.productId == item.productId) {
          element.purchased += element.minQuantitySell;   // Always purchase the minimun queantity sell
          founded = true;
        }
      });
    }
    if (!founded) {
      final itemCatalog = new ProductAvail(
        productId: item.productId,
        productName: item.productName,
        productDescription: item.productDescription,
        productType: item.productType,
        brand: item.brand,
        numImages: item.numImages,
        numVideos: item.numVideos,
        avail: item.avail,
        purchased: 0,
        productPrice: item.productPrice,
        personeId: item.productId,
        personeName: item.personeName,
        businessName: item.businessName,
        email: item.email,
        taxId: item.taxId,
        taxApply: item.taxApply,
        idUnit: item.idUnit,
        remark: item.remark,
        minQuantitySell: item.minQuantitySell
      );
      _items.add(itemCatalog);
    }
    notifyListeners();
  }
  void remove (ProductAvail item) {
    if (this._items.length > 0) {
      this.items.forEach((element) {
        if (element.productId == item.productId) (element.purchased == element.minQuantitySell) ? element.purchased = 0 : element.purchased -= element.minQuantitySell; // Always purchase the minimun queantity sell
      });
    }
    notifyListeners();
  }
  void incrementAvail (ProductAvail item) {
    this.items.forEach((element) { if (element.productId == item.productId) element.purchased += element.minQuantitySell;});  // Always purchase the minimun queantity sell
    notifyListeners();
  }
  void decrementAvail (ProductAvail item) {
    this.items.forEach((element) { if (element.productId == item.productId) element.purchased -= element.minQuantitySell;});  // Always purchase the minimun queantity sell
    notifyListeners();
  }
  ProductAvail  getItem (int index) {
    return _items[index];
  }
  void clearCatalog () {
    this._items.forEach((element) {
      element.purchased = 0;
      notifyListeners();
    });
  }
  int get numItems => this._items.length;

}