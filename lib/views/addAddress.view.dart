import 'package:flutter/material.dart';

import 'package:plataforma_compras/utils/responsiveWidget.dart';
import 'package:plataforma_compras/utils/colors.util.dart';
import 'package:plataforma_compras/views/address.view.dart';
import 'package:plataforma_compras/utils/configuration.util.dart';

class AddAddressView extends StatelessWidget {
  final String personeId;
  final String userId;
  AddAddressView (this.personeId, this.userId);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
        elevation: 0.0,
        leading: IconButton(
            icon: Image.asset('assets/images/logoCross.png'),
            onPressed: (){
              Navigator.pop(context);
            }
        ),
        title: Text(
          'Entrega',
          style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 16.0,
              fontWeight: FontWeight.w500
          ),
          textAlign: TextAlign.left,
        ),
        actions: <Widget>[
          IconButton(
              icon: Image.asset('assets/images/logoQuestion.png'),
              onPressed: null
          )
        ],
      ),
      body: ResponsiveWidget (
        smallScreen: _SmallScreenView(personeId: this.personeId, userId: this.userId),
        largeScreen: _LargeScreenView(personeId: this.personeId, userId: this.userId),
      ),
    );
  }
}
class _SmallScreenView extends StatelessWidget {
  final String personeId;
  final String userId;
  _SmallScreenView ({@required this.personeId, @required this.userId});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding (
        padding: const EdgeInsets.all(20.0),
        child: Column (
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container (
                child: Image.asset('assets/images/addressMessage.png')
            ),
            Text(
              'Añade',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24.0,
                fontFamily: 'SF Pro Display',
                fontStyle: FontStyle.normal,
                color: Colors.black,
              ),
            ),
            Text(
              'tu dirección',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24.0,
                fontFamily: 'SF Pro Display',
                fontStyle: FontStyle.normal,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.0,),
            Text(
              'Indícanos dónde quieres recibir tu pedido para continuar.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                fontFamily: 'SF Pro Display',
                fontStyle: FontStyle.normal,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 40.0,),
            Container(
              child: GestureDetector (
                onTap: () async {
                  Navigator.push (
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddressView(this.personeId, this.userId, COME_FROM_ANOTHER)
                      )
                  );
                },
                child: Container (
                  height: 64.0,
                  decoration: BoxDecoration (
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8.0),
                    gradient: LinearGradient(
                        colors: <Color>[
                          Color (0xFF833C26),
                          //Color (0XFF863F25),
                          //Color (0xFF8E4723),
                          Color (0xFF9A541F),
                          //Color (0xFFB16D1A),
                          //Color (0xFFDE9C0D),
                          Color (0xFFF9B806),
                          Color (0XFFFFC107),
                        ]
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset (5,5),
                        blurRadius: 10
                      )
                    ]
                  ),
                  child: Center (
                    child: const Text (
                      'Añadir dirección',
                      style: TextStyle(
                          fontSize: 24.0,
                          color: tanteLadenBackgroundWhite
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _LargeScreenView extends StatelessWidget {
  final String personeId;
  final String userId;
  _LargeScreenView ({@required this.personeId, @required this.userId});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding (
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container (
                child: Image.asset('assets/images/addressMessage.png')
            ),
            Text(
              'Añade',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24.0,
                fontFamily: 'SF Pro Display',
                fontStyle: FontStyle.normal,
                color: Colors.black,
              ),
            ),
            Text(
              'tu dirección',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24.0,
                fontFamily: 'SF Pro Display',
                fontStyle: FontStyle.normal,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.0,),
            Text(
              'Indícanos dónde quieres recibir tu pedido para continuar.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                fontFamily: 'SF Pro Display',
                fontStyle: FontStyle.normal,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 40.0,),
            Row(
              children: [
                Spacer(flex: 1,),
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 80.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration (
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8.0),
                        gradient: LinearGradient(
                            colors: <Color>[
                              Color (0xFF833C26),
                              //Color (0XFF863F25),
                              //Color (0xFF8E4723),
                              Color (0xFF9A541F),
                              //Color (0xFFB16D1A),
                              //Color (0xFFDE9C0D),
                              Color (0xFFF9B806),
                              Color (0XFFFFC107),
                            ]
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              offset: Offset (5,5),
                              blurRadius: 10
                          )
                        ]
                      ),
                      child: const Text(
                        'Añadir dirección',
                        style: TextStyle(
                            fontSize: 24.0,
                            color: tanteLadenBackgroundWhite
                        ),
                      ),
                      height: 64.0,
                    ),
                    onTap: () async {
                      Navigator.push (
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddressView(this.personeId, this.userId, COME_FROM_ANOTHER)
                          )
                      );
                    },
                  ),
                ),
                Spacer(flex: 1,)
              ],
            )
          ],
        ),
      ),
    );
  }
}