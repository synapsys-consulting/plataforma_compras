import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:plataforma_compras/utils/configuration.util.dart';
import 'package:plataforma_compras/models/productAvail.model.dart';

class PurchaseDetailModifyController {

  Future<ProductAvail> getProductAvailable (int productId) async {
      final Uri url = Uri.parse ('$SERVER_IP/getProductAvailWithProductId/' + productId.toString());

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
        final List<Map<String, dynamic>> resultListJson = json.decode(res.body)['products'].cast<Map<String, dynamic>>();
        debugPrint ('Entre medias de la api RESPONSE.');
        final List<ProductAvail> resultListProducts = resultListJson.map<ProductAvail>((json) => ProductAvail.fromJson(json)).toList();

        debugPrint ('Antes de terminar de responder la API.');
        //return resultListProducts;
        return resultListProducts[0];   // Always has one product, the product that was purchased
      } else {
        throw ("No se ha encontrado el producto.");
      }
  }
}