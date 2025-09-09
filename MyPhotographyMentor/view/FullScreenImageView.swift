//
//  FullScreenImageView.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/12.
//

import SwiftUI

// MARK: - Full Screen Image View
struct FullScreenImageView: View {
    let image: UIImage
    @Binding var isPresented: Bool

    // State variables to manage gestures
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @State private var finalOffset: CGSize = .zero

    var body: some View {
        ZStack {
            // Background to handle taps
            Color.black
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false  // 点击任意位置退出全屏
                }

            VStack {
                // The full-screen image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .offset(
                        x: finalOffset.width + currentOffset.width,
                        y: finalOffset.height + currentOffset.height
                    )
                    .scaleEffect(max(1.0, finalScale * currentScale))
                    .onTapGesture {
                        isPresented = false  // 点击任意位置退出全屏
                    }
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                self.currentScale = value
                            }
                            .onEnded { value in
                                self.finalScale *= value
                                self.currentScale = 1.0
                            }
                            .simultaneously(
                                with:
                                    DragGesture()
                                    .onChanged { value in
                                        self.currentOffset = value.translation
                                    }
                                    .onEnded { value in
                                        self.finalOffset.width +=
                                            value.translation.width
                                        self.finalOffset.height +=
                                            value.translation.height
                                        self.currentOffset = .zero
                                    }
                            )
                    )
                // Tap anywhere to exit, or use gestures to zoom and drag.
                // 点击任意位置退出，或使用手势缩放和拖动
                Text("Tap anywhere to exit, or use gestures to zoom and drag.")
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top)
            }
            //            .padding()
        }
    }
}

#Preview {
    @Previewable @State var showingPhotoPicker = false
    var image : UIImage = UIImage(imageLiteralResourceName: "peony")
    
    FullScreenImageView(image: image, isPresented: $showingPhotoPicker)
}
