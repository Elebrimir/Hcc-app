// Copyright (c) 2026 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hcc_app/providers/team_provider.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late TeamProvider teamProvider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    teamProvider = TeamProvider(firestore: fakeFirestore);
  });

  group('TeamProvider Tests', () {
    test('addTeam adds a team to Firestore', () async {
      final teamData = {
        'name': 'Senior A',
        'category': 'Sènior',
        'season': 2025,
      };

      final teamId = await teamProvider.addTeam(teamData);

      expect(teamId, isNotEmpty);
      final snapshot =
          await fakeFirestore.collection('teams').doc(teamId).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['name'], 'Senior A');
    });

    test('updateTeam updates team data in Firestore', () async {
      final docRef = await fakeFirestore.collection('teams').add({
        'name': 'Senior A',
        'category': 'Sènior',
      });

      await teamProvider.updateTeam(docRef.id, {'name': 'Senior B'});

      final snapshot =
          await fakeFirestore.collection('teams').doc(docRef.id).get();
      expect(snapshot.data()?['name'], 'Senior B');
    });

    test('deleteTeam removes team from Firestore', () async {
      final docRef = await fakeFirestore.collection('teams').add({
        'name': 'Senior A',
      });

      await teamProvider.deleteTeam(docRef.id);

      final snapshot =
          await fakeFirestore.collection('teams').doc(docRef.id).get();
      expect(snapshot.exists, isFalse);
    });
  });
}
