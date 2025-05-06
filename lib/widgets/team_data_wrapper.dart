// coverage:ignore-file
// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/models/team_model.dart';

class TeamDataWrapper extends StatelessWidget {
  final Stream<QuerySnapshot<TeamModel>>? teamStream;
  final Widget Function(BuildContext context, List<TeamModel> teams) builder;

  const TeamDataWrapper({
    super.key,
    required this.teamStream,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (teamStream == null) {
      return builder(context, []);
    }
    return StreamBuilder<QuerySnapshot<TeamModel>>(
      stream: teamStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al carregar els equips'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return builder(context, []);
        }
        final List<TeamModel> teams =
            snapshot.data!.docs
                .map((docSnapshot) => docSnapshot.data())
                .toList();
        return builder(context, teams);
      },
    );
  }
}
