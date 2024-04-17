import Factory
import MabyKit
import SwiftUI

struct AddBathingEventView: View {
    @Injected(Container.eventService) private var eventService
    
    @State private var date = Date.now
    @State private var bathingType = BathingEvent.BathingType.bath
    
    var body: some View {
        AddEventView(
            "🫧 Bathing",
            onAdd: {
                eventService.addBathing(date: date, type: bathingType)
            }
        ) {
            Section() {
                DatePicker("Date", selection: $date)
            }
            Section {
                Picker("Bathing type", selection: $bathingType) {
                    Text("Bath").tag(BathingEvent.BathingType.bath)
                    Text("Sponge").tag(BathingEvent.BathingType.sponge)
                    Text("Shower").tag(BathingEvent.BathingType.shower)
                    Text("Mixed").tag(BathingEvent.BathingType.mixed)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

// case bath, sponge, shower, mixed

struct AddBathingEvent_Previews: PreviewProvider {
    static var previews: some View {
        AddBathingEventView()
    }
}
