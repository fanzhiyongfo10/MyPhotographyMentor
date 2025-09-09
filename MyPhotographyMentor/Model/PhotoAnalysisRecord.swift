//
//  PhotoAnalysisRecord.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/13.
//

import Foundation
import Photos
import PhotosUI
import SwiftData
import SwiftUI
import UIKit

/**
 * #照片记录
 在SwiftUI中，存取照片分析记录，包括照片的ID、分析结果的文件名（txt文本文件）、分析时间等，请给出方案和建议

 ====好的，这是一个在SwiftUI中存储和访问照片分析记录的方案和建议。

 * #方案概述

 要实现您的需求，您需要处理两类数据：
 1.   **结构化数据**： 照片ID、分析结果文件名、分析时间。这类数据适合存储在数据库中，以便于查询和管理。
 2 .  **非结构化数据**： 实际的分析结果内容（txt文本）。这类数据适合作为文件存储在应用的沙盒目录中。
 我们将使用 SwiftData （如果您的项目支持 iOS 17+）或 Core Data 来存储结构化数据，并使用 FileManager 来管理文本文件。

 * **推荐方案：使用 SwiftData**

 * SwiftData 是 Apple 在 iOS 17 引入的，专为 SwiftUI设计的现代化数据持久化框架。它简单、强大，是存储这类记录的最佳选择。
 */

/**
 * #建议和注意事项
 * 1.   **照片ID的重要性：** 您之前提到了照片文件名，但如前所述，**照片的本地标识符（localIdentifier）**是唯一可靠的ID，因为它不会因照片库中的编辑或移动而改变。请确保您保存的是此ID。
 * 在 PHPickerResult 中，assetIdentifier 为 nil 是一个常见情况，通常是因为用户选择了非照片库中的项目，例如从 iCloud 共享相册或流媒体服务中选择的图片。
 * 为什么 assetIdentifier 会是 nil？
 assetIdentifier 是 PHAsset 的唯一标识符。一个 PHAsset 对象代表了本地照片库中的一个媒体资源（如照片或视频）。

 当用户通过 PHPickerViewController 选择照片时，如果该图片：

 是从 iCloud 照片库中下载但尚未完全同步到本地。

 仅作为 iCloud 共享相册中的预览。

 是从其他应用（如文件或第三方云服务）导入到 PHPicker 视图中的。

 甚至是动态生成的 live photo 的部分（PHAsset 仅代表整体）。

 在这些情况下，PHPickerResult 可能不与本地 PHAsset 直接关联，因此 assetIdentifier 为 nil。
 * # 解决方案
 要解决这个问题，你需要将 PHPickerResult 作为唯一的标识来保存，或者从它获取图片数据本身。

 * # 将 PHPickerResult 本身保存到数据库（推荐）
 PHPickerResult 对象包含了足够的信息来在将来重新加载图片。你可以直接将其数据（例如 itemProvider）序列化后保存，但这个方法比较复杂。

 更简单、更可靠的方式是：不要依赖于 assetIdentifier。PHPickerResult 提供了 itemProvider，你可以通过它来获取图片数据，并将图片数据保存到你的应用沙盒中。

 * #保存图片到应用沙盒的方案：

 * # 为什么这个方案更好？

 * **可靠性高**： 它不依赖于 PHAsset 的存在，无论是从照片库、iCloud 还是其他来源，只要是图片，都能被正确处理。

 * **数据独立**： 图片数据被保存到你的应用沙盒中，即使原始照片在用户的照片库中被删除，你保存的数据仍然存在。

 * **简化逻辑**： 你只需在数据库中存储一个文件名（UUID().uuidString），而不是复杂的 PHPickerResult 对象。

 *
  * 2.   **SwiftData 的配置：** 在您的 App 主文件中，不要忘记添加 modelContainer 修饰符来初始化 SwiftData。
  * 3.  **UI 线程与后台任务：** 文件读写和数据库操作都应在后台线程进行，以避免阻塞 UI。SwiftData 的 @Query 已经为您处理了后台加载，但对于手动调用保存和读取函数，最好在 Task { ... } 中执行。

  * 4.  **文件管理：** 随着记录的增加，Documents 目录下的文件会越来越多。在删除数据库中的记录时，也应一并删除对应的 .txt 文件，以避免占用过多存储空间。

  * 5.  **错误处理：** 在实际应用中，务必对文件读写和数据库操作进行健壮的错误处理，例如使用 do-catch 块来捕获可能出现的异常。
 */

