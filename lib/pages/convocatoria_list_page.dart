import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/providers/convocatoria_provider.dart';
import 'package:hcc_app/pages/create_convocatoria_page.dart';

import 'package:intl/intl.dart';

class ConvocatoriaListPage extends StatefulWidget {
  const ConvocatoriaListPage({super.key});

  @override
  State<ConvocatoriaListPage> createState() => _ConvocatoriaListPageState();
}

class _ConvocatoriaListPageState extends State<ConvocatoriaListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConvocatoriaProvider>(
        context,
        listen: false,
      ).fetchConvocatorias();
    });
  }

  @override
  Widget build(BuildContext context) {
    final convocatoriaProvider = Provider.of<ConvocatoriaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convocatòries'),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body:
          convocatoriaProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : convocatoriaProvider.convocatorias.isEmpty
              ? const Center(child: Text('No hi ha convocatòries creades.'))
              : ListView.builder(
                itemCount: convocatoriaProvider.convocatorias.length,
                itemBuilder: (context, index) {
                  final convocatoria =
                      convocatoriaProvider.convocatorias[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(convocatoria.teamName),
                      subtitle: Text(
                        'Creat el: ${DateFormat('dd/MM/yyyy HH:mm').format(convocatoria.createdAt.toDate())}\n'
                        'Jugadors: ${convocatoria.players.length} - Delegats: ${convocatoria.delegates.length}',
                      ),
                      isThreeLine: true,
                      onTap: () {
                        // TODO: Navigate to details page
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateConvocatoriaPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
