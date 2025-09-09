//
//  PhotoSelectView.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/10.
//

import SwiftUI

struct PhotoSelectView: View {
    // 存储选中的图片
    @State private var selectedImage: UIImage?
    @State private var selectedImageName: String?
    // 控制照片选择器的显示与隐藏
    @State private var showingPhotoPicker = false

    var body: some View {
        VStack(spacing: 20) {
            // 显示选中的照片
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(10)
            } else {
                Text("未选择照片")
                    .foregroundColor(.gray)
            }

            // 点击按钮打开照片选择器
            Button("选择照片") {
                showingPhotoPicker = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        // 使用 .sheet 模态地展示 PhotoPicker
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPicker(
                selectedImage: $selectedImage,
                selectedImageName: $selectedImageName,
                showingPicker: $showingPhotoPicker
            )
        }
    }
}

#Preview {
    PhotoSelectView()
}
