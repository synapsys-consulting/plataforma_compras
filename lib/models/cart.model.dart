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
        productNameLong: item.productNameLong,
        productDescription: item.productDescription,
        productType: item.productType,
        brand: item.brand,
        numImages: item.numImages,
        numVideos: item.numVideos,
        purchased: item.minQuantitySell,  // Always purchase the minimun quantity sell
        productPrice: item.productPrice,
        totalBeforeDiscount: item.totalBeforeDiscount,
        taxAmount: item.taxAmount,
        personeId: item.productId,
        personeName: item.personeName,
        businessName: item.businessName,
        email: item.email,
        taxId: item.taxId,
        taxApply: item.taxApply,
        productPriceDiscounted: item.productPriceDiscounted,
        totalAmount: item.totalAmount,
        discountAmount: item.discountAmount,
        idUnit: item.idUnit,
        remark: item.remark,
        minQuantitySell: item.minQuantitySell,
        partnerId: item.partnerId,
        partnerName: item.partnerName
      );
      _items.add(itemCart);
    }
    totalPrice = _items.fold(0, (total, current) => total + (current.totalAmount * current.purchased));
    totalTax = _items.fold(0, (total, current) => total + (((current.productPriceDiscounted * current.taxApply)/100) * current.purchased));
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
    totalPrice = _items.fold(0, (total, current) => total + (current.totalAmount * current.purchased));
    totalTax = _items.fold(0, (total, current) => total + (((current.productPriceDiscounted * current.taxApply)/100) * current.purchased));
    notifyListeners();
  }
  void incrementAvail (ProductAvail item) {
    this.items.forEach((element) { if (element.productId == item.productId) element.purchased += element.minQuantitySell;});  // Always purchase the minimun queantity sell
    totalPrice = _items.fold(0, (total, current) => total + (current.totalAmount * current.purchased));
    totalTax = _items.fold(0, (total, current) => total + (((current.productPriceDiscounted * current.taxApply)/100) * current.purchased));
    notifyListeners();
  }
  void decrementAvail (ProductAvail item) {
    this.items.forEach((element) { if (element.productId == item.productId) element.purchased -= element.minQuantitySell;});  // Always purchase the minimun queantity sell
    totalPrice = _items.fold(0, (total, current) => total + (current.totalAmount * current.purchased));
    totalTax = _items.fold(0, (total, current) => total + (((current.productPriceDiscounted * current.taxApply)/100) * current.purchased));
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