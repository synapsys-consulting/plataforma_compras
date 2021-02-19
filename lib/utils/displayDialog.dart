import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:plataforma_compras/utils/colors.util.dart';

class DisplayDialog {
  static Future<void> displayDialog (BuildContext context, Widget image, String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return SimpleDialog (
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(0.0),
                  //width: 96.0,
                  //height: 96.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFE0E4EE),
                          offset: Offset(4.0,4.0),
                          spreadRadius: 1.0,
                          blurRadius: 15.0,
                        ),
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(-4.0, -4.0),
                          spreadRadius: 1.0,
                          blurRadius: 15.0,
                        ),
                      ]
                  ),
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    width: 96.0,
                    height: 96.0,
                    child: Image.asset(
                        'assets/images/imageDialogBox.png'
                      //'assets/Group8.png'
                    ),
                  ),
                ),
                SizedBox(height: 40.0,),
                image,
                //Image.asset('assets/images/weightMessage.png'),
                SizedBox(height: 24.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontSize: 24.0,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                Padding (
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Center(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.justify,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 6,
                    ),
                  ),
                ),
                SizedBox(height: 40.0,),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(

            ),
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: RaisedButton(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration (
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8.0),
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color (0xFF833C26),
                          Color (0xFF9A541F),
                          Color (0xFFF9B806),
                          Color (0XFFFFC107),
                        ],
                      )
                  ),
                  //padding: const EdgeInsets.fromLTRB(145.0, 20.0, 145.0, 20.0),
                  child: const Text(
                      'Entendido',
                      style: TextStyle(
                          fontSize: 24,
                          color: tanteLadenBackgroundWhite
                      )
                  ),
                  height: 64,
                ),
                elevation: 8.0, // New
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SizedBox(height: 24.0),
          ],
          elevation: 24.0,
        );
      }
    );
  }
}