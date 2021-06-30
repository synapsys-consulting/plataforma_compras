import 'package:flutter/foundation.dart';
import 'package:plataforma_compras/models/productAvail.model.dart';

class Cart with ChangeNotifier {
  /// Internal, private state of the cart. Stores the ids of each item.
  final List<ProductAvail> _items = [];
  double totalPrice= 0.0;
  double totalTax = 0.0;

  List<ProductAvail> get items => _items;

  void add (ProductAvail item) {
    bool founded = false;
    if (this._items.length > 0) {
      this.items.forEach((element) {
        if (element.productId == item.productId) {
          element.purchased += element.minQuantitySell; // Always purchase the minimun queantity sell
          founded = true;
        }
      });
    }
    if (!founded) {
      final itemCart = new ProductAvail (
        productId: item.productId,
        productName: item.productName,
        productDescription: item.productDescription,
        productType: item.productType,
        brand: item.brand,
        numImages: item.numImages,
        numVideos: item.numVideos,
        avail: item.avail,
        purchased: item.minQuantitySell,  // Always purchase the minimun queantity sell
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
      _items.add(itemCart);
    }
    totalPrice = _items.fold(0, (total, current) => total + (current.productPrice * current.purchased));
    totalTax = _items.fold(0, (total, current) => total + (((current.productPrice * current.taxApply)/100) * current.purchased));
    notifyListeners();
  }
  void remove (ProductAvail item) {
    bool founded = false;
    ProductAvail tmpElement;
    if (this._items.length > 0) {
      this._items.forEach((element) {
        if (element.productId == item.productId) {
          if (element.purchased == element.minQuantitySell) {
            founded = true;
            tmpElement = element;
          } else {
            element.purchased -= element.minQuantitySell; // Always purchase the minimun queantity sell
          }
        }
      });
    }
    if (founded) {
      this._items.remove(tmpElement);
    }
    totalPrice = _items.fold(0, (total, current) => total + (current.productPrice * current.purchased));
    totalTax = _items.fold(0, (total, current) => total + (((current.productPrice * current.taxApply)/100) * current.purchased));
    notifyListeners();
  }
  void incrementAvail (ProductAvail item) {
    this.items.forEach((element) { if (element.productId == item.productId) element.purchased += element.minQuantitySell;});  // Always purchase the minimun queantity sell
    totalPrice = _items.fold(0, (total, current) => total + (current.productPrice * current.purchased));
    totalTax = _items.fold(0, (total, current) => total + (((current.productPrice * current.taxApply)/100) * current.purchased));
    notifyListeners();
  }
  void decrementAvail (ProductAvail item) {
    this.items.forEach((element) { if (element.productId == item.productId) element.purchased -= element.minQuantitySell;});  // Always purchase the minimun queantity sell
    totalPrice = _items.fold(0, (total, current) => total + (current.productPrice * current.purchased));
    totalTax = _items.fold(0, (total, current) => total + (((current.productPrice * current.taxApply)/100) * current.purchased));
    notifyListeners();
  }

  ProductAvail getItem (int index) {
    return _items[index];
  }

  void clearCart () {
    this._items.clear();
    this.totalPrice = 0.0;
    this.totalTax = 0.0;
    notifyListeners();
  }

  int get numItems => this._items.length;
}