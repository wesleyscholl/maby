import Factory
import MabyKit
import SwiftUI

struct AddBreastPumpEventView: View {
    @Injected(Container.eventService) private var eventService
    
    @State private var startDate = Date.now
    @State private var endDate = Date.now
    @State private var breast = BreastPumpEvent.Breast.left
    @State private var amount: Int32 = 100
    
    var body: some View {
        AddEventView(
            "🥛 Breast Pumping",
            onAdd: {
                eventService.addBreastPump(
                    start: startDate,
                    end: endDate,
                    breast: breast,
                    amount: amount
                )
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
            
            Section("Breast") {
                Picker("Breast", selection: $breast) {
                    Text("Left").tag(BreastPumpEvent.Breast.left)
                    Text("Right").tag(BreastPumpEvent.Breast.right)
                    Text("Both").tag(BreastPumpEvent.Breast.both)
                }
                .pickerStyle(.segmented)
            }
            Section("Amount (mL)") {
                TextField("Amount in milliliters", value: $amount, format: .number)
                    .keyboardType(.numberPad)
            }
        }
    }
}

struct AddBreastPumpEvent_Previews: PreviewProvider {
    static var previews: some View {
        AddBreastPumpEventView()
    }
}
