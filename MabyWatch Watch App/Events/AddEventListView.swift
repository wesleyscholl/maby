import MabyKit
import SwiftUI

struct AddEventListView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Feeding") {
                    NavigationLink(destination: AddNursingEventView()) {
                        Text("🍼 Nursing")
                    }
                }
                
                Section("Hygiene") {
                    Button(action: { }) {
                        Text("🧷 Diaper change")
                    }
                }
                
                Section("Health") {
                    Button(action: { }) {
                        Text("🌝 Sleep")
                    }
                    
                    Button(action: { }) {
                        Text("🤢 Vomit")
                    }
                }
            }
        }
        .navigationTitle("Add event")
    }
}

struct AddEventListView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventListView()
    }
}