import Foundation
import UserNotifications
import SwiftUI

enum TimerMode: String, CaseIterable, Identifiable {
    case work = "Work"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
    
    var id: String { self.rawValue }
}

class PomodoroTimer: ObservableObject {
    // 1. @AppStorage properties
    @AppStorage("workDuration") var workDurationMinutes: Int = 45 {
        didSet { updateDurations() }
    }
    @AppStorage("shortBreakDuration") var shortBreakDurationMinutes: Int = 10 {
        didSet { updateDurations() }
    }
    @AppStorage("longBreakDuration") var longBreakDurationMinutes: Int = 30 {
        didSet { updateDurations() }
    }
    @AppStorage("cyclesBeforeLongBreak") var cyclesBeforeLongBreak: Int = 4 {
        didSet { updateCycleSettings() }
    }
    @AppStorage("showCycleInMenuBar") var showCycleInMenuBar: Bool = true {
        didSet { updateMenuBarTitle() }
    }

    // 2. Regular stored properties
    private var currentDuration: Int {
        switch currentMode {
        case .work: return workDurationMinutes * 60
        case .shortBreak: return shortBreakDurationMinutes * 60
        case .longBreak: return longBreakDurationMinutes * 60
        }
    }

    // 3. @Published properties
    @Published var timeLeft: Int = 0
    @Published var timeLeftString: String = "45:00"
    @Published var isRunning = false
    @Published var currentMode: TimerMode = .work
    @Published var menuBarTitle = "🍅"
    @Published var currentCycle: Int = 1
    @Published var totalCyclesCompleted: Int = 0
    private var timer: Timer?
    
    // Computed property for background color
    var backgroundColor: Color {
        switch currentMode {
        case .work: return .red.opacity(0.2)
        case .shortBreak: return .green.opacity(0.2)
        case .longBreak: return .blue.opacity(0.2)
        }
    }

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
        updateMenuBarTitle()
    }
    
    func setMode(to mode: TimerMode) {
        currentMode = mode
        resetTimer()
    }
    
    func resetCycles() {
        currentCycle = 1
        totalCyclesCompleted = 0
        updateMenuBarTitle()
    }

    private func updateDurations() {
        if !isRunning {
            resetTimer()
        }
    }
    
    private func updateCycleSettings() {
        // Ensure current cycle is valid with new settings
        if currentCycle > cyclesBeforeLongBreak {
            currentCycle = 1
        }
        updateMenuBarTitle()
    }

    private static func timeString(from seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private func updateTimeLeftString() {
        timeLeftString = PomodoroTimer.timeString(from: timeLeft)
    }

    private func updateMenuBarTitle() {
        let symbol: String
        switch currentMode {
        case .work: symbol = "🍅"
        case .shortBreak: symbol = "☕️"
        case .longBreak: symbol = "🏖"
        }
        
        if isRunning && showCycleInMenuBar {
            menuBarTitle = "\(symbol) \(timeLeftString) [\(currentCycle)/\(cyclesBeforeLongBreak)]"
        } else if isRunning {
            menuBarTitle = "\(symbol) \(timeLeftString)"
        } else {
            // Not running
            switch currentMode {
            case .work: menuBarTitle = "🍅"
            case .shortBreak: menuBarTitle = "☕️"
            case .longBreak: menuBarTitle = "🏖"
            }
        }
    }

    private func timerExpired() {
        isRunning = false
        timer?.invalidate()
        sendNotification()
        switchToNextMode()
    }

    private func switchToNextMode() {
        if currentMode == .work {
            // Work session completed
            if currentCycle >= cyclesBeforeLongBreak {
                // Time for a long break
                currentMode = .longBreak
                totalCyclesCompleted += 1
                currentCycle = 1
            } else {
                // Short break
                currentMode = .shortBreak
                currentCycle += 1
            }
        } else {
            // Break completed, back to work
            currentMode = .work
        }
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
            if currentCycle >= cyclesBeforeLongBreak {
                content.title = "Long Break Time!"
                content.body = "Well done! You've completed \(cyclesBeforeLongBreak) work cycles. Time for a long break!"
            } else {
                content.title = "Break Time!"
                content.body = "Time to take a short break (Cycle \(currentCycle)/\(cyclesBeforeLongBreak))"
            }
        case .shortBreak:
            content.title = "Back to Work!"
            content.body = "Your break is over (Cycle \(currentCycle)/\(cyclesBeforeLongBreak))"
        case .longBreak:
            content.title = "Back to Work!"
            content.body = "Your long break is over. Starting a new set of cycles!"
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }
}
