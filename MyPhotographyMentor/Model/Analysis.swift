//
//  Analysis.swift
//  MyPhotographyMentor
//
//  Created by 范志勇 on 2025/9/10.
//

import Foundation
import PhotosUI
import SwiftUI
import UIKit
import UniformTypeIdentifiers

// 硬编码的文本内容
let textContent = """
    This is a lovely capture with significant artistic potential! You've successfully highlighted the delicate beauty of the peony. As your photography instructor, I see many strengths in this image, along with clear opportunities to elevate it from a good photograph to a truly outstanding one.

    Let's break it down:

    ---

    ### **Professional Analysis & Evaluation**

    #### **1. Composition**

    *   **Strengths:**
        *   **Effective Depth of Field:** The shallow depth of field beautifully isolates the main peony, creating a soft, dreamy bokeh in the background. This immediately draws the viewer's eye to your intended subject.
        *   **Pleasant Color Palette:** The blend of soft pinks, whites, and greens in the foreground, contrasted with the vibrant, blurred reds and greens in the background, creates an appealing color harmony.
        *   **Leading Lines (Subtle):** The diagonal stem leading into the main flower, along with the implied curve of the petals, gently guides the eye.

    *   **Areas for Improvement:**
        *   **Subject Placement:** The main peony is quite centered and feels a bit "cut off" on the right side. While it's largely dominant, the slight crop on the right edge of the main flower, and the presence of other cropped flower parts on the far right and bottom left, create visual tension.
        *   **Distracting Elements:** The partial flowers on the far right and bottom left, along with the somewhat prominent green leaves (especially the one creating a strong diagonal on the left, and the one crossing behind the main flower) compete for attention and interrupt the flow. The bright bokeh circles in the background, while colorful, are also quite strong and pull the eye away from the main subject.
        *   **Negative Space:** The amount and quality of negative space could be improved to better frame the subject and allow it to breathe.

    #### **2. Lighting**

    *   **Strengths:**
        *   **Beautiful Backlighting/Side-Lighting:** The light source is coming from behind and slightly to the right, illuminating the delicate petals with a soft glow and creating a lovely translucency, especially on the pink lower petals. This highlights the texture and form of the flower beautifully.
        *   **Dynamic Range:** There's a good balance between light and shadow on the main flower, providing depth.

    *   **Areas for Improvement:**
        *   **Highlight Control:** Some of the brighter white petals on the top left of the main flower are very close to being "blown out," meaning they've lost detail due to overexposure. This is a common challenge with bright subjects in strong backlight.
        *   **Contrast in Shadows:** While the shadows add depth, a very subtle lift could reveal a touch more detail in the deepest parts of the flower without losing its form.

    #### **3. Subject Matter**

    *   **Strengths:**
        *   **Inherent Beauty:** Peonies are stunning flowers, and this one is a beautiful specimen with wonderful texture and color variation from white to deep pink.
        *   **Intimacy:** The close-up nature allows for appreciation of the individual petals and the intricate structure of the flower.

    *   **Areas for Improvement:**
        *   **Clarity of Intent:** While the main peony is clearly the subject, the presence of other partial flowers suggests a broader "field of flowers" idea that isn't fully realized, making the composition feel a little ambiguous. A clearer decision to focus solely on one flower, or to show a more deliberate arrangement of multiple flowers, would strengthen the image.

    #### **4. Technical Execution**

    *   **Strengths:**
        *   **Sharp Focus:** The main peony is sharply in focus, which is crucial for a close-up like this.
        *   **Pleasing Bokeh:** The background blur is smooth and creamy, enhancing the separation of the subject.
        *   **Vibrant Colors:** The colors are rich and appealing, suggesting a good white balance and color rendition.

    *   **Areas for Improvement:**
        *   **Dynamic Range Management:** As mentioned under lighting, careful exposure is needed to retain detail in both the brightest highlights and the deepest shadows.
        *   **Potential for Cleaner Edges:** While generally sharp, a slight refinement of the edges of the petals could enhance the definition.

    ---

    ### **Expert Suggestions for Improvement**

    To elevate this photograph further, consider these actionable steps:

    #### **1. Refine Your Composition**

    *   **Rule of Thirds/Golden Ratio:** Instead of centering the main peony, try placing it along one of the intersections of the Rule of Thirds grid. This often creates a more dynamic and pleasing composition.
    *   **Isolate the Subject:**
        *   **Change Your Angle:** Move around the flower. Experiment with shooting slightly higher, lower, or from a different side to find an angle where the main peony stands alone, or where other elements complement it rather than distract.
        *   **Simplify the Background:** Actively look for a "cleaner" background. This might mean getting lower to use the ground as background, or higher to use the sky (if possible), or simply finding a pocket where other flowers are farther away and blur out more effectively.
        *   **Eliminate Distractions:** Be ruthless with what's in your frame. Crop out those partial flowers on the edges. If a leaf is cutting across your subject, try to gently move it (without damaging the plant) or adjust your position.
    *   **Use Negative Space Deliberately:** Allow more "breathing room" around your main flower, especially if it helps to isolate it against a clean, blurred background.

    #### **2. Master the Light**

    *   **Control Highlights:**
        *   **Exposure Compensation:** Use your camera's exposure compensation dial to slightly underexpose (e.g., -0.3 to -0.7 EV) to protect those bright white petals. You can always brighten the overall image later in post-processing.
        *   **Shoot During Golden Hour:** The soft, warm light of early morning or late afternoon (golden hour) is often more forgiving for delicate white/light-colored subjects, reducing the harshness that can blow out highlights.
        *   **Diffused Light:** If shooting in harsh midday sun, look for shade or use a translucent diffuser to soften the light.
    *   **Enhance Shadows (Post-Processing):** In editing, gently lift the shadows a touch to reveal more detail in the darker parts of the flower, while still maintaining depth and contrast.

    #### **3. Enhance Subject Isolation**

    *   **Wider Aperture:** If your lens allows, use an even wider aperture (e.g., f/1.8 or f/2.8) to maximize background blur, provided you can maintain critical focus on your subject.
    *   **Distance to Background:** The more distance between your subject and the background elements, the blurrier the background will be. Look for subjects that are naturally separated from the background.

    #### **4. Post-Processing Refinements**

    *   **Crop for Impact:** Experiment with different crops to eliminate distractions and strengthen the composition. For instance, cropping out the partial flower on the right and bottom left, and potentially giving a bit more space to the top and left, might enhance the main flower.
    *   **Global and Local Adjustments:**
        *   **Exposure & Contrast:** Adjust overall exposure to bring the mid-tones to life.
        *   **Highlights & Shadows:** Use the highlight and shadow sliders to recover detail in the brightest and darkest areas.
        *   **White & Black Points:** Set your white and black points to ensure good contrast.
        *   **Clarity/Texture (Subtle):** A very subtle increase in clarity or texture can enhance the delicate details of the petals without making them look harsh.
        *   **Color Grading:** Play with saturation and vibrance, and perhaps a slight color grade, to evoke a specific mood. A touch of warmth might be beautiful here.
    *   **Vignette (Optional):** A subtle vignette can help draw the eye even more to the center of the image.
    *   **Spot Healing/Cloning:** If there are any tiny distracting specks or elements, use the spot healing brush to clean them up.

    ---

    This image has a fantastic foundation. By being more deliberate with your compositional choices and refining your exposure to handle those bright highlights, you'll undoubtedly create even more captivating floral portraits. Keep up the excellent work!
    """



