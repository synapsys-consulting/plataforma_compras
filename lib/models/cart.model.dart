import 'package:flutter/foundation.dart';
import 'package:plataforma_compras/models/productAvail.model.dart';

class Cart with ChangeNotifier {
  /// Internal, private state of the cart. Stores the ids of each item.
  final List<ProductAvail> _items = [];
  double totalPrice= 0.0;

  List<ProductAvail> get items => _items;

  void add (ProductAvail item){
    bool founded = false;
    if (this._items.length > 0) {
      this.items.forEach((element) {
        if (element.productId == item.productId) {
          element.purchased += 1;
          founded = true;
        }
      });
    }
    if (!founded) {
      final itemCart = new ProductAvail(
          productId: item.productId,
          productName: item.productName,
          productDescription: item.productDescription,
          productType: item.productType,
          brand: item.brand,
          numImages: item.numImages,
          numVideos: item.numVideos,
          avail: item.avail,
          purchased: 1,
          productPrice: item.productPrice,
          personeId: item.productId,
          personeName: item.personeName,
          taxId: item.taxId,
          taxApply: item.taxApply,
          remark: item.remark
      );
      _items.add(itemCart);
    }
    totalPrice = _items.fold(0, (total, current) => total + (current.productPrice * current.purchased));
    notifyListeners();
  }
  void remove (ProductAvail item) {
    bool founded = false;
    ProductAvail tmpElement;
    if (this._items.length > 0) {
      this._items.forEach((element) {
        if (element.productId == item.productId) {
          if (element.purchased == 1) {
            founded = true;
            tmpElement = element;
          }
          else {
            element.purchased -= 1;
          }
        }
      });
    }
    if (founded) {
      this._items.remove(tmpElement);
    }
    totalPrice = _items.fold(0, (total, current) => total + (current.productPrice * current.purchased));
    notifyListeners();
  }
  void incrementAvail (ProductAvail item) {
    this.items.forEach((element) { if (element.productId == item.productId) element.purchased += 1;});
    totalPrice = _items.fold(0, (total, current) => total + (current.productPrice * current.purchased));
    notifyListeners();
  }
  void decrementAvail (ProductAvail item) {
    this.items.forEach((element) { if (element.productId == item.productId) element.purchased -= 1;});
    totalPrice = _items.fold(0, (total, current) => total + (current.productPrice * current.purchased));
    notifyListeners();
  }

  ProductAvail getItem (int index) {
    return _items[index];
  }

  void clearCart () {
    this._items.clear();
    this.totalPrice = 0.0;
    notifyListeners();
  }

  int get numItems => this._items.length;
}