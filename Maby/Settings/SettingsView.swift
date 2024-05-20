import SwiftUI

struct SettingsView: View {
    @State private var showingEditBaby = false
    @State private var showingRemoveBaby = false
    @State private var notificationsEnabled = false
    @Environment(\.colorScheme) var colorScheme
    
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
                Button(action: { 
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showingEditBaby.toggle() 
                    }) {
                    Label {
                        Text("Edit baby details")
                            .foregroundColor(colorScheme == .dark ? .white : .gray)
                    } icon: {
                        Image(systemName: "info.square.fill")
                    }
                    .symbolRenderingMode(.multicolor)
                }
                Button(action: { 
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showingRemoveBaby.toggle() 
                    }) {
                    Label {
                        Text("Remove baby")
                            .foregroundColor(colorScheme == .dark ? .white : .gray)
                    } icon: {
                        Image(systemName: "trash.square.fill")
        
                    .symbolRenderingMode(.multicolor)
                }
            }
            }
            Section("Notifications") {
                Toggle(isOn: $notificationsEnabled) {
                    Text("Daily Reminder Notifications")
                        .foregroundColor(colorScheme == .dark ? .white : .gray)
                }
                .onChange(of: notificationsEnabled) { newValue in
                    if newValue {
                        NotificationScheduler.scheduleDailyNotifications()
                    } else {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }
                }
            }
            Section("About") {
                Link(destination: sourceCodeUrl) {
                    Label {
                        Text("Open source code")
                            .foregroundColor(colorScheme == .dark ? .white : .gray)
                    } icon: {
                        Image(systemName: "arrow.up.right.square.fill")
                        .foregroundColor(.green)
                    }
                    .symbolRenderingMode(.multicolor)
                }
            }
            Section() {
                Text("Joyful \(version)")
                Text(
                    "Made with \(Image(systemName: "heart.fill").symbolRenderingMode(.palette)) by Wesley Scholl"
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
        .onChange(of: showingEditBaby) { newValue in
            if !newValue {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
        .onChange(of: showingRemoveBaby) { newValue in
            if !newValue {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
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
