import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:plataforma_compras/models/cart.model.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';

class CartController {
  static const String messageInfo = 'En los productos al peso, el importe se ajustará a la cantidad servida. El cobro del importe final se realizará tras la presentación de tu pedido.';

  void tramitarPedido(Cart cart) async {
    try {
      var url = Uri.parse('$SERVER_IP/savePurchasedProducts');
      final http.Response res = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'purchased_products': cart.items.map<Map<String, dynamic>>((e) {
              return {
                'product_id': e.productId,
                'product_name': e.productName,
                'product_description': e.productDescription,
                'product_type': e.productType,
                'brand': e.brand,
                'num_images': e.numImages,
                'num_videos': e.numVideos,
                'avail': e.avail,
                'product_price': e.productPrice,
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