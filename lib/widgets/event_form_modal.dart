// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hcc_app/models/event_model.dart';
import 'package:hcc_app/providers/event_provider.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/services/notification_service.dart';

class EventFormModal extends StatefulWidget {
  final Event? event; // Si es null, estamos creando. Si no, editando.

  const EventFormModal({super.key, this.event});

  @override
  State<EventFormModal> createState() => _EventFormModalState();
}

class _EventFormModalState extends State<EventFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;
  DateTime? _recurrenceEndDate;
  bool _isRecurrent = false;
  RecurrenceFrequency _frequency = RecurrenceFrequency.weekly;
  int _interval = 1;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, rellenamos los campos con los datos del evento
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _locationController = TextEditingController(
      text: widget.event?.location ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.event?.description ?? '',
    );
    _startDate = widget.event?.startTime ?? DateTime.now();
    _endDate =
        widget.event?.endTime ?? _startDate.add(const Duration(hours: 1));
    if (widget.event?.recurrenceRule != null) {
      _isRecurrent = true;
      _frequency = widget.event!.recurrenceRule!.frequency;
      _interval = widget.event!.recurrenceRule!.interval;
      _recurrenceEndDate = widget.event!.recurrenceEndDate;
    }
  }

  // METODOS PARA SELECCIONAR FECHAS Y GUARDAR EL FORMULARIO

  Future<void> _selectStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDate),
      );
      if (pickedTime != null) {
        setState(() {
          _startDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          final duration = _endDate.difference(_startDate);
          _endDate = _startDate.add(duration);
        });
      }
    }
  }

  Future<void> _selectEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endDate),
      );
      if (pickedTime != null) {
        setState(() {
          _endDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(hours: 1));
        }
      }
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final eventProvider = context.read<EventProvider>();
      final userProvider = context.read<UserProvider>();
      final userId = userProvider.firebaseUser?.uid;

      if (userId == null) {
        debugPrint("Error: Usuari no autenticat");
        return;
      }

      final event = Event(
        id: widget.event?.id ?? '',
        title: _titleController.text,
        startTime: _startDate,
        endTime: _endDate,
        description: _descriptionController.text,
        location: _locationController.text,
        confirmedUsers: widget.event?.confirmedUsers ?? [],
        recurrenceRule: _getRecurrenceRule(), // Usa el método que creamos
        recurrenceEndDate: _isRecurrent ? _recurrenceEndDate : null,
        excludedDates: const [],
        creatorUid: userId,
      );

      final eventData = event.toFirestore();

      try {
        if (widget.event == null) {
          final newEventId = await eventProvider.addEvent(eventData, userId);
          final newEvent = event.copyWith(id: newEventId);
          await NotificationService.scheduleEventNotification(newEvent);
          debugPrint("Notificación programada para el nuevo evento");
        } else {
          await eventProvider.updateEvent(widget.event!.id, eventData);
          await NotificationService.cancelNotification(widget.event!.id);
          await NotificationService.scheduleEventNotification(event);
          debugPrint("Notificación actualizada para el evento editado");
        }

        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (e) {
        debugPrint("Error al guardar el evento: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el evento: $e')),
        );
      }
    }
  }

  Future<void> _selectRecurrenceEndDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _recurrenceEndDate = selectedDate;
      });
    }
  }

  String _getFrequencyText(RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return 'Diari';
      case RecurrenceFrequency.weekly:
        return 'Setmanal';
      case RecurrenceFrequency.monthly:
        return 'Mensual';
      case RecurrenceFrequency.yearly:
        return 'Anual';
    }
  }

  String _getIntervalSuffix() {
    switch (_frequency) {
      case RecurrenceFrequency.daily:
        return 'dia(es)';
      case RecurrenceFrequency.weekly:
        return 'setmana(es)';
      case RecurrenceFrequency.monthly:
        return 'mes(os)';
      case RecurrenceFrequency.yearly:
        return 'any(s)';
    }
  }

  RecurrenceRule? _getRecurrenceRule() {
    if (!_isRecurrent) return null;
    return RecurrenceRule(frequency: _frequency, interval: _interval);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.event == null
                    ? 'Nou Esdeveniment'
                    : 'Editar Esdeveniment',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Títol',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'El títol no pot estar buit' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Lloc de l\'esdeveniment',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Data Inici: ${DateFormat('dd/MM/yyyy HH:mm').format(_startDate)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _selectStartDate,
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: const Text(
                      'Canviar',
                      style: TextStyle(color: Colors.cyan),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Data Fi: ${DateFormat('dd/MM/yyyy HH:mm').format(_endDate)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _selectEndDate,
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: const Text(
                      'Canviar',
                      style: TextStyle(color: Colors.cyan),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildRecurrenceSection(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text(widget.event == null ? 'Crear' : 'Guardar Canvis'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecurrenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkbox para activar recurrencia
        CheckboxListTile(
          title: const Text(
            'Esdeveniment recurrent',
            style: TextStyle(color: Colors.white),
          ),
          value: _isRecurrent,
          onChanged: (value) {
            setState(() {
              _isRecurrent = value!;
            });
          },
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        if (_isRecurrent) ...[
          const SizedBox(height: 10),
          // Frecuencia
          DropdownButtonFormField<RecurrenceFrequency>(
            initialValue: _frequency,
            onChanged: (value) {
              setState(() {
                _frequency = value!;
              });
            },
            items:
                RecurrenceFrequency.values.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(
                      _getFrequencyText(frequency),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
            decoration: const InputDecoration(
              labelText: 'Es repeteix cada',
              labelStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
            ),
            dropdownColor: Colors.grey[900],
          ),
          const SizedBox(height: 10),
          // Intervalo
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Interval',
              labelStyle: const TextStyle(color: Colors.grey),
              border: const OutlineInputBorder(),
              suffixText: _getIntervalSuffix(),
              suffixStyle: const TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            initialValue: _interval.toString(),
            onChanged: (value) {
              setState(() {
                _interval = int.tryParse(value) ?? 1;
              });
            },
          ),
          const SizedBox(height: 10),
          // Fecha de fin de recurrencia
          ListTile(
            title: const Text(
              'Data de fi de recurrència',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              _recurrenceEndDate == null
                  ? 'Sense data de fi'
                  : DateFormat('dd/MM/yyyy').format(_recurrenceEndDate!),
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.cyan),
              onPressed: _selectRecurrenceEndDate,
            ),
          ),
        ],
      ],
    );
  }
}
