import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/models/convocatoria_model.dart';
import 'package:hcc_app/models/player_model.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:hcc_app/providers/player_provider.dart';
import 'package:hcc_app/providers/convocatoria_provider.dart';
import 'package:intl/intl.dart';

class ConvocatoriaDetailsPage extends StatelessWidget {
  final ConvocatoriaModel convocatoria;
  final FirebaseFirestore? firestore;

  const ConvocatoriaDetailsPage({
    super.key,
    required this.convocatoria,
    this.firestore,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final playerProvider = Provider.of<PlayerProvider>(context);
    final userUid = userProvider.firebaseUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalls Convocatòria'),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream:
            (firestore ?? FirebaseFirestore.instance)
                .collection('convocatorias')
                .doc(convocatoria.id)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al carregar les dades.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final updatedConvocatoria = ConvocatoriaModel.fromFirestore(
            snapshot.data!,
          );

          return StreamBuilder<List<PlayerModel>>(
            stream:
                userUid != null
                    ? playerProvider.getPlayersByParent(userUid)
                    : Stream.value([]),
            builder: (context, snapshot) {
              final myChildrenIds =
                  snapshot.data?.map((p) => p.id).toList() ?? [];
              final userEmail = userProvider.userModel?.email;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(updatedConvocatoria),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      'Jugadors (${updatedConvocatoria.players.length})',
                    ),
                    const SizedBox(height: 8),
                    _buildUserList(
                      context,
                      updatedConvocatoria.id,
                      updatedConvocatoria.players,
                      myChildrenIds,
                      userEmail,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      'Delegats (${updatedConvocatoria.delegates.length})',
                    ),
                    const SizedBox(height: 8),
                    _buildUserList(
                      context,
                      updatedConvocatoria.id,
                      updatedConvocatoria.delegates,
                      myChildrenIds,
                      userEmail,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(ConvocatoriaModel convocatoria) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              convocatoria.teamName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Creat el: ${DateFormat('dd/MM/yyyy HH:mm').format(convocatoria.createdAt.toDate())}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildUserList(
    BuildContext context,
    String convocatoriaId,
    List<ConvokedUser> users,
    List<String?> myChildrenIds,
    String? userEmail,
  ) {
    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('No hi ha ningú assignat.'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final user = users[index];
        final isMyChild = myChildrenIds.contains(user.userId);
        final isMe = user.userId == userEmail;
        final canConfirm = isMyChild || isMe;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(user.status),
            child: Icon(_getStatusIcon(user.status), color: Colors.white),
          ),
          title: Text(user.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.status.name.toUpperCase()),
              if (canConfirm && user.status == ConvocationStatus.pending)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed:
                            () => _updateStatus(
                              context,
                              convocatoriaId,
                              user.userId,
                              ConvocationStatus.confirmed,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('CONFIRMAR'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed:
                            () => _updateStatus(
                              context,
                              convocatoriaId,
                              user.userId,
                              ConvocationStatus.declined,
                            ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('REBUTJAR'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          trailing: Text(user.role.toUpperCase()),
        );
      },
    );
  }

  void _updateStatus(
    BuildContext context,
    String convocatoriaId,
    String userId,
    ConvocationStatus status,
  ) async {
    final provider = Provider.of<ConvocatoriaProvider>(context, listen: false);
    try {
      await provider.updateConvocationStatus(convocatoriaId, userId, status);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estat actualitzat a ${status.name}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Color _getStatusColor(ConvocationStatus status) {
    switch (status) {
      case ConvocationStatus.confirmed:
        return Colors.green;
      case ConvocationStatus.declined:
        return Colors.red;
      case ConvocationStatus.pending:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(ConvocationStatus status) {
    switch (status) {
      case ConvocationStatus.confirmed:
        return Icons.check;
      case ConvocationStatus.declined:
        return Icons.close;
      case ConvocationStatus.pending:
        return Icons.access_time;
    }
  }
}
