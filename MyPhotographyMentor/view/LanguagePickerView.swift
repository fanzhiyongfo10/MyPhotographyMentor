//
//  LanguagePickerView.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/16.
//

import SwiftUI

struct LanguagePickerView: View {
//    @Environment(AppState.self) private var appState
    @State private var appState: AppState
    @Environment(\.dismiss) var dismiss // 用于关闭视图
//    \($appState.photoAnalysisState.selectedLanguage)
    
    let languages = ["English", "中文", "Español", "Français", "Deutsch", "Português", "日本語", "한국어"] // 语言列表

    init(appState: AppState) {
        self._appState = State(wrappedValue: appState)
    }
    
    var body: some View {
        List(languages, id: \.self) { language in
            Button(action: {
                appState.photoAnalysisState.selectedLanguage = language
                appState.photoAnalysisState.isShowingLanguagePicker = false
                dismiss() // 关闭当前弹窗
            }) {
                HStack {
                    Text(language)
                        .foregroundStyle(.primary)
                    Spacer()
                    if language == appState.photoAnalysisState.selectedLanguage {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .navigationTitle("Select AI Response Language")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}
