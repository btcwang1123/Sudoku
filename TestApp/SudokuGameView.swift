import SwiftUI
import Combine // 引入 Combine 框架用於計時器

// 自定義顏色
extension Color {
    static let userFilledNumber = Color(red: 0.1, green: 0.2, blue: 0.6) // 深藍色
    static let lightBlueHighlight = Color.blue.opacity(0.05) // 最淺的藍色
    static let mediumBlueHighlight = Color.blue.opacity(0.1) // 中等淺藍色
    static let selectedCellBlue = Color.blue.opacity(0.15) // 選中單元格的淺藍色
}

// UndoAction 結構用於儲存復原操作的資訊
struct UndoAction {
    let row: Int
    let col: Int
    let oldValue: Int // 該單元格在操作前的值
    let oldNotes: Set<Int> // 新增：儲存操作前的筆記
}

// CellData 結構用於儲存每個單元格的值和筆記
struct CellData: Equatable {
    var value: Int // 主要的數獨數字，0 表示空
    var notes: Set<Int> // 儲存筆記數字的集合

    init(value: Int = 0, notes: Set<Int> = []) {
        self.value = value
        self.notes = notes
    }
}

// SudokuBoard 結構用於管理數獨板的數據
struct SudokuBoard {
    var board: [[CellData]] // 數獨板現在儲存 CellData
    let initialBoard: [[CellData]] // 初始板也儲存 CellData

    init(initialBoard: [[Int]]) {
        // 將 Int 陣列轉換為 CellData 陣列
        self.initialBoard = initialBoard.map { row in
            row.map { value in
                CellData(value: value)
            }
        }
        self.board = self.initialBoard
    }

    // 新增一個帶有 CellData 陣列參數的 init，以便在 isSolved 中創建臨時 SudokuBoard
    init(initialBoard: [[CellData]], board: [[CellData]]) {
        self.initialBoard = initialBoard
        self.board = board
    }

    // 檢查數字在指定位置是否有效
    func isValid(row: Int, col: Int, num: Int) -> Bool {
        // 檢查行
        for c in 0..<9 {
            if c != col && board[row][c].value == num { // 訪問 CellData 的 value
                return false
            }
        }

        // 檢查列
        for r in 0..<9 {
            if r != row && board[r][col].value == num { // 訪問 CellData 的 value
                return false
            }
        }

        // 檢查 3x3 方塊
        let startRow = (row / 3) * 3
        let startCol = (col / 3) * 3
        for r in startRow..<startRow + 3 {
            for c in startCol..<startCol + 3 {
                if r != row && c != col && board[r][c].value == num { // 訪問 CellData 的 value
                    return false
                }
            }
        }
        return true
    }

    // 檢查整個數獨板是否解決
    func isSolved() -> Bool {
        for r in 0..<9 {
            for c in 0..<9 {
                if board[r][c].value == 0 { // 訪問 CellData 的 value
                    return false // 還有空單元格
                }
                let tempValue = board[r][c].value
                var tempBoard = board
                tempBoard[r][c].value = 0 // 暫時清空值以便 isValid 檢查
                
                // 使用臨時板來檢查有效性
                if !SudokuBoard(initialBoard: initialBoard, board: tempBoard).isValid(row: r, col: c, num: tempValue) {
                    return false
                }
            }
        }
        return true
    }

    // 重置數獨板到初始狀態
    mutating func reset() {
        self.board = self.initialBoard
    }
}

