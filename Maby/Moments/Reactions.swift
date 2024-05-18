import SwiftUI

struct Reaction {
    let imageName: String
    var isShown: Bool
    var rotation: Double
    var isSelected: Bool
}

public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}

let colorPink = Color(red: 246/255, green: 138/255, blue: 162/255)
let mediumPink = Color(red: 255/255, green: 193/255, blue: 206/255)

struct ReactionBackgroundView: View {
    @Binding var showReactionsBackground: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 35)
            .fill(colorScheme == .dark ? Color(UIColor.tertiarySystemGroupedBackground) : .gray)
            .frame(width: screenWidth * 0.95, height: screenHeight * 0.06)
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
                    .frame(width: screenHeight * 0.06, height: screenHeight * 0.06)
                    .opacity(reaction.isSelected && reaction.isShown ? 1 : 0)
                    .scaleEffect(reaction.isSelected && reaction.isShown ? 0.85 : 0)
                    .animation(.spring(), value: reaction.isSelected)
                Image(systemName: reaction.imageName)
                    .frame(width: screenHeight * 0.05, height: screenHeight * 0.05)
                    .foregroundColor(.white)
                    .scaleEffect(reaction.isShown ? 1 : 0)
                    .rotationEffect(.degrees(reaction.isShown ? reaction.rotation : 0))
                    .padding(.horizontal, 10)
            }
        }.onDisappear {
            withAnimation(.interpolatingSpring(stiffness: 170, damping: 15)) {
                reaction.isShown = false
            }
        }
    }
}
