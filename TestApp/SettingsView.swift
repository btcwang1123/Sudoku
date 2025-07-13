import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("設定")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            Text("這裡將是應用程式的設定選項。")
                .font(.title2)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
