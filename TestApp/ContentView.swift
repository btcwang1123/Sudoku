import SwiftUI

// MARK: - TabSelection Enum

// 定義一個枚舉來表示不同的 Tab
enum TabSelection: Hashable {
    case sudoku
    case dailyChallenge
    case settings
    case gameHistory
}

// MARK: - ContentView

struct ContentView: View {
    @State private var selectedTab: TabSelection = .sudoku
    
    // 使用 @AppStorage 自動處理數據的加載和保存
    @AppStorage("sudokuGameHistory") private var gameHistoryData: Data = Data()
    
    // @State 變數用於在 App 運行時操作解碼後的數據
    @State private var gameHistory: [ReportItem] = []

    // 準備傳遞給 SudokuGameView 的新遊戲題目，用於「再玩一次」功能
    @State private var puzzleToReplay: [[Int]]? = nil
    
    @State private var hasStartedGame = false
    @State private var currentPuzzle: [[Int]] = []
    @State private var currentDifficulty: String = "中等"

    
    func generatePuzzle(difficulty: String) -> [[Int]] {
        // 回傳一個空的 9x9 棋盤，未來可以改成真的生成器
        return Array(repeating: Array(repeating: 0, count: 9), count: 9)
    }


    var body: some View {
        TabView(selection: $selectedTab) {
            // 1. 數獨遊戲頁面
            Group {
                if hasStartedGame {
                    SudokuGameView(
                        selectedTab: $selectedTab,
                        onGameSolved: { reportItem in
                            addReportToHistory(reportItem)
                            hasStartedGame = false // 回到主畫面
                        },
                        initialPuzzle: currentPuzzle,
                        gameDifficulty: currentDifficulty
                    )
                } else {
                    GameCreationView { selectedDifficulty, newPuzzle in
                        currentDifficulty = selectedDifficulty
                        currentPuzzle = newPuzzle
                        hasStartedGame = true
                    }
                }
            }
            .tabItem {
                Label("數獨", systemImage: "square.grid.3x3.fill")
            }
            .tag(TabSelection.sudoku)


            // 2. 每日挑戰頁面
            DailyChallengeView()
                .tabItem {
                    Label("每日挑戰1", systemImage: "calendar")
                }
                .tag(TabSelection.dailyChallenge)

            // 3. 設定頁面
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(TabSelection.settings)

            // 4. 遊戲歷史記錄頁面
            GameHistoryView(
                gameHistory: $gameHistory, // 傳遞歷史數據的 Binding
                selectedTab: $selectedTab, // 傳遞 selectedTab 方便跳轉
                puzzleToReplay: $puzzleToReplay // 傳遞要重玩的題目
            )
            .tabItem {
                Label("報告", systemImage: "doc.text.fill")
            }
            .tag(TabSelection.gameHistory)
            // badge 用於顯示新通知，例如有新的遊戲報告
            .badge(gameHistory.contains(where: { $0.isNew }) ? "!" : nil)
        }
        .onAppear(perform: loadGameHistory) // App 啟動時加載歷史記錄
        .onChange(of: gameHistory) { _ in // 當歷史記錄改變時 (新增、編輯、刪除)
            saveGameHistory() // 自動保存
        }
    }

    // 將新報告添加到歷史記錄中
    private func addReportToHistory(_ item: ReportItem) {
        // 將舊報告的 isNew 設為 false
        for i in 0..<gameHistory.count {
            gameHistory[i].isNew = false
        }
        
        var newItem = item
        newItem.isNew = true // 將新報告標記為 isNew
        
        gameHistory.insert(newItem, at: 0) // 將新報告放在最前面
        selectedTab = .gameHistory // 自動切換到報告歷史 Tab
    }

    // 從 AppStorage 加載並解碼歷史記錄
    private func loadGameHistory() {
        if let decodedData = try? JSONDecoder().decode([ReportItem].self, from: gameHistoryData) {
            gameHistory = decodedData
        }
    }

    // 將歷史記錄編碼並保存到 AppStorage
    private func saveGameHistory() {
        if let encodedData = try? JSONEncoder().encode(gameHistory) {
            gameHistoryData = encodedData
        }
    }
}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
