import 'package:flutter/foundation.dart';
import 'package:plataforma_compras/models/multiPricesProductAvail.model.dart';

class Catalog with ChangeNotifier {
  /// Internal, private state of the Warehouse. Stores the ids of each item.
  final List<MultiPricesProductAvail> _items = [];

  List<MultiPricesProductAvail> get items => _items;

  void add (MultiPricesProductAvail item) {
    bool founded = false;
    if (this._items.length > 0) {
      this.items.forEach((element) {
        if (element.productId == item.productId) {
          element.purchased += element.minQuantitySell;   // Always purchase the minimum quantity sell
          element.totalAmountAccordingQuantity = element.getTotalAmountAccordingQuantity(); // Update the price according the quantity purchased
          founded = true;
        }
      });
    }
    if (!founded) {
      final itemCatalog = new MultiPricesProductAvail(
        productId: item.productId,
        productCode: item.productCode,
        productName: item.productName,
        productNameLong: item.productNameLong,
        productDescription: item.productDescription,
        productType: item.productType,
        brand: item.brand,
        numImages: item.numImages,
        numVideos: item.numVideos,
        purchased: 0,
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
        partnerName: item.partnerName,
        quantityMinPrice: item.quantityMinPrice,
        quantityMaxPrice: item.quantityMaxPrice,
        productCategoryId: item.productCategoryId,
        rn: item.rn
      );
      item.items.forEach((element) {
        itemCatalog.items.add(element);
      });
      _items.add(itemCatalog);
    }
    notifyListeners();
  }
  void addChildrenToFatherElement (int productIdFather, MultiPricesProductAvail children) {
    if (this._items.length > 0) {
      this.items.forEach((element) {
        if (element.productId == productIdFather) {
          element.items.add(children);
        }
      });
    }
  }
  void remove (MultiPricesProductAvail item) {
    if (this._items.length > 0) {
      this.items.forEach((element) {
        //if (element.productId == item.productId) (element.purchased == element.minQuantitySell) ? element.purchased = 0 : element.purchased -= element.minQuantitySell; // Always purchase the minimum quantity sell
        if (element.productId == item.productId) {
          (element.purchased == element.minQuantitySell) ? element.purchased = 0 : element.purchased -= element.minQuantitySell;  // Always purchase the minimum quantity sell
          element.totalAmountAccordingQuantity = element.getTotalAmountAccordingQuantity();   // Update the price according the quantity purchased
        }
      });
    }
    notifyListeners();
  }
  void incrementAvail (MultiPricesProductAvail item) {
    this.items.forEach((element) {
      if (element.productId == item.productId) {
        element.purchased += element.minQuantitySell;
        element.totalAmountAccordingQuantity = element.getTotalAmountAccordingQuantity();   // Update the price according the quantity purchased
      }
    });  // Always purchase the minimum quantity sell
    notifyListeners();
  }
  void decrementAvail (MultiPricesProductAvail item) {
    this.items.forEach((element) {
      if (element.productId == item.productId) {
        element.purchased -= element.minQuantitySell;
        element.totalAmountAccordingQuantity = element.getTotalAmountAccordingQuantity();   // Update the price according the quantity purchased
      }
    });  // Always purchase the minimum quantity sell
    notifyListeners();
  }
  MultiPricesProductAvail  getItem (int index) {
    return _items[index];
  }
  void clearCatalog () {
    this._items.forEach((element) {
      element.purchased = 0;
      element.totalAmountAccordingQuantity = element.getTotalAmountAccordingQuantity();
      notifyListeners();
    });
  }
  void removeCatalog () {
    this._items.clear();
    notifyListeners();
  }
  int get numItems => this._items.length;

}