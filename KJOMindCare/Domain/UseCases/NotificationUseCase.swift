import Foundation
import UserNotifications

final class NotificationUseCase {

    private let identifier = "daily_notification"

    // 🔐 Permiso
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(
            options: [.alert, .sound, .badge]
        )
        return granted ?? false
    }

    // ⏰ Programar notificación diaria
    func scheduleDaily(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "KJOMindCare"
        content.body = "Daily Reminder 🌱"
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // ❌ Cancelar
    func cancel() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

