import Factory
import MabyKit
import SwiftUI

@main
struct MabyApp: App {
    @Injected(Container.container) private var persistentContainer
    init() {
        @Environment(\.colorScheme) var colorScheme
        UITabBar.appearance().backgroundColor = colorScheme == .dark ? UIColor.systemGray : UIColor.systemBackground
        }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
//            ContentView()
//                .environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}
