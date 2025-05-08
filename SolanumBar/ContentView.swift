import SwiftUI

struct ContentView: View {
    @EnvironmentObject var pomodoroTimer: PomodoroTimer
    @State private var workInput: String = ""
    @State private var breakInput: String = ""

    var body: some View {
        VStack(spacing: 15) {
            Text("Pomodoro Timer")
                .font(.headline)

            Text(pomodoroTimer.timeLeftString)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .padding(.bottom)

            HStack(spacing: 10) {
                Button(pomodoroTimer.isRunning ? "Pause" : "Start") {
                    if pomodoroTimer.isRunning {
                        pomodoroTimer.pauseTimer()
                    } else {
                        pomodoroTimer.startTimer()
                    }
                }
                .keyboardShortcut(.defaultAction) // Allows Enter key to trigger

                Button("Reset") {
                    pomodoroTimer.resetTimer()
                }
            }

            Divider().padding(.vertical, 5)

            Text("Settings").font(.caption.weight(.semibold))
            HStack {
                Text("Work (min):")
                TextField("\(pomodoroTimer.workDurationMinutes)", text: $workInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .onAppear { workInput = "\(pomodoroTimer.workDurationMinutes)" } // Initialize
                    .onChange(of: workInput) { _, newValue in
                        if let newDuration = Int(newValue) {
                            pomodoroTimer.workDurationMinutes = newDuration
                            // The didSet observer will handle updating durations
                        }
                    }
            }

            HStack {
                Text("Break (min):")
                TextField("\(pomodoroTimer.shortBreakDurationMinutes)", text: $breakInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .onAppear { breakInput = "\(pomodoroTimer.shortBreakDurationMinutes)" } // Initialize
                    .onChange(of: breakInput) { _, newValue in
                        if let newDuration = Int(newValue) {
                            pomodoroTimer.shortBreakDurationMinutes = newDuration
                            // The didSet observer will handle updating durations
                        }
                    }
            }

            Divider().padding(.vertical, 5)

            Button("Quit PomodoroBar") {
                NSApplication.shared.terminate(nil)
            }
            .foregroundColor(.red)
        }
        .padding()
        .frame(width: 250) // Adjust width as needed
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PomodoroTimer()) // For previewing
    }
}
