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
    @required this.avail,
    @required this.purchased,
    @required this.productPrice,
    @required this.personeId,
    @required this.personeName,
    @required this.taxId,
    @required this.taxApply,
    @required this.remark
  }
  );
  final int productId;
  final String productName;
  final String productDescription;
  final String productType;
  final String brand;
  final int numImages;
  final int numVideos;
  int avail;
  int purchased;
  final double productPrice;
  final int personeId;
  final String personeName;
  final int taxId;
  final double taxApply;
  final String remark;

  factory ProductAvail.fromJson (Map<String, dynamic> json) {
    return ProductAvail (
        productId: int.parse(json['PRODUCT_ID'].toString()),
        productName: json['PRODUCT_NAME'],
        productDescription: json['PRODUCT_DESCRIPTION'] ?? '',
        productType: json['PRODUCT_TYPE'] ?? '',
        brand: json['BRAND'] ?? '',
        numImages: int.parse((json['NUM_IMAGES'] ?? '0').toString()),
        numVideos: int.parse((json['NUM_VIDEOS'] ?? '0').toString()),
        avail: int.parse((json['AVAIL'] ?? '0').toString()),
        purchased: 0,
        productPrice: double.parse(json['PRODUCT_PRICE'].toString()),
        personeId: int.parse((json['PERSONE_ID'] ?? '0').toString()),
        personeName: json['PERSONE_NAME'] ?? '',
        taxId: int.parse(json['TAX_ID'].toString()),
        taxApply: double.parse(json['TAX_APPLY'].toString()),
        remark: json['REMARK'] ?? '',
    );
  }
}