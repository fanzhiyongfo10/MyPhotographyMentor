//
//  HistoryReviewView.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/9.
//

import SwiftUI
import SwiftData

// 为了分割线，套装一层
struct HistoryReviewView: View {
    var body: some View {

        VStack(spacing: 0) {
            // 分割线
            Divider()
            PhotoReviewListView()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationTitle("Photo Review List")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            
        }
    } // var body: some View {
}

#Preview {
    HistoryReviewView()
}
