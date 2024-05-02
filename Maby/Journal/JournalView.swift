import CoreData
import Factory
import MabyKit
import SwiftUI

struct JournalView: View {
    @Injected(Container.eventService) private var eventService
    
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
            ForEach(events) { section in
                Section(header: JournalSectionHeader(date: section.id)) {
                    ForEach(section) { event in
                        EventView(event: event)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive, action: {
//                                    eventToEdit = event
//                                    isShowingEditSheet = true
                                    print("delete")
                                }){
                                    Label("Delete", systemImage: "trash")
                                }.tint(.red)
                            }
                        .swipeActions(edge: .trailing) {
                                Button(action: {
//                                    eventToEdit = event
//                                    isShowingEditSheet = true
                                    print("edit")
                                }){
                                    Label("Edit", systemImage: "pencil")
                                }.tint(.yellow)
                            }
                    }
                    
                    .onDelete { indexSet in
                        eventService.delete(events: indexSet.map { section[$0] })
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
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

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
            .mockedDependencies()
    }
}
