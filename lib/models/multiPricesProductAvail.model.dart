import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:plataforma_compras/models/productAvail.model.dart';

class MultiPricesProductAvail extends ProductAvail {
  MultiPricesProductAvail({
    @required productId,
    @required productCode,
    @required productName,
    @required productNameLong,
    @required productDescription,
    @required productType,
    @required brand,
    @required numImages,
    @required numVideos,
    @required purchased,
    @required productPrice,
    @required totalBeforeDiscount, // PRICE WITH TAX INCLUDED
    @required taxAmount,
    @required personeId,
    @required personeName,
    @required businessName,
    @required email,
    @required taxId,
    @required taxApply,
    @required productPriceDiscounted,
    @required totalAmount,
    @required discountAmount,
    @required idUnit,
    @required remark,
    @required minQuantitySell,
    @required partnerId,
    @required partnerName,
    @required quantityMinPrice,
    @required quantityMaxPrice,
    @required productCategoryId,
    @required rn
  }): super (
    productId: productId,
    productCode: productCode,
    productName: productName,
    productNameLong: productNameLong,
    productDescription: productDescription,
    productType: productType,
    brand: brand,
    numImages: numImages,
    numVideos: numVideos,
    purchased: purchased,
    productPrice: productPrice,
    totalBeforeDiscount: totalBeforeDiscount,
    taxAmount: taxAmount,
    personeId: personeId,
    personeName: personeName,
    businessName: businessName,
    email: email,
    taxId: taxId,
    taxApply: taxApply,
    productPriceDiscounted: productPriceDiscounted,
    totalAmount: totalAmount,
    discountAmount: discountAmount,
    idUnit: idUnit,
    remark: remark,
    minQuantitySell: minQuantitySell,
    partnerId: partnerId,
    partnerName: partnerName,
    quantityMinPrice: quantityMinPrice,
    quantityMaxPrice: quantityMaxPrice,
    productCategoryId: productCategoryId,
    rn: rn
  ){
    this.totalAmountAccordingQuantity = totalAmount;
  }

  factory MultiPricesProductAvail.fromJson (Map<String, dynamic> json) {
    return MultiPricesProductAvail (
        productId: int.parse(json['PRODUCT_ID'].toString()),
        productCode: int.parse(json['PRODUCT_CODE'].toString()),
        productName: json['PRODUCT_NAME'],
        productNameLong: json['PRODUCT_NAME_LONG'],
        productDescription: json['PRODUCT_DESCRIPTION'] ?? '',
        productType: json['PRODUCT_TYPE'] ?? '',
        brand: json['BRAND'] ?? '',
        numImages: int.parse((json['NUM_IMAGES'] ?? '0').toString()),
        numVideos: int.parse((json['NUM_VIDEOS'] ?? '0').toString()),
        purchased: 0,
        productPrice: double.parse(json['PRODUCT_PRICE'].toString()),
        totalBeforeDiscount: double.parse(json['TOTAL_BEFORE_DISCOUNT'].toString()),
        taxAmount: double.parse(json['TAX_AMOUNT'].toString()),
        personeId: int.parse((json['PERSONE_ID'] ?? '0').toString()),
        personeName: json['PERSONE_NAME'] ?? '',
        businessName: json['BUSINESS_NAME'].toString() ?? '',
        email: json['EMAIL'] ?? '',
        taxId: int.parse(json['TAX_ID'].toString()),
        taxApply: double.parse(json['TAX_APPLY'].toString()),
        productPriceDiscounted: double.parse(json['PRODUCT_PRICE_DISCOUNTED'].toString()),
        totalAmount: double.parse(json['TOTAL_AMOUNT'].toString()),
        discountAmount: int.parse(json['DISCOUNT_AMOUNT'].toString()),
        idUnit: json['ID_UNIT'] ?? '',
        remark: json['REMARK'] ?? '',
        minQuantitySell: double.parse((json['MIN_QUANTITY_SELL'] ?? '0').toString()),
        partnerId: int.parse((json['PARTNER_ID'] ?? '1').toString()),
        partnerName: json['PARTNER_NAME'] ?? '',
        quantityMinPrice: double.parse((json['QUANTITY_MIN_PRICE'] ?? '0').toString()),
        quantityMaxPrice: double.parse((json['QUANTITY_MAX_PRICE'] ?? '99999').toString()),
        productCategoryId: int.parse((json['PRODUCT_CATEGORY_ID'] ?? '0').toString()),
        rn: int.parse((json['RN'] ?? '1').toString()),
    );
  }