// 把 <ol><li>...</li></ol> 扁平化为 "1. ..." 段落
private func flattenOrderedList(_ html: String) -> String {
    var result = html
    let pattern = "(?s)<ol>(.*?)</ol>"
    if let regex = try? NSRegularExpression(pattern: pattern) {
        let ns = result as NSString
        let matches = regex.matches(in: result, range: NSRange(location: 0, length: ns.length))
        for match in matches.reversed() {
            let listContent = ns.substring(with: match.range(at: 1))
            let liRegex = try! NSRegularExpression(pattern: "<li>(.*?)</li>", options: [.dotMatchesLineSeparators])
            let items = liRegex.matches(in: listContent, range: NSRange(location: 0, length: (listContent as NSString).length))
            var counter = 1
            var replacement = ""
            for li in items {
                let inner = (listContent as NSString).substring(with: li.range(at: 1))
                replacement += "<p>\(counter). \(inner)</p>\n"
                counter += 1
            }
            result = (result as NSString).replacingCharacters(in: match.range, with: replacement)
        }
    }
    return result
}

// 把 <ul><li>...</li></ul> 扁平化为 "• ..." 段落，保留嵌套层级缩进
private func flattenUnorderedList(_ html: String, level: Int = 0) -> String {
    var result = html
    let pattern = "(?s)<ul>(.*?)</ul>"
    if let regex = try? NSRegularExpression(pattern: pattern) {
        let ns = result as NSString
        let matches = regex.matches(in: result, range: NSRange(location: 0, length: ns.length))
        for match in matches.reversed() {
            let listContent = ns.substring(with: match.range(at: 1))

            // 递归处理嵌套 <ul>
            let inner = flattenUnorderedList(listContent, level: level + 1)

            // 把 <li> 转换成带缩进的行
            let liRegex = try! NSRegularExpression(pattern: "<li>(.*?)</li>", options: [.dotMatchesLineSeparators])
            let items = liRegex.matches(in: inner, range: NSRange(location: 0, length: (inner as NSString).length))
            var replacement = ""
            for li in items {
                let innerItem = (inner as NSString).substring(with: li.range(at: 1))
                let indent = String(repeating: "&nbsp;&nbsp;&nbsp;&nbsp;", count: max(0, level)) // 每层缩进4空格
                replacement += "<p>\(indent)• \(innerItem)</p>\n"
            }
            result = (result as NSString).replacingCharacters(in: match.range, with: replacement)
        }
    }
    return result
}



