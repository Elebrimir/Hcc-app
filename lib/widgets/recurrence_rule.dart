// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hcc_app/models/event_model.dart';
import 'package:intl/intl.dart';

class RecurrenceSelector extends StatefulWidget {
  final Function(RecurrenceRule?) onRecurrenceChanged;

  const RecurrenceSelector({super.key, required this.onRecurrenceChanged});

  @override
  _RecurrenceSelectorState createState() => _RecurrenceSelectorState();
}

class _RecurrenceSelectorState extends State<RecurrenceSelector> {
  bool _isRecurrent = false;
  RecurrenceFrequency _frequency = RecurrenceFrequency.weekly;
  int _interval = 1;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text(
            'Esdeveniment recurrent?',
            style: TextStyle(color: Colors.white),
          ),
          value: _isRecurrent,
          onChanged: (value) {
            setState(() {
              _isRecurrent = value!;
              _updateRecurrenceRule();
            });
          },
          activeColor: Colors.lightGreenAccent,
          checkColor: Colors.lightGreenAccent,
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        if (_isRecurrent) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<RecurrenceFrequency>(
            initialValue: _frequency,
            onChanged: (value) {
              setState(() {
                _frequency = value!;
                _updateRecurrenceRule();
              });
            },
            items:
                RecurrenceFrequency.values.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(_getFrequencyText(frequency)),
                  );
                }).toList(),
            decoration: const InputDecoration(
              labelText: 'Freqüència de repetició',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Interval (cada quants períodes)',
              border: const OutlineInputBorder(),
              suffixText: _getIntervalSuffix(),
            ),
            keyboardType: TextInputType.number,
            initialValue: _interval.toString(),
            onChanged: (value) {
              setState(() {
                _interval = int.tryParse(value) ?? 1;
                _updateRecurrenceRule();
              });
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Data de finalització'),
            subtitle: Text(
              _endDate != null
                  ? 'Sense data de finalització'
                  : DateFormat('dd/MM/yyyy').format(_endDate!),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _selectEndDate,
            ),
          ),
        ],
      ],
    );
  }

  String _getFrequencyText(RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return 'Dia';
      case RecurrenceFrequency.weekly:
        return 'Setmana';
      case RecurrenceFrequency.monthly:
        return 'Mes';
      case RecurrenceFrequency.yearly:
        return 'Any';
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

  void _updateRecurrenceRule() {
    if (_isRecurrent) {
      widget.onRecurrenceChanged(
        RecurrenceRule(frequency: _frequency, interval: _interval),
      );
    } else {
      widget.onRecurrenceChanged(null);
    }
  }

  Future<void> _selectEndDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _endDate = selectedDate;
        _updateRecurrenceRule();
      });
    }
  }
}
