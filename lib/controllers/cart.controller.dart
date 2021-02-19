import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:plataforma_compras/models/cart.model.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';

class CartController {
  static const String messageInfo = 'En los productos al peso, el importe se ajustará a la cantidad servida. El cobro del importe final se realizará tras la presentación de tu pedido.';

  void tramitarPedido(Cart cart) async {
    try {
      final http.Response res = await http.post("$SERVER_IP/savePurchasedProducts",
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'purchased_products': cart.items.map<Map<String, dynamic>>((e) {
              return {
                'product_id': e.product_id,
                'product_name': e.product_name,
                'product_description': e.product_description,
                'product_type': e.product_type,
                'brand': e.brand,
                'num_images': e.num_images,
                'num_videos': e.num_videos,
                'avail': e.avail,
                'product_price': e.product_price,
              };
            }
            ).toList()
          })
      );
      if (res.statusCode == 200) {

      }
    } catch (e) {

    }
  }
}