//import SwiftUI
//import PermissionsSwiftUI
//
//struct Permissions: View {
//    @State var showModal = false
//           var body: some View {
//               Button(action: {
//                   showModal=true
//               }, label: {
//                   Text("Ask user for permissions")
//               })
//               .JMModal(showModal: $showModal, for: [.photoFull, .microphone, .camera])
//               .changeHeaderTo("Requesting Permissions")
//               .changeHeaderDescriptionTo("Joyful needs certain permissions for all the features to work.")
//               .changeBottomDescriptionTo("If the permissions are not granted, you have to enable the permissions in Settings > Joyful")
//               .setAccentColor(toPrimary: Color(.sRGB, red: 246/255, green: 138/255, blue: 162/255, opacity: 1), toTertiary: Color(red: 255/255, green: 193/255, blue: 206/255))
//           }
//}
//
//#Preview {
//    Permissions()
//}
