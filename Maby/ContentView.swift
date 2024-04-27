import CoreData
import Factory
import MabyKit
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(fetchRequest: allBabies)
    private var babies: FetchedResults<Baby>
    
    @State private var showingAddBaby = false
    
    private let databaseUpdates = NotificationCenter.default.publisher(
        for: .NSManagedObjectContextDidSave
    )
    
    var body: some View {
        NavigationView {
            TabView {
                if !babies.isEmpty {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    AddEventListView()
                        .tabItem {
                            Label("Add event", systemImage: "plus")
                        }
//                    JournalView()
//                        .tabItem {
//                            Label("Journal", systemImage: "book")
//                        }
//                    ChartView()
//                        .tabItem {
//                            Label("Chart", systemImage: "chart.bar.xaxis")
//                        }
                    TimelineView()
                        .tabItem {
                            Label("Timeline", systemImage: "bolt")
                        }
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                    TestView()
                        .tabItem {
                            Label("Test", systemImage: "figure.child.circle.fill")
                        }
                    
//                        .navigationBarHidden(true)
                }
            }
            .background(.black)
            .sheet(isPresented: $showingAddBaby) {
                AddBabyView()
                    .interactiveDismissDisabled(true)
            }
            .onAppear {
                showingAddBaby = babies.isEmpty
            }
            .onReceive(databaseUpdates) { _ in
                // Delay showing the sheet to give time for the rest of the sheets to hide.
                // Removing this results in the sheet not being shown due to the delete one being shown still.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showingAddBaby = babies.isEmpty
                }
            }
        }.navigationBarBackButtonHidden(true)
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
