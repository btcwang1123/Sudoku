import Foundation

// 用於存儲單次遊戲報告的歷史數據模型
struct ReportItem: Identifiable, Codable, Equatable {
    
    // MARK: - Stored Properties
    
    let id: UUID
    let difficulty: String
    let yourTime: Int // 單位：秒
    let errorCount: Int
    let averageTime: Int // 該難度的平均時間
    let rankPercentage: Int // 擊敗的玩家百分比
    let completionDate: Date // 完成日期
    
    // 原始題目（只包含初始數字，0表示空），用於「再玩一次」功能
    let initialPuzzle: [[Int]]
    
    // 使用者可以編輯的屬性
    var notes: String
    var rating: Int // 評分 (例如 0-5 星)
    
    // 用於 UI 顯示的狀態，不儲存到裝置中
    var isNew: Bool = false

    // MARK: - Computed Properties
    
    // 將時間（秒）格式化為 "MM:SS" 字符串
    var formattedTime: String {
        let minutes = yourTime / 60
        let seconds = yourTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 將平均時間（秒）格式化為 "MM:SS" 字符串
    var formattedAverageTime: String {
        let minutes = averageTime / 60
        let seconds = averageTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Initializer

    // 自定義初始化方法，方便創建實例並自動生成 UUID
    init(id: UUID = UUID(), difficulty: String, yourTime: Int, errorCount: Int, averageTime: Int, rankPercentage: Int, completionDate: Date, notes: String = "", rating: Int = 0, initialPuzzle: [[Int]], isNew: Bool = false) {
        self.id = id
        self.difficulty = difficulty
        self.yourTime = yourTime
        self.errorCount = errorCount
        self.averageTime = averageTime
        self.rankPercentage = rankPercentage
        self.completionDate = completionDate
        self.notes = notes
        self.rating = rating
        self.initialPuzzle = initialPuzzle
        self.isNew = isNew
    }
    
    // MARK: - Codable Conformance
    
    // 定義要編碼（儲存）的鍵。我們特意排除了 `isNew`，因為它只是暫時的UI狀態。
    enum CodingKeys: String, CodingKey {
        case id, difficulty, yourTime, errorCount, averageTime, rankPercentage, completionDate, initialPuzzle, notes, rating
    }
    
    // Equatable 協議的實現，用於判斷兩個 ReportItem 是否相等
    static func == (lhs: ReportItem, rhs: ReportItem) -> Bool {
        return lhs.id == rhs.id
    }
}
