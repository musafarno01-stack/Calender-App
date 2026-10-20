import 'dart:convert';

enum ItemType { event, task, reminder, habit, note }

enum Priority { low, medium, high, urgent }

class OrganizerItem {
  const OrganizerItem({
    required this.id,
    required this.type,
    required this.title,
    required this.createdAt,
    this.description = '',
    this.dueAt,
    this.completed = false,
    this.priority = Priority.medium,
    this.category = 'Personal',
  });

  final String id;
  final ItemType type;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? dueAt;
  final bool completed;
  final Priority priority;
  final String category;

  OrganizerItem copyWith({
    String? title,
    String? description,
    DateTime? dueAt,
    bool clearDueAt = false,
    bool? completed,
    Priority? priority,
    String? category,
  }) {
    return OrganizerItem(
      id: id,
      type: type,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'dueAt': dueAt?.toIso8601String(),
        'completed': completed,
        'priority': priority.name,
        'category': category,
      };

  factory OrganizerItem.fromJson(Map<String, dynamic> json) {
    return OrganizerItem(
      id: json['id'] as String,
      type: ItemType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => ItemType.task,
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse(
            json['createdAt'] as String? ?? '',
          ) ??
          DateTime.now(),
      dueAt: DateTime.tryParse(json['dueAt'] as String? ?? ''),
      completed: json['completed'] as bool? ?? false,
      priority: Priority.values.firstWhere(
        (value) => value.name == json['priority'],
        orElse: () => Priority.medium,
      ),
      category: json['category'] as String? ?? 'Personal',
    );
  }

  static String encodeList(List<OrganizerItem> items) =>
      jsonEncode(items.map((item) => item.toJson()).toList());

  static List<OrganizerItem> decodeList(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! List) {
      throw const FormatException('Expected a list of organizer items.');
    }

    return decoded.map((entry) {
      if (entry is! Map) {
        throw const FormatException('Invalid organizer item.');
      }
      return OrganizerItem.fromJson(
        Map<String, dynamic>.from(entry),
      );
    }).toList();
  }
}