/// #首先，定义一个用于存储分析记录的 SwiftData 模型。
@Model
final class PhotoAnalysisRecord {
    // 存储照片，jpg
    var photoFileName: String

    // 存储分析结果的 txt 文件名
    var analysisFileName: String

    // 学习心得体会（备注）
    var studyNote: String

    // 分析时间
    var analysisTime: Date

    // 评分
    var currentPhotoRating: Int
    var currentAnalysisRating: Int
    
    // AI 响应语言
    var selectedLanguage: String

    init(
        photoFileName: String,
        analysisFileName: String,
        studyNote: String,
        currentPhotoRating: Int,
        currentAnalysisRating: Int,
        analysisTime: Date,
        selectedLanguage: String
    ) {
        self.photoFileName = photoFileName
        self.analysisFileName = analysisFileName
        self.studyNote = studyNote
        self.currentPhotoRating = currentPhotoRating
        self.currentAnalysisRating = currentAnalysisRating
        self.analysisTime = analysisTime
        self.selectedLanguage = selectedLanguage
    }
}

/// *# 其次，当您完成照片分析后，执行以下步骤来保存数据：
/// *1   **将分析结果保存到文件**： 在应用的 Documents 目录下创建一个唯一的文件名，并将分析结果文本写入。
/// *2   **将记录保存到数据库**： 创建 PhotoAnalysisRecord 实例，并将其添加到 SwiftData 上下文。
/// *
@MainActor
func saveAnalysisRecord(
    photoImage: UIImage,
    analysisText: String,
    studyNote: String,
    currentPhotoRating: Int,
    currentAnalysisRating: Int,
    selectedLanguage: String,
    modelContext: ModelContext
) {
    // 0.1 准备 获取 png、或jpg 格式的图片数据
    var imageData: Data?
    var photoFileExt: String = ".png"

    if let tmp = photoImage.pngData() {
        imageData = tmp
    } else if let tmp = photoImage.jpegData(compressionQuality: 0.8) {
        imageData = tmp
        photoFileExt = ".jpg"
    }

    if imageData == nil {
        return
    }

    // 0.2 唯一ID
    let idString = UUID().uuidString

    // 1.1 生成唯一的 txt 文件名
    let analysisFileName = idString + ".txt"
    // 1.2. 生成唯一的 图片 文件名
    let photoFileName = idString + photoFileExt

    // 2. 获取文档目录路径
    let analysisFileURL = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )[0].appendingPathComponent(analysisFileName)

    let photoFileURL = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )[0].appendingPathComponent(photoFileName)

    do {
        // 3. 将分析文本写入文件
        try imageData!.write(to: photoFileURL)
        print("photoFileURL，保存成功")

        try analysisText.write(
            to: analysisFileURL,
            atomically: true,
            encoding: .utf8
        )
        print("analysisFileURL，保存成功")

        // 4. 获取 SwiftData 上下文
        //        let modelContext = try ModelContainer(for: PhotoAnalysisRecord.self)
        //            .mainContext

        // 5. 创建并保存记录到数据库
        let record = PhotoAnalysisRecord(
            photoFileName: photoFileName,
            analysisFileName: analysisFileName,
            studyNote: studyNote,
            currentPhotoRating: currentPhotoRating,
            currentAnalysisRating: currentAnalysisRating,
            analysisTime: Date(),
            selectedLanguage: selectedLanguage
        )
        modelContext.insert(record)
        try modelContext.save()

        print("记录保存成功：\(record.analysisFileName)")
    } catch {
        print("保存失败: \(error.localizedDescription)")
    }
}

/// 将 UIImage 保存为无损 PNG 文件到应用的文档目录。
///
/// - Parameters:
///   - image: 要保存的 UIImage 对象。
///   - fileName: 要保存的文件名（不含扩展名）。
/// - Returns: 保存成功后的文件路径，如果失败则返回 nil。
func saveImageAsPNG(image: UIImage, fileName: String) -> URL? {
    // 1. 获取 PNG 格式的图片数据
    guard let imageData = image.pngData() else {
        print("无法将图片转换为 PNG 数据。")
        return nil
    }

    // 2. 获取文档目录路径
    let fileManager = FileManager.default
    guard
        let documentsDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
    else {
        print("无法访问文档目录。")
        return nil
    }

    // 3. 构建完整的图片文件路径
    let fileURL = documentsDirectory.appendingPathComponent(fileName)
        .appendingPathExtension("png")

    // 4. 写入文件
    do {
        try imageData.write(to: fileURL)
        print("图片已成功保存为 PNG：\(fileURL.path)")
        return fileURL
    } catch {
        print("保存图片失败：\(error.localizedDescription)")
        return nil
    }
}

