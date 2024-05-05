import Factory
import MabyKit
import SwiftUI

// MARK: - Event view
struct EventView: View {
    let event: Event
    
    @ViewBuilder
    private var icon: some View {
        if let _ = event as? BottleFeedEvent {
            EventIcon(
                icon: "🍼",
                startColor: .blue,
                endColor: .blue.opacity(0.5)
            )
        } else if let _ = event as? DiaperEvent {
            EventIcon(
                icon: "🚼",
                startColor: .orange,
                endColor: .orange.opacity(0.5)
            )
        } else if let _ = event as? NursingEvent {
            EventIcon(
                icon: "🤱🏻",
                startColor: .blue,
                endColor: .blue.opacity(0.5)
            )
        } else if let _ = event as? SleepEvent {
            EventIcon(
                icon: "😴",
                startColor: .black.opacity(0.8),
                endColor: .black.opacity(0.2)
            )
        } else if let _ = event as? VomitEvent {
            EventIcon(
                icon: "🤢",
                startColor: .brown,
                endColor: .brown.opacity(0.6)
            )
         } else if let _ = event as? BreastPumpEvent {
            EventIcon(
                icon: "🥛",
                startColor: .brown,
                endColor: .brown.opacity(0.6)
            )
         } else if let _ = event as? BathingEvent {
            EventIcon(
                icon: "🛁",
                startColor: .purple,
                endColor: .purple.opacity(0.6)
            )
         } else if let _ = event as? ActivityEvent {
            EventIcon(
                icon: "🪇",
                startColor: .green,
                endColor: .green.opacity(0.6)
            )
        } else {
            Text("❓")
        }
    }
    
    @ViewBuilder
    private var details: some View {
        if let bottleEvent = event as? BottleFeedEvent {
            BottleEventDetails(event: bottleEvent)
        } else if let diaperEvent = event as? DiaperEvent {
            DiaperEventDetails(event: diaperEvent)
        } else if let nursingEvent = event as? NursingEvent {
            NursingEventDetails(event: nursingEvent)
        } else if let sleepEvent = event as? SleepEvent {
            SleepEventDetails(event: sleepEvent)
        } else if let vomitEvent = event as? VomitEvent {
            VomitEventDetails(event: vomitEvent)
        } else if let breastPumpEvent = event as? BreastPumpEvent {
            BreastPumpEventDetails(event: breastPumpEvent)
        } else if let bathingEvent = event as? BathingEvent {
            BathingEventDetails(event: bathingEvent)
        } else if let activityEvent = event as? ActivityEvent {
            ActivityEventDetails(event: activityEvent)
        } else {
            Text("❓")
        }
    }
    
