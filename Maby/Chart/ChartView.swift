import SwiftUI
import CoreData
import Factory
import MabyKit
import SwiftUICharts

struct ChartView: View {
    @Injected(Container.eventService) private var eventService

    @SectionedFetchRequest<Date, Event>(
        sectionIdentifier: \.groupStart,
        sortDescriptors: [
            SortDescriptor(\.start, order: .reverse)
        ]
    ) private var events: SectionedFetchResults<Date, Event>
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    private let eventTypes = ["BottleFeedEvent", "DiaperEvent", "NursingEvent", "SleepEvent", "VomitEvent", "BreastPumpEvent", "BathingEvent", "ActivityEvent"]
    private let colors: [Color] = [.blue, .orange, .pink, .green, .purple, .yellow, .indigo, .mint]
    @State private var animate = false

    var body: some View {
        let todayData = countEvents(for: 1)
        let lastWeekData = countEvents(for: 7)
        List {
            BabyCard()
                .clearBackground()
            Section(header: Text("Summary for \(Date(), formatter: dateFormatter)")){
                HStack {
                    CustomBarChartView(data: todayData, colors: colors)
                }.padding(5)
                Text("Totals").font(.title3)
            }
            .headerProminence(.increased)
            Section(header: Text("Summary for last week")){
                HStack {
                    CustomBarChartView(data: lastWeekData, colors: colors)
                }.padding(5)
                Text("Totals").font(.title3)
            }
            .headerProminence(.increased)
            Section(header: Text("Daily Events")){
                ForEach(events) { section in
                    Section(header: JournalSectionHeader(date: section.id)) {
                        ForEach(section) { event in
                            EventView(event: event)
                        }
                        .onDelete { indexSet in
                            eventService.delete(events: indexSet.map { section[$0] })
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        }
                    }
                }
            }.headerProminence(.increased)
        }.onAppear {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    private func countEvents(for days: Int) -> [(String, Double)] {
        let startOfDay = Calendar.current.date(byAdding: .day, value: -days, to: Calendar.current.startOfDay(for: Date()))!
        let endOfDay = Calendar.current.startOfDay(for: Date())
        var counts: [Double] = [0, 0, 0, 0, 0, 0, 0, 0]
        for section in events {
            for event in section {
                if event.start >= startOfDay && event.start < endOfDay {
                    switch String(describing: type(of: event)) {
                    case eventTypes[0]:
                        counts[0] += 1
                    case eventTypes[1]:
                        counts[1] += 1
                    case eventTypes[2]:
                        counts[2] += 1
                    case eventTypes[3]:
                        counts[3] += 1
                    case eventTypes[4]:
                        counts[4] += 1
                    case eventTypes[5]:
                        counts[5] += 1
                    case eventTypes[6]:
                        counts[6] += 1
                    case eventTypes[7]:
                        counts[7] += 1
                    default:
                        break
                    }
                }
            }
        }
        return Array(zip(eventTypes, counts))
    }
}

private struct JournalSectionHeader: View {
    let date: Date
    var body: some View {
        Text(date, format: .dateTime.day().month().year())
    }
}

struct CustomBarChartView: View {
    let data: [(String, Double)]
    let colors: [Color]
    @State private var animate = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(data.indices) { index in
                    if index < 4 {
                        chartColumn(index: index)
                    }
                }
            }.padding(10)
            Spacer()
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(data.indices) { index in
                    if index >= 4 {
                        chartColumn(index: index)
                    }
                }
            }.padding(10)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).delay(0.5)) {
                self.animate = true
            }
        }
        .onDisappear {
            self.animate = false
        }
    }

    @ViewBuilder
    private func chartColumn(index: Int) -> some View {
        VStack {
            Text("\(Int(data[index].1))").font(.caption)
                .opacity(self.animate ? 1 : 0)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1).delay(0.6)) {
                        self.animate = true
                    }
                }
            Rectangle()
                .fill(colors[index % colors.count])
                .cornerRadius(5)
                .shadow(color: .black, radius: 1, x: 0, y: 1)
                .scaleEffect(y: self.animate ? 1 : 0, anchor: .bottom)
                .frame(width: UIScreen.main.bounds.width * 0.18, height: CGFloat(data[index].1 == 0 ? 1 : data[index].1 * UIScreen.main.bounds.height * 0.01))
                .onAppear {
                    withAnimation(.easeInOut(duration: 1).delay(0.5)) {
                        self.animate = true
                    }
                }
                .onDisappear {
                    self.animate = false
                }
            let words = data[index].0.replacingOccurrences(of: "Event", with: "")
                .replacingOccurrences(of: "BottleFeed", with: "Bottle Feedings")
                .replacingOccurrences(of: "Diaper", with: "Diaper Changes")
                .replacingOccurrences(of: "Nursing", with: "Breast Feedings")
                .replacingOccurrences(of: "Sleep", with: "Sleep &Naps")
                .replacingOccurrences(of: "Vomit", with: "Vomit &Burping")
                .replacingOccurrences(of: "BreastPump", with: "Breast Pumping")
                .replacingOccurrences(of: "Bathing", with: "Bath &Showers")
                .replacingOccurrences(of: "Activity", with: "Activities &Play")
                .split(separator: " ")

            VStack {
                ForEach(words, id: \.self) { word in
                    Text(String(word).replacingOccurrences(of: "&Naps", with: "& Naps").replacingOccurrences(of: "&Burping", with: "& Burping").replacingOccurrences(of: "&Showers", with: "& Showers").replacingOccurrences(of: "&Play", with: "& Play"))
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

private struct EventTotalView<E: Event>: View where E: NSManagedObject, E: Event {
    private let text: String
    private let icon: String
    private let selectedDate: Date

    init(
        _ text: String,
        icon: String,
        date: Date
    ) {
        self.text = text
        self.icon = icon
        self.selectedDate = date
    }

    var body: some View {
        let fetchRequest = FetchRequest<E>(
            sortDescriptors: [
                SortDescriptor(\.start, order: .reverse)
            ],
            predicate: NSPredicate(format: "start >= %@ AND start < %@",
                                    selectedDate.startOfDay as NSDate,
                                    selectedDate.endOfDay as NSDate)
        )

        return VStack {
            HStack {
                Text(icon)
                    .font(.title)
                
                VStack(alignment: .leading) {
                    Text("\(text) (\(fetchRequest.wrappedValue.count))")
                }
            }
        }
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    var endOfDay: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
    }
}

struct EventListView: View {
    @State private var selectedDate = Date()

    var body: some View {
        VStack {
            Text("Summary for \(selectedDate, formatter: DateFormatter())")
            Section(header: Text("Feeding")) {
                EventTotalView<NursingEvent>(
                    "Nursing",
                    icon: "🤱",
                    date: selectedDate
                )
                EventTotalView<BottleFeedEvent>(
                    "Bottle Feed",
                    icon: "🍼",
                    date: selectedDate
                )
            }
            Section(header: Text("Hygiene")) {
                EventTotalView<DiaperEvent>(
                    "Diaper Change",
                    icon: "🚼",
                    date: selectedDate
                )
            }
            Section(header: Text("Health")) {
                EventTotalView<SleepEvent>(
                    "Sleep",
                    icon: "😴",
                    date: selectedDate
                )
                
                EventTotalView<VomitEvent>(
                    "Vomit",
                    icon: "🤢",
                    date: selectedDate
                )
            }
        }
    }
}
