import SwiftUI

struct DailyChallengeView: View {
    var body: some View {
        VStack {
            Text("每日挑戰test")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            Text("這裡將顯示每日數獨挑戰！")
                .font(.title2)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
    }
}

struct DailyChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        DailyChallengeView()
    }
}
