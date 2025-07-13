import SwiftUI

struct GameHistoryView: View {
    @Binding var gameHistory: [ReportItem]
    @Binding var selectedTab: TabSelection
    @Binding var puzzleToReplay: [[Int]]?
    
    // (修改) 簡化狀態管理：只需一個 state 來保存當前選擇的報告即可
    @State private var selectedReport: ReportItem?

    var body: some View {
        NavigationView {
            // (修改) 使用 ZStack 和 Color 來設置背景色，讓 List 的 plain 樣式更好看
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                List {
                    if gameHistory.isEmpty {
                        Text("目前沒有遊戲歷史紀錄。\n快去玩一局來看看你的報告吧！") // (修改) 中文化提示
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(gameHistory.indices, id: \.self) { index in
                            // 使用 index 找到對應的 report item 的綁定
                            HistoryRowView(report: $gameHistory[index], displayIndex: gameHistory.count - index)
                                .onTapGesture {
                                    self.selectedReport = gameHistory[index]
                                }
                        }
                        .onDelete(perform: deleteItems)
                        .listRowSeparator(.hidden) // 隱藏分隔線
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)) // 調整邊距
                        .listRowBackground(Color.clear) // 讓自定義卡片背景生效
                    }
                }
                .listStyle(.plain)
                .navigationTitle("遊戲歷史")
            }
            .sheet(item: $selectedReport) { report in
                // (修改) 這裡需要一個方法來找到原始的綁定
                // 因為 selectedReport 是一個副本，我們需要找到 gameHistory 中的原始項目來綁定
                if let index = gameHistory.firstIndex(where: { $0.id == report.id }) {
                    GameReportDetailView(
                        report: $gameHistory[index], // 將綁定傳遞給詳情頁
                        selectedTab: $selectedTab,
                        puzzleToReplay: $puzzleToReplay,
                        onDismiss: {
                            selectedReport = nil // 關閉 sheet 時重置
                        }
                    )
                }
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        gameHistory.remove(atOffsets: offsets)
    }
}

// MARK: - HistoryRowView (將列表項提取為獨立的 View)

struct HistoryRowView: View {
    @Binding var report: ReportItem
    let displayIndex: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // 1. 難易度標籤
            DifficultyBadgeView(difficulty: report.difficulty)

            // 2. 主要資訊 (垂直排列)
            VStack(alignment: .leading, spacing: 6) {
                // 第一行：時間 & 錯誤
                HStack {
                    Image(systemName: "clock")
                    Text(report.formattedTime)
                    Spacer()
                    Image(systemName: "xmark.circle")
                    Text("\(report.errorCount) 次錯誤")
                        .foregroundColor(report.errorCount > 0 ? .red : .secondary)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                // 第二行：備註 (如果有的話)
                if !report.notes.isEmpty {
                    Text(report.notes)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }

                // 第三行：評分 & 日期
                HStack {
                    RatingView(rating: report.rating)
                    Spacer()
                    Text(relativeDateString(from: report.completionDate))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // 4. 導航箭頭
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // (新增) 相對日期格式化函數
    private func relativeDateString(from date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今天"
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_Hant_TW") // 台灣中文
            formatter.dateFormat = "M月d日"
            return formatter.string(from: date)
        }
    }
}


// MARK: - DifficultyBadgeView (修改後的版本)

struct DifficultyBadgeView: View {
    let difficulty: String

    var body: some View {
        ZStack {
            Circle()
                .fill(difficultyColor(difficulty).gradient) // 使用漸層色更好看
                .frame(width: 48, height: 48)
                .shadow(color: difficultyColor(difficulty).opacity(0.4), radius: 3, y: 2)

            Text(difficultyShortForm(difficulty))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }

    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "簡單": return .green
        case "中等": return .orange
        case "困難": return .red
        default: return .gray
        }
    }
    
    private func difficultyShortForm(_ difficulty: String) -> String {
        return String(difficulty.prefix(1)) // (修改) 直接取第一個字，例如 "簡"
    }
}

// MARK: - RatingView (新增的輔助 View)

struct RatingView: View {
    let rating: Int
    
    var body: some View {
        HStack(spacing: 2) {
            if rating > 0 {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
        }
    }
}
