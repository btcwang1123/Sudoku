import SwiftUI

struct GameReportDetailView: View {
    @Binding var report: ReportItem // 修改為 @Binding，以便在詳情頁編輯並傳遞更改
    @Binding var selectedTab: TabSelection // 用於切換 Tab
    @Binding var puzzleToReplay: [[Int]]? // 用於通知 SudokuGameView 播放新題目
    let onDismiss: () -> Void // 用於關閉本 sheet

    @FocusState private var isNotesFocused: Bool // 用於控制 TextEditor 的焦點

    // 將複雜的單元格繪製邏輯提取到一個獨立的 View
    private struct CellViewForReport: View {
        let value: Int
        let row: Int
        let col: Int

        var body: some View {
            Text(value == 0 ? "" : "\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: 30, height: 30) // 小一點的單元格
                .background(Color.gray.opacity(0.1))
                .overlay(
                    Rectangle()
                        .stroke(Color.black.opacity(0.5), lineWidth: 0.5)
                )
                .overlay(alignment: .trailing) { // 使用 alignment 參數簡化
                    if (col + 1) % 3 == 0 && col != 8 {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 1.5, height: 30)
                    }
                }
                .overlay(alignment: .bottom) { // 使用 alignment 參數簡化
                    if (row + 1) % 3 == 0 && row != 8 {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 30, height: 1.5)
                    }
                }
        }
    }

    // 用於顯示題目板（不含用戶填寫的數字，只顯示初始提示數字）
    private var simplePuzzleBoard: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(0..<9) { row in
                GridRow {
                    ForEach(0..<9) { col in
                        CellViewForReport(
                            value: report.initialPuzzle[row][col],
                            row: row,
                            col: col
                        )
                    }
                }
            }
        }
        .border(Color.black, width: 2)
        .padding(.top, 10)
    }

    var body: some View {
        // 使用 NavigationView 包裹整個內容，以便管理導航欄
        NavigationView {
            // 使用 ScrollView 確保內容可滾動，防止內容被截斷
            ScrollView {
                VStack(spacing: 20) {
                    Text("遊戲報告詳情")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("難度:")
                                .font(.headline)
                            Spacer()
                            Text(report.difficulty)
                                .font(.body)
                        }
                        HStack {
                            Text("作答時間:")
                                .font(.headline)
                            Spacer()
                            Text(report.formattedTime)
                                .font(.body)
                        }
                        HStack {
                            Text("錯誤數量:")
                                .font(.headline)
                            Spacer()
                            Text("\(report.errorCount) 個")
                                .font(.body)
                                .foregroundColor(report.errorCount > 0 ? .red : .primary)
                        }
                        Divider()
                        HStack {
                            Text("平均時間 (\(report.difficulty) 難度):")
                                .font(.headline)
                            Spacer()
                            Text(report.formattedAverageTime)
                                .font(.body)
                        }
                        HStack {
                            Text("您領先於:")
                                .font(.headline)
                            Spacer()
                            Text("\(report.rankPercentage)% 的玩家")
                                .font(.body)
                                .foregroundColor(report.rankPercentage >= 75 ? .green : .primary)
                        }
                        HStack {
                            Text("完成日期:")
                                .font(.headline)
                            Spacer()
                            Text(report.completionDate, style: .date)
                                .font(.body)
                        }
                        // 備註輸入框 - 現在可編輯
                        VStack(alignment: .leading) {
                            Text("備註:")
                                .font(.headline)
                            TextEditor(text: $report.notes) // 綁定到 report.notes，使其可編輯
                                .frame(height: 80) // 稍微增加高度
                                .border(Color.gray.opacity(0.3), width: 1)
                                .cornerRadius(5)
                                .focused($isNotesFocused) // 綁定焦點狀態
                                .overlay(
                                    // 在備註為空時顯示提示文字
                                    Text(report.notes.isEmpty && !isNotesFocused ? "Add notes here..." : "")
                                        .foregroundColor(.placeholderText)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 12)
                                        .allowsHitTesting(false) // 讓點擊事件穿透到 TextEditor
                                        .opacity(report.notes.isEmpty ? 1 : 0),
                                    alignment: .topLeading
                                )
                                .toolbar { // 添加鍵盤工具列，用於隱藏鍵盤
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("完成") {
                                            isNotesFocused = false
                                        }
                                    }
                                }
                        }
                        // 評分顯示與編輯
                        HStack {
                            Text("評分:")
                                .font(.headline)
                            Spacer()
                            HStack(spacing: 2) {
                                ForEach(0..<5) { star in
                                    Image(systemName: star < report.rating ? "star.fill" : "star")
                                        .font(.body)
                                        .foregroundColor(.yellow)
                                        // 點擊手勢：更新評分
                                        .onTapGesture {
                                            // 如果點擊已經發光的星星，則取消評分 (設為0)
                                            // 否則，將評分設為點擊的星星數 + 1
                                            report.rating = (star + 1 == report.rating) ? 0 : (star + 1)
                                        }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding(.horizontal) // 保持 VStack 內容的水平間距

                    Text("原始題目:")
                        .font(.headline)
                    simplePuzzleBoard // 顯示原始題目

                    // "再玩一次" 和 "分享" 按鈕
                    HStack(spacing: 20) {
                        Button(action: {
                            puzzleToReplay = report.initialPuzzle // 設置要重玩的題目
                            selectedTab = .sudoku // 切換到數獨遊戲 Tab
                            onDismiss() // 關閉本詳情頁
                        }) {
                            Label("再玩一次", systemImage: "arrow.counterclockwise.circle.fill")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(15)
                        }

                        ShareLink(item: generateShareText(report: report)) {
                            Label("分享", systemImage: "square.and.arrow.up.fill")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20) // 確保底部按鈕有足夠的下邊距
                }
                .padding(.top) // 為整個 ScrollView 內容提供頂部邊距
            }
            .navigationTitle("") // 清除 NavigationBar 上的默認標題
            .toolbar { // 使用 toolbar 替換 navigationBarItems 和 navigationBarHidden
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("關閉") {
                        onDismiss() // 點擊關閉按鈕，關閉 sheet
                    }
                }
            }
            // 處理鍵盤的安全區域，讓鍵盤不會遮擋內容
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }

    // 生成分享文本
    private func generateShareText(report: ReportItem) -> String {
        return """
        我剛剛完成了一個【\(report.difficulty)】難度的數獨！
        時間：\(report.formattedTime)
        錯誤：\(report.errorCount) 個
        擊敗了 \(report.rankPercentage)% 的玩家！
        #數獨挑戰 #SudokuGame
        """
    }
}