    var body: some View {
        HStack {
            icon
                .font(.largeTitle)
            details
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Event icon
private struct EventIcon: View {
    let icon: LocalizedStringKey
    let startColor: Color
    let endColor: Color
    
    var body: some View {
        Text(icon)
            .padding(5)
            .background(
                LinearGradient(
                    colors: [startColor, endColor],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(5)
    }
}

private func formatDate(for event: Event) -> String {
    event.start.formatted(.dateTime.hour().minute())
}

// MARK: - Detail specific views
private struct BottleEventDetails: View {
    let event: BottleFeedEvent
    
    private var formattedAmount: String {
        let quantityWithMeasure = Measurement(
            value: Double(event.quantity),
            unit: UnitVolume.milliliters
        )
        
        return formatMl(amount: quantityWithMeasure)
    }
    
    var body: some View {
        Text("Fed 👩🏻‍🍼 **\(formattedAmount)** from bottle at \(formatDate(for: event))")
    }
}

private struct DiaperEventDetails: View {
    let event: DiaperEvent
    
    var diaperTypeText: String {
        switch event.type {
        case .mixed:
            return "Mixed diaper 💦💩"
        case .wet:
            return "Wet diaper 💦"
        case .clean:
            return "Clean diaper 🧷"
        case .dirty:
            return "Dirty diaper 💩"
        }
    }
    
    var body: some View {
        Text("Changed a **\(diaperTypeText)** at \(formatDate(for: event))")
    }
}

private struct BathingEventDetails: View {
    let event: BathingEvent
    
    var bathingTypeText: String {
        switch event.type {
        case .bath:
            return "Took a Bath 🛁"
        case .sponge:
            return "Sponge bath 🧽"
        case .shower:
            return "Showered 🚿"
        case .sink:
            return "Bathed in the Sink 💧"
        }
    }
    
    var body: some View {
        Text("**\(bathingTypeText)** at \(formatDate(for: event))")
    }
}

private struct ActivityEventDetails: View {
    let event: ActivityEvent
    
    var activityTypeText: String {
        switch event.type {
        case .tummy:
            return "Tummy time 🙇🏻‍♀️"
        case .indoor:
            return "Indoor play 🧸"
        case .outdoor:
            return "Outdoor play 🛝"
        }
    }
    
    private var formattedDate: String {
        event.start.formatted(.dateTime.hour().minute())
    }
    
    private var duration: String {
        (event.start..<event.end).formatted(
            .components(
                style: .narrow,
                fields: [.hour, .minute]
            )
        )
    }
    
    var body: some View {
        Text("**\(activityTypeText)** at \(formatDate(for: event))  for **\(duration)**")
    }
}

private struct NursingEventDetails: View {
    let event: NursingEvent
    
    private var breastText: String {
        switch event.breast {
        case .left:
            return "left breast"
        case .right:
            return "right breast"
        case .both:
            return "both breasts"
        }
    }
    
    private var formattedDate: String {
        event.start.formatted(.dateTime.hour().minute())
    }
    
    private var duration: String {
        (event.start..<event.end).formatted(
            .components(
                style: .narrow,
                fields: [.hour, .minute]
            )
        )
    }
    
    var body: some View {
        Text("Nursed 🤱🏼 from \(breastText) at \(formattedDate) for **\(duration)**")
    }
}

private struct SleepEventDetails: View {
    let event: SleepEvent
    
    private var duration: String {
        (event.start..<event.end).formatted(
            .components(
                style: .narrow,
                fields: [.hour, .minute]
            )
        )
    }
    
    var body: some View {
        Text("Slept 💤 for **\(duration)** at \(formatDate(for: event))")
    }
}

private struct VomitEventDetails: View {
    let event: VomitEvent
    private var description: AttributedString {
        switch event.type {
        case .vomit:
            return try! AttributedString(markdown: "Cleaned **vomit** 🤮")
        case .burping:
            return try! AttributedString(markdown: "**Burping** 🫧")
        case .spitup:
            return try! AttributedString(markdown: "Cleaned **spit up** 💦")
        }
    }
    var body: some View {
        Text("\(description) at \(formatDate(for: event))")
    }
}

private struct BreastPumpEventDetails: View {
    let event: BreastPumpEvent
    
    private var breastText: String {
        switch event.breast {
        case .left:
            return "left breast"
        case .right:
            return "right breast"
        case .both:
            return "both breasts"
        }
    }
    
    private var formattedDate: String {
        event.start.formatted(.dateTime.hour().minute())
    }
    
    private var duration: String {
        (event.start..<event.end).formatted(
            .components(
                style: .narrow,
                fields: [.hour, .minute]
            )
        )
    }

    private var formattedAmount: String {
        let amountWithMeasure = Measurement(
            value: Double(event.amount),
            unit: UnitVolume.milliliters
        )
        return formatMl(amount: amountWithMeasure)
    }
    
    var body: some View {
        Text("Pumped **\(formattedAmount)** 🍼 from \(breastText) at \(formattedDate) for **\(duration)**")
    }
}

#if DEBUG
struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: BottleFeedEvent(
            context: Container.previewContainer().viewContext,
            date: Date.now,
            quantity: 250
        ))
        .previewDisplayName("Bottle event")
        
        EventView(event: DiaperEvent(
            context: Container.previewContainer().viewContext,
            date: Date.now,
            type: DiaperEvent.DiaperType.mixed
        ))
        .previewDisplayName("Diaper event")
        
        EventView(event: NursingEvent(
            context: Container.previewContainer().viewContext,
            start: Date.now,
            end: Date.now.addingTimeInterval(1000),
            breast: .left
        ))
        .previewDisplayName("Nursing event")
        
        EventView(event: SleepEvent(
            context: Container.previewContainer().viewContext,
            start: Date.now,
            end: Date.now.addingTimeInterval(10000)
        ))
        .previewDisplayName("Sleep event")
        
        EventView(event: VomitEvent(
            context: Container.previewContainer().viewContext,
            date: Date.now,
            type: .spitup
        ))
        .previewDisplayName("Vomit event")
    }
}
#endif