// MARK: - SudokuGenerator 範例 (這仍然是模擬，現在這個 View 不再直接使用它)
// 只有 ContentView 會使用它來生成題目
struct SudokuGenerator {
    static func generatePuzzle(difficulty: String) -> [[Int]] {
        // 這裡應該是你實際的數獨題目生成邏輯
        // 根據難度返回不同的題目
        switch difficulty {
        case "簡單":
            return [
                [5, 3, 0, 0, 7, 0, 0, 0, 0],
                [6, 0, 0, 1, 9, 5, 0, 0, 0],
                [0, 9, 8, 0, 0, 0, 0, 6, 0],
                [8, 0, 0, 0, 6, 0, 0, 0, 3],
                [4, 0, 0, 8, 0, 3, 0, 0, 1],
                [7, 0, 0, 0, 2, 0, 0, 0, 6],
                [0, 6, 0, 0, 0, 0, 2, 8, 0],
                [0, 0, 0, 4, 1, 9, 0, 0, 5],
                [0, 0, 0, 0, 8, 0, 0, 7, 9]
            ]
        case "中等":
            return [
                [0, 0, 0, 6, 0, 0, 4, 0, 0],
                [7, 0, 0, 0, 0, 3, 6, 0, 0],
                [0, 0, 0, 0, 9, 1, 0, 8, 0],
                [0, 1, 0, 0, 7, 0, 0, 0, 0], // Changed from all zeros for demo
                [0, 5, 0, 1, 8, 0, 0, 0, 3],
                [0, 0, 0, 3, 0, 6, 0, 4, 5],
                [0, 4, 0, 2, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0]
            ]
        case "困難":
            return [
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0]
            ]
        default: // 默認簡單題目
            return [
                [5, 3, 0, 0, 7, 0, 0, 0, 0],
                [6, 0, 0, 1, 9, 5, 0, 0, 0],
                [0, 9, 8, 0, 0, 0, 0, 6, 0],
                [8, 0, 0, 0, 6, 0, 0, 0, 3],
                [4, 0, 0, 8, 0, 3, 0, 0, 1],
                [7, 0, 0, 0, 2, 0, 0, 0, 6],
                [0, 6, 0, 0, 0, 0, 2, 8, 0],
                [0, 0, 0, 4, 1, 9, 0, 0, 5],
                [0, 0, 0, 0, 8, 0, 0, 7, 9]
            ]
        }
    }
}


// SudokuGameView 是應用程式的主要數獨遊戲視圖
struct SudokuGameView: View {
    @Binding var selectedTab: TabSelection
    let onGameSolved: (ReportItem) -> Void
    // MARK: 移除 puzzleToPlay 和 selectedDifficulty 綁定
    // @Binding var puzzleToPlay: [[Int]]?
    // @Binding var selectedDifficulty: String?
    
    private func isInAffectedRegion(selectedRow: Int?, selectedCol: Int?, row: Int, col: Int) -> Bool {
        guard let sr = selectedRow, let sc = selectedCol else {
            return false
        }
        let sameRow = sr == row
        let sameCol = sc == col
        let sameBlock = (sr / 3 == row / 3) && (sc / 3 == col / 3)
        return sameRow || sameCol || sameBlock
    }


    @State private var sudoku: SudokuBoard
    @State private var originalInitialBoard: [[Int]] // 用於報告

    @State private var selectedRow: Int? = nil
    @State private var selectedCol: Int? = nil
    @State private var isSolved: Bool = false {
        didSet {
            if isSolved {
                stopTimer()
                let report = ReportItem(
                    difficulty: currentDifficulty,
                    yourTime: timeElapsed,
                    errorCount: errorCount,
                    averageTime: calculateAverageTime(for: currentDifficulty),
                    rankPercentage: calculateRankPercentage(yourTime: timeElapsed, difficulty: currentDifficulty),
                    completionDate: Date(),
                    notes: "",
                    rating: 0,
                    initialPuzzle: originalInitialBoard
                )
                onGameSolved(report)
                showCompletionPopup = true
            }
        }
    }
    @State private var errorMessage: String? = nil
    @State private var highlightedNumber: Int? = nil
    @State private var isNoteModeActive: Bool = false

    @State private var timeElapsed: Int = 0
    @State private var isTimerRunning: Bool = false
    @State private var timerSubscription: AnyCancellable? = nil

    @State private var errorCount: Int = 0
    @State private var undoStack: [UndoAction] = []
    
    @State private var showCompletionPopup: Bool = false
    
    // MARK: currentDifficulty 現在是直接從 init 接收到的，並作為 @State 管理
    @State private var currentDifficulty: String
    
    

    // MARK: 更新的初始化方法 - 只接收初始題目和難度
    init(selectedTab: Binding<TabSelection>,
         onGameSolved: @escaping (ReportItem) -> Void,
         initialPuzzle: [[Int]], // <-- 新增：直接接收初始題目
         gameDifficulty: String // <-- 新增：直接接收遊戲難度
    ) {
        _selectedTab = selectedTab
        self.onGameSolved = onGameSolved
        
        // 使用傳入的 initialPuzzle 和 gameDifficulty 來初始化狀態
        _sudoku = State(initialValue: SudokuBoard(initialBoard: initialPuzzle))
        _originalInitialBoard = State(initialValue: initialPuzzle)
        _currentDifficulty = State(initialValue: gameDifficulty) // 直接初始化難度
    }

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    VStack {
                        Text("難度")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(currentDifficulty)
                            .font(.headline)
                    }
                    .padding(.trailing, 20)

