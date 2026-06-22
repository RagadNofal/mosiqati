import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String titleKey;
  final String bodyKey;
  // Optional pre-translated strings (used when added programmatically).
  final String? titleEn;
  final String? titleAr;
  final String? bodyEn;
  final String? bodyAr;
  final IconData icon;
  final Color color;
  final DateTime time;
  bool isRead;

  NotificationModel({
    required this.id,
    this.titleKey = '',
    this.bodyKey = '',
    this.titleEn,
    this.titleAr,
    this.bodyEn,
    this.bodyAr,
    required this.icon,
    required this.color,
    required this.time,
    this.isRead = false,
  });

  /// Returns the display title for the given language code ('en' or 'ar').
  /// Prefers the pre-translated field; falls back to the localisation key.
  String getTitle(String lang, String Function(String) t) {
    if (lang == 'ar') return titleAr ?? (titleKey.isNotEmpty ? t(titleKey) : titleEn ?? '');
    return titleEn ?? (titleKey.isNotEmpty ? t(titleKey) : '');
  }

  /// Returns the display body for the given language code ('en' or 'ar').
  String getBody(String lang, String Function(String) t) {
    if (lang == 'ar') return bodyAr ?? (bodyKey.isNotEmpty ? t(bodyKey) : bodyEn ?? '');
    return bodyEn ?? (bodyKey.isNotEmpty ? t(bodyKey) : '');
  }
}

class NotificationsProvider extends ChangeNotifier {
  final List<NotificationModel> _items = [
    NotificationModel(
      id: '1',
      titleKey: 'notifOffer',
      bodyKey: 'notifOfferBody',
      icon: Icons.local_offer_rounded,
      color: Color(0xFF912F56),
      time: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    NotificationModel(
      id: '2',
      titleKey: 'notifOrder',
      bodyKey: 'notifOrderBody',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF3D7A6A),
      time: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: '3',
      titleKey: 'notifReminder',
      bodyKey: 'notifReminderBody',
      icon: Icons.music_note_rounded,
      color: Color(0xFFD4A853),
      time: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationModel(
      id: '4',
      titleKey: 'notifMessage',
      bodyKey: 'notifMessageBody',
      icon: Icons.chat_bubble_rounded,
      color: Color(0xFF521945),
      time: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<NotificationModel> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _items[idx].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (final n in _items) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
  }

  /// Prepends [notification] to the list, deduplicating by id.
  /// If a notification with the same id already exists it is replaced.
  void addNotification(NotificationModel notification) {
    _items.removeWhere((n) => n.id == notification.id);
    _items.insert(0, notification);
    notifyListeners();
  }
}
