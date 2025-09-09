//
//  PhotoAnalysisView.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/9.
//

import SwiftUI

@Observable
class PhotoAnalysisState {
    //    $appState.photoAnalysisState.selectedImage
    // 1. 选择照片
    // 1.1)存储选中的图片
    var selectedImage: UIImage?
    var selectedImageName: String?

    // 3. AI
    // 3.1)变量
    var responseText: String = ""
    var isLoading: Bool = false
    var isSuccessfull: Bool = false
    var attributedAnalysis: AttributedString? = nil
    var studyNote: String = "Study Note"
    var isShowingStudyNote: Bool = true  //false

    // 打分
    var currentPhotoRating: Int = 0
    var currentAnalysisRating: Int = 0

    // AI 响应语言
    var selectedLanguage: String = "English"
    var isShowingLanguagePicker: Bool = false
}

class AIResponseItemProvider: NSObject, UIActivityItemSource {
    var responseText: String

    init(responseText: String) {
        self.responseText = responseText
    }

    func activityViewControllerPlaceholderItem(
        _ activityViewController: UIActivityViewController
    ) -> Any {
        return "AI Response"
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        // Return the plain text response
        return responseText
    }
}

struct PhotoAnalysisView: View {
    // 关键：使用 @Environment 访问 @Observable 类型的共享状态
    //    @Environment(AppState.self) private var appState
    @State private var appState: AppState
    // 构造函数，确保可以接收 AppState
    init(appState: AppState) {
        self._appState = State(wrappedValue: appState)
    }

    // 使用 @Environment 获取 modelContext
    @Environment(\.modelContext) private var modelContext

    // 文字格式化
    @StateObject private var viewModel = TextFileViewModel()

    @State private var fullText: String =
        "Professional analysis, evaluation, and improvement suggestions"

    // 1. 选择照片
    // 1.1)存储选中的图片
    //    @State private var selectedImage: UIImage?
    //    @State private var selectedImageName: String?
    // 1.2)控制照片选择器的显示与隐藏
    @State private var showingPhotoPicker = false

    // 2. 照片全屏显示
    // 2.1)全屏显示控制变量
    @State private var showingFullScreenImage = false

    // 3. AI
    // 3.1)变量
    @State private var promptText: String =
        "Professional analysis, evaluation, and improvement suggestions"
    //    @State private var responseText: String = ""
    //    @State private var isLoading: Bool = false
    //    @State private var isSuccessfull: Bool = false
    @State private var saveMessage: String = ""

    // In a real app, you would use a secure way to store your API key.
    // For this example, we'll keep it as a constant.
    let apiKey: String = "AIzaSyB0yrvRUgR8Mo_l36gdUlaa_LMj3ELeUEs"  // This will be provided at runtime.

    let SYSTEM_PROMPT =
    "You are a world-class photography instructor. Please analyze this photo's composition, lighting, subject matter, and technical execution, and provide expert suggestions for improvement. Your response should use Markdown formatting, including headings, bold text, and lists, to ensure clarity and readability. All your responses must be in ."  // English Chinese

    // 4. 分享
    @State private var isShowingShareSheet = false
    @State private var pdfURL: URL?
    @State private var isGenerating = false  // 生成pdf文件

    // 5. 评分
    // 使用 @State 管理当前评分，缺省为 0 星
    //    @State private var currentPhotoRating: Int = 0
    //    @State private var currentAnalysisRating: Int = 0

    // 6. 学习笔记
    //    @State private var isShowingStudyNote = false

    // 3.2）Function to send a request to the AI model

    // 控制 more 列表框是否显示
    @State private var showingMoreMenu = false

    @MainActor
    func sendToAI() async {
        guard
            !promptText.isEmpty
                || $appState.photoAnalysisState.selectedImage != nil
        else {
            return
        }

        appState.photoAnalysisState.responseText = ""
        appState.photoAnalysisState.isLoading = true
        appState.photoAnalysisState.isSuccessfull = false  // 标志，开始时，重置为不成功
        appState.photoAnalysisState.attributedAnalysis = nil  //
        appState.photoAnalysisState.currentPhotoRating = 0
        appState.photoAnalysisState.currentAnalysisRating = 0
        
        saveMessage = ""

        let urlString =
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            self.appState.photoAnalysisState.responseText = "Error: Invalid URL"  //错误: 无效的 URL
            self.appState.photoAnalysisState.isLoading = false
            self.appState.photoAnalysisState.isSuccessfull = false
            return
        }