func saveImageFromPickerResult(item: PHPickerResult) {
    // 1. 获取 itemProvider
    let itemProvider = item.itemProvider

    // 2. 检查是否可加载图片类型
    guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
        print("该项目不是图片类型，无法加载。")
        return
    }

    // 3. 异步加载图片
    itemProvider.loadObject(ofClass: UIImage.self) { image, error in
        DispatchQueue.main.async {
            if let uiImage = image as? UIImage {
                // 4. 将图片数据保存到文件
                if let data = uiImage.jpegData(compressionQuality: 0.8) {
                    let fileName = UUID().uuidString + ".jpg"
                    let fileURL = FileManager.default.urls(
                        for: .documentDirectory,
                        in: .userDomainMask
                    )[0].appendingPathComponent(fileName)

                    do {
                        try data.write(to: fileURL)
                        print("图片已保存到文件：\(fileName)")

                        // 5. 在这里，你可以将这个文件名保存到你的数据库中
                        // databaseManager.save(imageFileName: fileName)

                    } catch {
                        print("保存图片到文件失败：\(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

// 这是一个帮助函数，用于从应用沙盒中加载图片
private func loadImageFromFile(fileName: String) -> UIImage? {
    let fileURL = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )[0].appendingPathComponent(fileName)
    return UIImage(contentsOfFile: fileURL.path)
}
/*
struct AnalysisListView: View {
    // 自动从 SwiftData 数据库中获取所有记录，按时间倒序排列
    @Query(sort: \PhotoAnalysisRecord.analysisTime, order: .reverse) private
        var records: [PhotoAnalysisRecord]

    // 一个用于格式化时间的 DateFormatter
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        //        NavigationStack {
        // 表头
        List {
            // 表头
            //            Section {
            //                HStack {
            //                    Text("照片").bold()
            //                    Spacer()
            //                    Text("分析时间").bold()
            //                }
            //            }
            // 第一个 Section 的表头会固定
            Section(header: Text("照片分析记录").font(.headline)) {

                // 列表内容
                ForEach(records) { record in
                    NavigationLink {
                        // 点击后跳转到详细页面
                        RecordDetailView(record: record)
                    } label: {
                        HStack {
                            // 照片图标
                            if let uiImage = loadImageFromFile(
                                fileName: record.photoFileName
                            ) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    //                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 8)
                                    )
                            } else {
                                // 如果图片文件不存在，显示一个占位符
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            // 分析时间
                            Text(record.analysisTime, formatter: timeFormatter)
                        }
                    }
                }
            }  // Section
            //            }
            //            .frame(maxHeight: .infinity, alignment: .top)
            //            .navigationTitle("照片分析记录")
            //            .navigationBarTitleDisplayMode(.inline)
        }  // List {
        // 关键：在这里显式地设置列表样式
        .listStyle(.grouped)
    }
}
*/

// 记录的详细页面，用于展示分析结果
struct RecordDetailView: View {
    // 删除当前记录
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    // 文字格式化
    @StateObject private var viewModel = TextFileViewModel()

    // 加载图像
    @State var record: PhotoAnalysisRecord
    @State private var analysisText: String = "正在加载..."
    @State private var photo: UIImage? = nil

    // 2. 照片全屏显示
    // 2.1)全屏显示控制变量
    @State private var showingFullScreenImage = false

    // 4. 分享
    @State private var isShowingShareSheet = false
    @State private var pdfURL: URL?
    @State private var isGenerating = false  // 生成pdf文件

    // 学习笔记
    @State private var isShowingStudyNote = false

    var body: some View {
        ZStack {
            VStack {
                // 添加分隔线
                Divider()
                
                HStack {
                    // 左侧，照片
                    VStack {
                        if photo == nil {
                            Text("正在加载照片")
                        } else {
                            Image(uiImage: photo!)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(20)
                                .onTapGesture {
                                    // 2.2）当用户点击照片时，显示全屏视图
                                    self.showingFullScreenImage = true
                                }
                            
                            // 你的自定义星级视图
                            RatingView(rating: $record.currentPhotoRating)
                            
                            Text(
                                // 点击照片->全屏显示
                                "Click on the photo -> Full screen"
                            )
                            .padding()
                            .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    
                    // 右侧，文字
                    VStack {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                // ... 你可以在这里添加照片图标，时间等
                                if let att = viewModel.attributedContent {
                                    Text(att)
                                        .lineSpacing(5)
                                } else {
                                    Text(analysisText)
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
                        // 你的自定义星级视图
                        RatingView(
                            rating: $record.currentAnalysisRating,
                            starColor: Color.green.opacity(0.8)
                        )
                        
                        if isShowingStudyNote {
                            //                                Text("Study Note")
                            // ====请求文字
                            TextEditor(text: $record.studyNote)
                                .frame(maxWidth: .infinity)
                            // 1. 添加内边距，让文本内容与边框不粘连
                                .padding(10)
                                .background(Color.green.opacity(0.3))
                            
                            // 2. 使用 overlay 叠加一个描边的圆角矩形作为边框
                            //                                    .overlay(
                            //                                        RoundedRectangle(cornerRadius: 20)  // 自定义圆角
                            //                                            .stroke(
                            //                                                Color.gray.opacity(0.6),
                            //                                                lineWidth: 1
                            //                                            )  // 设置描边颜色和粗细
                            //
                            //                                    )
                            // 3. 限制 TextEditor 的高度，否则它会占据所有可用空间
                                .frame(height: 300)
                                .padding([.top], 8)  // 给整个组件添加外边距
                                .autocapitalization(.none)
                        }
                        
                    }
                    .background(Color.gray.opacity(0.05))  // 用背景色来可视化效果
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .cornerRadius(20)
                }
            }
            .padding([.leading, .trailing], 8)
            .navigationTitle("Photo Analysis Review")
            .task {
                // 在新视图出现时加载分析结果文件
                analysisText = loadAnalysisText(fileName: record.analysisFileName)
                viewModel.renderMarkdown(analysisText)
                
                if let uiImage = loadImageFromFile(fileName: record.photoFileName) {
                    photo = uiImage
                }
                //            currentAnalysisRating = record.currentAnalysisRating
                //            studyNote = record.studyNote
            }
            // 2.3）全屏显示，Present the full-screen image as a fullScreenCover.
            .fullScreenCover(isPresented: $showingFullScreenImage) {
                if let image = photo {
                    FullScreenImageView(
                        image: image,
                        isPresented: $showingFullScreenImage
                    )
                }
            }
            .toolbar {  // 右侧工具栏
                //======= 学习笔记
                Button {  // 学习笔记
                    isShowingStudyNote.toggle()
                } label: {
                    Label("Study Note", systemImage: "pencil.and.scribble")
                }
                
                // 删除当前记录
                Button {
                    deleteRecord()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
                Button(action: {  // 分享
                    isGenerating = true
                    Task {
                        //                            if let url = await viewModel.generatePDFTempURL() {
                        if let url = await viewModel.generatePDFTempURL(
                            withImage: photo!
                        ) {
                            pdfURL = url
                            isShowingShareSheet = true
                        }
                        isGenerating = false
                    }
                }) {
                    Label(
                        "Share",
                        systemImage: "square.and.arrow.up"
                    )
                }  // Button(action: { // 分享
                .padding()
                .sheet(isPresented: $isShowingShareSheet) {
                    if let url = pdfURL {
                        // PDF文件
                        ShareSheet(activityItems: [url])
                    }
                    
                }  // 分享
            } // toolbar
            
            // 覆盖视图：等待提示
            if isGenerating {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)

                ProgressView("PDF is creating...")  // 正在生成PDF...
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding()
                    .background(Color.secondary)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }  // if isGenerating {
            
        }// ZStack
    }

    private func loadAnalysisText(fileName: String) -> String {
        let fileURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent(fileName)
        do {
            return try String(contentsOf: fileURL)
        } catch {
            print("加载分析文件失败：\(error)")
            return "加载分析结果失败。"
        }
    }

    private func deleteRecord() {
        modelContext.delete(record)
        // 注意：删除后，你可能需要关闭当前视图
        dismiss()
    }
}

struct PhotoReviewListView: View {
    // 假设你的数据是从 SwiftData 获取的
    @Query(sort: \PhotoAnalysisRecord.analysisTime, order: .reverse) private
        var records: [PhotoAnalysisRecord]

    // 可以在这里设置表头的背景颜色
    private let headerBackgroundColor = Color(.systemBackground)

    var body: some View {
        // 使用 ZStack 将表头和可滚动内容分层
        ZStack(alignment: .top) {

            // 1. 可滚动的内容部分
            ScrollView {
                // 用于向上偏移内容，为固定的表头留出空间
                Color.clear.frame(height: 44)  // 这是一个占位符，高度与表头相同

                // LazyVStack 用于高效渲染列表项
                LazyVStack(alignment: .leading, spacing: 0) {
                    // 表头部分
                    //                    HStack {
                    //                        Text("照片").bold()
                    //                        Spacer()
                    //                        Text("分析时间").bold()
                    //                    }
                    //                    .padding(.horizontal)
                    //                    .frame(height: 44) // 确保表头有固定高度

                    // 列表项
                    ForEach(records) { record in
                        // ... 你的列表项视图，可以包含 NavigationLink
                        PhotoReviewListItemView(record: record)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))  // 设置列表背景色

            // 2. 固定在顶部的表头
            HStack {
                Text("Photo")  // 照片
                    .font(.headline)
                    .foregroundColor(.gray)
                    //                    .bold()
                    .frame(width: 120)

                Text("Analysis and Scoring")  // 分析时间
                    .font(.headline)
                    .foregroundColor(.gray)
                    //                    .bold()
                    .frame(width: 220)

                //                Spacer(minLength: 20)
                Text("Study Notes")  // 心得体会
                    .font(.headline)
                    .foregroundColor(.gray)
                    //                    .bold()
                    .frame(width: 280)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 44)  // 确保高度与上面 LazyVStack 的占位符一致
            .background(headerBackgroundColor)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)  // 添加阴影以区分
        }
    }
}

// 示例：一个自定义的列表项视图
struct PhotoReviewListItemView: View {
    //    let record: PhotoAnalysisRecord
    @State var record: PhotoAnalysisRecord
    //    @State private var currentPhotoRating: Int = 0
    //    @State private var currentAnalysisRating: Int = 0

    // 一个用于格式化时间的 DateFormatter
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        // 使用 NavigationLink 确保可点击跳转
        NavigationLink(destination: RecordDetailView(record: record)) {
            HStack {
                // 照片图标: 120x120
                if let uiImage = loadImageFromFile(
                    fileName: record.photoFileName
                ) {
                    Image(uiImage: uiImage)
                        .resizable()
                        //                                    .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    // 如果图片文件不存在，显示一个占位符
                    Image(systemName: "photo.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .trailing) {
                    // 打分
                    HStack {
                        Text("Photo:")
                            .frame(width: 80, alignment: .trailing)
                        //                            .multilineTextAlignment(.trailing)

                        RatingView(rating: $record.currentPhotoRating)
                    }
                    HStack {
                        Text("Analysis:")
                            .frame(width: 80, alignment: .trailing)
                        //                            .multilineTextAlignment(.trailing)
                        RatingView(
                            rating: $record.currentAnalysisRating,
                            starColor: Color.green.opacity(0.8)
                        )
                    }
                    // 格式化后的分析时间
                    Text(record.analysisTime, formatter: timeFormatter)
                        .padding(.top, 4)
                        .foregroundColor(.gray)
                    Text(record.selectedLanguage)
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)

                Spacer()

                VStack {
                    ZStack(alignment: .topLeading) {  // 使用 ZStack 来分层
                        // 1. 背景色视图
                        Color.gray.opacity(0.05)  // 你的背景颜色

                        // 2. TextEditor 视图
                        TextEditor(text: $record.studyNote)
                            .scrollContentBackground(.hidden)  // 关键：隐藏 TextEditor 自身的背景
                            .padding(.horizontal)  // 添加内边距让文本不紧贴边缘
                            .multilineTextAlignment(.leading)
                    }
                    .frame(height: 120)  // 设置 ZStack 的高度
                    .cornerRadius(10)  // 添加圆角
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 120)
                //                .cornerRadius(20)

            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(Color.white)
        }
        // 手动添加列表项之间的分隔线
        .overlay(
            Divider(),
            alignment: .bottom
        )
    }
}
