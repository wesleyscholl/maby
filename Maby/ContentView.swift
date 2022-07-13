import CoreData
import Factory
import MabyKit
import SwiftUI

struct ContentView: View {
    @FetchRequest(fetchRequest: allBabies())
    private var babies: FetchedResults<Baby>
    
    @State private var showingAddBaby = false
    
    var body: some View {
        VStack {
            if !babies.isEmpty {
                TabView {
                    AddEventView()
                        .tabItem {
                            Label("Add event", systemImage: "plus")
                        }
                    
                    JournalView()
                        .tabItem {
                            Label("Journal", systemImage: "book")
                        }
                }
            }
        }
        .sheet(isPresented: $showingAddBaby) {
            AddBabyView()
                .interactiveDismissDisabled(true)
        }
        .onAppear {
            showingAddBaby = babies.isEmpty
        }
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