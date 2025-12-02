// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/user_model.dart';
import 'package:hcc_app/models/product_model.dart';

class SaleOrder {
  final String id;
  final String name;
  final DateTime date;
  final String status;
  final UserModel partner;
  final String creatorUid;
  final double? amount;
  final String? currency;
  final List<SaleOrderLine> saleOrderLines;
  final String? paymentState;
  final Timestamp createdAt;

  SaleOrder({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
    required this.partner,
    required this.creatorUid,
    this.amount,
    this.currency,
    required this.saleOrderLines,
    this.paymentState,
    required this.createdAt,
  });

  factory SaleOrder.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    final partnerData = data?['partner'] as Map<String, dynamic>?;

    return SaleOrder(
      id: snapshot.id,
      name: data?['name'] ?? '',
      date: (data?['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data?['status'] ?? '',
      partner: partnerData != null
          ? UserModel.fromMap(partnerData)
          : UserModel(),
      creatorUid: data?['creatorUid'] ?? '',
      amount: (data?['amount'] as num?)?.toDouble(),
      currency: data?['currency'],
      saleOrderLines:
          (data?['saleOrderLines'] as List<dynamic>?)
              ?.map((e) => SaleOrderLine.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      paymentState: data?['paymentState'],
      createdAt: data?['created_at'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'date': date,
      'status': status,
      'partner': partner.toFirestore(),
      'creatorUid': creatorUid,
      'amount': amount,
      'currency': currency,
      'saleOrderLines': saleOrderLines.map((e) => e.toFirestore()).toList(),
      'paymentState': paymentState,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}

class SaleOrderLine {
  final String id;
  final Product product;
  final String name;
  final String productCode;
  final double price;
  final int quantity;
  final double total;

  SaleOrderLine({
    required this.id,
    required this.product,
    required this.name,
    required this.productCode,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory SaleOrderLine.fromMap(Map<String, dynamic> data) {
    return SaleOrderLine(
      id: data['id'] ?? '',
      product: Product.fromMap(data['product'] as Map<String, dynamic>),
      name: data['name'] ?? '',
      productCode: data['productCode'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'product': product.toFirestore(),
      'name': name,
      'productCode': productCode,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }
}
