//
//  GeminiAIView.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/10.
//
/*
import SwiftUI

import SwiftUI
import Foundation

// A simple utility to format AI response text.
func formatAIResponse(_ text: String) -> AttributedString {
    var result = AttributedString(text)
    
    // Simple markdown-like formatting for headings and lists.
    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
    
    var formattedText = ""
    for line in lines {
        if line.hasPrefix("# ") {
            formattedText += "**\(line.dropFirst(2))**\n"
        } else if line.hasPrefix("* ") {
            formattedText += "• \(line.dropFirst(2))"
        } else {
            formattedText += line
        }
        formattedText += "\n"
    }

    // Apply bolding to formatted text.
    if let range = result.range(of: "**(.+?)**", options: .regularExpression) {
        result[range].font = .title.bold()
    }
    
    // Add custom line breaks for better display
    result = AttributedString(formattedText)
    
    return result
}

struct GeminiAIView: View {
    // 发送的内容
    @State private var promptText: String = ""
    @State private var responseText: String = ""
    @State private var isLoading: Bool = false
    @State private var saveMessage: String = ""

    // In a real app, you would use a secure way to store your API key.
    // For this example, we'll keep it as a constant.
    let apiKey: String = "" // This will be provided at runtime.
    
    // Function to send a request to the AI model
    @MainActor
    func sendToAI() async {
        guard !promptText.isEmpty else {
            return
        }

        isLoading = true
        saveMessage = ""

        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            self.responseText = "错误: 无效的 URL"
            self.isLoading = false
            return
        }

        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": promptText]
                    ]
                ]
            ]
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload) else {
            self.responseText = "错误: 无法创建请求体"
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = jsonResponse["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                self.responseText = text
            } else {
                self.responseText = "无法解析 AI 响应。"
            }
        } catch {
            self.responseText = "发生错误: \(error.localizedDescription)"
        }
        
        self.isLoading = false
    }
    
    // Function to save the response to a file
    func saveToFile() {
        guard !responseText.isEmpty else {
            saveMessage = "没有内容可保存。"
            return
        }
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "AI_Response_\(Int(Date().timeIntervalSince1970)).txt"
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        do {
            try responseText.write(to: fileURL, atomically: true, encoding: .utf8)
            saveMessage = "文件已保存到: \(fileURL.path)"
        } catch {
            saveMessage = "保存文件失败: \(error.localizedDescription)"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("AI 助手")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // TextEditor for user input
            TextEditor(text: $promptText)
                .frame(height: 150)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            // Buttons for actions
            HStack {
                Button("发送到 AI") {
                    Task {
                        await sendToAI()
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading || promptText.isEmpty)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                Spacer()
                
                Button("保存为文件") {
                    saveToFile()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(responseText.isEmpty)
            }
            
            // Display AI response
            ScrollView {
                if !responseText.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(formatAIResponse(responseText))
                            .lineSpacing(5)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                } else {
                    Text("AI 回复将显示在此处。")
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            
            // Save message
            if !saveMessage.isEmpty {
                Text(saveMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
*/
/*
import SwiftUI
import Foundation
import PhotosUI
import UniformTypeIdentifiers

// A simple utility to format AI response text.
func formatAIResponse(_ text: String) -> AttributedString {
    var result = AttributedString(text)

    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)

    var formattedText = ""
    for line in lines {
        if line.hasPrefix("# ") {
            formattedText += "**\(line.dropFirst(2))**\n"
        } else if line.hasPrefix("* ") {
            formattedText += "• \(line.dropFirst(2))\n"
        } else {
            formattedText += line + "\n"
        }
    }

    result = AttributedString(formattedText)

    if let range = result.range(of: "**(.+?)**", options: .regularExpression) {
        result[range].font = .title.bold()
    }

    return result
}

// MARK: - Photo Picker Wrapper
// Wraps the UIKit PHPickerViewController for use in SwiftUI.
struct PhotoPicker2: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker2

        init(_ parent: PhotoPicker2) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let result = results.first else { return }

            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

// MARK: - Main Content View
struct GeminiAIView: View {
    @State private var promptText: String = ""
    @State private var responseText: String = ""
    @State private var isLoading: Bool = false
    @State private var saveMessage: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingPhotoPicker = false

    // In a real app, you would use a secure way to store your API key.
    // For this example, we'll keep it as a constant.
    let apiKey: String = ""

    @MainActor
    func sendToAI() async {
        guard !promptText.isEmpty || selectedImage != nil else {
            return
        }

        isLoading = true
        saveMessage = ""

        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            self.responseText = "错误: 无效的 URL"
            self.isLoading = false
            return
        }
        
        var parts: [[String: Any]] = []
        
        // Add text prompt
        if !promptText.isEmpty {
            parts.append(["text": promptText])
        }
        
        // Add image data
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            let base64Image = imageData.base64EncodedString()
            parts.append([
                "inlineData": [
                    "mimeType": "image/jpeg",
                    "data": base64Image
                ]
            ])
        }

        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": parts
                ]
            ]
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload) else {
            self.responseText = "错误: 无法创建请求体"
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = jsonResponse["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                self.responseText = text
            } else {
                self.responseText = "无法解析 AI 响应。"
            }
        } catch {
            self.responseText = "发生错误: \(error.localizedDescription)"
        }

        self.isLoading = false
    }

    func saveToFile() {
        guard !responseText.isEmpty else {
            saveMessage = "没有内容可保存。"
            return
        }

        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "AI_Response_\(Int(Date().timeIntervalSince1970)).txt"
        let fileURL = documentDirectory.appendingPathComponent(fileName)

        do {
            try responseText.write(to: fileURL, atomically: true, encoding: .utf8)
            saveMessage = "文件已保存到: \(fileURL.path)"
        } catch {
            saveMessage = "保存文件失败: \(error.localizedDescription)"
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("AI 助手")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack {
                Button(action: {
                    self.showingPhotoPicker = true
                }) {
                    VStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 5)
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 30))
                                        .foregroundColor(.gray)
                                )
                        }
                        Text(selectedImage == nil ? "选择照片" : "已选择")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .sheet(isPresented: $showingPhotoPicker) {
                    PhotoPicker2(selectedImage: $selectedImage)
                }
                
                // TextEditor for user input
                TextEditor(text: $promptText)
                    .frame(height: 150)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal)
            
            // Buttons for actions
            HStack {
                Button("发送到 AI") {
                    Task {
                        await sendToAI()
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading || (promptText.isEmpty && selectedImage == nil))
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                Spacer()
                
                Button("保存为文件") {
                    saveToFile()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(responseText.isEmpty)
            }
            
            // Display AI response
            ScrollView {
                if !responseText.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(formatAIResponse(responseText))
                            .lineSpacing(5)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                } else {
                    Text("AI 回复将显示在此处。")
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            
            // Save message
            if !saveMessage.isEmpty {
                Text(saveMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
*/
/*
import SwiftUI
import Foundation
import PhotosUI
import UniformTypeIdentifiers

// A simple utility to format AI response text.
func formatAIResponse(_ text: String) -> AttributedString {
    var result = AttributedString(text)

    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)

    var formattedText = ""
    for line in lines {
        if line.hasPrefix("# ") {
            formattedText += "**\(line.dropFirst(2))**\n"
        } else if line.hasPrefix("* ") {
            formattedText += "• \(line.dropFirst(2))\n"
        } else {
            formattedText += line + "\n"
        }
    }

    result = AttributedString(formattedText)

    if let range = result.range(of: "**(.+?)**", options: .regularExpression) {
        result[range].font = .title.bold()
    }

    return result
}

// MARK: - Photo Picker Wrapper
// Wraps the UIKit PHPickerViewController for use in SwiftUI.
struct PhotoPicker2: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker2

        init(_ parent: PhotoPicker2) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let result = results.first else { return }

            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

// MARK: - Image Compression
func compressImage(image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat, quality: CGFloat) -> Data? {
    let size = image.size
    var newSize: CGSize

    if size.width > maxWidth || size.height > maxHeight {
        let widthRatio = maxWidth / size.width
        let heightRatio = maxHeight / size.height
        let ratio = min(widthRatio, heightRatio)
        newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
    } else {
        newSize = size
    }

    // UIGraphicsBeginImageContextWithOptions will create a bitmap graphics context
    // It's the standard way to resize images on iOS.
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: CGRect(origin: .zero, size: newSize))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage?.jpegData(compressionQuality: quality)
}


// MARK: - Main Content View
struct GeminiAIView: View {
    @State private var promptText: String = ""
    @State private var responseText: String = ""
    @State private var isLoading: Bool = false
    @State private var saveMessage: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingPhotoPicker = false

    // In a real app, you would use a secure way to store your API key.
    // For this example, we'll keep it as a constant.
    let apiKey: String = ""

    @MainActor
    func sendToAI() async {
        guard !promptText.isEmpty || selectedImage != nil else {
            return
        }

        isLoading = true
        saveMessage = ""

        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            self.responseText = "错误: 无效的 URL"
            self.isLoading = false
            return
        }
        
        var parts: [[String: Any]] = []
        
        // Add text prompt
        if !promptText.isEmpty {
            parts.append(["text": promptText])
        }
        
        // Add image data
        if let image = selectedImage, let compressedData = compressImage(image: image, maxWidth: 1024, maxHeight: 1024, quality: 0.7) {
            let base64Image = compressedData.base64EncodedString()
            parts.append([
                "inlineData": [
                    "mimeType": "image/jpeg",
                    "data": base64Image
                ]
            ])
        }

        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": parts
                ]
            ]
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload) else {
            self.responseText = "错误: 无法创建请求体"
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = jsonResponse["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                self.responseText = text
            } else {
                self.responseText = "无法解析 AI 响应。"
            }
        } catch {
            self.responseText = "发生错误: \(error.localizedDescription)"
        }

        self.isLoading = false
    }

    func saveToFile() {
        guard !responseText.isEmpty else {
            saveMessage = "没有内容可保存。"
            return
        }

        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "AI_Response_\(Int(Date().timeIntervalSince1970)).txt"
        let fileURL = documentDirectory.appendingPathComponent(fileName)

        do {
            try responseText.write(to: fileURL, atomically: true, encoding: .utf8)
            saveMessage = "文件已保存到: \(fileURL.path)"
        } catch {
            saveMessage = "保存文件失败: \(error.localizedDescription)"
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("AI 助手")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack {
                Button(action: {
                    self.showingPhotoPicker = true
                }) {
                    VStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 5)
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 30))
                                        .foregroundColor(.gray)
                                )
                        }
                        Text(selectedImage == nil ? "选择照片" : "已选择")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .sheet(isPresented: $showingPhotoPicker) {
                    PhotoPicker2(selectedImage: $selectedImage)
                }
                
                // TextEditor for user input
                TextEditor(text: $promptText)
                    .frame(height: 150)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal)
            
            // Buttons for actions
            HStack {
                Button("发送到 AI") {
                    Task {
                        await sendToAI()
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading || (promptText.isEmpty && selectedImage == nil))
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                Spacer()
                
                Button("保存为文件") {
                    saveToFile()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(responseText.isEmpty)
            }
            
            // Display AI response
            ScrollView {
                if !responseText.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(formatAIResponse(responseText))
                            .lineSpacing(5)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                } else {
                    Text("AI 回复将显示在此处。")
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            
            // Save message
            if !saveMessage.isEmpty {
                Text(saveMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
*/

