import Foundation
import UserNotifications

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification access granted.")
            } else if let error = error {
                print("Notification access denied: \(error.localizedDescription).")
            }
        }
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - ZaloPay Transaction Notification
    func scheduleZaloPayTransaction(
        title: String,
        message: String,
        amount: String,
        accountNumber: String,
        date: Date,
        time: Date,
        transactionId: String,
        referenceNumber: String,
        note: String
    ) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "HH:mm:ss"
        let timeString = dateFormatter.string(from: time)
        
        let content = UNMutableNotificationContent()
        content.title = title
        
        // Format giống ZaloPay giao dịch
        var bodyText = message
        if !amount.isEmpty && !accountNumber.isEmpty {
            bodyText = "Quy khach da duoc thanh toan \(amount) VND tu nhan vien \(accountNumber)"
            
            if !transactionId.isEmpty {
                bodyText += ", Ngay GD: \(dateString) \(timeString). Ma GD \(transactionId)"
            }
            
            if !referenceNumber.isEmpty {
                bodyText += ". LH \(referenceNumber) (0d)"
            }
            
            if !note.isEmpty {
                bodyText += ". \(note)."
            }
        }
        
        content.body = bodyText
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "ZALOPAY_TRANSACTION"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("ZaloPay transaction notification scheduled!")
            }
        }
    }
    
    // MARK: - ZaloPay Promotion/Gift Notification
    func scheduleZaloPayPromotion(
        title: String,
        message: String,
        amount: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "ZALOPAY_PROMOTION"
        
        // Thêm subtitle nếu có số tiền
        if !amount.isEmpty {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            
            if let number = Int(amount) {
                let formattedAmount = formatter.string(from: NSNumber(value: number)) ?? amount
                content.subtitle = "Số tiền: \(formattedAmount)đ"
            }
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding promotion notification: \(error.localizedDescription)")
            } else {
                print("ZaloPay promotion notification scheduled!")
            }
        }
    }
    
    // MARK: - MB Bank Style Notification (Original)
    func scheduleMBBankNotification(
        account: String,
        amount: String,
        date: Date,
        time: Date,
        service: String,
        note: String
    ) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        let dateString = formatter.string(from: date)
        
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: time)
        
        let maskedAccount = maskAccountNumber(account)
        
        let content = UNMutableNotificationContent()
        content.title = "Thông báo biến động số dư"
        content.body = "TK \(maskedAccount)|GD: \(amount)VND \(dateString) \(timeString) |SD: \(service)VND|ND: \(note)"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MBBANK_NOTIFICATION"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("MB Bank notification scheduled successfully!")
            }
        }
    }
    
    // MARK: - Display notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // iOS 14+ style
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // MARK: - Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        print("Notification tapped: \(categoryIdentifier)")
        
        // Reset badge count
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        completionHandler()
    }
    
    // MARK: - Helper Functions
    private func maskAccountNumber(_ account: String) -> String {
        guard account.count >= 5 else { return account }
        let start = account.prefix(2)
        let end = account.suffix(3)
        return "\(start)xxx\(end)"
    }
    
    // Clear all notifications
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // Get pending notifications count
    func getPendingNotificationsCount(completion: @escaping (Int) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(requests.count)
        }
    }
    
    // Schedule multiple notifications (for testing)
    func scheduleMultipleNotifications(count: Int) {
        for i in 1...count {
            let content = UNMutableNotificationContent()
            content.title = "Test Notification \(i)"
            content.body = "This is test notification number \(i)"
            content.sound = .default
            content.badge = NSNumber(value: i)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(i), repeats: false)
            let request = UNNotificationRequest(identifier: "test-\(i)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling test notification \(i): \(error.localizedDescription)")
                }
            }
        }
    }
}