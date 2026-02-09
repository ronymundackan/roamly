import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus { pending, accepted, rejected }

class CompanionRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String senderEmail;
  final RequestStatus status;
  final DateTime timestamp;

  CompanionRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.senderEmail,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'senderEmail': senderEmail,
      'status': status.toString().split('.').last, // Store as string
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory CompanionRequest.fromMap(Map<String, dynamic> map) {
    return CompanionRequest(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      status: RequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => RequestStatus.pending,
      ),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
