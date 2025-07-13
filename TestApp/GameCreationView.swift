import SwiftUI

struct GameCreationView: View {
    let startGame: (String, [[Int]]) -> Void // 閉包，用於啟動遊戲並傳遞難度和題目

    @State private var selectedDifficulty: String = "簡單" // 預設難度
    let difficulties = ["簡單", "中等", "困難"]

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("開始數獨遊戲")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)

            Picker("選擇難度", selection: $selectedDifficulty) {
                ForEach(difficulties, id: \.self) { difficulty in
                    Text(difficulty).tag(difficulty)
                }
            }
            .pickerStyle(.segmented) // 分段控制器風格
            .padding(.horizontal)

            Button(action: {
                // 根據選擇的難度生成題目
                let newPuzzle = SudokuGenerator.generatePuzzle(difficulty: selectedDifficulty)
                startGame(selectedDifficulty, newPuzzle) // 調用閉包傳遞難度和題目
            }) {
                Text("開始遊戲")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 200)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .shadow(radius: 5)

            Spacer()
        }
        .navigationTitle("新遊戲")
    }
}
