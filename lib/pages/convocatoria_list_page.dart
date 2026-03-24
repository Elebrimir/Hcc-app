import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/providers/convocatoria_provider.dart';
import 'package:hcc_app/models/convocatoria_model.dart';
import 'package:hcc_app/pages/create_convocatoria_page.dart';
import 'package:hcc_app/pages/convocatoria_details_page.dart';
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: convocatoriaProvider.convocatorias.length,
                itemBuilder: (context, index) {
                  final convocatoria =
                      convocatoriaProvider.convocatorias[index];

                  final matchDate =
                      convocatoria.eventStartTime?.toDate() ??
                      convocatoria.createdAt.toDate();
                  final day = DateFormat('dd').format(matchDate);
                  final month =
                      DateFormat('MMM').format(matchDate).toUpperCase();

                  final totalPlayers = convocatoria.players.length;
                  final confirmedPlayers =
                      convocatoria.players
                          .where((p) => p.status == ConvocationStatus.confirmed)
                          .length;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ConvocatoriaDetailsPage(
                                  convocatoria: convocatoria,
                                ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Date Column
                            Container(
                              width: 60,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red[900],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    day,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    month,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Info Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    convocatoria.eventTitle ?? 'Sense títol',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    convocatoria.teamName,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.people,
                                        size: 16,
                                        color: Colors.red[900],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$confirmedPlayers / $totalPlayers Jugadors',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
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