                    Spacer()

                    VStack {
                        Text("錯誤")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(errorCount)")
                            .font(.headline)
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    VStack {
                        Text("時間")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(timeString(from: timeElapsed))
                            .font(.headline)
                    }
                    .padding(.leading, 20)
                    
                    Button(action: {
                        isTimerRunning.toggle()
                    }) {
                        Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 10)
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // MARK: 修正 Grid 內容的報錯
                Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                    ForEach(0..<9, id: \.self) { row in
                        GridRow {
                            ForEach(0..<9, id: \.self) { col in
                                // 預先計算需要的邏輯值（移出 ViewBuilder 區域）
                                let cellValue = sudoku.board[row][col].value
                                let isInitialCell = sudoku.initialBoard[row][col].value != 0
                                let isSelectedCell = selectedRow == row && selectedCol == col
                                let isConflictingCell = cellValue != 0 && !sudoku.isValid(row: row, col: col, num: cellValue)

                                let inAffectedRegion = isInAffectedRegion(selectedRow: selectedRow, selectedCol: selectedCol, row: row, col: col)

                                Group {
                                    CellView(
                                        cellData: sudoku.board[row][col],
                                        isInitial: isInitialCell,
                                        isSelected: isSelectedCell,
                                        isConflicting: isConflictingCell,
                                        highlightedNumber: highlightedNumber,
                                        inSelectedRowOrColOrBlock: inAffectedRegion,
                                        row: row,
                                        col: col
                                    )
                                    .onTapGesture {
                                        handleCellTap(row: row, col: col)
                                    }
                                }
                                .id(UUID()) // 為每個單元格提供唯一的識別符
                            }
                        }
                    }
                }
                .border(Color.black, width: 2)


                HStack {
                    Spacer()
                    ActionButton(title: "復原", iconName: "arrow.uturn.backward.circle.fill") {
                        if let lastAction = undoStack.popLast() {
                            var tempSudoku = sudoku
                            tempSudoku.board[lastAction.row][lastAction.col].value = lastAction.oldValue
                            tempSudoku.board[lastAction.row][lastAction.col].notes = lastAction.oldNotes
                            sudoku = tempSudoku
                            
                            isSolved = false
                            errorMessage = nil
                            highlightedNumber = nil
                        }
                    }
                    Spacer()
                    ActionButton(title: "清除", iconName: "eraser.fill") {
                        if let r = selectedRow, let c = selectedCol {
                            var tempSudoku = sudoku
                            if sudoku.initialBoard[r][c].value == 0 {
                                undoStack.append(UndoAction(row: r, col: c, oldValue: sudoku.board[r][c].value, oldNotes: sudoku.board[r][c].notes))
                                
                                tempSudoku.board[r][c].value = 0
                                tempSudoku.board[r][c].notes = []
                            }
                            sudoku = tempSudoku
                            
                            isSolved = false
                            errorMessage = nil
                            highlightedNumber = nil
                        }
                    }
                    Spacer()
                    ActionButton(title: "筆記", iconName: isNoteModeActive ? "pencil.circle.fill" : "pencil.circle") {
                        isNoteModeActive.toggle()
                        if let r = selectedRow, let c = selectedCol, sudoku.initialBoard[r][c].value != 0 {
                            selectedRow = nil
                            selectedCol = nil
                        }
                        highlightedNumber = nil
                    }
                    .background(isNoteModeActive ? Color.blue.opacity(0.1) : Color.clear)
                    .cornerRadius(10)
                    Spacer()
                    ActionButton(title: "提示", iconName: "lightbulb.fill", badgeCount: 1) {
                        errorMessage = "尚未實作提示功能"
                    }
                    .opacity(0.5)
                    .disabled(true)
                    Spacer()
                }
                .padding(.top, 20)
                .frame(maxWidth: .infinity)

