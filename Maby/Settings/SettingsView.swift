import SwiftUI

struct SettingsView: View {
    @State private var showingEditBaby = false
    @State private var showingRemoveBaby = false
    
    private var sourceCodeUrl: URL {
        return URL(string: "https://github.com/wesleyscholl/maby")!
    }
    
    private var version: String {
        let infoDictionary = Bundle.main.infoDictionary
        
        let releaseVersionNumber = infoDictionary?[
            "CFBundleShortVersionString"
        ] as? String
        
        let buildVersion = infoDictionary?[
            "CFBundleVersion"
        ] as? String
        
        if releaseVersionNumber != nil && buildVersion != nil {
            return "v\(releaseVersionNumber!) (Build \(buildVersion!))"
        } else {
            return "v1.0.0 (1)"
        }
    }
    
    var body: some View {
        List {
            BabyCard()
                .clearBackground()
            Section("Baby") {
                Button(action: { showingEditBaby.toggle() }) {
                    Label("Edit baby details", systemImage: "info.square.fill")
                }
                Button(action: { showingRemoveBaby.toggle() }) {
                    Label("Remove baby", systemImage: "trash.square.fill")
                        .symbolRenderingMode(.multicolor)
                }
            }
            Section("About") {
                Link(destination: sourceCodeUrl) {
                    Label("Open source code", systemImage: "arrow.up.right.square.fill")
                        .symbolRenderingMode(.multicolor)
                }
            }
            Section() {
                Text("Joyful \(version)")
                Text(
                    "Made with \(Image(systemName: "heart.fill").symbolRenderingMode(.multicolor)) by Wesley Scholl"
                )
            }
            .foregroundColor(.gray)
            .listRowSeparator(.hidden)
            .frame(maxWidth: .infinity, alignment: .center)
            .clearBackground()
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .sheet(isPresented: $showingEditBaby) {
            EditBabyDetailsView()
        }
        .sheet(isPresented: $showingRemoveBaby) {
            RemoveBabyView()
                .sheetSize(.medium)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .mockedDependencies()
    }
}
