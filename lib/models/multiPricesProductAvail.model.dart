import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:plataforma_compras/models/productAvail.model.dart';

class MultiPricesProductAvail extends ProductAvail {
  MultiPricesProductAvail({
    @required productId,
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
  });

  factory MultiPricesProductAvail.fromJson (Map<String, dynamic> json) {
    return MultiPricesProductAvail (
        productId: int.parse(json['PRODUCT_ID'].toString()),
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
        minQuantitySell: int.parse((json['MIN_QUANTITY_SELL'] ?? '0').toString()),
        partnerId: int.parse((json['PARTNER_ID'] ?? '1').toString()),
        partnerName: json['PARTNER_NAME'] ?? '',
        quantityMinPrice: int.parse((json['QUANTITY_MIN_PRICE'] ?? '0').toString()),
        quantityMaxPrice: int.parse((json['QUANTITY_MAX_PRICE'] ?? '99999').toString()),
        productCategoryId: int.parse((json['PRODUCT_CATEGORY_ID'] ?? '0').toString()),
        rn: int.parse((json['RN'] ?? '1').toString()),
    );
  }
  final List<ProductAvail> _items = [];   // Save the registers which have the different prices depending the amount

  List<ProductAvail> get items => _items;

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
      _items.add(itemCatalog);
    }
  }
  ProductAvail getItem (int index) {
    return _items[index];
  }
  void clear () {
    this._items.clear();
  }
  int get numItems => this._items.length;
}