                HStack(spacing: 10) {
                    ForEach(1..<10) { number in
                        Button(action: {
                            if let r = selectedRow, let c = selectedCol {
                                var tempSudoku = sudoku
                                if isNoteModeActive {
                                    if tempSudoku.board[r][c].notes.contains(number) {
                                        tempSudoku.board[r][c].notes.remove(number)
                                    } else {
                                        tempSudoku.board[r][c].notes.insert(number)
                                    }
                                    tempSudoku.board[r][c].value = 0
                                } else {
                                    if sudoku.initialBoard[r][c].value == 0 {
                                        undoStack.append(UndoAction(row: r, col: c, oldValue: sudoku.board[r][c].value, oldNotes: sudoku.board[r][c].notes))

                                        tempSudoku.board[r][c].value = number
                                        tempSudoku.board[r][c].notes = []
                                    }
                                }
                                
                                if !isNoteModeActive && tempSudoku.board[r][c].value != 0 && !tempSudoku.isValid(row: r, col: c, num: tempSudoku.board[r][c].value) {
                                    errorCount += 1
                                }

                                sudoku = tempSudoku

                                if sudoku.isSolved() {
                                    isSolved = true
                                    errorMessage = nil
                                } else {
                                    isSolved = false
                                    errorMessage = nil
                                }
                                highlightedNumber = nil
                            }
                        }) {
                            Text("\(number)")
                                .font(.title2)
                                .frame(width: 35, height: 50)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.top, 20)

                if let error = errorMessage {
                    Text(error)
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()
            }
            .padding()
            .onAppear {
                startTimer()
                // MARK: 在 onAppear 中不再需要處理 puzzleToPlay 或 selectedDifficulty 綁定
                // 因為題目和難度已經在 init 中直接傳入
            }
            .onDisappear(perform: stopTimer)
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                if isTimerRunning {
                    timeElapsed += 1
                }
            }

            if showCompletionPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { } // 點擊背景不關閉彈窗
                
                VStack(spacing: 20) {
                    Text("挑戰成功！")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            showCompletionPopup = false
                            // 呼叫 resetGame() 將當前數獨盤清空並重置計時等狀態
                            resetGame(with: Array(repeating: Array(repeating: 0, count: 9), count: 9))
                            // 保持在數獨 Tab。ContentView 會偵測到 activeGamePuzzle 變成 nil
                            // 然後下次就會顯示 GameCreationView 讓用戶選擇新難度。
                            selectedTab = .sudoku
                        }) {
                            Text("新挑戰！")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showCompletionPopup = false
                            selectedTab = .gameHistory
                            // MARK: 返回歷史頁後也清空盤面
                            resetGame(with: Array(repeating: Array(repeating: 0, count: 9), count: 9)) // 清空盤面
                        }) {
                            Text("看結果！")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 10)
                )
                .padding(.horizontal, 40)
            }
        }
    }

    private func timeString(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func startTimer() {
        isTimerRunning = true
        if timerSubscription == nil {
            timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    if isTimerRunning {
                        timeElapsed += 1
                    }
                }
        }
    }

    private func stopTimer() {
        isTimerRunning = false
        timerSubscription?.cancel()
        timerSubscription = nil
    }
    
    // MARK: resetGame 函數更新 - 現在它只清空盤面為全零
    private func resetGame(with newPuzzle: [[Int]]? = nil) {
        // SudokuGameView 不再生成題目，所以 newPuzzle 參數主要用於外部指定一個清空盤面
        let puzzleToLoad = newPuzzle ?? Array(repeating: Array(repeating: 0, count: 9), count: 9)

        sudoku = SudokuBoard(initialBoard: puzzleToLoad) // 使用提供的題目（或全零盤）
        originalInitialBoard = puzzleToLoad // originalInitialBoard 應該是最初載入的題目，這裡可能需要根據實際情況調整

        // 重新初始化其他遊戲狀態
        selectedRow = nil
        selectedCol = nil
        isSolved = false
        errorMessage = nil
        highlightedNumber = nil
        isNoteModeActive = false
        timeElapsed = 0
        errorCount = 0
        undoStack = []
        startTimer() // 重置後重新開始計時
    }

    // 模擬計算平均時間的函數
    private func calculateAverageTime(for difficulty: String) -> Int {
        switch difficulty {
        case "簡單": return 180
        case "中等": return 300
        case "困難": return 600
        default: return 240
        }
    }

    // 模擬計算擊敗百分比的函數
    private func calculateRankPercentage(yourTime: Int, difficulty: String) -> Int {
        let avgTime = calculateAverageTime(for: difficulty)
        
        if yourTime < Int(Double(avgTime) / 2.0) {
            return Int.random(in: 95...99)
        } else if yourTime < Int(Double(avgTime) * 0.8) {
            return Int.random(in: 75...94)
        } else { // Corrected logic: anything above 80% of average time
            return Int.random(in: 10...74) // Adjusted range to cover all remaining cases
        }
    }
    
    // 新增：處理單元格點擊事件的函數
    private func handleCellTap(row: Int, col: Int) {
        if let currentRow = selectedRow, let currentCol = selectedCol, currentRow == row && currentCol == col {
            // 如果點擊了已經選中的單元格，則取消選擇
            selectedRow = nil
            selectedCol = nil
            highlightedNumber = nil
        } else {
            selectedRow = row
            selectedCol = col
            // 如果選中的單元格有值，則高亮相同的數字
            if sudoku.board[row][col].value != 0 {
                highlightedNumber = sudoku.board[row][col].value
            } else {
                highlightedNumber = nil
            }
        }
        errorMessage = nil // 清除錯誤訊息
    }
}

