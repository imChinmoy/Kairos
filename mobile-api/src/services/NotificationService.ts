import { initializeApp, getApps, applicationDefault } from 'firebase-admin/app';
import { getMessaging, Message } from 'firebase-admin/messaging';
import { logger } from '../utils/logger';

// Initialize Firebase Admin if not already initialized
try {
  if (!getApps().length) {
    initializeApp({
      credential: applicationDefault(), // Will use GOOGLE_APPLICATION_CREDENTIALS or Firebase defaults
    });
    logger.info('Firebase Admin initialized successfully');
  }
} catch (error) {
  logger.error('Error initializing Firebase Admin', error);
}

export class NotificationService {
  /**
   * Send a push notification to a specific device via FCM
   */
  static async sendPushNotification(
    fcmToken: string,
    title: string,
    body: string,
    data?: Record<string, string>
  ): Promise<boolean> {
    try {
      if (!getApps().length) {
        logger.warn('Cannot send notification: Firebase Admin is not initialized');
        return false;
      }

      const message: Message = {
        token: fcmToken,
        notification: {
          title,
          body,
        },
        data: data || {},
      };

      const response = await getMessaging().send(message);
      logger.info(`Successfully sent FCM message: ${response}`);
      return true;
    } catch (error) {
      logger.error('Error sending push notification', error);
      return false;
    }
  }
}