// MARK: - GameReportDetailView_Previews

struct GameReportDetailView_Previews: PreviewProvider {
    @State static var previewSelectedTab: TabSelection = .sudoku
    @State static var previewPuzzleToReplay: [[Int]]? = nil
    
    // 預覽用的 ReportItem，用於測試 GameReportDetailView
    @State static var sampleReport = ReportItem(
        difficulty: "中等",
        yourTime: 280,
        errorCount: 1,
        averageTime: 300,
        rankPercentage: 65,
        completionDate: Date().addingTimeInterval(-3600*24*3),
        notes: "這題中間很卡，但最後還是解出來了！不錯的挑戰。",
        rating: 4,
        initialPuzzle: [
            [5, 3, 4, 6, 7, 8, 9, 1, 2],
            [6, 7, 2, 1, 9, 5, 3, 4, 8],
            [1, 9, 8, 3, 4, 2, 5, 6, 7],
            [8, 5, 9, 7, 6, 1, 4, 2, 3],
            [4, 2, 6, 8, 5, 3, 7, 9, 1],
            [7, 1, 3, 9, 2, 4, 8, 5, 6],
            [9, 6, 1, 5, 3, 7, 2, 8, 4],
            [2, 8, 7, 4, 1, 9, 6, 3, 0],
            [3, 0, 0, 0, 0, 0, 0, 0, 0]
        ]
    )

    static var previews: some View {
        GameReportDetailView(
            report: $sampleReport, // 傳遞綁定，以便在預覽中模擬編輯
            selectedTab: $previewSelectedTab,
            puzzleToReplay: $previewPuzzleToReplay,
            onDismiss: { }
        )
        .previewDisplayName("Game Report Detail")
    }
}

// 為了 TextEditor 的 placeholderText
extension Color {
    static var placeholderText: Color {
        Color(.placeholderText)
    }
}
