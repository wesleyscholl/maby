import Factory
import MabyKit
import SwiftUI

struct AddVomitEventView: View {
    @Injected(Container.eventService) private var eventService
    
    @State private var date = Date.now
    @State private var type = VomitEvent.VType.spitup
    
    var body: some View {
        AddEventView(
            "🤢 Vomit, Burping or Spit Up",
            onAdd: { eventService.addVomit(date: date, type: type) }
        ) {
            Section("Time") {
                DatePicker("Date", selection: $date)
            }
            Section("Type") {
                Picker("Type", selection: $type) {
                    Text("Spit Up").tag(VomitEvent.VType.spitup)
                    Text("Burping").tag(VomitEvent.VType.burping)
                    Text("Vomit").tag(VomitEvent.VType.vomit)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

struct AddVomitEvent_Previews: PreviewProvider {
    static var previews: some View {
        AddVomitEventView()
    }
}
