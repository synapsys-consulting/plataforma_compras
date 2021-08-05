import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PurchaseLine {
  PurchaseLine ({
    @required this.orderId,
    @required this.providerName,
    @required this.allStatus,
    @required this.numStatus,
    @required this.items,
    @required this.situation,
    @required this.totalAmount,
    @required this.taxAmount,
    @required this.discountAmount,
    @required this.productPriceFinal,
    @required this.productPrice,
    @required this.totalBeforeDiscountWithoutTax,
    @required this.totalAfterDiscountWithoutTax,
    @required this.orderDate
  });
  final int orderId;
  final String providerName;
  final String allStatus;
  final int numStatus;
  final int items;
  final String situation;
  final double totalAmount;
  final double taxAmount;
  final double discountAmount;
  final double productPriceFinal;
  final double productPrice;
  final double totalBeforeDiscountWithoutTax;
  final double totalAfterDiscountWithoutTax;
  final DateTime orderDate;
  factory PurchaseLine.fromJson (Map<String, dynamic> json) {
    return new PurchaseLine (
      orderId: int.parse(json['ORDER_ID'].toString()),
      providerName: json['PROVIDER_NAME'],
      allStatus: json['ALL_STATUS'],
      numStatus: int.parse(json['NUM_STATUS'].toString()),
      items: int.parse(json['ITEMS'].toString()),
      situation: json['SITUACION'],
      totalAmount: double.parse(json['TOTAL_AMOUNT'].toString()),
      taxAmount: double.parse(json['TAX_AMOUNT'].toString()),
      discountAmount: double.parse(json['DISCOUNT_AMOUNT'].toString()),
      productPriceFinal: double.parse(json['PRODUCT_PRICE_FINAL'].toString()),
      productPrice: double.parse(json['PRODUCT_PRICE'].toString()),
      totalBeforeDiscountWithoutTax: double.parse(json['TOTAL_BEFORE_DISCOUNT_WITHOUT_TAX'].toString()),
      totalAfterDiscountWithoutTax: double.parse(json['TOTAL_AFTER_DISCOUNT_WITHOUT_TAX'].toString()),
      orderDate: DateTime.parse(json['ORDER_DATE'])
    );
  }
}