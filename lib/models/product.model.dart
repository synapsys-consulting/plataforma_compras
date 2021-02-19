import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Product {
  const Product({
    @required this.product_id,
    @required this.product_code,
    @required this.product_category_id,
    @required this.product_category,
    @required this.product_name,
    @required this.product_name_internal,
    @required this.product_description,
    @required this.brand_id,
    @required this.brand,
    @required this.min_quantity_sell,
    @required this.language_code,
    @required this.product_price,
    @required this.tax_id,
    @required this.currency_id,
    @required this.unit_id,
    @required this.des_unit,
    @required this.weeks_warning,
    @required this.quantity_min_price,
    @required this.quantity_max_price,
    @required this.type_day_delivery,
    @required this.des_delivery_type,
    @required this.min_days_delivery,
    @required this.max_days_delivery,
    @required this.remark,
    @required this.days_delivery,
    @required this.product_type_id,
    @required this.provider_id,
    @required this.persone_name,
    @required this.partner_id,
    @required this.partner_name,
    @required this.eff_date,
    @required this.exp_date,
    @required this.days_exp,
    @required this.expoiled_flag,
    @required this.countable_flag,
    @required this.source_id,
    @required this.num_images,
    @required this.num_videos
  });
  final int product_id;
  final String product_code;
  final int product_category_id;
  final String product_category;
  final String product_name;
  final String product_name_internal;
  final String product_description;
  final int brand_id;
  final String brand;
  final double min_quantity_sell;
  final String language_code;
  final double product_price;
  final int tax_id;
  final String currency_id;
  final String unit_id;
  final String des_unit;
  final double weeks_warning;
  final double quantity_min_price;
  final double quantity_max_price;
  final String type_day_delivery;
  final String des_delivery_type;
  final double min_days_delivery;
  final double max_days_delivery;
  final String remark;
  final String days_delivery;
  final int product_type_id;
  final int provider_id;
  final String persone_name;
  final String partner_id;
  final String partner_name;
  final String eff_date;
  final String exp_date;
  final int days_exp;
  final String expoiled_flag;
  final String countable_flag;
  final String source_id;
  final int num_images;
  final int num_videos;
  
  factory Product.fromJson (Map<String, dynamic> json) {
    print ('I am in.');
    print (json);
    print ('Hola');
    print ('El PRODUCT_ID: ' + int.parse(json['PRODUCT_ID'].toString()).toString());
    print ('PRODUCT_CODE: '+ json['PRODUCT_CODE']);
    print ('PRODUCT_CATEGORY_ID: ' + json['PRODUCT_CATEGORY_ID'].toString());
    print ('PRODUCT_CATEGORY: '+ json['PRODUCT_CATEGORY']);
    print ('PRODUCT_NAME: '+ json['PRODUCT_NAME']);
    print ('PRODUCT_NAME_INTERNAL: '+ json['PRODUCT_NAME_INTERNAL']);
    //print ('PRODUCT_DESCRIPTION: ' + json['PRODUCT_DESCRIPTION'] == null ? '' : json['PRODUCT_DESCRIPTION']);
    //if ()
    //print ('PRODUCT_DESCRIPTION: ' + json['PRODUCT_DESCRIPTION'] ?? 'Venía un null');
    print (json['PRODUCT_DESCRIPTION'] ?? '');
    print ('BRAND_ID: ' + int.parse(json['PRODUCT_ID'].toString()).toString());
    print('PRODUCT_TYPE_ID: ' + int.parse((json['PRODUCT_TYPE_ID'] ?? '-3').toString()).toString());
    print('PROVIDER_ID: ' + int.parse(json['PROVIDER_ID'].toString()).toString());
    print('PERSONE_NAME: ' + json['PERSONE_NAME']);
    print('PARTNER_ID: ' + json['PARTNER_ID']);
    print('PARTNER_NAME: ' + json['PARTNER_NAME']);
    print('DAYS_EXP: ' + int.parse(json['DAYS_EXP'] ?? '-3').toString());
    print('NUM_IMAGES: ' + int.parse(json['NUM_IMAGES'].toString()).toString());
    print('NUM_VIDEOS: ' + int.parse(json['NUM_VIDEOS'].toString()).toString());
    print('Adios');
    return Product (
      product_id: int.parse(json['PRODUCT_ID'].toString()),
      product_code: json['PRODUCT_CODE'] ?? '',
      product_category_id: int.parse(json['PRODUCT_CATEGORY_ID'].toString()),
      product_category: json['PRODUCT_CATEGORY'],
      product_name: json['PRODUCT_NAME'],
      product_name_internal: json['PRODUCT_NAME_INTERNAL'],
      product_description: json['PRODUCT_DESCRIPTION'] ?? '',
      brand_id: int.parse((json['BRAND_ID'] ?? '-3').toString()),
      brand: json['BRAND'] ?? '',
      min_quantity_sell: double.parse(json['MIN_QUANTITY_SELL'].toString()),
      language_code: json['LANGUAGE_CODE'],
      product_price: double.parse(json['PRODUCT_PRICE'].toString()),
      tax_id: int.parse(json['TAX_ID'].toString()),
      currency_id: json['CURRENCY_ID'],
      unit_id: json['UNIT_ID'],
      des_unit: json['DES_UNIT'],
      weeks_warning: double.parse(json['WEEKS_WARNING'].toString()),
      quantity_min_price: double.parse(json['QUANTITY_MIN_PRICE'].toString()),
      quantity_max_price: double.parse(json['QUANTITY_MAX_PRICE'].toString()),
      type_day_delivery: json['TYPE_DAY_DELIVERY'] ?? '',
      des_delivery_type: json['DES_DELIVERY_TYPE'] ?? '',
      min_days_delivery: double.parse((json['MIN_DAYS_DELIVERY'] ?? '-3').toString()),
      max_days_delivery: double.parse((json['MAX_DAYS_DELIVERY'] ?? '-3').toString()),
      remark: json['REMARK'] ?? '',
      days_delivery: json['DAYS_DELIVERY'] ?? '',
      product_type_id: int.parse((json['PRODUCT_TYPE_ID'] ?? '-3').toString()),
      provider_id: int.parse(json['PROVIDER_ID'].toString()),
      persone_name: json['PERSONE_NAME'],
      partner_id: json['PARTNER_ID'],
      partner_name: json['PARTNER_NAME'],
      eff_date: json['EFF_DATE'],
      exp_date: json['EXP_DATE'] ?? '',
      days_exp: int.parse((json['DAYS_EXP'] ?? '-3').toString()),
      expoiled_flag: json['EXPOILED_FLAG'] ?? '',
      countable_flag: json['COUNTABLE_FLAG'] ?? '',
      source_id: json['SOURCE_ID'],
      num_images: int.parse((json['NUM_IMAGES'] ?? '0').toString()),
      num_videos: int.parse((json['NUM_VIDEOS'] ?? '0').toString())
    );
  }
}