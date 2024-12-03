// lib/models/task.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final DateTime deadline;
  final int importance;
  final String category;
  final DateTime? createdAt;

  Task({
    required this.id,
    required this.title,
    required this.deadline,
    required this.importance,
    required this.category,
    this.createdAt,
  });

  // Firestore 도큐먼트에서 Task 객체로 변환
  factory Task.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      deadline: (data['deadline'] as Timestamp).toDate(),
      importance: data['importance'] ?? 1,
      category: data['category'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Task 객체를 Firestore 도큐먼트로 변환
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'deadline': Timestamp.fromDate(deadline),
      'importance': importance,
      'category': category,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
