// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hcc_app/models/team_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/utils/responsive_container.dart';
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
        title: const Text('Equips', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[900],
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
    return ResponsiveContainer(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        elevation: 3.0,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor:
                    team.image == null
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                backgroundImage:
                    (team.image != null && team.image!.isNotEmpty)
                        ? NetworkImage(team.image!)
                        : null,
                child:
                    (team.image == null)
                        ? Text(
                          _getName(team),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
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
                      _getName(team),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (team.coaches != null) ...[
                      const SizedBox(height: 50.0),
                      Text(
                        'Entrenadors: ${team.coaches!.map((coach) => coach.name).join(', ')}',
                      ),
                    ],
                    if (team.delegates != null) ...[
                      const SizedBox(height: 5.0),
                      Text(
                        'Delegats: ${team.delegates!.map((delegate) => delegate.name).join(', ')}',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 1.0),
              Expanded(
                flex: 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'PJ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${team.games}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(width: 2.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'PG',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${team.win}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(width: 2.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'PE',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${team.draw}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(width: 2.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'PP',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${team.lose}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(width: 2.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'GF',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${team.goals}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(width: 2.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'GC',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${team.goalsAgainst}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(width: 2.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'DG',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${team.goalDifference}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getName(TeamModel team) {
    return '${team.name}';
  }
}
