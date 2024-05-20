import Factory
import MabyKit
import SwiftUI

struct AddBathingEventView: View {
    @Injected(Container.eventService) private var eventService
    
    @State private var date = Date.now
    @State private var bathingType = BathingEvent.BathingType.bath
    
    var body: some View {
        AddEventView(
            "🛁 Bath or Shower",
            onAdd: {
                eventService.addBathing(date: date, type: bathingType)
            }
        ) {
            Section("Time") {
                DatePicker("Date", selection: $date)
            }
            Section("Type") {
                Picker("Bathing type", selection: $bathingType) {
                    Text("Bath").tag(BathingEvent.BathingType.bath)
                    Text("Sponge").tag(BathingEvent.BathingType.sponge)
                    Text("Shower").tag(BathingEvent.BathingType.shower)
                    Text("Sink").tag(BathingEvent.BathingType.sink)
                }
                .onChange(of: bathingType) { _ in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

struct AddBathingEvent_Previews: PreviewProvider {
    static var previews: some View {
        AddBathingEventView()
    }
}
