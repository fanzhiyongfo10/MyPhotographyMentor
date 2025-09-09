//
//  RatingView.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/14.
//

import SwiftUI

struct RatingView: View {
    // 绑定到父视图的变量，用于存储和更新评分
    @Binding var rating: Int
    var starColor: Color = Color.orange.opacity(0.7)//yellow
    
    // 星星总数
    var maxRating: Int = 5
    
    var body: some View {
        HStack(spacing: 4) {
            // 遍历所有星星
            ForEach(1...maxRating, id: \.self) { star in
                // 根据 rating 决定星星的图标
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: 24))
                    .foregroundStyle(starColor)
                    // 当点击星星时，更新 rating 的值
                    .onTapGesture {
                        self.rating = star
                    }
            }
        }
    }
}

import SwiftUI
import SwiftData

struct RecordDetailViewWithRating: View {
    let record: PhotoAnalysisRecord
    
    // 使用 @State 管理当前评分，缺省为 0 星
    @State private var currentRating: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 你的照片显示代码
            // ...
            
            // 星级评价区域
            VStack(alignment: .leading) {
                Text("星级评价")
                    .font(.headline)
                
                // 你的自定义星级视图
                RatingView(rating: $currentRating)
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("分析详情")
        // 这里你可以根据需要，从数据库加载之前保存的评分
        .onAppear {
            // 示例：从数据库加载历史评分
            // self.currentRating = record.rating
        }
    }
}
