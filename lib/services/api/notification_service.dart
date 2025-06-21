import 'package:frontend/services/api/api_service.dart';

class NotificationService {
  final ApiService _apiService;

  NotificationService(this._apiService);

  // Get all notifications
  Future<List<dynamic>> getNotifications() async {
    return await _apiService.get('/notifications');
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _apiService.put('/notifications/$notificationId/read', {});
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _apiService.put('/notifications/read-all', {});
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _apiService.delete('/notifications/$notificationId');
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    await _apiService.delete('/notifications');
  }

  // Get unread notifications count
  Future<int> getUnreadCount() async {
    final response = await _apiService.get('/notifications/unread-count');
    return response['count'] as int;
  }
} 