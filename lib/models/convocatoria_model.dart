import 'package:cloud_firestore/cloud_firestore.dart';

enum ConvocationStatus { pending, confirmed, declined }

class ConvokedUser {
  final String userId;
  final String name;
  final String role; // 'player' or 'delegate'
  final ConvocationStatus status;

  ConvokedUser({
    required this.userId,
    required this.name,
    required this.role,
    this.status = ConvocationStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'role': role,
      'status': status.name,
    };
  }

  factory ConvokedUser.fromMap(Map<String, dynamic> map) {
    return ConvokedUser(
      userId: map['userId'],
      name: map['name'],
      role: map['role'],
      status: ConvocationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ConvocationStatus.pending,
      ),
    );
  }

  ConvokedUser copyWith({
    String? userId,
    String? name,
    String? role,
    ConvocationStatus? status,
  }) {
    return ConvokedUser(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}

class ConvocatoriaModel {
  final String id;
  final String teamId;
  final String teamName;
  final String eventId;
  final List<ConvokedUser> players;
  final List<ConvokedUser> delegates;
  final Timestamp createdAt;

  ConvocatoriaModel({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.eventId,
    required this.players,
    required this.delegates,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'eventId': eventId,
      'players': players.map((e) => e.toMap()).toList(),
      'delegates': delegates.map((e) => e.toMap()).toList(),
      'createdAt': createdAt,
    };
  }

  factory ConvocatoriaModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return ConvocatoriaModel(
      id: snapshot.id,
      teamId: data['teamId'],
      teamName: data['teamName'] ?? '',
      eventId: data['eventId'],
      players:
          (data['players'] as List<dynamic>?)
              ?.map((e) => ConvokedUser.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      delegates:
          (data['delegates'] as List<dynamic>?)
              ?.map((e) => ConvokedUser.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: data['createdAt'] as Timestamp,
    );
  }
}
