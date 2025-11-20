import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hcc_app/models/product_model.dart';
import 'package:hcc_app/models/sale_order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Product Model', () {
    test('should correctly serialize and deserialize', () async {
      final instance = FakeFirebaseFirestore();
      final data = {
        'name': 'Test Product',
        'code': 'TP001',
        'price': 100.0,
        'image': 'http://image.com',
        'created_at': Timestamp.now(),
      };
      final ref = await instance.collection('products').add(data);
      final snapshot = await ref.get();

      final product = Product.fromFirestore(snapshot, null);

      expect(product.name, 'Test Product');
      expect(product.price, 100.0);
      expect(product.code, 'TP001');

      final map = product.toFirestore();
      expect(map['name'], 'Test Product');
      expect(map['price'], 100.0);
    });

    test('should handle nulls and type conversion', () async {
      final instance = FakeFirebaseFirestore();
      final data = {
        'price': 100, // int
      };
      final ref = await instance.collection('products').add(data);
      final snapshot = await ref.get();

      final product = Product.fromFirestore(snapshot, null);
      expect(product.price, 100.0);
      expect(product.name, '');
      expect(product.code, '');
    });

    test('fromMap should work correctly', () {
      final data = {'id': '123', 'name': 'Map Product', 'price': 50};
      final product = Product.fromMap(data);
      expect(product.id, '123');
      expect(product.name, 'Map Product');
      expect(product.price, 50.0);
    });
  });

  group('SaleOrder Model', () {
    test(
      'should correctly serialize and deserialize with nested objects',
      () async {
        final instance = FakeFirebaseFirestore();
        final partnerData = {
          'id': 'user1',
          'name': 'John',
          'email': 'john@test.com',
          'role': 'admin',
        };
        final productData = {'id': 'prod1', 'name': 'Prod 1', 'price': 50.0};
        final lineData = {
          'id': 'line1',
          'product': productData,
          'name': 'Line 1',
          'productCode': 'P1',
          'price': 50.0,
          'quantity': 2,
          'total': 100.0,
        };

        final orderData = {
          'name': 'Order 1',
          'date': Timestamp.now(),
          'status': 'draft',
          'partner': partnerData,
          'saleOrderLines': [lineData],
          'amount': 100.0,
          'created_at': Timestamp.now(),
        };

        final ref = await instance.collection('orders').add(orderData);
        final snapshot = await ref.get();

        final order = SaleOrder.fromFirestore(snapshot, null);

        expect(order.name, 'Order 1');
        expect(order.partner.name, 'John');
        expect(order.saleOrderLines.length, 1);
        expect(order.saleOrderLines.first.product.name, 'Prod 1');
        expect(order.saleOrderLines.first.total, 100.0);

        final map = order.toFirestore();
        expect(map['partner']['name'], 'John');
        expect(map['saleOrderLines'][0]['product']['name'], 'Prod 1');
      },
    );

    test('should handle nulls and missing nested data', () async {
      final instance = FakeFirebaseFirestore();
      final data = {'name': 'Empty Order'};
      final ref = await instance.collection('orders').add(data);
      final snapshot = await ref.get();

      final order = SaleOrder.fromFirestore(snapshot, null);
      expect(order.name, 'Empty Order');
      expect(order.saleOrderLines, isEmpty);
      expect(order.partner.name, isNull); // UserModel defaults
    });
  });
}
