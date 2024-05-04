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
                        GeometryReader { geometry in
                            EventView(event: event)
                                .scaleEffect(self.scaleFactor(for: geometry.frame(in: .global).minY, maxY: geometry.frame(in: .global).maxY))
                                .animation(.easeInOut(duration: 0.25))
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
    private func scaleFactor(for minY: CGFloat, maxY: CGFloat) -> CGFloat {
    let startScale: CGFloat = 0.9
    let endScale: CGFloat = 1.0
    let lowerBound: CGFloat = UIScreen.main.bounds.height - 75 // Start scaling up 100 points from the bottom of the screen
    let upperBound: CGFloat = 25 // Start scaling down 100 points from the top of the screen

    if maxY > lowerBound {
        let progress = (lowerBound - maxY) / 100
        return startScale + (endScale - startScale) * progress
    } else if minY < upperBound {
        let progress = minY / 100
        return startScale + (endScale - startScale) * progress
    } else {
        return endScale
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
