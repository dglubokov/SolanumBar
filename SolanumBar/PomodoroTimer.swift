import Foundation
import UserNotifications
import SwiftUI

enum TimerMode {
    case work
    case shortBreak
}

class PomodoroTimer: ObservableObject {
    // 1. @AppStorage properties must come first
    @AppStorage("workDuration") var workDurationMinutes: Int = 25 {
        didSet { updateDurations() }
    }
    @AppStorage("shortBreakDuration") var shortBreakDurationMinutes: Int = 5 {
        didSet { updateDurations() }
    }

    // 2. Regular stored properties
    private var currentDuration: Int {
        switch currentMode {
        case .work: return workDurationMinutes * 60
        case .shortBreak: return shortBreakDurationMinutes * 60
        }
    }

    // 3. @Published properties
    @Published var timeLeft: Int = 0
    @Published var timeLeftString: String = "25:00"
    @Published var isRunning = false
    @Published var currentMode: TimerMode = .work
    @Published var menuBarTitle = "🍅"
    private var timer: Timer?

    init() {
        // Initialize with default values first
        self.timeLeft = currentDuration
        self.timeLeftString = PomodoroTimer.timeString(from: currentDuration)
        resetTimer()
        requestNotificationPermission()
    }

    func startTimer() {
        timer?.invalidate()
        if timeLeft <= 0 { resetTimer() }
        
        isRunning = true
        updateMenuBarTitle()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeLeft > 0 {
                self.timeLeft -= 1
                self.updateTimeLeftString()
                self.updateMenuBarTitle()
            } else {
                self.timerExpired()
            }
        }
    }

    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        menuBarTitle = "⏸ \(timeLeftString)"
    }

    func resetTimer() {
        timer?.invalidate()
        isRunning = false
        timeLeft = currentDuration
        updateTimeLeftString()
        menuBarTitle = currentMode == .work ? "🍅" : "☕️"
    }

    private func updateDurations() {
        if !isRunning {
            resetTimer()
        }
    }

    private static func timeString(from seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private func updateTimeLeftString() {
        timeLeftString = PomodoroTimer.timeString(from: timeLeft)
    }

    private func updateMenuBarTitle() {
        let symbol = currentMode == .work ? "🍅" : "☕️"
        menuBarTitle = "\(symbol) \(timeLeftString)"
    }

    private func timerExpired() {
        isRunning = false
        timer?.invalidate()
        sendNotification()
        switchToNextMode()
    }

    private func switchToNextMode() {
        currentMode = currentMode == .work ? .shortBreak : .work
        resetTimer()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            print("Notification permission granted")
        }
    }

    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.sound = .default

        switch currentMode {
        case .work:
            content.title = "Break Time!"
            content.body = "Time to take a short break"
        case .shortBreak:
            content.title = "Back to Work!"
            content.body = "Your break is over"
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }
}
