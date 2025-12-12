import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/models/team_model.dart';
import 'package:hcc_app/models/convocatoria_model.dart';
import 'package:hcc_app/models/event_model.dart';
import 'package:hcc_app/providers/convocatoria_provider.dart';
import 'package:uuid/uuid.dart';

class CreateConvocatoriaPage extends StatefulWidget {
  final FirebaseFirestore? firestore;

  const CreateConvocatoriaPage({super.key, this.firestore});

  @override
  State<CreateConvocatoriaPage> createState() => _CreateConvocatoriaPageState();
}

class _CreateConvocatoriaPageState extends State<CreateConvocatoriaPage> {
  int _currentStep = 0;
  TeamModel? _selectedTeam;
  String? _selectedTeamId;
  List<ConvokedUser> _selectedPlayers = [];
  List<ConvokedUser> _selectedDelegates = [];

  // Event Form Data
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Convocatòria'),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: Text(
                    _currentStep == 2 ? 'Crear Convocatòria' : 'Següent',
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Enrere'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Equip'),
            content: _buildTeamSelectionStep(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.editing,
          ),
          Step(
            title: const Text('Jugadors'),
            content: _buildPlayerSelectionStep(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.editing,
          ),
          Step(
            title: const Text('Partit'),
            content: _buildEventDetailsStep(),
            isActive: _currentStep >= 2,
            state: _currentStep == 2 ? StepState.editing : StepState.indexed,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSelectionStep() {
    return StreamBuilder<QuerySnapshot<TeamModel>>(
      stream:
          (widget.firestore ?? FirebaseFirestore.instance)
              .collection('teams')
              .withConverter<TeamModel>(
                fromFirestore: TeamModel.fromFirestore,
                toFirestore: (TeamModel team, _) => team.toFirestore(),
              )
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final teams =
            snapshot.data?.docs.map((doc) {
              final team = doc.data();
              // We need to attach the ID manually if it's not in the model,
              // but TeamModel doesn't seem to have an ID field.
              // We'll use the doc.id separately.
              return MapEntry(doc.id, team);
            }).toList() ??
            [];

        if (teams.isEmpty) {
          return const Text('No hi ha equips disponibles.');
        }

        return DropdownButtonFormField<String>(
          initialValue: _selectedTeamId,
          decoration: const InputDecoration(labelText: 'Selecciona un equip'),
          items:
              teams.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value.name ?? 'Sense nom'),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedTeamId = value;
              _selectedTeam =
                  teams.firstWhere((entry) => entry.key == value).value;
              // Reset selections when team changes
              _selectedPlayers = [];
              _selectedDelegates = [];
            });
          },
        );
      },
    );
  }

  Widget _buildPlayerSelectionStep() {
    if (_selectedTeam == null) {
      return const Text('Si us plau, selecciona un equip primer.');
    }

    final players = _selectedTeam!.players ?? [];
    final delegates = _selectedTeam!.delegates ?? [];

    if (players.isEmpty && delegates.isEmpty) {
      return const Text('Aquest equip no té jugadors ni delegats assignats.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (players.isNotEmpty) ...[
          const Text(
            'Jugadors',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ...players.map((player) {
            final isSelected = _selectedPlayers.any(
              (p) => p.userId == player.email,
            ); // Using email as ID for now as UserModel doesn't have ID
            return CheckboxListTile(
              title: Text('${player.name} ${player.lastname}'),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedPlayers.add(
                      ConvokedUser(
                        userId: player.email ?? '',
                        name: '${player.name} ${player.lastname}',
                        role: 'player',
                      ),
                    );
                  } else {
                    _selectedPlayers.removeWhere(
                      (p) => p.userId == player.email,
                    );
                  }
                });
              },
            );
          }),
        ],
        if (delegates.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Delegats',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ...delegates.map((delegate) {
            final isSelected = _selectedDelegates.any(
              (d) => d.userId == delegate.email,
            );
            return CheckboxListTile(
              title: Text('${delegate.name} ${delegate.lastname}'),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedDelegates.add(
                      ConvokedUser(
                        userId: delegate.email ?? '',
                        name: '${delegate.name} ${delegate.lastname}',
                        role: 'delegate',
                      ),
                    );
                  } else {
                    _selectedDelegates.removeWhere(
                      (d) => d.userId == delegate.email,
                    );
                  }
                });
              },
            );
          }),
        ],
      ],
    );
  }

  Widget _buildEventDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Títol del partit'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Introdueix un títol';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Ubicació'),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Data'),
            subtitle: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('Hora Inici'),
                  subtitle: Text(_startTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _pickTime(true),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text('Hora Fi'),
                  subtitle: Text(_endTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _pickTime(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_selectedTeam == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona un equip per continuar')),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_selectedPlayers.isEmpty && _selectedDelegates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona almenys un jugador o delegat'),
          ),
        );
        return;
      }
    } else if (_currentStep == 2) {
      if (_formKey.currentState!.validate()) {
        _createConvocatoria();
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _createConvocatoria() async {
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final event = Event(
      id: const Uuid().v4(), // Temporary ID, will be replaced by Firestore ID
      title: _titleController.text,
      startTime: startDateTime,
      endTime: endDateTime,
      location: _locationController.text,
      confirmedUsers: [], // Will be populated as users confirm
      description: 'Convocatòria per ${_selectedTeam!.name}',
    );

    try {
      await Provider.of<ConvocatoriaProvider>(
        context,
        listen: false,
      ).createConvocatoria(
        teamId: _selectedTeamId!,
        teamName: _selectedTeam!.name ?? 'Equip',
        event: event,
        players: _selectedPlayers,
        delegates: _selectedDelegates,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Convocatòria creada correctament!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la convocatòria: $e')),
        );
      }
    }
  }
}
