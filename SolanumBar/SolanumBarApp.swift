import SwiftUI

@main
struct PomodoroBarApp: App {
    @StateObject private var pomodoroTimer = PomodoroTimer()
    
    var body: some Scene {
        MenuBarExtra(content: {
            ContentView()
                .environmentObject(pomodoroTimer)
        }, label: {
            Text(pomodoroTimer.menuBarTitle)
        })
        .menuBarExtraStyle(.window)
    }
}