// CellView, NoteGridView, ActionButton 結構體保持不變
// (從您提供的程式碼中，這些部分沒有變動)

// CellView 是數獨板中每個單元格的視圖
struct CellView: View {
    let cellData: CellData // 現在接收 CellData
    let isInitial: Bool
    let isSelected: Bool
    let isConflicting: Bool // 新增屬性來標記衝突單元格
    let highlightedNumber: Int? // 新增屬性來接收高亮數字
    let inSelectedRowOrColOrBlock: Bool // 是否在選中的行、列或九宮格內
    let row: Int // 用於邊框判斷
    let col: Int // 用於邊框判斷

    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor) // 使用計算屬性來決定背景色
                .frame(width: 40, height: 40) // 固定單元格大小
            
            if cellData.value != 0 {
                Text("\(cellData.value)")
                    .font(.title2)
                    .foregroundColor(isInitial ? .black : (isConflicting ? .red : .userFilledNumber)) // 衝突時紅色，初始黑色，使用者填寫深藍色
            } else if !cellData.notes.isEmpty {
                // 顯示筆記
                NoteGridView(notes: Array(cellData.notes).sorted()) // 傳遞排序後的筆記
            }
        }
        // Apply thin borders to all sides of each cell
        .overlay(
            Rectangle()
                .stroke(Color.black.opacity(0.5), lineWidth: 0.5) // Thin border for all cells
        )
        // Add thicker right borders for every 3rd column (except the last one)
        .overlay(
            Group {
                if (col + 1) % 3 == 0 && col != 8 {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 2, height: 40) // Thicker line
                }
            }
            , alignment: .trailing
        )
        // Add thicker bottom borders for every 3rd row (except the last one)
        .overlay(
            Group {
                if (row + 1) % 3 == 0 && row != 8 {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 40, height: 2) // Thicker line
                }
            }
            , alignment: .bottom
        )
    }

    // 根據狀態計算背景色
    private var backgroundColor: Color {
        if isSelected {
            return Color.selectedCellBlue // 選中單元格 (淺藍色)
        } else if highlightedNumber != nil && cellData.value == highlightedNumber && cellData.value != 0 {
            return Color.mediumBlueHighlight // 高亮相同數字 (比選中更淺的藍色)
        } else if inSelectedRowOrColOrBlock {
            return Color.lightBlueHighlight // 選中行/列/九宮格 (最淺的藍色)
        } else {
            return Color.white // 預設白色背景
        }
    }
}

// 用於顯示筆記的 3x3 網格視圖
struct NoteGridView: View {
    let notes: [Int]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<3) { row in
                HStack(spacing: 0) {
                    ForEach(0..<3) { col in
                        let number = row * 3 + col + 1 // 1到9的數字
                        Text(notes.contains(number) ? "\(number)" : "")
                            .font(.system(size: 10)) // 較小的字體
                            .foregroundColor(.gray) // 淺灰色
                            .frame(width: 40/3, height: 40/3) // 在單元格內均勻分佈
                    }
                }
            }
        }
    }
}

// 底部操作按鈕的自定義視圖
struct ActionButton: View {
    let title: String
    let iconName: String
    var badgeCount: Int? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Image(systemName: iconName)
                        .font(.title) // 較大的圖標
                        .foregroundColor(.gray)
                    if let count = badgeCount {
                        Text("\(count)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 15, y: -15)
                    }
                }
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60) // 讓按鈕區域更大並均勻分佈
            .contentShape(Rectangle()) // 使整個區域可點擊
        }
    }
}
