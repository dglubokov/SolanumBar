import SwiftUI

struct CycleConfigurationView: View {
    @EnvironmentObject var pomodoroTimer: PomodoroTimer
    @State private var cyclesInput: String = ""
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Cycle Settings")
                .font(.headline)
                
            Divider()
            
            HStack {
                Text("Cycles before long break:")
                TextField("\(pomodoroTimer.cyclesBeforeLongBreak)", text: $cyclesInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .onAppear { cyclesInput = "\(pomodoroTimer.cyclesBeforeLongBreak)" }
                    .onChange(of: cyclesInput) { _, newValue in
                        if let newCycles = Int(newValue), newCycles > 0 {
                            pomodoroTimer.cyclesBeforeLongBreak = newCycles
                        }
                    }
            }
            
            Toggle("Show cycle in menu bar", isOn: $pomodoroTimer.showCycleInMenuBar)
                .padding(.vertical, 5)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Status")
                    .font(.caption.weight(.semibold))
                
                Text("Current cycle: \(pomodoroTimer.currentCycle) of \(pomodoroTimer.cyclesBeforeLongBreak)")
                    .font(.subheadline)
                
                Text("Total completed cycles: \(pomodoroTimer.totalCyclesCompleted)")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 5)
            
            Button("Reset Cycle Count") {
                pomodoroTimer.resetCycles()
            }
            .padding(.top, 5)
        }
        .padding()
        .frame(width: 250)
        .background(pomodoroTimer.backgroundColor)
    }
}

struct CycleConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        CycleConfigurationView()
            .environmentObject(PomodoroTimer())
    }
}
