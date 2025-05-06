// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hcc_app/models/team_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/widgets/team_data_wrapper.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot<TeamModel>> teamStream =
        FirebaseFirestore.instance
            .collection('teams')
            .withConverter<TeamModel>(
              fromFirestore: TeamModel.fromFirestore,
              toFirestore: (TeamModel team, _) => team.toFirestore(),
            )
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equips'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[300],

      body: TeamDataWrapper(
        builder: (context, teams) {
          if (teams.isEmpty) {
            return const Center(
              child: Text(
                'No teams available.',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return TeamDisplayItem(team: team);
            },
          );
        },
        teamStream: teamStream,
      ),
    );
  }
}

class TeamDisplayItem extends StatelessWidget {
  final TeamModel team;

  const TeamDisplayItem({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor:
                  team.image == null
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
              backgroundImage:
                  team.image != null ? NetworkImage(team.image!) : null,
              child:
                  (team.image == null)
                      ? Text(
                        _getName(team),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getCategory(team),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getName(TeamModel team) {
    return '${team.name}';
  }

  String _getCategory(TeamModel team) {
    return '${team.category}';
  }
}
