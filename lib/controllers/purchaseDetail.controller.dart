import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/models/purchaseLine.model.dart';

class PurchaseDetailController {
  Future<List<PurchaseLine>> getPurchaseLinesByOrderId (int userId, int orderId, String providerName) async {
    final Uri url = Uri.parse('$SERVER_IP/getPurchaseLinesByOrderId/' + userId.toString() + '/' + orderId.toString() + '/' + providerName);
    debugPrint ("La URI a la que llamamos es: " + '$SERVER_IP/getPurchaseLinesByOrderId/' + userId.toString() + '/' + orderId.toString() + '/' + providerName);
    final http.Response res = await http.get (
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          //'Authorization': jwt
        }
    );
    debugPrint('After the http call.');
    if (res.statusCode == 200) {
      debugPrint ('The Rest API has responsed.');
      final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['result'].cast<Map<String, dynamic>>();
      debugPrint ('Entre medias de la api RESPONSE.');
      final List<PurchaseLine> resultListPurchase = resultListJson.map<PurchaseLine>((json) => PurchaseLine.fromJson(json)).toList();
      return resultListPurchase;
    } else {
      final List<PurchaseLine> resultListPurchase = [];
      return resultListPurchase;
    }
  }
}