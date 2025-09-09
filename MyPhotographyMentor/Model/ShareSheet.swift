//
//  ShareSheet.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/10.
//

import CoreGraphics
import PDFKit
import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}

extension TextFileViewModel {
    func generatePDFTempURL(withImage image: UIImage) async -> URL? {
        guard let ns = nsAttributed else { return nil }

        let pdfURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent("AI_PhotoAnalysis.pdf")
        let path = pdfURL.path()

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                // 2. 调用生成PDF的方法
                //                if let pdfData = generateMultiPagePDF(from: ns) {
                if let pdfData = generateMultiPagePDF(
                    from: ns,
                    withImage: image
                ) {
                    // 3. 将PDF数据保存到文件中
                    do {
                        try pdfData.write(to: pdfURL)
                        if FileManager.default.fileExists(atPath: path) {
                            let size =
                                (try? FileManager.default.attributesOfItem(
                                    atPath: path
                                )[.size] as? Int) ?? 0
                            print("pdf文件，存在: \(path), 大小 \(size) bytes")
                            continuation.resume(returning: pdfURL)
                        } else {
                            print("❌ pdf文件，不存在: \(path)")
                            continuation.resume(returning: nil)
                        }
                    } catch {
                        print("保存PDF文件时出错: \(error)")
                        continuation.resume(returning: nil)
                    }
                } else {
                    continuation.resume(returning: nil)
                }

            }  // DispatchQueue.global(qos: .userInitiated).async {

        }
    }
}

func generateMultiPagePDF1(from attributedString: NSAttributedString) -> Data? {
    // 1. 设置PDF页面和绘制区域
    let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)  // Letter 纸张大小
    let textMargin = UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36)
    let drawableRect = CGRect(
        x: textMargin.left,
        y: textMargin.top,
        width: pageRect.width - textMargin.left - textMargin.right,
        height: pageRect.height - textMargin.top - textMargin.bottom
    )

    let format = UIGraphicsPDFRendererFormat()
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

    let data = renderer.pdfData { context in
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        // 创建第一个文本容器
        let textContainer = NSTextContainer(size: drawableRect.size)
        layoutManager.addTextContainer(textContainer)

        var currentGlyphIndex = 0
        let totalGlyphs = layoutManager.numberOfGlyphs

        // 循环绘制，处理多页内容
        while currentGlyphIndex < totalGlyphs {
            context.beginPage()

            // 使用 textContainer(forGlyphAt:) 确保布局管理器从正确的位置开始
            let container = layoutManager.textContainer(
                forGlyphAt: currentGlyphIndex,
                effectiveRange: nil
            )

            // 找到可以容纳在当前页面的文本范围
            let glyphRange = layoutManager.glyphRange(for: container!)

            // 绘制文本
            layoutManager.drawGlyphs(
                forGlyphRange: glyphRange,
                at: drawableRect.origin
            )

            // 更新已绘制的文本索引
            currentGlyphIndex += glyphRange.length

            // 如果还有剩余文本，添加一个新的文本容器
            if currentGlyphIndex < totalGlyphs {
                let newTextContainer = NSTextContainer(size: drawableRect.size)
                layoutManager.addTextContainer(newTextContainer)
            }
        }
    }
    return data
}

