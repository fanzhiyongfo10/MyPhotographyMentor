//
//  PreAIResponse.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/12.
//

import SwiftUI
import UIKit

// AI响应的预设
struct PreAIResponse: View {
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) // 预设
        {
            VStack( // 第一部分
                alignment: .leading,
                spacing: 0
            ) {
                Text(
                    "Professional Photography Analysis & Evaluation"
                )
                .padding(8)
                .font(
                    .system(
                        .title2,
                        design: .rounded
                    )
                )
                .foregroundColor(.blue)

                Text("1. Composition")
                    .padding(8)
                    .font(
                        .system(
                            .title3,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.indigo)

                Text("2. Lighting")
                    .padding(8)
                    .font(
                        .system(
                            .title3,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.indigo)

                Text("3. Subject Matter")
                    .padding(8)
                    .font(
                        .system(
                            .title3,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.indigo)

                Text("4. Technical Execution")
                    .padding(8)
                    .font(
                        .system(
                            .title3,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.indigo)

            }  // VStack(alignment: .leading, spacing: 0)
            .padding(8)

            VStack( // 第二部分
                alignment: .leading,
                spacing: 0
            ) {
                Text(
                    "Expert Suggestion for Improvement"
                )
                .padding(8)
                .font(
                    .system(
                        .title2,
                        design: .rounded
                    )
                )
                .foregroundColor(.blue)

                Text(
                    "1. Compositional Refinements"
                )
                .padding(8)
                .font(
                    .system(
                        .title3,
                        design: .rounded
                    )
                )
                .foregroundColor(.indigo)

                Text("2. Lighting Enhancements")
                    .padding(8)
                    .font(
                        .system(
                            .title3,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.indigo)

                Text(
                    "3. Technical & Post-Processing Adjustments"
                )
                .padding(8)
                .font(
                    .system(
                        .title3,
                        design: .rounded
                    )
                )
                .foregroundColor(.indigo)

                Text("4. Creative Exploration")
                    .padding(8)
                    .font(
                        .system(
                            .title3,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.indigo)
            }  // VStack(alignment: .leading, spacing: 0) // 第二部分
        }  // VStack(alignment: .leading, spacing: 0) { // 预设
            
            
        
    }
}

#Preview {
    PreAIResponse()
}
