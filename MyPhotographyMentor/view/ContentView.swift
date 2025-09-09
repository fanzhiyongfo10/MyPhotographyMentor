//
//  ContentView.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/9.
//

import CoreData
import SwiftUI

// 创建一个可观察的视图模型，用于保存视图状态
// 注意：这个模型应该包含你需要保留的所有状态
// 关键：在这里使用 @Observable 宏
@Observable
class AppState {
    var photoAnalysisState: PhotoAnalysisState = PhotoAnalysisState()
}

// 菜单项，使用 Enum 来管理，更易于维护
enum MenuItem: String, CaseIterable, Identifiable, Hashable {
    case home = "Home"
    case photoAnalysis = "Photo Analysis"
    case photoEnhancement = "Photo Enhancement"
    case historyReview = "Photo Review"

    var id: String { self.rawValue }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .photoAnalysis: return "photo"
        case .photoEnhancement: return "wand.and.sparkles.inverse"
        case .historyReview: return "photo.stack.fill"
        }
    }
}

struct ContentView: View {
    // 使用 @State 来持有整个应用的状态，确保其生命周期与视图相同
    @State private var appState = AppState()
    
    var body: some View {
        NavigationView {
            // Sidebar
            List {
                // HomeView
                NavigationLink(destination: HomeView(appState: appState)) {
                    Label("Home", systemImage: "house.fill")
                }
                NavigationLink(destination: PhotoAnalysisView(appState: appState)) {
                    Label("Photo Analysis", systemImage: "text.below.photo")
                }
                NavigationLink(destination: PhotoEnhancementView()) {
                    Label(
                        "Photo Enhancement",
                        systemImage: "wand.and.sparkles.inverse"
                    )
                }
                NavigationLink(destination: HistoryReviewView()) {  //HistoryReviewView
                    Label("Photo Review", systemImage: "photo.badge.checkmark")
                        .symbolRenderingMode(.multicolor)
                }
            }
            .navigationTitle("Menu")
            // 这是关键部分：将标题显示模式设置为紧凑
            .navigationBarTitleDisplayMode(.inline)

            // 照片分析
            HistoryReviewView()

        }
    }  // var body: some View {
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView()
}