func generateMultiPagePDF(
    from attributedString: NSAttributedString,
    withImage image: UIImage
) -> Data? {
    let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)  // Letter 纸张大小
    let format = UIGraphicsPDFRendererFormat()
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

    let textMargin = UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36)
    let drawableRect = CGRect(
        x: textMargin.left,
        y: textMargin.top,
        width: pageRect.width - textMargin.left - textMargin.right,
        height: pageRect.height - textMargin.top - textMargin.bottom
    )

    let data = renderer.pdfData { context in
        var currentPageNumber = 1  // 页码

        // --- 绘制第一页：标题和照片 ---
        context.beginPage()

        let title = "Photo Analysis By AI"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.black,
        ]
        let titleString = NSAttributedString(
            string: title,
            attributes: titleAttributes
        )
        let titleRect = CGRect(
            x: drawableRect.minX,
            y: drawableRect.minY,
            width: drawableRect.width,
            height: 30
        )
        titleString.draw(in: titleRect)

        // 计算图像的显示尺寸和位置，保持长宽比
        let imageSize = image.size
        let maxImageWidth = drawableRect.width
        // 为日期和页脚预留空间
        let maxImageHeight = drawableRect.height - titleRect.maxY - 20 - 40 - 20
        let imageRatio = min(
            maxImageWidth / imageSize.width,
            maxImageHeight / imageSize.height
        )
        let scaledImageWidth = imageSize.width * imageRatio
        let scaledImageHeight = imageSize.height * imageRatio

        let imageRect = CGRect(
            x: drawableRect.minX + (drawableRect.width - scaledImageWidth) / 2,
            y: titleRect.maxY + 20,
            width: scaledImageWidth,
            height: scaledImageHeight
        )
        image.draw(in: imageRect)

        // 绘制日期时间
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
//        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        let dateTimeString = dateFormatter.string(from: Date())
        let dateTimeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.gray,
        ]
        let dateTimeStringSize = dateTimeString.size(
            withAttributes: dateTimeAttributes
        )
        let dateTimeRect = CGRect(
            x: drawableRect.minX
                + (drawableRect.width - dateTimeStringSize.width) / 2,
            y: imageRect.maxY + 10,
            width: dateTimeStringSize.width,
            height: dateTimeStringSize.height
        )
        dateTimeString.draw(
            in: dateTimeRect,
            withAttributes: dateTimeAttributes
        )

        // 绘制第一页的页码
        drawPageNumber(
            pageNumber: currentPageNumber,
            in: context,
            pageRect: pageRect
        )
        currentPageNumber += 1

        // --- 绘制后续页面：NSAttributedString 内容 ---

        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        // 创建第一个文本容器
        let textContainer = NSTextContainer(size: drawableRect.size)
        layoutManager.addTextContainer(textContainer)

        var currentGlyphIndex = 0
        let totalGlyphs = layoutManager.numberOfGlyphs

        // 循环绘制，处理多页内容
        while currentGlyphIndex < totalGlyphs {
            context.beginPage()

            // 使用 textContainer(forGlyphAt:) 确保布局管理器从正确的位置开始
            let container = layoutManager.textContainer(
                forGlyphAt: currentGlyphIndex,
                effectiveRange: nil
            )

            // 找到可以容纳在当前页面的文本范围
            let glyphRange = layoutManager.glyphRange(for: container!)

            // 绘制文本
            layoutManager.drawGlyphs(
                forGlyphRange: glyphRange,
                at: drawableRect.origin
            )

            // 绘制当前页的页码
            drawPageNumber(
                pageNumber: currentPageNumber,
                in: context,
                pageRect: pageRect
            )
            currentPageNumber += 1

            // 更新已绘制的文本索引
            currentGlyphIndex += glyphRange.length

            // 如果还有剩余文本，添加一个新的文本容器
            if currentGlyphIndex < totalGlyphs {
                let newTextContainer = NSTextContainer(size: drawableRect.size)
                layoutManager.addTextContainer(newTextContainer)
            }
        }

    }
    return data
}

// 辅助函数：用于绘制页码
func drawPageNumber(
    pageNumber: Int,
    in context: UIGraphicsPDFRendererContext,
    pageRect: CGRect
) {
    let pageNumberString = "\(pageNumber)"
    let pageNumberAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 12),
        .foregroundColor: UIColor.gray,
    ]
    let pageNumberStringSize = pageNumberString.size(
        withAttributes: pageNumberAttributes
    )

    // 计算页码的绘制位置（底部居中）
    let x = (pageRect.width - pageNumberStringSize.width) / 2
    let y = pageRect.height - 36  // 距离底部 36 点

    let rect = CGRect(
        x: x,
        y: y,
        width: pageNumberStringSize.width,
        height: pageNumberStringSize.height
    )

    // 在PDF上下文中绘制页码
    pageNumberString.draw(in: rect, withAttributes: pageNumberAttributes)
}
