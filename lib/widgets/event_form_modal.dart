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
  late DateTime _startDate;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, rellenamos los campos con los datos del evento
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _startDate = widget.event?.startTime ?? DateTime.now();
    _locationController = TextEditingController(
      text: widget.event?.location ?? '',
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
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
        });
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
      final eventData = {
        'title': _titleController.text,
        'startTime': _startDate,
        'endTime': _startDate.add(const Duration(hours: 1)),
        'description': '',
      };

      if (widget.event == null) {
        final newEventId = await eventProvider.addEvent(eventData, userId);
        final newEvent = Event(
          id: newEventId,
          title: eventData['title'] as String,
          startTime: eventData['startTime'] as DateTime,
          endTime: eventData['endTime'] as DateTime,
          description: eventData['description'] as String,
          confirmedUsers: [],
        );
        await NotificationService.scheduleEventNotification(newEvent);
        debugPrint("Notificación programada para el nuevo evento");
      } else {
        await eventProvider.updateEvent(widget.event!.id, eventData).id ??
            hashCode;
        final updatedEvent = Event(
          id: widget.event!.id,
          title: eventData['title'] as String,
          startTime: eventData['startTime'] as DateTime,
          endTime: eventData['endTime'] as DateTime,
          description: eventData['description'] as String,
          confirmedUsers: [],
        );
        await NotificationService.cancelNotification(widget.event!.id);
        await NotificationService.scheduleEventNotification(updatedEvent);
        debugPrint("Notificación actualizada para el evento editado");
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    }
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.event == null ? 'Nou Esdeveniment' : 'Editar Esdeveniment',
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
            const SizedBox(height: 20),
            TextFormField(
              controller: _locationController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Lloc de l\'esdeveniment',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Data Inici: ${DateFormat('dd/MM/yyyy HH:mm').format(_startDate)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: _selectDate,
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: const Text('Canviar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Data Fi: ${DateFormat('dd/MM/yyyy HH:mm').format(_startDate.add(const Duration(hours: 1)))}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveForm,
              child: Text(widget.event == null ? 'Crear' : 'Guardar Canvis'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

extension on Future<void> {
  Future get id async => null;
}
