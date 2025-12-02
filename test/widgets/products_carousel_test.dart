import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hcc_app/models/product_model.dart';
import 'package:hcc_app/widgets/products_carousel.dart';

void main() {
  testWidgets('ProductsCarousel renders products from stream', (
    WidgetTester tester,
  ) async {
    final instance = FakeFirebaseFirestore();
    await instance.collection('products').add({
      'name': 'Test Product',
      'code': 'TP001',
      'price': 10.0,
      'image': 'http://example.com/image.png',
      'attributes': [],
      'created_at': Timestamp.now(),
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductsCarousel(
            productsStream: instance
                .collection('products')
                .withConverter<Product>(
                  fromFirestore: Product.fromFirestore,
                  toFirestore: (product, _) => product.toFirestore(),
                )
                .snapshots(),
            builder: (context, products) {
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Text(products[index].name);
                },
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test Product'), findsOneWidget);
  });

  testWidgets('ProductsCarousel renders empty state when no data', (
    WidgetTester tester,
  ) async {
    final instance = FakeFirebaseFirestore();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductsCarousel(
            productsStream: instance
                .collection('products')
                .withConverter<Product>(
                  fromFirestore: Product.fromFirestore,
                  toFirestore: (product, _) => product.toFirestore(),
                )
                .snapshots(),
            builder: (context, products) {
              if (products.isEmpty) {
                return const Text('No products');
              }
              return Container();
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No products'), findsOneWidget);
  });
}
