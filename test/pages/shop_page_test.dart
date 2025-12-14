// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hcc_app/pages/shop_page.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  testWidgets('ShopPage renders and displays products', (tester) async {
    // Setup Fake Firestore
    final fakeFirestore = FakeFirebaseFirestore();
    await fakeFirestore.collection('products').add({
      'name': 'Camiseta Oficial',
      'code': 'TSHIRT001',
      'price': 25.0,
      'image': 'http://example.com/image.png',
      'attributes': [],
      'created_at': DateTime.now(),
    });

    // Run test inside mockNetworkImagesFor to handle network images
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(home: ShopPage(firestore: fakeFirestore)),
      );

      // Verify static texts
      expect(find.text('Botiga'), findsOneWidget);
      expect(find.text('Productes Destacats'), findsOneWidget);

      // Wait for stream to emit
      await tester.pumpAndSettle();

      // Verify product is displayed
      // Note: ProductsCarousel might display the name
      expect(find.text('Camiseta Oficial'), findsOneWidget);
      expect(find.text('25.00 €'), findsOneWidget);
    });
  });
}