  final List<ProductAvail> _items = [];   // Save the registers which have the different prices depending the amount
  int _indexElementAmongQuantity = -1;    // Save the element according quantity. Default = -1. It is the father element
  double totalAmountAccordingQuantity;    // Save the field totalAmount according the quantity of the product purchased

  List<ProductAvail> get items => this._items;

  void add (ProductAvail item) {
    bool founded = false;
    if (this._items.length > 0) {
      this.items.forEach((element) {
        if (element.productId == item.productId) {
          founded = true;
        }
      });
    }
    if (!founded) {
      final itemCatalog = new ProductAvail(
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
        quantityMaxPrice: item.quantityMaxPrice,
        quantityMinPrice: item.quantityMinPrice,
        productCategoryId: item.productCategoryId,
        rn: item.rn
      );
      this._items.add(itemCatalog);
    }
  }
  ProductAvail getItem (int index) {
    return this._items[index];
  }
  void clear () {
    this._items.clear();
  }
  int get numItems => this._items.length;

  int getIndexElementAmongQuantity () {
    return this._indexElementAmongQuantity;
  }
  double getTotalAmountAccordingQuantity () {
    double totalAmountAccordingQuantity;
    if (this._items.length > 0) {
      // The product hast multi-prices according quantity
      //debugPrint ('Estoy en el totalAmountAccordingQuantity. Dentro de _items > 0');
      if (this.purchased <= this.quantityMaxPrice) {
        // See the first element, the father element
        totalAmountAccordingQuantity = this.totalAmount;
        this._indexElementAmongQuantity = -1;  // Save the element according quantity
        //debugPrint ('Estoy en el totalAmountAccordingQuantity. Father element.');
      } else {
        // See the rest of the elements, children elements
        for (var j = 0; j < this._items.length; j++) {
          //debugPrint ('Estoy en el totalAmountAccordingQuantity. Children element.');
          if (this.purchased <= this._items[j].quantityMaxPrice) {
            totalAmountAccordingQuantity = this._items[j].totalAmount;
            this._indexElementAmongQuantity = j;  // Save the element according quantity
            //debugPrint ('Estoy en el totalAmountAccordingQuantity. El indice que marca el totalAmountAccordingQuantity es: ' + this._indexElementAmongQuantity.toString());
            break;
          }
        }
      }
    } else {
      //debugPrint ('Estoy en el totalAmountAccordingQuantity. Dentro de _items = 0');
      totalAmountAccordingQuantity = this.totalAmount;
      this._indexElementAmongQuantity = -1;  // Save the element according quantity
    }
    //debugPrint ('Estoy en el totalAmountAccordingQuantity. Retorno: ' + totalAmountAccordingQuantity.toString());
    return totalAmountAccordingQuantity;
  }
  double productPriceDiscountedAccordingQuantity () {
    double productPriceDiscountedAccordingQuantity;
    if (this._items.length > 0) {
      // The product hast multi-prices according quantity
      if (this.purchased < this.quantityMaxPrice) {
        // See the first element, the father element
        productPriceDiscountedAccordingQuantity = this.productPriceDiscounted;
      } else {
        // See the rest the elements
        for (var j = 0; j < this._items.length; j++) {
          if (this.purchased < this._items[j].quantityMaxPrice) {
            productPriceDiscountedAccordingQuantity = this._items[j].productPriceDiscounted;
            break;
          }
        }
      }
    } else {
      productPriceDiscountedAccordingQuantity = this.productPriceDiscounted;
    }
    return productPriceDiscountedAccordingQuantity;
  }
}