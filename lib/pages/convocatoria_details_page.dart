import 'package:flutter/material.dart';
import 'package:hcc_app/models/convocatoria_model.dart';
import 'package:intl/intl.dart';

class ConvocatoriaDetailsPage extends StatelessWidget {
  final ConvocatoriaModel convocatoria;

  const ConvocatoriaDetailsPage({super.key, required this.convocatoria});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalls Convocatòria'),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSectionTitle('Jugadors (${convocatoria.players.length})'),
            const SizedBox(height: 8),
            _buildUserList(convocatoria.players),
            const SizedBox(height: 24),
            _buildSectionTitle('Delegats (${convocatoria.delegates.length})'),
            const SizedBox(height: 8),
            _buildUserList(convocatoria.delegates),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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

  Widget _buildUserList(List<ConvokedUser> users) {
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
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(user.status),
            child: Icon(_getStatusIcon(user.status), color: Colors.white),
          ),
          title: Text(user.name),
          subtitle: Text(user.status.name.toUpperCase()),
          trailing: Text(user.role.toUpperCase()),
        );
      },
    );
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
