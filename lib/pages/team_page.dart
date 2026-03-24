// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hcc_app/models/team_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcc_app/utils/responsive_container.dart';
import 'package:hcc_app/widgets/team_data_wrapper.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:hcc_app/widgets/team_form_modal.dart';
import 'package:provider/provider.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;
    final bool canAddTeam =
        userModel?.role == 'Admin' ||
        userModel?.role == 'Coach' ||
        userModel?.role == 'Delegate';

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
      floatingActionButton:
          canAddTeam
              ? FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const TeamFormModal(),
                  );
                },
                backgroundColor: Colors.red[900],
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
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
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor:
                        team.image == null
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                    backgroundImage:
                        (team.image != null && team.image!.isNotEmpty)
                            ? NetworkImage(team.image!)
                            : null,
                    child:
                        (team.image == null || team.image!.isEmpty)
                            ? Text(
                              (team.name ?? 'T').substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 24,
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
                          team.name ?? 'Sense nom',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        if (team.coaches != null &&
                            team.coaches!.isNotEmpty) ...[
                          Text(
                            'Entrenadors: ${team.coaches!.map((coach) => coach.name).join(', ')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        if (team.delegates != null &&
                            team.delegates!.isNotEmpty) ...[
                          Text(
                            'Delegats: ${team.delegates!.map((delegate) => delegate.name).join(', ')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(context, 'PJ', (team.games ?? 0).toString()),
                  _buildStatItem(context, 'PG', (team.win ?? 0).toString()),
                  _buildStatItem(context, 'PE', (team.draw ?? 0).toString()),
                  _buildStatItem(context, 'PP', (team.lose ?? 0).toString()),
                  _buildStatItem(context, 'GF', (team.goals ?? 0).toString()),
                  _buildStatItem(
                    context,
                    'GC',
                    (team.goalsAgainst ?? 0).toString(),
                  ),
                  _buildStatItem(
                    context,
                    'DG',
                    (team.goalDifference ?? 0).toString(),
                    isHighlight: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color: isHighlight ? Colors.red[900] : Colors.black87,
          ),
        ),
      ],
    );
  }
}
