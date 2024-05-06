import CoreData
import Factory
import MabyKit
import SwiftUI

struct JournalView: View {
    @Injected(Container.eventService) private var eventService
    
    let darkGrey = Color(red: 128/255, green: 128/255, blue: 128/255)
    @Binding var selectedIndex: Int
    @SectionedFetchRequest<Date, Event>(
        sectionIdentifier: \.groupStart,
        sortDescriptors: [
            SortDescriptor(\.start, order: .reverse)
        ]
    ) private var events: SectionedFetchResults<Date, Event>

    var body: some View {
        List {
            BabyCard()
                .clearBackground()
            if events.isEmpty {
                Section("No Events") {
                   Button(action: {
                        selectedIndex = 1
                    }) {
                            HStack {
                                Text("Tap")
                                Image(systemName: "plus")
                                Text("to add some")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(darkGrey)
                                    .opacity(0.7)
                            }.font(.system(size: 16))
                                .foregroundStyle(darkGrey)
                                .multilineTextAlignment(.center)
                                .opacity(0.7)
                        
                    }
                }
            } else {
                ForEach(events) { section in
                    Section(header: JournalSectionHeader(date: section.id)) {
                        ForEach(section) { event in
                            EventView(event: event)
                                .contextMenu {
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        // observableAsset.updateFavoriteStatus()
                                    }) {
                                        Text("Favorite")
                                        Image(systemName: "heart.fill")
                                    }
                                }   
                        }
                        .onDelete { indexSet in
                            eventService.delete(events: indexSet.map { section[$0] })
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        }
                    }
                }
            }
        }.onAppear {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
    }
}

private struct JournalSectionHeader: View {
    let date: Date
    
    var body: some View {
        Text(date, format: .dateTime.day().month().year())
    }
}

//struct JournalView_Previews: PreviewProvider {
//    static var previews: some View {
//        JournalView()
//            .mockedDependencies()
//    }
//}
