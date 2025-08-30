// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:hcc_app/models/event_model.dart';
import 'package:hcc_app/providers/event_provider.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    // Si estamos editando, rellenamos los campos con los datos del evento
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _startDate = widget.event?.startTime ?? DateTime.now();
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

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final eventProvider = context.read<EventProvider>();
      final userProvider = context.read<UserProvider>();
      final userId = userProvider.firebaseUser?.uid;

      if (userId == null) {
        print("Error: Usuari no autenticat");
        return;
      }
      final eventData = {
        'title': _titleController.text,
        'startTime': _startDate,
        'endTime': _startDate.add(const Duration(hours: 1)),
        'description': '',
      };

      if (widget.event == null) {
        eventProvider.addEvent(eventData, userId);
      } else {
        eventProvider.updateEvent(widget.event!.id, eventData);
      }

      Navigator.of(context).pop(); // Cierra el modal
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(_startDate)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: _selectDate,
                  child: const Text('Canviar'),
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
