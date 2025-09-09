//
//  TextFileViewModel.swift
//  MarkdownTextViewer
//
//  Manual Markdown -> NSAttributedString renderer (fixed heading inline parsing)
//  Supports headings, paragraphs, ordered/unordered nested lists, inline **bold** and *italic*,
//  search highlight, and PDF export (single-page example).
//
//  Created by 范志勇 on 2025/9/9.
//

import Combine
import SwiftUI
import UIKit

@MainActor
class TextFileViewModel: ObservableObject {
    @Published var plainText: String = ""
    @Published var attributedContent: AttributedString? = nil  // for SwiftUI
    @Published var searchText: String = "" {
        didSet { applySearchHighlight() }
    }
    @Published var fontSize: CGFloat = 16 {
        didSet { renderFromPlainTextKeepHighlight() }
    }

    // Keep an NSAttributedString copy for highlighting / pdf export
    var nsAttributed: NSAttributedString?

    var fileName: String = "未加载"
    private let defaultBundleFile = "文本-4FCF-9AB5-4F-0"

    // MARK: - Load helpers
    // 方式1：读取文件
    func reloadFromDefaultBundle() {
        fileName = "\(defaultBundleFile).txt"
        if let url = Bundle.main.url(
            forResource: defaultBundleFile,
            withExtension: "txt"
        ) {
            load(from: url)
            return
        }
        if let docs = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first {
            let fileURL = docs.appendingPathComponent(
                "\(defaultBundleFile).txt"
            )
            if FileManager.default.fileExists(atPath: fileURL.path) {
                load(from: fileURL)
                return
            }
        }
        plainText = "无法找到文件: \(defaultBundleFile).txt"
        nsAttributed = nil
        attributedContent = nil
    }

