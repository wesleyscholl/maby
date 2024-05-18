import MabyKit
import SwiftUI

struct BabyDetailsFormView<Confirm: View>: View {
    let title: LocalizedStringKey
    let confirmButton: Confirm
    
    @Binding private var name: String
    @Binding private var gender: Baby.Gender
    @Binding private var birthday: Date
    @State private var pickerColor: Color = .blue

    init(
        title: LocalizedStringKey,
        name: Binding<String>,
        gender: Binding<Baby.Gender>,
        birthday: Binding<Date>,
        @ViewBuilder _ button: () -> Confirm
    ) {
        self.title = title
        self._name = name
        self._gender = gender
        self._birthday = birthday
        self.confirmButton = button()
    }
    
    private var disableButton: Bool {
        !isValidBaby(name: name, birthday: birthday)
    }
    
    var body: some View {
        Form {
            VStack {
                if gender == .boy {
                    Image("babyboyz")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                } else if gender == .girl {
                    Image("baby-girl-1")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                } else if gender == .other {
                    Image("baby-g")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                }
                Text(title)
                    .font(.largeTitle)
            }
            .clearBackground()
            
            Section("Name") {
                TextField("Baby's name", text: $name)
            }
            
            Section("Baby's info") {
                Picker("Gender", selection: $gender) {
                    Text("Boy")
                        .tag(Baby.Gender.boy)
                    Text("Girl")
                        .tag(Baby.Gender.girl)
                    Text("Other")
                        .tag(Baby.Gender.other)
                }
                .accentColor(pickerColor)
                .onChange(of: gender) { newGender in
                    switch newGender {
                    case .boy:
                        pickerColor = .blue
                    case .girl:
                        pickerColor = Color(red: 246/255, green: 138/255, blue: 162/255)
                    case .other:
                        pickerColor = .orange
                    }
                }
                DatePicker(
                    "Birthday",
                    selection: $birthday,
                    in: Date.distantPast...Date.now,
                    displayedComponents: [.date]
                )
            }
            confirmButton
                .disabled(disableButton)
                .buttonStyle(.primaryAction)
                .tint(gender == .boy ? .blue : gender == .girl ? Color(red: 246/255, green: 138/255, blue: 162/255) : .orange)
                .clearBackground()
        }
    }
            
}

struct BabyDetailsFormView_Previews: PreviewProvider {
    static var previews: some View {
        BabyDetailsFormView(
            title: "Add baby",
            name: Binding.constant("Test"),
            gender: Binding.constant(Baby.Gender.girl),
            birthday: Binding.constant(Date.now)
        ) {
            Button(action: { }) {
                Text("Add baby")
            }
        }
    }
}
