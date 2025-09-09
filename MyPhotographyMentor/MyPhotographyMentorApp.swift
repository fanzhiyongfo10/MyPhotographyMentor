//
//  MyPhotographyMentorApp.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/9.
//

import SwiftUI
import SwiftData

/**
 * # 使用SwiftData
 */
@main
struct MyPhotographyMentorApp: App {
    var body: some Scene {
        WindowGroup {
            // 在这里放置你的主视图
            ContentView()
        }
        // 使用 .modelContainer 初始化 SwiftData
        .modelContainer(for: PhotoAnalysisRecord.self)
    }
    
}

/* core data
@main
struct MyPhotographyMentorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            // 在这里放置你的主视图
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
}
*/

/*
import SwiftUI
import SwiftData

@main
struct MyPhotographyMentorApp: App {
    var body: some Scene {
        WindowGroup {
            // 在这里放置你的主视图，例如 AnalysisListView()
            AnalysisListView()
        }
        // 使用 .modelContainer 初始化 SwiftData
        .modelContainer(for: PhotoAnalysisRecord.self)
    }
}
*/
