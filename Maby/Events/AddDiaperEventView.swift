import Factory
import MabyKit
import SwiftUI

struct AddDiaperEventView: View {
    @Injected(Container.eventService) private var eventService
    
    @State private var date = Date.now
    @State private var diaperType = DiaperEvent.DiaperType.wet
    
    var body: some View {
        AddEventView(
            "🚼 Diaper Change",
            onAdd: {
                eventService.addDiaperChange(date: date, type: diaperType)
            }
        ) {
            Section("Time") {
                DatePicker("Date", selection: $date)
            }
            Section("Type") {
                Picker("Diaper type", selection: $diaperType) {
                    Text("Wet").tag(DiaperEvent.DiaperType.wet)
                    Text("Dirty").tag(DiaperEvent.DiaperType.dirty)
                    Text("Mixed").tag(DiaperEvent.DiaperType.mixed)
                    Text("Clean").tag(DiaperEvent.DiaperType.clean)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

struct AddDiaperEvent_Previews: PreviewProvider {
    static var previews: some View {
        AddDiaperEventView()
    }
}
