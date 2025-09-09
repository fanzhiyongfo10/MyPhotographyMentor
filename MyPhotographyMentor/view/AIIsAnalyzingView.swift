//
//  AIIsAnalyzingView.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/13.
//

import SwiftUI

struct AIIsAnalyzingView: View {
    var body: some View {
        ZStack {
            Image("AIAnalyzing")
                .resizable()
//                .scaledToFit()
                .scaledToFill()
                .opacity(0.2)
            
            Color.gray.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center) {
                Spacer()
                
                VStack(alignment: .center)  {
                    Text("😀 AI is analyzing...")
//                        .padding(.top, 40)
//                        .padding(.bottom, 20)
//                        .padding(.leading, 20)
//                        .padding(.trailing,20)
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.yellow) //green
//                        .background(Color.gray)
                        .font(
                            .system(
                                .title,
                                design: .rounded
                            )
                        )
                    
                    // 显示正在进行
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(
                                tint: .yellow
                            )
                        )
                        .scaleEffect(2.0)  // 将 ProgressView 放大到原来的两倍
                        .padding(20)
//                        .padding(.top, 20)
//                        .padding(.bottom, 20)
                    //                                            .padding(20)
                    
                    Text("☕️ wait a moment")
                        .padding(20)
                    //                                            .padding(20)
//                        .padding(.top, 20)
//                        .padding(.bottom, 20)
                        .foregroundColor(.yellow)
                        .font(
                            .system(
                                .title3,
                                design: .rounded
                            )
                        )
                }
                .padding(40)
                .cornerRadius(20)
                .background(Color.gray.opacity(0.6))
                .frame(maxWidth: .infinity)
                
            } // VStack(alignment: .center) {
        }
    }
}

#Preview {
    AIIsAnalyzingView()
}
