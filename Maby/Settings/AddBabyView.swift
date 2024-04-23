import Factory
import MabyKit
import SwiftUI

struct AddBabyView: View {
    @Injected(Container.babyService) private var babyService
    
    @Environment(\.colorScheme) var colorScheme
    @State private var name = ""
    @State private var gender = Baby.Gender.boy
    @State private var birthday = Date.now
    
    private func onAdd() {
        let _ = babyService.add(
            name: name,
            birthday: birthday,
            gender: gender
        )
    }
    
    var body: some View {
        BabyDetailsFormView(
            title: "Add a baby",
            name: $name,
            gender: $gender,
            birthday: $birthday
        ) {
            Button(action: onAdd) {
                Text("Add baby")
            }.shadow(color: .gray.opacity(0.5), radius: 0.5, x: 0.5, y: 0.5)
        }
    }
}

struct AddBabyView_Previews: PreviewProvider {
    static var previews: some View {
        AddBabyView()
            .sheet(isPresented: Binding.constant(true)) {
                AddBabyView()
            }
    }
}
