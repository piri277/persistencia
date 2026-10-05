import 'package:flutter/material.dart';
import 'package:servicios_modelo/theme.dart';
import 'package:servicios_modelo/ui/product/product_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ejemplo servicios',
      theme: appTheme,
      home: ProductView(),
    );
  }
}
