import SwiftUI

struct Reaction {
    let imageName: String
    var isShown: Bool
    var rotation: Double
    var isSelected: Bool
}

struct ReactionBackgroundView: View {
    @Binding var showReactionsBackground: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 35)
            .fill(Color(UIColor.tertiarySystemGroupedBackground))
            .frame(width: 375, height: 60)
            .scaleEffect(showReactionsBackground ? 1 : 0, anchor: .bottomTrailing)
            .animation(
                .interpolatingSpring(stiffness: 170, damping: 15).delay(0.05),
                value: showReactionsBackground
            )
    }
}

struct ReactionBarView: View {
    @Binding var reactions: [Reaction]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(reactions.indices, id: \.self) { index in
                ReactionButtonView(reaction: $reactions[index])
            }
        }
        .drawingGroup()
        .onDisappear {
            withAnimation(.interpolatingSpring(stiffness: 170, damping: 15).delay(0.05)) {
                for index in reactions.indices {
                    reactions[index].isShown = false
                }
            }
        }
    }
}

struct ReactionButtonView: View {
    @Binding var reaction: Reaction
    let colorPink = Color(red: 246/255, green: 138/255, blue: 162/255)
    let mediumPink = Color(red: 255/255, green: 193/255, blue: 206/255)

    var body: some View {
        Button(action: {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring()) {
                reaction.isSelected.toggle()
            }
        }) {
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient:
                                            Gradient(colors: [mediumPink, colorPink]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .opacity(reaction.isSelected && reaction.isShown ? 1 : 0)
                    .scaleEffect(reaction.isSelected && reaction.isShown ? 0.9 : 0)
                    .animation(.spring(), value: reaction.isSelected)
                Image(systemName: reaction.imageName)
                    .foregroundColor(.white)
                    .scaleEffect(reaction.isShown ? 1 : 0)
                    .rotationEffect(.degrees(reaction.isShown ? reaction.rotation : 0))
            }
        }.onDisappear {
            withAnimation(.interpolatingSpring(stiffness: 170, damping: 15)) {
                reaction.isShown = false
            }
        }
    }
}