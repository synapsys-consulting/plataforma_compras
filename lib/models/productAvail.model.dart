import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductAvail {
  ProductAvail({
    @required this.product_id,
    @required this.product_name,
    @required this.product_description,
    @required this.product_type,
    @required this.brand,
    @required this.num_images,
    @required this.num_videos,
    @required this.avail,
    @required this.product_price,
    @required this.persone_id,
    @required this.persone_name,
    @required this.tax_id,
    @required this.tax_apply,
    @required this.remark
  }
  );
  final int product_id;
  final String product_name;
  final String product_description;
  final String product_type;
  final String brand;
  final int num_images;
  final int num_videos;
  int avail;
  final double product_price;
  final int persone_id;
  final String persone_name;
  final int tax_id;
  final double tax_apply;
  final String remark;

  factory ProductAvail.fromJson (Map<String, dynamic> json) {
    return ProductAvail (
        product_id: int.parse(json['PRODUCT_ID'].toString()),
        product_name: json['PRODUCT_NAME'],
        product_description: json['PRODUCT_DESCRIPTION'] ?? '',
        product_type: json['PRODUCT_TYPE'] ?? '',
        brand: json['BRAND'] ?? '',
        num_images: int.parse((json['NUM_IMAGES'] ?? '0').toString()),
        num_videos: int.parse((json['NUM_VIDEOS'] ?? '0').toString()),
        avail: int.parse((json['AVAIL'] ?? '0').toString()),
        product_price: double.parse(json['PRODUCT_PRICE'].toString()),
        persone_id: int.parse((json['PERSONE_ID'] ?? '0').toString()),
        persone_name: json['PERSONE_NAME'] ?? '',
        tax_id: int.parse(json['TAX_ID'].toString()),
        tax_apply: double.parse(json['TAX_APPLY'].toString()),
        remark: json['REMARK'] ?? '',
    );
  }
}