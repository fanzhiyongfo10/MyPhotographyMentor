//
//  HomeView.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/9.
//

import SwiftUI

struct HomeView: View {
    @State private var appState: AppState
    // 构造函数，确保可以接收 AppState
    init(appState: AppState) {
        self._appState = State(wrappedValue: appState)
    }

    // 文字格式化
    @StateObject private var viewModel = TextFileViewModel()

    // 2. 照片全屏显示
    // 2.1)全屏显示控制变量
    @State private var showingFullScreenImage = false

    var body: some View {

        VStack {
            // 添加分隔线
            Divider()
            VStack {
                HStack {
                    VStack {
                        Text("Quickly Improve Your Photography Skills") // 快速提升你的摄影能力
                            .font(.title2)
                        HStack {
                            Text("(Photography + Editing)") //（拍照+后期）
                                .font(.headline)
//                                .padding(4)  // 添加 padding 以增加点击区域
                                .padding([.top, .bottom], 4)
                                .padding([.leading, .trailing], 8)
                            Text("(Photographic Eye)") // （摄影眼）
                                .font(.headline)
                                .padding([.top, .bottom], 4)
                                .padding([.leading, .trailing], 8)
                        }
                    }
                    //                    .padding(20)
                    .frame(maxWidth: .infinity)
                    //                    .frame(maxHeight: .infinity)

                    VStack {
                        Text("Flollow Two Steps") //两步法
                            .font(.title2)
                        
                        HStack {
                            NavigationLink(destination: PhotoAnalysisView(appState: appState)) {
                                Text("-1- Photo Analysis (World-Class)") //-1- 照片分析（世界级）
                                    .font(.headline)
//                                    .padding(4)  // 添加 padding 以增加点击区域
                                    .padding([.top, .bottom], 4)
                                    .padding([.leading, .trailing], 8)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
//                            Spacer()
                            
                            Text("-2- Actions") // -2- 接受建议，实战演练
                                .font(.headline)
//                                .padding(4)  // 添加 padding 以增加点击区域
                                .padding([.top, .bottom], 4)
                                .padding([.leading, .trailing], 8)
                        }
                    }
                    //                    .padding(20)
                    .frame(maxWidth: .infinity)
                    //                    .frame(maxHeight: .infinity)
                }
                .padding(4)

                HStack {
                    VStack {
                        ZStack(alignment: .topLeading) {
                            Image("peony")
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(20)
                                .onTapGesture {
                                    // 2.2）当用户点击照片时，显示全屏视图
                                    self.showingFullScreenImage = true
                                }

                            Text("Sample Photo")
                                .font(.largeTitle)
                                .background(Color.gray)
                                .foregroundColor(.white)
                        }

                        Text(
                            // 点击照片->全屏显示
                            "Click on the photo -> Full screen"
                        )
                        .foregroundColor(.gray)

                        Spacer()
                        VStack {
                            Text("Photos, shot with a phone, DSLR, or other camera.") // 你一定有大量照片，拍摄设备可能有手机、单反相机、微单等。
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Analyze them, and get world-class, professional guidance.") //选择一些照片，进行分析，一定会给你世界级水平的专业指导意见。
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Composition, lighting, subject matter, technique, and editing.") //包括但不限于构图、用光、主体、技术、后期等。
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        //                        Spacer()
                    }
                    //                    .background(Color.red)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)

                    VStack {
                        ScrollView {
                            //                            Text(textContent)
                            VStack(alignment: .leading, spacing: 10) {
                                if let att = viewModel.attributedContent {
                                    Text(att)
                                        .lineSpacing(5)
                                } else {
                                    Text(textContent)
                                        .lineSpacing(5)
                                }

                            }
                            .padding()
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(10)
                        }

                    }
                    //                    .background(Color.green)
                    .background(Color.gray.opacity(0.1))  // 用背景色来可视化效果
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .cornerRadius(20)
                }
                //                .background(Color.green)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .cornerRadius(20)
                .padding(.horizontal, 10)
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .navigationTitle("My Photography Mentor")
        .navigationBarTitleDisplayMode(.inline)
        // 关键点：使用 .onAppear() 在视图出现时触发数据加载
        .onAppear {
            viewModel.renderMarkdown(textContent)
        }
        // 2.3）全屏显示，Present the full-screen image as a fullScreenCover.
        .fullScreenCover(isPresented: $showingFullScreenImage) {

            FullScreenImageView(
                image: UIImage(imageLiteralResourceName: "peony"),
                isPresented: $showingFullScreenImage
            )
        }
    }
}

//#Preview {
//    HomeView()
//}
