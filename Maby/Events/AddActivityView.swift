import Factory
import MabyKit
import SwiftUI

struct AddActivityEventView: View {
    @Injected(Container.eventService) private var eventService
    
    @State private var startDate = Date.now
    @State private var endDate = Date.now
    @State private var activityType = ActivityEvent.ActivityType.tummy
    
    var body: some View {
        AddEventView(
            "🪇 Activity",
            onAdd: {
                eventService.addActivity(start: startDate, end: endDate, type: activityType)
            }
        ) {
            Section("Time") {
                DatePicker(
                    "Start",
                    selection: $startDate,
                    in: Date.distantPast...Date.now
                )
                
                DatePicker(
                    "End",
                    selection: $endDate,
                    in: startDate...Date.distantFuture
                )
            }
            Section {
                Picker("Activity type", selection: $activityType) {
                    Text("Tummy Time").tag(ActivityEvent.ActivityType.tummy)
                    Text("Indoor Play").tag(ActivityEvent.ActivityType.indoor)
                    Text("Outdoor Play").tag(ActivityEvent.ActivityType.outdoor)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

struct AddActivityEvent_Previews: PreviewProvider {
    static var previews: some View {
        AddActivityEventView()
    }
}