import SwiftUI
import Foundation
import PhotosUI
import UniformTypeIdentifiers
/*
// A simple utility to format AI response text.
func formatAIResponse(_ text: String) -> AttributedString {
    var result = AttributedString(text)

    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)

    var formattedText = ""
    for line in lines {
        if line.hasPrefix("# ") {
            formattedText += "**\(line.dropFirst(2))**\n"
        } else if line.hasPrefix("* ") {
            formattedText += "• \(line.dropFirst(2))\n"
        } else {
            formattedText += line + "\n"
        }
    }

    result = AttributedString(formattedText)

    if let range = result.range(of: "**(.+?)**", options: .regularExpression) {
        result[range].font = .title.bold()
    }

    return result
}
*/
// A simple utility to format AI response text.
func formatAIResponse1(_ text: String) -> AttributedString {
    var result = AttributedString()
    var lastIndex = text.startIndex

    // Regular expression to find all Markdown elements.
    // This looks for headings (#), bold text (**...**), and list items (* ).
    let regexPattern = "(#+ .*)|(\\*\\*.*?\\*\\*)|(\\* .*)"
    
    do {
        let regex = try NSRegularExpression(pattern: regexPattern, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        for match in matches {
            guard let swiftRange = Range(match.range, in: text) else { continue }
            
            // Append the text before the match
            if lastIndex < swiftRange.lowerBound {
                result.append(AttributedString(text[lastIndex..<swiftRange.lowerBound]))
            }
            
            let markdownSubstring = String(text[swiftRange])
            
            if markdownSubstring.hasPrefix("#") {
                // Handle headings
                let trimmed = markdownSubstring.drop(while: { $0 == "#" || $0.isWhitespace })
                var attributedString = AttributedString(String(trimmed))
                attributedString.font = .title.bold()
                result.append(attributedString)
            } else if markdownSubstring.hasPrefix("**") {
                // Handle bold text
                let trimmed = markdownSubstring.dropFirst(2).dropLast(2)
                var attributedString = AttributedString(String(trimmed))
                attributedString.font = .body.bold()
                result.append(attributedString)
            } else if markdownSubstring.hasPrefix("* ") {
                // Handle list items
                let trimmed = markdownSubstring.dropFirst(2)
                var attributedString = AttributedString("• " + String(trimmed))
                result.append(attributedString)
            }
            
            lastIndex = swiftRange.upperBound
        }
        
        // Append any remaining text after the last match
        if lastIndex < text.endIndex {
            result.append(AttributedString(text[lastIndex..<text.endIndex]))
        }
        
    } catch {
        print("Invalid regex: \(error.localizedDescription)")
    }
    
    return result
}

// A simple utility to format AI response text.
func formatAIResponse2(_ text: String) -> AttributedString {
    var result = AttributedString()
    var lastIndex = text.startIndex

    // Regular expression to find all Markdown elements.
    // This looks for headings (#), bold text (**...**), and list items (* ).
    let regexPattern = "(#+ .*)|(\\*\\*.*?\\*\\*)|(\\* .*)"
    
    do {
        let regex = try NSRegularExpression(pattern: regexPattern, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        for match in matches {
            guard let swiftRange = Range(match.range, in: text) else { continue }
            
            // Append the text before the match
            if lastIndex < swiftRange.lowerBound {
                result.append(AttributedString(text[lastIndex..<swiftRange.lowerBound]))
            }
            
            let markdownSubstring = String(text[swiftRange])
            
            if markdownSubstring.hasPrefix("#") {
                // Handle headings
                let trimmed = markdownSubstring.drop(while: { $0 == "#" || $0.isWhitespace })
                var attributedString = AttributedString(String(trimmed))
                attributedString.font = .title.bold()
                result.append(attributedString)
            } else if markdownSubstring.hasPrefix("**") {
                // Handle bold text
                let trimmed = markdownSubstring.dropFirst(2).dropLast(2)
                var attributedString = AttributedString(String(trimmed))
                attributedString.font = .body.bold()
                result.append(attributedString)
            } else if markdownSubstring.hasPrefix("* ") {
                // Handle list items
                let trimmed = markdownSubstring.dropFirst(2)
                var attributedString = AttributedString("• " + String(trimmed))
                result.append(attributedString)
            }
            
            lastIndex = swiftRange.upperBound
        }
        
        // Append any remaining text after the last match
        if lastIndex < text.endIndex {
            result.append(AttributedString(text[lastIndex..<text.endIndex]))
        }
        
    } catch {
        print("Invalid regex: \(error.localizedDescription)")
    }
    
    return result
}

// A simple utility to format AI response text.
func formatAIResponse3(_ text: String) -> AttributedString {
    var result = AttributedString()
    var lastIndex = text.startIndex

    // Regular expression to find all Markdown elements.
    // This looks for headings (#), bold text (**...**), and list items (* ).
    let regexPattern = "(#+ .*)|(\\*\\*.*?\\*\\*)|(\\* .*)"
    
    do {
        let regex = try NSRegularExpression(pattern: regexPattern, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        for match in matches {
            guard let swiftRange = Range(match.range, in: text) else { continue }
            
            // Append the text before the match
            if lastIndex < swiftRange.lowerBound {
                result.append(AttributedString(text[lastIndex..<swiftRange.lowerBound]))
            }
            
            let markdownSubstring = String(text[swiftRange])
            
            if markdownSubstring.hasPrefix("#") {
                // Handle headings
                let trimmed = markdownSubstring.drop(while: { $0 == "#" || $0.isWhitespace })
                var attributedString = AttributedString(String(trimmed))
                attributedString.font = .title.bold()
                result.append(attributedString)
            } else if markdownSubstring.hasPrefix("**") {
                // Handle bold text
                let trimmed = markdownSubstring.dropFirst(2).dropLast(2)
                var attributedString = AttributedString(String(trimmed))
                attributedString.font = .body.bold()
                result.append(attributedString)
            } else if markdownSubstring.hasPrefix("* ") {
                // Handle list items
                let trimmed = markdownSubstring.dropFirst(2)
                var attributedString = AttributedString("• " + String(trimmed))
                result.append(attributedString)
            }
            
            lastIndex = swiftRange.upperBound
        }
        
        // Append any remaining text after the last match
        if lastIndex < text.endIndex {
            result.append(AttributedString(text[lastIndex..<text.endIndex]))
        }
        
    } catch {
        print("Invalid regex: \(error.localizedDescription)")
    }
    
    return result
}

// A simple utility to format AI response text.
func formatAIResponse4(_ text: String) -> AttributedString {
    var result = AttributedString()
    var lastIndex = text.startIndex

    // Regular expression to find all Markdown elements.
    // This looks for headings (#), bold text (**...**), and list items (* ).
    let regexPattern = "(#+ .*)|(\\*\\*.*?\\*\\*)|(\\* .*)"
    
    do {
        let regex = try NSRegularExpression(pattern: regexPattern, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        for match in matches {
            guard let swiftRange = Range(match.range, in: text) else { continue }
            
            // Append the text before the match
            if lastIndex < swiftRange.lowerBound {
                result.append(AttributedString(text[lastIndex..<swiftRange.lowerBound]))
            }
            
            let markdownSubstring = String(text[swiftRange])
            
            if markdownSubstring.hasPrefix("#") {
                // Handle headings
                let trimmed = markdownSubstring.drop(while: { $0 == "#" || $0.isWhitespace })
                var attributedString = AttributedString(String(trimmed))
                attributedString.font = .title.bold()
                result.append(attributedString)
            } else if markdownSubstring.hasPrefix("* ") {
                // Handle list items
                let trimmed = markdownSubstring.dropFirst(2)
                var attributedString = AttributedString("• " + String(trimmed))
                result.append(attributedString)
            } else if markdownSubstring.hasPrefix("*") {
                // Handle bold text
                let trimmed = markdownSubstring.dropFirst(2).dropLast(2)
                var attributedString = AttributedString(String(trimmed))
                attributedString.font = .body.bold()
                result.append(attributedString)
            }
            
            lastIndex = swiftRange.upperBound
        }
        
        // Append any remaining text after the last match
        if lastIndex < text.endIndex {
            result.append(AttributedString(text[lastIndex..<text.endIndex]))
        }
        
    } catch {
        print("Invalid regex: \(error.localizedDescription)")
    }
    
    return result
}

// MARK: - Photo Picker Wrapper
// Wraps the UIKit PHPickerViewController for use in SwiftUI.
struct PhotoPicker2: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker2

        init(_ parent: PhotoPicker2) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let result = results.first else { return }

            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

// MARK: - Image Compression
func compressImage1(image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat, quality: CGFloat) -> Data? {
    let size = image.size
    var newSize: CGSize

    if size.width > maxWidth || size.height > maxHeight {
        let widthRatio = maxWidth / size.width
        let heightRatio = maxHeight / size.height
        let ratio = min(widthRatio, heightRatio)
        newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
    } else {
        newSize = size
    }

    // UIGraphicsBeginImageContextWithOptions will create a bitmap graphics context
    // It's the standard way to resize images on iOS.
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: CGRect(origin: .zero, size: newSize))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage?.jpegData(compressionQuality: quality)
}

// MARK: - Main Content View
struct GeminiAIView: View {
    @State private var promptText: String = ""
    @State private var responseText: String = ""
    @State private var isLoading: Bool = false
    @State private var saveMessage: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingPhotoPicker = false

    // In a real app, you would use a secure way to store your API key.
    // For this example, we'll keep it as a constant.
    let apiKey: String = ""
    
    let SYSTEM_PROMPT = "You are a world-class photography instructor. Please analyze this photo's composition, lighting, subject matter, and technical execution, and provide expert suggestions for improvement. Your response should use Markdown formatting, including headings, bold text, and lists, to ensure clarity and readability. All your responses must be in English."

    @MainActor
    func sendToAI() async {
        guard !promptText.isEmpty || selectedImage != nil else {
            return
        }

        isLoading = true
        saveMessage = ""

        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            self.responseText = "错误: 无效的 URL"
            self.isLoading = false
            return
        }
        
        var parts: [[String: Any]] = []
        
        // Add text prompt
        if !promptText.isEmpty {
            parts.append(["text": promptText])
        }
        
        // Add image data
        if let image = selectedImage, let compressedData = compressImage(image: image, maxWidth: 1024, maxHeight: 1024, quality: 0.7) {
            let base64Image = compressedData.base64EncodedString()
            parts.append([
                "inlineData": [
                    "mimeType": "image/jpeg",
                    "data": base64Image
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
                        "text": SYSTEM_PROMPT
                    ]
                ]
            ]
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload) else {
            self.responseText = "错误: 无法创建请求体"
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = jsonResponse["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                self.responseText = text
            } else {
                self.responseText = "无法解析 AI 响应。"
            }
        } catch {
            self.responseText = "发生错误: \(error.localizedDescription)"
        }

        self.isLoading = false
    }

    func saveToFile() {
        guard !responseText.isEmpty else {
            saveMessage = "没有内容可保存。"
            return
        }

        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "AI_Response_\(Int(Date().timeIntervalSince1970)).txt"
        let fileURL = documentDirectory.appendingPathComponent(fileName)

        do {
            try responseText.write(to: fileURL, atomically: true, encoding: .utf8)
            saveMessage = "文件已保存到: \(fileURL.path)"
        } catch {
            saveMessage = "保存文件失败: \(error.localizedDescription)"
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("AI 助手")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack {
                Button(action: {
                    self.showingPhotoPicker = true
                }) {
                    VStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 5)
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 30))
                                        .foregroundColor(.gray)
                                )
                        }
                        Text(selectedImage == nil ? "选择照片" : "已选择")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .sheet(isPresented: $showingPhotoPicker) {
                    PhotoPicker2(selectedImage: $selectedImage)
                }
                
                // TextEditor for user input
                TextEditor(text: $promptText)
                    .frame(height: 150)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal)
            
            // Buttons for actions
            HStack {
                Button("发送到 AI") {
                    Task {
                        await sendToAI()
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading || (promptText.isEmpty && selectedImage == nil))
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                Spacer()
                
                Button("保存为文件") {
                    saveToFile()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(responseText.isEmpty)
            }
            
            // Display AI response
            ScrollView {
                if !responseText.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        if let att = formatAIResponse(responseText) {
                            Text(att)
                                .lineSpacing(5)
                        }
//                        Text(formatAIResponse(responseText))
//                            .lineSpacing(5)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                } else {
                    Text("AI 回复将显示在此处。")
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            
            // Save message
            if !saveMessage.isEmpty {
                Text(saveMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        .padding()
    }
}


#Preview {
    GeminiAIView()
}
