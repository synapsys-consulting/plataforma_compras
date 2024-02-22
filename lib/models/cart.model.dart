import 'package:flutter/foundation.dart';
import 'package:plataforma_compras/models/multiPricesProductAvail.model.dart';

class Cart with ChangeNotifier {
  /// Internal, private state of the cart. Stores the ids of each item.
  final List<MultiPricesProductAvail> _items = [];
  double totalPrice= 0.0;
  double totalTax = 0.0;

  List<MultiPricesProductAvail> get items => _items;

  void add (MultiPricesProductAvail item) {
    bool founded = false;
    if (this._items.length > 0) {
      this.items.forEach((element) {
        if (element.productId == item.productId) {
          element.purchased += element.minQuantitySell;   // Always purchase the minimum quantity sell
          element.totalAmountAccordingQuantity = element.getTotalAmountAccordingQuantity();   // Update the price according the quantity purchased
          founded = true;
        }
      });
    }
    if (!founded) {
      final itemCart = new MultiPricesProductAvail (
        productId: item.productId,
        productCode: item.productCode,
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
        personId: item.productId,
        personName: item.personeName,
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
        partnerName: item.partnerName,
        quantityMinPrice: item.quantityMinPrice,
        quantityMaxPrice: item.quantityMaxPrice,
        productCategoryId: item.productCategoryId,
        rn: item.rn
      );
      item.items.forEach((element) {
        itemCart.items.add(element);
      });
      itemCart.totalAmountAccordingQuantity = itemCart.getTotalAmountAccordingQuantity();   // Update the price according the quantity purchased
      _items.add(itemCart);
    }
    totalPrice = _items.fold(0, (total, current) => total + (current.getTotalAmountAccordingQuantity() * current.purchased));
    totalTax = _items.fold(0, (total, current) => total + (((current.productPriceDiscountedAccordingQuantity() * current.taxApply)/100) * current.purchased));
    notifyListeners();
  }
  void remove (MultiPricesProductAvail item) {
    bool founded = false;
    MultiPricesProductAvail? tmpElement;
    if (this._items.length > 0) {
      this._items.forEach((element) {
        if (element.productId == item.productId) {
          if (element.purchased == element.minQuantitySell) {
            founded = true;
            tmpElement = element;
          } else {
            element.purchased -= element.minQuantitySell; // Always purchase the minimum quantity sell
            element.totalAmountAccordingQuantity = element.getTotalAmountAccordingQuantity(); // Update the price according the quantity purchased
          }
        }
      });
    }
    if (founded) {
      this._items.remove(tmpElement);
    }
    totalPrice = _items.fold(0, (total, current) => total + (current.getTotalAmountAccordingQuantity() * current.purchased));
    totalTax = _items.fold(0, (total, current) => total + (((current.productPriceDiscountedAccordingQuantity() * current.taxApply)/100) * current.purchased));
    notifyListeners();
  }
  void incrementAvail (MultiPricesProductAvail item) {
    this.items.forEach((element) {
      if (element.productId == item.productId) {
        element.purchased += element.minQuantitySell;
        element.totalAmountAccordingQuantity = element.getTotalAmountAccordingQuantity();   // Update the price according the quantity purchased
      }
    });  // Always purchase the minimum quantity sell
    totalPrice = _items.fold(0, (total, current) => total + (current.getTotalAmountAccordingQuantity() * current.purchased));
    totalTax = _items.fold(0, (total, current) => total + (((current.productPriceDiscountedAccordingQuantity() * current.taxApply)/100) * current.purchased));
    notifyListeners();
  }
  void decrementAvail (MultiPricesProductAvail item) {
    this.items.forEach((element) {
      if (element.productId == item.productId) {
        element.purchased -= element.minQuantitySell;
        element.totalAmountAccordingQuantity = element.getTotalAmountAccordingQuantity();   // Update the price according the quantity purchased
      }
    });  // Always purchase the minimum quantity sell
    totalPrice = _items.fold(0, (total, current) => total + (current.getTotalAmountAccordingQuantity() * current.purchased));
    totalTax = _items.fold(0, (total, current) => total + (((current.productPriceDiscountedAccordingQuantity() * current.taxApply)/100) * current.purchased));
    notifyListeners();
  }

  MultiPricesProductAvail getItem (int index) {
    return _items[index];
  }

  void removeCart () {
    this._items.clear();
    this.totalPrice = 0.0;
    this.totalTax = 0.0;
    notifyListeners();
  }

  int get numItems => this._items.length;

}