func processMarkdown(_ markdown: String) -> AttributedString? {
    do {
        // 解析 Markdown 为 NSAttributedString
        let nsAttributedString = try NSAttributedString(
            markdown: markdown,
            //            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace),
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace),
            baseURL: nil
        )

        // 创建可变 NSAttributedString
        let mutableAttributedString = NSMutableAttributedString(
            attributedString: nsAttributedString
        )

        // 分割
        let lines = markdown.components(separatedBy: .newlines)
        var currentIndex = 0

        // 遍历
        for line in lines {
            let range = NSRange(
                location: currentIndex,
                length: line.utf16.count
            )

            if line.hasPrefix("### ")
                && range.location + range.length
                    <= mutableAttributedString.length
            {
                // ## 一级标题
                mutableAttributedString.addAttributes(
                    [
                        .font: UIFont.boldSystemFont(ofSize: 24),
                        .foregroundColor: UIColor.systemBlue,
                    ],
                    range: NSRange(
                        location: currentIndex,
                        length: line.utf16.count - 4
                    )
                )
            } else if line.hasPrefix("#### ")
                && range.location + range.length
                    <= mutableAttributedString.length
            {
                // ### 二级标题
                mutableAttributedString.addAttributes(
                    [
                        .font: UIFont.boldSystemFont(ofSize: 20),
                        .foregroundColor: UIColor.systemGreen,
                    ],
                    range: NSRange(
                        location: currentIndex,
                        length: line.utf16.count - 4
                    )
                )
            }

            // 更新索引
            currentIndex += range.length + 1
        }

        // 转换为 AttributedString
        return AttributedString(mutableAttributedString)
    } catch {
        print("Markdown 解析失败: \(error)")
        return nil
    }
}

func formatAIResponse(_ markdown: String) -> AttributedString? {
    do {
        let attributedString = try NSAttributedString(
            markdown: markdown,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace),  //inlineOnlyPreservingWhitespace
            baseURL: nil
        )
        return AttributedString(attributedString)
    } catch {
        print("Markdown 解析失败: \(error)")
        return nil
    }
}

// A simple utility to format AI response text.
func formatAIResponseOK(_ text: String) -> AttributedString {
    var result = AttributedString()
    var lastIndex = text.startIndex

    // Regular expression to find all Markdown elements.
    // This looks for headings (#), bold text (**...**), and list items (* ).
    let regexPattern = "(#+ .*)|(\\*\\*.*?\\*\\*)|(\\* .*)"

    do {
        let regex = try NSRegularExpression(pattern: regexPattern, options: [])
        let matches = regex.matches(
            in: text,
            options: [],
            range: NSRange(location: 0, length: text.utf16.count)
        )

        for match in matches {
            guard let swiftRange = Range(match.range, in: text) else {
                continue
            }

            // Append the text before the match
            if lastIndex < swiftRange.lowerBound {
                result.append(
                    AttributedString(text[lastIndex..<swiftRange.lowerBound])
                )
            }

            let markdownSubstring = String(text[swiftRange])

            if markdownSubstring.hasPrefix("#") {
                // Handle headings
                let trimmed = markdownSubstring.drop(while: {
                    $0 == "#" || $0.isWhitespace
                })
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

// MARK: - Image Compression
func compressImage(
    image: UIImage,
    maxWidth: CGFloat,
    maxHeight: CGFloat,
    quality: CGFloat
) -> Data? {
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