        var parts: [[String: Any]] = []

        // Add text prompt
        if !promptText.isEmpty {
            parts.append(["text": promptText])
        }

        // Add image data
        if let image = appState.photoAnalysisState.selectedImage,
            let compressedData = compressImage(
                image: image,
                maxWidth: 1024,
                maxHeight: 1024,
                quality: 0.7
            )
        {
            let base64Image = compressedData.base64EncodedString()
            parts.append([
                "inlineData": [
                    "mimeType": "image/jpeg",
                    "data": base64Image,
                ]
            ])
        }

        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": parts
                ]
            ],
            "systemInstruction": [
                "parts": [
                    [
                        "text": SYSTEM_PROMPT + appState.photoAnalysisState.selectedLanguage
                    ]
                ]
            ],
        ]

        guard
            let httpBody = try? JSONSerialization.data(withJSONObject: payload)
        else {
            self.appState.photoAnalysisState.responseText =
                "Error: Unable to create request body"  //错误: 无法创建请求体
            self.appState.photoAnalysisState.isLoading = false
            self.appState.photoAnalysisState.isSuccessfull = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonResponse = try JSONSerialization.jsonObject(with: data)
                as? [String: Any],
                let candidates = jsonResponse["candidates"] as? [[String: Any]],
                let firstCandidate = candidates.first,
                let content = firstCandidate["content"] as? [String: Any],
                let parts = content["parts"] as? [[String: Any]],
                let firstPart = parts.first,
                let text = firstPart["text"] as? String
            {
                self.appState.photoAnalysisState.responseText = text
                viewModel.renderMarkdown(text)
                appState.photoAnalysisState.attributedAnalysis =
                    viewModel.attributedContent
                appState.photoAnalysisState.isSuccessfull = true
            } else {
                self.appState.photoAnalysisState.responseText =
                    "Unable to parse AI response."  // 无法解析 AI 响应。
                appState.photoAnalysisState.isSuccessfull = false
            }
        } catch {
            self.appState.photoAnalysisState.responseText =
                "Error occurred: \(error.localizedDescription)"  // 发生错误:
            appState.photoAnalysisState.isSuccessfull = false
        }

        self.appState.photoAnalysisState.isLoading = false
    }

    // 3.3）Function to save the response to a file
    /*
    func saveToFile() {
        guard !responseText.isEmpty else {
            saveMessage = "没有内容可保存。"
            return
        }
    
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        let fileName = "AI_Response_\(Int(Date().timeIntervalSince1970)).txt"
        let fileURL = documentDirectory.appendingPathComponent(fileName)
    
        do {
            try responseText.write(
                to: fileURL,
                atomically: true,
                encoding: .utf8
            )
            saveMessage = "文件已保存到: \(fileURL.path)"
        } catch {
            saveMessage = "保存文件失败: \(error.localizedDescription)"
        }
    }
    */
    var body: some View {
        ZStack {
            // 使用 VStack 将主内容和分隔线垂直排列
            VStack(spacing: 0) {
                // 添加分隔线
                Divider()

                // 你的主视图内容
                HStack(alignment: .top, spacing: 10) {  // 第三层，内套左右两侧区域
                    // ==== 左侧区域
                    VStack(alignment: .leading) {  // 左侧区域
                        // Here we use the disabled modifier
                        //                    Text("左侧")
                        HStack {  // 第一行
                            // ====按钮：Choose Photo
                            Button {
                                // 1.3)显示控制：照片选择器
                                showingPhotoPicker = true
                            } label: {
                                Text("Choose Photo")
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(20)

                            // ====选择的图片：图标、文件名
                            if let image = appState.photoAnalysisState
                                .selectedImage
                            {
                                HStack(spacing: 8) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .padding(.leading, 16)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(
                                                Color.white,
                                                lineWidth: 2
                                            )
                                        )
                                        .shadow(radius: 3)

                                    if let name = appState.photoAnalysisState
                                        .selectedImageName
                                    {
                                        Text(name)
                                            .font(.caption)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                    }
                                }
                            } else {
                                Text("No photo chosen")
                                    .padding(.leading, 16)
                                    .foregroundColor(.gray)
                            }

                        }  // HStack { // 第一行

                        // ==== 照片
                        HStack {  // 照片
                            // 1.4)显示选中的照片
                            if let image = appState.photoAnalysisState
                                .selectedImage
                            {
                                VStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .onTapGesture {
                                            // 2.2）当用户点击照片时，显示全屏视图
                                            self.showingFullScreenImage = true
                                        }

                                    // 你的自定义星级视图
                                    RatingView(
                                        //                                        rating: $currentPhotoRating,
                                        rating: $appState.photoAnalysisState
                                            .currentPhotoRating,
                                        starColor: Color.yellow
                                    )

                                    Text(
                                        // 点击照片->全屏显示
                                        "Click on the photo -> Full screen"
                                    )
                                    .padding()
                                    .foregroundColor(.gray)

                                }
                            } else {
                                // 未选照片时，提示
                                Text(
                                    "Upload a photo and ask a question. I'll provide professional analysis and advice."
                                )
                                .foregroundColor(.gray)
                            }

                        }
                        .frame(maxWidth: .infinity)

                        Spacer()

                        // ====请求文字
                        TextEditor(text: $promptText)
                            .frame(maxWidth: .infinity)
                            // 1. 添加内边距，让文本内容与边框不粘连
                            .padding(10)

                            // 2. 使用 overlay 叠加一个描边的圆角矩形作为边框
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)  // 自定义圆角
                                    .stroke(
                                        Color.gray.opacity(0.6),
                                        lineWidth: 1
                                    )  // 设置描边颜色和粗细
                            )
                            // 3. 限制 TextEditor 的高度，否则它会占据所有可用空间
                            .frame(height: 100)
                            .padding([.top, .bottom], 10)  // 给整个组件添加外边距
                            .autocapitalization(.none)

                        // ==== 按钮：Send Analysis Request
                        Button {
                            Task {
                                await sendToAI()
                            }
                        } label: {
                            Text("Send Analysis Request")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(
                            appState.photoAnalysisState.selectedImage != nil
                                ? Color.blue : Color.gray
                        )
                        .cornerRadius(20)
                        .disabled(
                            appState.photoAnalysisState.selectedImage == nil
                                || appState.photoAnalysisState.isLoading
                                || promptText.isEmpty
                        )  // Here we use the disabled modifier

                    }  // VStack，左侧区域
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    //                .background(Color.red) // 测试用
                    .cornerRadius(20)

                    // ==== 右侧区域：AI 响应
                    VStack {  // 右侧区域
                        //                    Text("右侧")
                        if !appState.photoAnalysisState.responseText.isEmpty {
                            ScrollView {  // 滚动
                                // AI分析文本
                                VStack(alignment: .leading, spacing: 10) {
                                    if let att = appState.photoAnalysisState
                                        .attributedAnalysis
                                    {
                                        Text(att)
                                            .lineSpacing(5)
                                    } else if let att = viewModel
                                        .attributedContent
                                    {
                                        Text(att)
                                            .lineSpacing(5)
                                    } else {
                                        Text(
                                            appState.photoAnalysisState
                                                .responseText
                                        )
                                        .lineSpacing(5)
                                    }

                                }
                                .padding()
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity,
                                    alignment: .leading
                                )
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(10)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)

                            // 你的自定义星级视图
                            if appState.photoAnalysisState.isSuccessfull {
                                RatingView(
                                    //                                    rating: $currentAnalysisRating,
                                    rating: $appState.photoAnalysisState
                                        .currentAnalysisRating,
                                    starColor: Color.green.opacity(0.8)
                                )
                            }

                            if appState.photoAnalysisState.isShowingStudyNote {
                                //                                Text("Study Note")
                                // ====请求文字
                                TextEditor(
                                    text: $appState.photoAnalysisState.studyNote
                                )
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

                        } else {  // if !responseText.isEmpty {
                            if appState.photoAnalysisState.isLoading {
                                AIIsAnalyzingView()
                            } else {  //if isLoading {
                                ScrollView {  // 滚动
                                    Text("Photo Analysis By AI")
                                        //                                        .padding(20)
                                        .padding(.top, 40)
                                        .padding(.bottom, 10)
                                        .font(
                                            .system(
                                                .title,
                                                design: .rounded
                                            )
                                        )

                                    // 预设的大纲
                                    PreAIResponse()
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

                    }  // VStack 右侧区域
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    //                .background(Color.green) // 测试用
                    .background(Color.gray.opacity(0.05))  // 用背景色来可视化效果
                    .cornerRadius(20)

                }  // HStack(alignment: .top, spacing: 10)，第三层，内套左右两侧区域
                .padding(.horizontal, 10)
                .padding(.top, 10)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)

            }
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("My Photography Mentor -1- Photo Analysis")
            .navigationBarTitleDisplayMode(.inline)
            // 1.5）使用 .sheet 模态地展示 PhotoPicker
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoPicker(
                    selectedImage: $appState.photoAnalysisState.selectedImage,
                    selectedImageName: $appState.photoAnalysisState
                        .selectedImageName,
                    showingPicker: $showingPhotoPicker
                )
            }
            // 2.3）全屏显示，Present the full-screen image as a fullScreenCover.
            .fullScreenCover(isPresented: $showingFullScreenImage) {
                if let image = appState.photoAnalysisState.selectedImage {
                    FullScreenImageView(
                        image: image,
                        isPresented: $showingFullScreenImage
                    )
                }
            }
            // 当 isShowingLanguagePicker 为 true 时，显示语言选择器
            .sheet(
                isPresented: $appState.photoAnalysisState
                    .isShowingLanguagePicker
            ) {
                NavigationStack {
                    LanguagePickerView(appState: appState)
                }
            }
            .toolbar {  // 右侧工具栏
                //======= 测试用，加载本地文件
                ToolbarItem {
                    Button {  // Reload
                        viewModel.renderMarkdown(textContent)
                        appState.photoAnalysisState.responseText = textContent
                    } label: {
                        Label("Reload", systemImage: "arrow.clockwise")
                    }
                }

                //======= 学习笔记
                ToolbarItem {
                    Button {  // 学习笔记
                        appState.photoAnalysisState.isShowingStudyNote.toggle()
                    } label: {
                        Label("Study Note", systemImage: "pencil.and.scribble")
                    }
                    .disabled(appState.photoAnalysisState.responseText.isEmpty)
                }

                //======= 保存文件
                ToolbarItem {
                    Button {  // 保存文件
                        MyPhotographyMentor.saveAnalysisRecord(
                            photoImage: appState.photoAnalysisState
                                .selectedImage!,
                            analysisText: appState.photoAnalysisState
                                .responseText,
                            studyNote: appState.photoAnalysisState.studyNote,
                            currentPhotoRating: appState.photoAnalysisState
                                .currentPhotoRating,
                            currentAnalysisRating: appState.photoAnalysisState
                                .currentAnalysisRating,
                            selectedLanguage: appState.photoAnalysisState.selectedLanguage,
                            modelContext: modelContext
                        )
                    } label: {
                        Label(
                            "Save",
                            systemImage: "checkmark"
                        )
                    }
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .disabled(appState.photoAnalysisState.responseText.isEmpty)
                }

                //======= 分享
                ToolbarItem {
                    Button(action: {  // 分享
                        isGenerating = true
                        Task {
                            //                            if let url = await viewModel.generatePDFTempURL() {
                            if let url = await viewModel.generatePDFTempURL(
                                withImage: appState.photoAnalysisState
                                    .selectedImage!
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
                    .disabled(appState.photoAnalysisState.responseText.isEmpty)
                    .sheet(isPresented: $isShowingShareSheet) {
                        if let url = pdfURL {
                            // PDF文件
                            ShareSheet(activityItems: [url])
                        }

                    }  // 分享
                }

                //======= more
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingMoreMenu.toggle()
                    }) {
                        Image(systemName: "ellipsis.circle")
                    }
                    // 使用 .popover 显示多列列表框
                    .popover(isPresented: $showingMoreMenu) {
                        VStack(alignment: .leading, spacing: 0) {
                            // 第一行：AI Response Language
                            Button(action: {
                                appState.photoAnalysisState
                                    .isShowingLanguagePicker = true
                            }) {
                                HStack {
                                    Text("AI Response Language")
                                        .foregroundColor(Color.gray)
                                    Spacer()
                                    Text(
                                        appState.photoAnalysisState
                                            .selectedLanguage
                                    )

                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Divider()

                        }
                        .frame(width: 300)
                        .presentationCompactAdaptation(.popover)
                    }
                }  // more

            }  // .toolbar { 右侧工具栏

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

        }  // ZStack
    }

}  // struct PhotoAnalysisView: View {

//#Preview {
//    PhotoAnalysisView()
//}
