import SwiftUI

struct ContentView: View {
    @EnvironmentObject var pomodoroTimer: PomodoroTimer
    @State private var workInput: String = ""
    @State private var shortBreakInput: String = ""
    @State private var longBreakInput: String = ""
    @State private var showCycleConfig: Bool = false

    var body: some View {
        VStack(spacing: 15) {
            Text("Pomodoro Timer")
                .font(.headline)

            Picker("Session", selection: Binding(
                get: { pomodoroTimer.currentMode },
                set: { pomodoroTimer.setMode(to: $0) }
            )) {
                ForEach(TimerMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal)

            // Cycle status display
            if pomodoroTimer.currentMode == .work {
                Text("Cycle: \(pomodoroTimer.currentCycle)/\(pomodoroTimer.cyclesBeforeLongBreak)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

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
                .keyboardShortcut(.defaultAction)

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
                    .onAppear { workInput = "\(pomodoroTimer.workDurationMinutes)" }
                    .onChange(of: workInput) { _, newValue in
                        if let newDuration = Int(newValue) {
                            pomodoroTimer.workDurationMinutes = newDuration
                        }
                    }
            }

            HStack {
                Text("Short Break (min):")
                TextField("\(pomodoroTimer.shortBreakDurationMinutes)", text: $shortBreakInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .onAppear { shortBreakInput = "\(pomodoroTimer.shortBreakDurationMinutes)" }
                    .onChange(of: shortBreakInput) { _, newValue in
                        if let newDuration = Int(newValue) {
                            pomodoroTimer.shortBreakDurationMinutes = newDuration
                        }
                    }
            }

            HStack {
                Text("Long Break (min):")
                TextField("\(pomodoroTimer.longBreakDurationMinutes)", text: $longBreakInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .onAppear { longBreakInput = "\(pomodoroTimer.longBreakDurationMinutes)" }
                    .onChange(of: longBreakInput) { _, newValue in
                        if let newDuration = Int(newValue) {
                            pomodoroTimer.longBreakDurationMinutes = newDuration
                        }
                    }
            }
            
            Button("Cycle Settings") {
                showCycleConfig.toggle()
            }
            .sheet(isPresented: $showCycleConfig) {
                CycleConfigurationView()
                    .environmentObject(pomodoroTimer)
            }

            Divider().padding(.vertical, 5)

            Button("Quit PomodoroBar") {
                NSApplication.shared.terminate(nil)
            }
            .foregroundColor(.red)
        }
        .padding()
        .frame(width: 250)
        .background(pomodoroTimer.backgroundColor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PomodoroTimer())
    }
}
