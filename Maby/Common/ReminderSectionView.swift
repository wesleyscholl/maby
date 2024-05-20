import SwiftUI

struct ReminderSectionView: View {
    @Binding var setReminder: Bool
    @Binding var reminderInterval: Int

    var body: some View {
        Section("Reminder") {
            Toggle("Set Reminder", isOn: $setReminder)
            if setReminder {
                Picker("Reminder Interval", selection: $reminderInterval) {
                    ForEach(1..<13) { i in
                        let hours = i / 2
                        let minutes = (i % 2) * 30
                        let intervalText: String
                        if hours == 1 && minutes > 0 {
                            intervalText = "\(hours) hour \(minutes) minutes"
                        } else if hours == 1 {
                            intervalText = "\(hours) hour"
                        } else if hours > 1 && minutes > 0 {
                            intervalText = "\(hours) hours \(minutes) minutes"
                        } else if hours > 1 {
                            intervalText = "\(hours) hours"
                        } else {
                            intervalText = "\(minutes) minutes"
                        }
                        return Text(intervalText).tag(i * 30)
                    }
                }
            }
        }
    }
}
