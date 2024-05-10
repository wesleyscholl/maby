import CoreData
import Factory
import MabyKit
import SwiftUI

extension UINavigationBar {
    static func configureAppearance(color: UIColor, backgroundColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor.withAlphaComponent(0.75)
        appearance.backgroundEffect = nil
        // appearance.titleTextAttributes = [.foregroundColor: color]
        // appearance.largeTitleTextAttributes = [.foregroundColor: color]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(fetchRequest: allBabies)
    private var babies: FetchedResults<Baby>
    @State private var showingAddBaby = false
    @State private var selectedIndex: Int = 0
    
    let colorPink = Color(red: 246/255, green: 138/255, blue: 162/255)

    private let databaseUpdates = NotificationCenter.default.publisher(
        for: .NSManagedObjectContextDidSave
    )

    enum TabItem {
        case moments, events, journal, summary, settings
    }
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedIndex) {
                if !babies.isEmpty {
                    HomeView()
                        .tabItem {
                            Label("Moments", systemImage: "person.crop.square.badge.camera")
                        }.tag(0)
                    AddEventListView()
                        .tabItem {
                            Label("Events", systemImage: "plus")
                        }.tag(1)
//                    JournalView(selectedIndex: $selectedIndex)
                    ScrollTransitionView()
                        .tabItem {
                            Label("Journal", systemImage: "book")
                        }.tag(2)
                    ChartView(selectedIndex: $selectedIndex)
                        .tabItem {
                            Label("Summary", systemImage: "chart.bar.xaxis")
                        }.tag(3)
//                    TimelineView()
//                        .tabItem {
//                            Label("Timeline", systemImage: "bolt")
//                        }
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }.tag(4)
//                    TestView()
//                        .tabItem {
//                            Label("Test", systemImage: "figure.child.circle.fill")
//                        }
                    
//                        .navigationBarHidden(true)
                }
            }
            .tint(colorPink)
            .background(.black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Joyful")
            .sheet(isPresented: $showingAddBaby) {
                AddBabyView()
                    .interactiveDismissDisabled(true)
            }
            .onAppear (perform: {
                UITabBar.appearance().unselectedItemTintColor = .gray
                UITabBarItem.appearance().badgeColor = UIColor(colorPink)
                UITabBar.appearance().backgroundColor = .systemGray4.withAlphaComponent(0.4)
                UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(colorPink)]
                UINavigationBar.appearance().backgroundColor = .black
                //UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
                //Above API will kind of override other behaviour and bring the default UI for TabView
                showingAddBaby = babies.isEmpty
            })
            .onReceive(databaseUpdates) { _ in
                // Delay showing the sheet to give time for the rest of the sheets to hide.
                // Removing this results in the sheet not being shown due to the delete one being shown still.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showingAddBaby = babies.isEmpty
                }
            }
        }
        .onChange(of: colorScheme) { value in
            if value == .dark {
                UINavigationBar.configureAppearance(color: .white, backgroundColor: UIColor.systemGray6)
            } else {
                UINavigationBar.configureAppearance(color: .black, backgroundColor: UIColor.systemGray6)
            }
        }
        .onAppear {
            if colorScheme == .dark {
                UINavigationBar.configureAppearance(color: .white, backgroundColor: UIColor.systemGray6)
            } else {
                UINavigationBar.configureAppearance(color: .black, backgroundColor: UIColor.systemGray6)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .mockedDependencies()
            .previewDisplayName("With data")
        
        ContentView()
            .mockedDependencies(empty: true)
            .previewDisplayName("Without data")
    }
}