    // 方式1：读取文件
    func load(from url: URL) {
        fileName = url.lastPathComponent
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            plainText = content
            renderFromPlainTextKeepHighlight()
        } catch {
            plainText = "读取失败: \(error.localizedDescription)"
            nsAttributed = nil
            attributedContent = nil
        }
    }

    // 方式2：直接转换文本：markdown
    func renderMarkdown(_ markdown: String) {
        plainText = markdown
        renderFromPlainTextKeepHighlight()
    }

    // MARK: - Render pipeline
    private func renderFromPlainTextKeepHighlight() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        nsAttributed = markdownToAttributedString(
            plainText,
            baseFontSize: fontSize
        )
        updatePublishedFromNSAttributed()
        if !query.isEmpty {
            applySearchHighlight()  // reapply
        }
    }

    private func updatePublishedFromNSAttributed() {
        guard let ns = nsAttributed else {
            attributedContent = nil
            return
        }
        if #available(iOS 15.0, *) {
            attributedContent =
                (try? AttributedString(ns, including: \.uiKit))
                ?? AttributedString(ns.string)
        } else {
            attributedContent = AttributedString(ns.string)
        }
    }

    // MARK: - Markdown -> NSMutableAttributedString (manual renderer)
    private func markdownToAttributedString(
        _ markdown: String,
        baseFontSize: CGFloat
    ) -> NSAttributedString {
        // Normalize newlines
        var text = markdown.replacingOccurrences(of: "\r\n", with: "\n")
        text = text.replacingOccurrences(of: "\r", with: "\n")

        // Split lines but we will group into blocks
        let rawLines = text.components(separatedBy: .newlines)

        let result = NSMutableAttributedString()
        let baseFont = UIFont.systemFont(ofSize: max(10, baseFontSize))
        let baseFontBold = UIFont.boldSystemFont(ofSize: max(10, baseFontSize))

        // paragraph styles defaults
        func paragraphStyle(
            paragraphSpacing: CGFloat = 6,
            firstIndent: CGFloat = 0,
            headIndent: CGFloat = 0
        ) -> NSMutableParagraphStyle {
            let p = NSMutableParagraphStyle()
            p.paragraphSpacing = paragraphSpacing
            p.firstLineHeadIndent = firstIndent
            p.headIndent = headIndent
            p.lineBreakMode = .byWordWrapping
            return p
        }

        // helper: apply inline bold/italic to a plain text and return attributed
        func attributedInline(from plain: String, font: UIFont)
            -> NSMutableAttributedString
        {
            let mutable = NSMutableAttributedString(
                string: plain,
                attributes: [.font: font, .foregroundColor: UIColor.label]
            )
            // bold **...**
            if let re = try? NSRegularExpression(
                pattern: "\\*\\*(.+?)\\*\\*",
                options: []
            ) {
                let full = mutable.string as NSString
                let matches = re.matches(
                    in: full as String,
                    options: [],
                    range: NSRange(location: 0, length: full.length)
                )
                for m in matches.reversed() {
                    if m.numberOfRanges >= 2 {
                        let inner = full.substring(with: m.range(at: 1))
                        mutable.replaceCharacters(in: m.range, with: inner)
                        let rng = NSRange(
                            location: m.range.location,
                            length: (inner as NSString).length
                        )
                        let newFont = UIFont.boldSystemFont(
                            ofSize: font.pointSize
                        )
                        mutable.addAttribute(.font, value: newFont, range: rng)
                        mutable.addAttribute(
                            .foregroundColor,
                            value: UIColor.systemPink,
                            range: rng
                        )  // optional color for bold
                    }
                }
            }
            // italic *...* (avoid interfering with bold)
            if let re = try? NSRegularExpression(
                pattern: "(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)",
                options: []
            ) {
                let full = mutable.string as NSString
                let matches = re.matches(
                    in: full as String,
                    options: [],
                    range: NSRange(location: 0, length: full.length)
                )
                for m in matches.reversed() {
                    if m.numberOfRanges >= 2 {
                        let inner = full.substring(with: m.range(at: 1))
                        mutable.replaceCharacters(in: m.range, with: inner)
                        let rng = NSRange(
                            location: m.range.location,
                            length: (inner as NSString).length
                        )
                        if let desc = font.fontDescriptor.withSymbolicTraits(
                            .traitItalic
                        ) {
                            let it = UIFont(
                                descriptor: desc,
                                size: font.pointSize
                            )
                            mutable.addAttribute(.font, value: it, range: rng)
                        }
                    }
                }
            }
            return mutable
        }

        // list counters for ordered lists: maintain per-level counter
        var orderedCounters: [Int: Int] = [:]
        var lastListLevel: Int = -1

        // process line by line, but we keep paragraphs that are plain text
        var i = 0
        while i < rawLines.count {
            let raw = rawLines[i]
            // keep original leading spaces to detect nesting
            let nsRaw = raw as NSString

            // Skip empty lines => add an empty paragraph
            if raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                result.append(
                    NSAttributedString(
                        string: "\n",
                        attributes: [.font: baseFont]
                    )
                )
                i += 1
                lastListLevel = -1
                continue
            }

            // --- HEADING HANDLING (fixed) ---
            // Match heading lines and process heading text with inline parser so **...** are interpreted
            if let hMatch = raw.range(
                of: #"^(#{1,6})\s*(.+)$"#,
                options: .regularExpression
            ) {
                let line = String(raw[hMatch])
                if let hashRange = line.range(
                    of: #"^#{1,6}"#,
                    options: .regularExpression
                ) {
                    let hashes = String(line[hashRange])
                    let level = hashes.count
                    // heading text (may include ** or *)
                    var title = line.replacingOccurrences(
                        of: #"^#{1,6}\s*"#,
                        with: "",
                        options: .regularExpression
                    )

                    // use inline parser to remove **/*** markers while preserving inline bold/italic
                    let titleAttr = attributedInline(
                        from: title,
                        font: baseFont
                    )

                    // Now scale fonts in titleAttr according to heading level while preserving bold/italic traits
                    let size: CGFloat
                    switch level {
                    case 1: size = max(24, baseFontSize + 10)
                    case 2: size = max(24, baseFontSize + 10)
                    case 3: size = max(22, baseFontSize + 2)
                    case 4: size = max(18, baseFontSize + 2)
                    default: size = max(14, baseFontSize)
                    }

                    // enumerate fonts inside titleAttr and replace with scaled fonts preserving traits
                    let titleNS = titleAttr
                    titleNS.enumerateAttribute(
                        .font,
                        in: NSRange(location: 0, length: titleNS.length),
                        options: []
                    ) { val, range, _ in
                        if let f = val as? UIFont {
                            // preserve symbolic traits if possible
                            let traits = f.fontDescriptor.symbolicTraits
                            var desc = f.fontDescriptor.withSize(size)
                            if let withTraits = desc.withSymbolicTraits(traits)
                            {
                                desc = withTraits
                            }
                            let newFont = UIFont(descriptor: desc, size: size)
                            titleNS.addAttribute(
                                .font,
                                value: newFont,
                                range: range
                            )
                        } else {
                            titleNS.addAttribute(
                                .font,
                                value: UIFont.boldSystemFont(ofSize: size),
                                range: range
                            )
                        }
                    }

                    // paragraph style and color
                    let para = paragraphStyle(
                        paragraphSpacing: 8,
                        firstIndent: 0,
                        headIndent: 0
                    )
                    titleNS.addAttribute(
                        .paragraphStyle,
                        value: para,
                        range: NSRange(location: 0, length: titleNS.length)
                    )
                    // set heading color (example: blue for h1/h2 etc.)
                    let headingColor: UIColor = {
                        switch level {
                        case 1: return UIColor.systemGreen
                        case 2: return UIColor.systemGreen
                        case 3: return UIColor.systemBlue
                        case 4: return UIColor.systemIndigo
                        default: return UIColor.systemPink
                        }
                    }()
                    titleNS.addAttribute(
                        .foregroundColor,
                        value: headingColor,
                        range: NSRange(location: 0, length: titleNS.length)
                    )

                    // append and newline
                    result.append(titleNS)
                    result.append(NSAttributedString(string: "\n"))
                    i += 1
                    lastListLevel = -1
                    continue
                }
            }

            // Unordered list item? pattern: ^(\s*)([-*+])\s+(.+)
            if let match = try? NSRegularExpression(
                pattern: #"^(\s*)([\-\*\+])\s+(.+)$"#,
                options: []
            ).firstMatch(
                in: raw,
                options: [],
                range: NSRange(location: 0, length: nsRaw.length)
            ) {
                let indentRange = match.range(at: 1)
                let contentRange = match.range(at: 3)
                let indentSpaces =
                    (indentRange.location != NSNotFound)
                    ? nsRaw.substring(with: indentRange).count : 0

                // ⚠️ 这里改：一个缩进层次 = 2 或 4 空格（看你的 Markdown 用法）
                let level =
                    indentSpaces >= 4
                    ? indentSpaces / 4
                    : (indentSpaces >= 2 ? indentSpaces / 2 : 0)

                let content = nsRaw.substring(with: contentRange)

                // 内容加 inline 样式
                let contentAttr = attributedInline(
                    from: content,
                    font: baseFont
                )

                // bullet
                var bullet = "    ●  "
                if level == 1 {
                    bullet = "        -  "
                } else if level == 2 {
                    bullet = "        -  "
                }
                let bulletAttr = NSAttributedString(
                    string: bullet,
                    attributes: [
                        .font: baseFont, .foregroundColor: UIColor.systemGray,
                    ]
                )

                let lineMutable = NSMutableAttributedString()
                lineMutable.append(bulletAttr)
                lineMutable.append(contentAttr)

                // ✅ 这里缩进要随 level 增加
                let indentLeft: CGFloat = 16 + CGFloat(level) * 20
                let headIndent = indentLeft + 14
                let para = paragraphStyle(
                    paragraphSpacing: 6,
                    firstIndent: indentLeft,
                    headIndent: headIndent
                )
                lineMutable.addAttribute(
                    .paragraphStyle,
                    value: para,
                    range: NSRange(location: 0, length: lineMutable.length)
                )

                result.append(lineMutable)
                result.append(NSAttributedString(string: "\n"))
                i += 1
                lastListLevel = level
                continue
            }

            // Ordered list item? pattern: ^(\s*)(\d+)\.\s+(.+)
            if let match = try? NSRegularExpression(
                pattern: #"^(\s*)(\d+)\.\s+(.+)$"#,
                options: []
            ).firstMatch(
                in: raw,
                options: [],
                range: NSRange(location: 0, length: nsRaw.length)
            ) {
                let indentRange = match.range(at: 1)
                let contentRange = match.range(at: 3)
                let indentSpaces =
                    (indentRange.location != NSNotFound)
                    ? nsRaw.substring(with: indentRange).count : 0
                let level = indentSpaces / 4
                let content = nsRaw.substring(with: contentRange)

                // When encountering an ordered items
                // remove counters for deeper levels
                for k in orderedCounters.keys where k > level {
                    orderedCounters.removeValue(forKey: k)
                }

                // increment the counter for this level
                orderedCounters[level] = (orderedCounters[level] ?? 0) + 1
                let counter = orderedCounters[level] ?? 1

                // prepare content and prefix
                let prefix = "    \(counter). "
                let prefixAttr = NSAttributedString(
                    string: prefix,
                    attributes: [
                        .font: baseFontBold,
                        .foregroundColor: UIColor.systemPink,
                    ]
                )  //UIColor.labe
                let contentAttr = attributedInline(
                    from: content,
                    font: baseFont
                )
                let lineMutable = NSMutableAttributedString()
                lineMutable.append(prefixAttr)
                lineMutable.append(contentAttr)

                let indentLeft: CGFloat = 16 + CGFloat(level) * 18
                let headIndent = indentLeft + 22  // more space for numbers
                let para = paragraphStyle(
                    paragraphSpacing: 6,
                    firstIndent: indentLeft,
                    headIndent: headIndent
                )
                lineMutable.addAttribute(
                    .paragraphStyle,
                    value: para,
                    range: NSRange(location: 0, length: lineMutable.length)
                )

                result.append(lineMutable)
                result.append(NSAttributedString(string: "\n"))
                i += 1
                lastListLevel = level
                continue
            }

            // Otherwise treat as a paragraph — maybe multiple consecutive lines until an empty line
            var paraLines: [String] = []
            var j = i
            while j < rawLines.count {
                let l = rawLines[j]
                if l.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    break
                }
                if l.range(of: #"^(#{1,6})\s+.*$"#, options: .regularExpression)
                    != nil
                {
                    break
                }
                if l.range(
                    of: #"^(\s*)[\-\*\+]\s+.*$"#,
                    options: .regularExpression
                ) != nil {
                    break
                }
                if l.range(
                    of: #"^(\s*)\d+\.\s+.*$"#,
                    options: .regularExpression
                ) != nil {
                    break
                }
                paraLines.append(l)
                j += 1
            }
            // join lines with space (preserve word boundaries)
            let paraText = paraLines.joined(separator: " ").trimmingCharacters(
                in: .whitespaces
            )
            let paraAttr = attributedInline(from: paraText, font: baseFont)
            let paraStyle = paragraphStyle(
                paragraphSpacing: 8,
                firstIndent: 0,
                headIndent: 0
            )
            paraAttr.addAttribute(
                .paragraphStyle,
                value: paraStyle,
                range: NSRange(location: 0, length: paraAttr.length)
            )
            result.append(paraAttr)
            result.append(NSAttributedString(string: "\n"))
            i = j
            lastListLevel = -1
        }

        return result
    }

    // MARK: - Search highlight
    private func applySearchHighlight() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            // restore original
            updatePublishedFromNSAttributed()
            return
        }
        guard let base = nsAttributed else {
            return
        }
        let mutable = NSMutableAttributedString(attributedString: base)
        let lower = mutable.string.lowercased() as NSString
        let q = query.lowercased()
        var start = 0
        while start < lower.length {
            let remaining = lower.length - start
            let r = lower.range(
                of: q,
                options: .caseInsensitive,
                range: NSRange(location: start, length: remaining)
            )
            if r.location == NSNotFound { break }
            // add highlight while preserving font
            mutable.addAttribute(
                .backgroundColor,
                value: UIColor.yellow.withAlphaComponent(0.9),
                range: r
            )
            mutable.addAttribute(
                .foregroundColor,
                value: UIColor.black,
                range: r
            )
            start = r.location + r.length
        }
        // publish
        if #available(iOS 15.0, *) {
            attributedContent =
                (try? AttributedString(mutable, including: \.uiKit))
                ?? AttributedString(mutable.string)
        } else {
            attributedContent = AttributedString(mutable.string)
        }
    }

    /*
    // MARK: - PDF export (single page example, no pagination)
    func exportPDF(to url: URL, pageSize: CGSize = CGSize(width: 595, height: 842)) throws {
        guard let ns = nsAttributed else {
            throw NSError(domain: "Export", code: 1, userInfo: [NSLocalizedDescriptionKey: "没有可导出的文档内容"])
        }
    
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)
        try renderer.writePDF(to: url) { ctx in
            ctx.beginPage()
            let inset: CGFloat = 36
            let drawingRect = CGRect(x: inset, y: inset, width: pageSize.width - inset * 2, height: pageSize.height - inset * 2)
            // naive draw (won't paginate). For long docs implement pagination by measuring text frames.
            ns.draw(in: drawingRect)
        }
    }
    */

    
    // MARK: - PDF export (multi-page with proper pagination)
    func exportPDF(
        to url: URL,
        pageSize: CGSize = CGSize(width: 595, height: 842)
    ) throws {
        guard let ns = nsAttributed else {
            throw NSError(
                domain: "Export",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "没有可导出的文档内容"]
            )
        }

        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(origin: .zero, size: pageSize),
            format: format
        )
        /*
        try renderer.writePDF(to: url) { ctx in
            var currentY: CGFloat = 0
            let inset: CGFloat = 36
            let drawingRect = CGRect(
                x: inset,
                y: inset,
                width: pageSize.width - inset * 2,
                height: pageSize.height - inset * 2
            )
            let lineHeight: CGFloat = 20  // define line height for pagination

            // Render content
            ns.enumerateAttributes(
                in: NSRange(location: 0, length: ns.length),
                options: []
            ) { (attrs, range, stop) in
                let text = ns.attributedSubstring(from: range)

                // Check if current content will overflow current page
                if currentY + lineHeight > pageSize.height {
                    ctx.beginPage()  // start new page
                    currentY = inset  // reset Y position for new page
                }

                text.draw(
                    in: CGRect(
                        x: drawingRect.origin.x,
                        y: currentY,
                        width: drawingRect.width,
                        height: lineHeight
                    )
                )
                currentY += lineHeight
            }
        }
        */
        do {
            try renderer.writePDF(to: url) { ctx in
                var currentY: CGFloat = 0
                let inset: CGFloat = 36
                let drawingRect = CGRect(
                    x: inset,
                    y: inset,
                    width: pageSize.width - inset * 2,
                    height: pageSize.height - inset * 2
                )
                let lineHeight: CGFloat = 20  // define line height for pagination

                // Render content
                ns.enumerateAttributes(
                    in: NSRange(location: 0, length: ns.length),
                    options: []
                ) { (attrs, range, stop) in
                    let text = ns.attributedSubstring(from: range)

                    // Check if current content will overflow current page
                    if currentY + lineHeight > pageSize.height {
                        ctx.beginPage()  // start new page
                        currentY = inset  // reset Y position for new page
                    }

                    text.draw(
                        in: CGRect(
                            x: drawingRect.origin.x,
                            y: currentY,
                            width: drawingRect.width,
                            height: lineHeight
                        )
                    )
                    currentY += lineHeight
                }
            }
            
            print("PDF 文件导出成功，路径：\(url.path())")
        } catch {
            print("PDF 导出失败：\(error)")
            throw error
        }
        
    }

    // MARK: - Share PDF
    func sharePDF(from viewController: UIViewController) {
        // Save the generated PDF to a temporary URL
        let pdfURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("document.pdf")

        do {
            try exportPDF(to: pdfURL)  // Generate the PDF file
            let activityViewController = UIActivityViewController(
                activityItems: [pdfURL],
                applicationActivities: nil
            )
            viewController.present(
                activityViewController,
                animated: true,
                completion: nil
            )
        } catch {
            print("Failed to generate PDF: \(error.localizedDescription)")
        }
    }

}

