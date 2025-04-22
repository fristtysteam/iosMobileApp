import SwiftUI
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var isPermissionGranted = false
    @Published var isEnabled = false
    
    private init() {
        // Load saved preference when service is created
        isEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        checkPermission()
    }
    
    func toggleNotifications(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "notificationsEnabled")
        
        if enabled {
            checkPermission()
        }
    }
    
    func notifyGoalCreated(goal: Goal) {
        guard isEnabled && isPermissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "New Goal Created"
        content.body = "You've set a new goal: \(goal.title)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(goal.id)-creation",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling creation notification: \(error)")
            }
        }
    }
    
    func notifyGoalDeleted(goal: Goal) {
        guard isEnabled && isPermissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Goal Deleted"
        content.body = "The goal '\(goal.title)' has been deleted"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(goal.id)-deletion",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling deletion notification: \(error)")
            }
        }
    }
    
    private func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isPermissionGranted = settings.authorizationStatus == .authorized
                
                if settings.authorizationStatus == .notDetermined {
                    self?.requestPermission()
                }
            }
        }
    }
    
    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isPermissionGranted = granted
                if !granted {
                    self?.isEnabled = false
                    UserDefaults.standard.set(false, forKey: "notificationsEnabled")
                } else {
                    self?.isEnabled = true
                    UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                }
                if let error = error {
                    print("Notification permission error: \(error)")
                }
            }
        }
    }
} 
