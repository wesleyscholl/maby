import Factory
import MabyKit
import SwiftUI

struct BabyCard: View {
    @FetchRequest private var babies: FetchedResults<Baby>
    
    init() {
        self._babies = FetchRequest(fetchRequest: allBabies)
    }
    
    private var name: String {
        babies.first?.name ?? ""
    }
    
    private var age: String {
        babies.first?.formattedAge ?? ""
    }
    
    private var gender: Baby.Gender {
            babies.first?.gender ?? .other
        }
    
    var body: some View {
        VStack {
            HStack {
                if gender == .boy {
                    Image("babyboyz")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding([.leading, .trailing], 20)
                    } else if gender == .girl {
                        Image("baby-girl-1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .padding([.leading, .trailing], 20)
                    } else if gender == .other {
                        Image("baby-g")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .padding([.leading, .trailing], 20)
                    }
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.title)
                    Text("\(age) old")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity,  alignment: .leading)
        .background(.gray.opacity(0.2))
        .cornerRadius(10)
        .shadow(radius: 8)
    }
}

#if DEBUG
struct BabyCard_Previews: PreviewProvider {
    static var previews: some View {
        BabyCard()
            .mockedDependencies()
    }
}
#endif

