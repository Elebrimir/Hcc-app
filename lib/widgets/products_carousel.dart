// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hcc_app/models/product_model.dart';

class ProductsCarousel extends StatelessWidget {
  final Stream<QuerySnapshot<Product>>? productsStream;
  final Widget Function(BuildContext context, List<Product> products) builder;

  const ProductsCarousel({
    super.key,
    required this.builder,
    this.productsStream,
  });

  @override
  Widget build(BuildContext context) {
    if (productsStream == null) {
      return builder(context, []);
    }
    return StreamBuilder<QuerySnapshot<Product>>(
      stream: productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al carregar els productes'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return builder(context, []);
        }
        final List<Product> products =
            snapshot.data!.docs
                .map((docSnapshot) => docSnapshot.data())
                .toList();
        return builder(context, products);
      },
    );
  }
}
