import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../entities/notification_payload.dart';

abstract class NotificationRepository {
  Future<Either<Failure, void>> initialize();
  Future<Either<Failure, String?>> getFirebaseToken();
  Future<Either<Failure, void>> subscribeToTopic(String topic);
  Future<Either<Failure, void>> unsubscribeFromTopic(String topic);
  Future<Either<Failure, void>> sendLocalNotification(
    NotificationPayload notification,
  );
  Future<Either<Failure, void>> scheduleNotification(
    NotificationPayload notification,
    DateTime scheduledTime,
  );
  Future<Either<Failure, void>> cancelNotification(String notificationId);
  Future<Either<Failure, void>> cancelAllNotifications();
  Future<Either<Failure, List<NotificationPayload>>> getPendingNotifications();
  Stream<NotificationPayload> get notificationStream;
  Stream<String?> get tokenStream;
}
