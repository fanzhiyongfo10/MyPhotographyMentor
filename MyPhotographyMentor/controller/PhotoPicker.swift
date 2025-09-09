//
//  PhotoPicker.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/10.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

// MARK: - UIViewControllerRepresentable Wrapper for PHPickerViewController
// This struct wraps the UIKit PHPickerViewController to be used in SwiftUI.
struct PhotoPicker: UIViewControllerRepresentable {
    // A binding to a UIImage to hold the selected image.
    @Binding var selectedImage: UIImage?
    
    // A binding to a String to hold the selected image's name.
    @Binding var selectedImageName: String?
//    @Binding var identifier_photo: String?
    
    // A binding to control the presentation of the picker.
    @Binding var showingPicker: Bool

    // Creates the PHPickerViewController.
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images // Allow only images
        config.selectionLimit = 1 // Allow only one selection

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    // This is called when the view updates, but we don't need to do anything here.
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    // Creates the coordinator that acts as the delegate for the PHPickerViewController.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator Class
    // The coordinator handles the communication from the PHPickerViewController back to our SwiftUI view.
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        // This method is called when the user finishes picking photos.
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Dismiss the picker view controller.
            parent.showingPicker = false

            guard let result = results.first else {
                self.parent.selectedImageName = nil
                return
            }
            
            // 获取照片的本地标识符
//            if let assetIdentifier = result.assetIdentifier {
//                self.parent.identifier_photo = assetIdentifier
//                // 调试：检测assetIdentifier
//                print(assetIdentifier)
//            }
            
            // Get the suggested name from the item provider.
            let suggestedName = result.itemProvider.suggestedName ?? "image"
            
            // Get the file extension from the item provider's uniform type identifier
            if let typeIdentifier = result.itemProvider.registeredTypeIdentifiers.first,
               let uttype = UTType(typeIdentifier),
               let fileExtension = uttype.preferredFilenameExtension {
                self.parent.selectedImageName = "\(suggestedName).\(fileExtension)"
                // 调试：检测assetIdentifier
                print("\(suggestedName).\(fileExtension)")
            } else {
                self.parent.selectedImageName = suggestedName
            }

            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                // Load the image on a background thread.
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let error = error {
                        print("Error loading image: \(error.localizedDescription)")
                        return
                    }

                    // Update the UI on the main thread.
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

func saveImageIdentifier(item: PHPickerResult) {
    // 获取照片的本地标识符
    if let assetIdentifier = item.assetIdentifier {
        // 在这里，你可以将 assetIdentifier 保存到你的数据库中
        print("保存本地标识符：\(assetIdentifier)")
        // 例如：
        // databaseManager.save(identifier: assetIdentifier)
    }
}

// ===== 使用 async/await 实现异步加载（推荐）
import Photos
import UIKit

/// 根据照片的本地标识符异步加载图片，使用 async/await。
///
/// - Parameter identifier: 照片在 Photos 库中的唯一本地标识符。
/// - Returns: 加载成功的 UIImage，如果未找到或加载失败则返回 nil。
func loadImageFromIdentifier(identifier: String) async throws -> UIImage? {
    return try await withCheckedThrowingContinuation { continuation in
        // 1. 根据本地标识符获取 PHAsset
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        guard let asset = fetchResult.firstObject else {
            continuation.resume(returning: nil)
            return
        }

        // 2. 创建图片请求选项
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        // 3. 从 PHAsset 请求图片数据
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { image, info in
            // 检查是否有错误信息
            if let error = info?[PHImageErrorKey] as? Error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(returning: image)
            }
        }
    }
}

// === 调用，在你的视图控制器或视图模型中
func loadAndDisplayImage(identifier: String) {
    // 使用 Task 在后台执行异步函数
    Task {
        do {
            let image = try await loadImageFromIdentifier(identifier: identifier)
            if let loadedImage = image {
                // UI 更新会自动回到主线程，无需 DispatchQueue.main.async
                // 调用
//                self.imageView.image = loadedImage
            } else {
                print("图片未找到")
            }
        } catch {
            print("图片加载失败：\(error)")
        }
    }
}
