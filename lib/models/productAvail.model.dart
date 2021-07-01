import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductAvail {
  ProductAvail({
    @required this.productId,
    @required this.productName,
    @required this.productDescription,
    @required this.productType,
    @required this.brand,
    @required this.numImages,
    @required this.numVideos,
    @required this.purchased,
    @required this.productPrice,
    @required this.totalBeforeDiscount, // PRICE WITH TAX INCLUDED
    @required this.taxAmount,
    @required this.personeId,
    @required this.personeName,
    @required this.businessName,
    @required this.email,
    @required this.taxId,
    @required this.taxApply,
    @required this.productPriceDiscounted,
    @required this.totalAmount,
    @required this.discountAmount,
    @required this.idUnit,
    @required this.remark,
    @required this.minQuantitySell
  }
  );
  final int productId;
  final String productName;
  final String productDescription;
  final String productType;
  final String brand;
  final int numImages;
  final int numVideos;
  int purchased;
  final double productPrice;
  final double totalBeforeDiscount;
  final double taxAmount;
  final int personeId;
  final String personeName;
  final String businessName;
  final String email;
  final int taxId;
  final double taxApply;
  final double productPriceDiscounted;   // FINAL PRICE WITH DISCOUNT INCLUDED
  final double totalAmount;              // FINAL PRICE WITH DISCOUNT INCLUDED AND TAXES
  final int discountAmount;           // PRODUCT_PRICE - PRODUCT_PRICE_DISCOUNTED
  final  String idUnit;
  final String remark;
  int minQuantitySell;

  factory ProductAvail.fromJson (Map<String, dynamic> json) {
    return ProductAvail (
      productId: int.parse(json['PRODUCT_ID'].toString()),
      productName: json['PRODUCT_NAME'],
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
      minQuantitySell: int.parse((json['MIN_QUANTITY_SELL'] ?? '0').toString())
    );
  }
}