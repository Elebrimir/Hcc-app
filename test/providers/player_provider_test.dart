// Copyright (c) 2026 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hcc_app/providers/player_provider.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late PlayerProvider playerProvider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    playerProvider = PlayerProvider(firestore: fakeFirestore);
  });

  group('PlayerProvider Tests', () {
    test('addPlayer adds a player to Firestore', () async {
      final playerData = {
        'name': 'Pau Petit',
        'category': 'Escoleta',
        'parent_ids': ['user123'],
      };

      final playerId = await playerProvider.addPlayer(playerData);

      expect(playerId, isNotEmpty);
      final snapshot =
          await fakeFirestore.collection('players').doc(playerId).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['name'], 'Pau Petit');
    });

    test('getPlayersByParent returns stream of players for a parent', () async {
      await fakeFirestore.collection('players').add({
        'name': 'Pau Petit',
        'parent_ids': ['user123'],
      });
      await fakeFirestore.collection('players').add({
        'name': 'Maria Petita',
        'parent_ids': ['user123'],
      });
      await fakeFirestore.collection('players').add({
        'name': 'Altre Xiquet',
        'parent_ids': ['other_user'],
      });

      final playersStream = playerProvider.getPlayersByParent('user123');
      final players = await playersStream.first;

      expect(players.length, 2);
      expect(players.any((p) => p.name == 'Pau Petit'), isTrue);
      expect(players.any((p) => p.name == 'Maria Petita'), isTrue);
      expect(players.any((p) => p.name == 'Altre Xiquet'), isFalse);
    });

    test('deletePlayer removes player from Firestore', () async {
      final docRef = await fakeFirestore.collection('players').add({
        'name': 'Pau Petit',
      });

      await playerProvider.deletePlayer(docRef.id);

      final snapshot =
          await fakeFirestore.collection('players').doc(docRef.id).get();
      expect(snapshot.exists, isFalse);
    });

    test('updatePlayerTeams updates team_ids in Firestore', () async {
      final docRef = await fakeFirestore.collection('players').add({
        'name': 'Pau Petit',
        'team_ids': [],
      });

      await playerProvider.updatePlayerTeams(docRef.id, ['teamA', 'teamB']);

      final snapshot =
          await fakeFirestore.collection('players').doc(docRef.id).get();
      expect(snapshot.data()?['team_ids'], containsAll(['teamA', 'teamB']));
    });

    test(
      'getPlayersByTeam returns players assigned to a team (array-contains)',
      () async {
        await fakeFirestore.collection('players').add({
          'name': 'Pau Petit',
          'team_ids': ['teamA', 'teamB'],
        });
        await fakeFirestore.collection('players').add({
          'name': 'Maria Petita',
          'team_ids': ['teamA'],
        });
        await fakeFirestore.collection('players').add({
          'name': 'Altre Xiquet',
          'team_ids': ['teamC'],
        });

        final playersStream = playerProvider.getPlayersByTeam('teamA');
        final players = await playersStream.first;

        expect(players.length, 2);
        expect(players.any((p) => p.name == 'Pau Petit'), isTrue);
        expect(players.any((p) => p.name == 'Maria Petita'), isTrue);
      },
    );
  });
}
