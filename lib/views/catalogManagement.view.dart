import 'package:flutter/material.dart';

import 'package:plataforma_compras/utils/colors.util.dart';

import 'newProduct.view.dart';

class CatalogManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
        elevation: 0.0,
        leading: IconButton(
          icon: Image.asset ('assets/images/leftArrow.png'),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          }
        ),
        title: Text (
          'Gestión del catálogo',
          style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 20.0,
              fontWeight: FontWeight.w300,
              color: tanteLadenIconBrown
          ),
        ),
      ),
      body: ListView (
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            leading: IconButton(
              icon: Image.asset ('assets/images/logoNewProduct.png'),
              onPressed: null,
            ),
            title: Text(
              'Crear un producto',
              style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 20,
                  fontWeight: FontWeight.normal
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => NewProductView()
              ));
            },
          ),
          Divider(height: 1.0, thickness: 1.0,),
          ListTile(
            leading: IconButton(
              icon: Image.asset ('assets/images/logoModifyProduct.png'),
              onPressed: null,
            ),
            title: Text(
              'Modificar un producto',
              style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 20,
                  fontWeight: FontWeight.normal
              ),
            ),
            onTap: () {
              //Navigator.push(context, MaterialPageRoute(
              //    builder: (context) => PersonalData(_token)
              //));
            },
          ),
          Divider(height: 1.0, thickness: 1.0,),
          ListTile(
            leading: IconButton (
              icon: Image.asset ('assets/images/logoUpCatalog.png'),
              onPressed: null,
            ),
            title: Text(
              'Subir catálogo',
              style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 20,
                  fontWeight: FontWeight.normal
              ),
            ),
            onTap: () {
              //Navigator.push(context, MaterialPageRoute(
              //    builder: (context) => PersonalData(_token)
              //));
            },
          ),
          Divider(height: 1.0, thickness: 1.0,),
        ],
      ),
    );
  }
}