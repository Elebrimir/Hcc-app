// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hcc_app/models/event_model.dart';
import 'package:hcc_app/providers/event_provider.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:hcc_app/utils/responsive_container.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hcc_app/widgets/event_form_modal.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Event>> _groupedEvents = {};

  Map<DateTime, List<Event>> _groupEvents(List<Event> events) {
    Map<DateTime, List<Event>> data = {};
    final lastDay = DateTime.utc(2030, 12, 31);

    for (var event in events) {
      final occurrences = event.generateRecurrences(untilDate: lastDay);
      for (var occurrence in occurrences) {
        final date = DateTime.utc(
          occurrence.startTime.year,
          occurrence.startTime.month,
          occurrence.startTime.day,
        );
        if (data[date] == null) data[date] = [];
        data[date]!.add(occurrence);
      }
    }
    return data;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final events = Provider.of<EventProvider>(context).events;
    _groupedEvents = _groupEvents(events);
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.read<EventProvider>();
    final userProvider = Provider.of<UserProvider>(context);
    final loggedInUser = userProvider.userModel;

    if (eventProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final eventsForSelectedDay =
        _groupedEvents[DateTime.utc(
          _selectedDay.year,
          _selectedDay.month,
          _selectedDay.day,
        )] ??
        [];

    return ResponsiveContainer(
      child: Column(
        children: [
          TableCalendar<Event>(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            locale: 'ca_ES',
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats:
                <CalendarFormat, String>{}..addAll(const {
                  CalendarFormat.month: 'Mes',
                  CalendarFormat.twoWeeks: '2 Setmanes',
                  CalendarFormat.week: 'Setmana',
                }),
            calendarFormat: CalendarFormat.month,
            rowHeight: 43,
            daysOfWeekHeight: 30,
            weekendDays: const [DateTime.saturday, DateTime.sunday],
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return _groupedEvents[DateTime.utc(
                    day.year,
                    day.month,
                    day.day,
                  )] ??
                  [];
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: TextStyle(color: Colors.grey[400]),
              todayDecoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.orange[400],
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: eventsForSelectedDay.length,
              itemBuilder: (context, index) {
                final event = eventsForSelectedDay[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[600]!),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                            event.title,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            event.description ?? '',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Text(
                            "${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          onTap: () {
                            if (loggedInUser?.role == 'Admin' ||
                                loggedInUser?.role == 'Coach') {
                              _editEvent(event);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _editEvent(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[800],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EventFormModal(event: event),
    );
  }
}
