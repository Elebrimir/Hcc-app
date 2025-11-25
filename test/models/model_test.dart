import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hcc_app/models/product_model.dart';
import 'package:hcc_app/models/sale_order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Product Model', () {
    test('should correctly serialize and deserialize', () async {
      final instance = FakeFirebaseFirestore();
      final size = Atribute(id: '1', name: 'size', value: 'M');
      final data = {
        'name': 'Test Product',
        'code': 'TP001',
        'price': 100.0,
        'image': 'http://image.com',
        'attributes': [size.toMap()],
        'created_at': Timestamp.now(),
      };
      final ref = await instance.collection('products').add(data);
      final snapshot = await ref.get();

      final product = Product.fromFirestore(snapshot, null);

      expect(product.name, 'Test Product');
      expect(product.price, 100.0);
      expect(product.code, 'TP001');
      expect(product.attributes[0].name, 'size');
      expect(product.attributes[0].value, 'M');

      final map = product.toFirestore();
      expect(map['name'], 'Test Product');
      expect(map['price'], 100.0);
      expect(map['attributes'][0]['name'], 'size');
      expect(map['attributes'][0]['value'], 'M');
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
      expect(product.attributes, []);
    });

    test('fromMap should work correctly', () {
      final size = Atribute(id: '1', name: 'color', value: 'red');
      final data = {
        'id': '123',
        'name': 'Map Product',
        'price': 50,
        'attributes': [size.toMap()],
      };
      final product = Product.fromMap(data);
      expect(product.id, '123');
      expect(product.name, 'Map Product');
      expect(product.price, 50.0);
      expect(product.attributes[0].name, 'color');
      expect(product.attributes[0].value, 'red');
      //Remove attributes from map to return empty list
      data.remove('attributes');
      final product2 = Product.fromMap(data);
      expect(product2.attributes, []);
    });
  });

  group('SaleOrder Model', () {
    test(
      'should correctly serialize and deserialize with nested objects',
      () async {
        final instance = FakeFirebaseFirestore();
        final now = Timestamp.now();
        final partnerData = {
          'id': 'user1',
          'name': 'John',
          'email': 'john@test.com',
          'role': 'admin',
        };
        final size = Atribute(id: '1', name: 'size', value: 'M');
        final color = Atribute(id: '2', name: 'color', value: 'red');
        final productData = {
          'id': 'prod1',
          'name': 'Prod 1',
          'code': 'P1',
          'price': 50.0,
          'image': 'http://image.com',
          'attributes': [size.toMap(), color.toMap()],
          'created_at': now,
        };
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
          'date': now,
          'status': 'draft',
          'partner': partnerData,
          'saleOrderLines': [lineData],
          'amount': 100.0,
          'created_at': now,
        };

        final ref = await instance.collection('orders').add(orderData);
        final snapshot = await ref.get();

        final order = SaleOrder.fromFirestore(snapshot, null);

        expect(order.name, 'Order 1');
        expect(order.partner.name, 'John');
        expect(order.saleOrderLines.length, 1);
        expect(order.saleOrderLines.first.product.name, 'Prod 1');
        expect(order.saleOrderLines.first.product.code, 'P1');
        expect(order.saleOrderLines.first.product.price, 50.0);
        expect(order.saleOrderLines.first.product.image, 'http://image.com');
        expect(order.saleOrderLines.first.product.attributes.length, 2);
        expect(order.saleOrderLines.first.product.attributes[0].name, 'size');
        expect(order.saleOrderLines.first.product.attributes[0].value, 'M');
        expect(order.saleOrderLines.first.product.attributes[1].name, 'color');
        expect(order.saleOrderLines.first.product.attributes[1].value, 'red');
        expect(order.saleOrderLines.first.total, 100.0);
        expect(order.saleOrderLines.first.product.createdAt, now);

        final map = order.toFirestore();
        expect(map['partner']['name'], 'John');
        expect(map['saleOrderLines'][0]['product']['name'], 'Prod 1');
        expect(map['saleOrderLines'][0]['product']['code'], 'P1');
        expect(map['saleOrderLines'][0]['product']['price'], 50.0);
        expect(
          map['saleOrderLines'][0]['product']['image'],
          'http://image.com',
        );
        expect(
          map['saleOrderLines'][0]['product']['created_at'],
          isA<FieldValue>(),
        );
        expect(
          map['saleOrderLines'][0]['product']['attributes'][0]['name'],
          'size',
        );
        expect(
          map['saleOrderLines'][0]['product']['attributes'][0]['value'],
          'M',
        );
        expect(
          map['saleOrderLines'][0]['product']['attributes'][1]['name'],
          'color',
        );
        expect(
          map['saleOrderLines'][0]['product']['attributes'][1]['value'],
          'red',
        );
        expect(map['saleOrderLines'][0]['total'], 100.0);
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
