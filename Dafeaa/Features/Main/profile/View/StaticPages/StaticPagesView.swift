//
//  StaticPagesView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct StaticPagesView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = MoreVM()
    var pageTitle :String{
        switch type {
        case .aboutApp :
            return "About Dafeaa".localized()
        case .privacyPolicy :
            return "Privacy Policy".localized()
        case .termsAndCondition :
            return "Terms & Conditions".localized()
        }
    }
    var content :String?{
        switch type {
        case .aboutApp :
           return viewModel.staticData?.about ?? ""
        case .privacyPolicy :
            return viewModel.staticData?.privacy ?? ""
        case .termsAndCondition :
            return viewModel.staticData?.terms ?? ""
        }

    }
    @State private var _dataContainer :  NSAttributedString?// = NSAttributedString(string: "")
    @Binding var type :StaticPages

    var body: some View {
        ZStack{
            VStack(spacing: 20){
                VStack{
                    NavigationBarView(title: pageTitle){
                        self.presentationMode.wrappedValue.dismiss()
                    }
//                    HTMLTextView(htmlText: content ?? "")
                    HTMLDescriptionView(html: content ?? "")
                        .padding([.leading,.trailing,.bottom],24)
                    
                    Spacer()
                }
                
               
            }
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            } else if viewModel.isFailed {
                ProgressView()
                    .hidden()
            }
        }.edgesIgnoringSafeArea(.bottom)
            .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)

        .onAppear(){
            switch type {
            case .aboutApp :
                viewModel.getStaticPages(type: "settings/about")
            case .privacyPolicy :
                viewModel.getStaticPages(type: "settings/privacy")
            case .termsAndCondition :
                viewModel.getStaticPages(type: "settings/terms")
            }
            AppState.shared.swipeEnabled = true
        }
        
    }
}

struct StaticPagesView_Previews: PreviewProvider {
    static var previews: some View {
        @State var type = StaticPages.aboutApp
        StaticPagesView(type: $type)
    }
}
enum StaticPages{
    case aboutApp, termsAndCondition, privacyPolicy
}

struct HTMLTextView: UIViewRepresentable {
    var htmlText: String
    var font : UIFont = UIFont(name: AppFonts.shared.name(.plain), size: 14) ?? .systemFont(ofSize: 14)
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
         if let attributedString = htmlText.attributedStringFromHTML {
             let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
             mutableAttributedString.addAttributes(
                 [.font: font],
                 range: NSRange(location: 0, length: mutableAttributedString.length)
             )
             uiView.attributedText = mutableAttributedString
         }
     }
}

extension String {
    var attributedStringFromHTML: NSAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            // Create attributed string from HTML
            let attributedString = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
            
            // Create a paragraph style with right alignment
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = Constants.shared.isAR ? .right:.left

            
            // Apply the paragraph style to the entire attributed string
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
            
            return attributedString
        } catch {
            print("Error creating attributed string from HTML: \(error)")
            return nil
        }
    }
}


import Foundation
import UIKit


// MARK: - Single Line Preview View
struct HTMLDescriptionPreviewView: View {
    let html: String
    var baseFontSize: CGFloat = 13
    var truncationMode: Text.TruncationMode = .tail
    
    private var isArabic: Bool {
        Constants.shared.isAR
    }
    
    var body: some View {
        Text(extractPlainText(from: html))
            .textModifier(.bold, baseFontSize, .black222222)
            .lineLimit(1)
            .truncationMode(truncationMode)
            .environment(\.layoutDirection,  html.isArabic  ? .rightToLeft : .leftToRight)
    }
    
    // MARK: - Plain Text Extraction
    private func extractPlainText(from html: String) -> String {
        do {
            let doc = try SwiftSoup.parse(html)
            guard let body = doc.body() else { return "" }
            
            // Extract text and clean whitespace
            let text = try body.text()
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        } catch {
            print("SwiftSoup Error: \(error)")
            return ""
        }
    }
}




func attributedStringFromHTML(_ html: String,
                              baseFont: UIFont = .systemFont(ofSize: 13),
                              textColor: UIColor = .black,
                              isRTL: Bool) -> NSAttributedString {

    let data = Data(html.utf8)
    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
        .documentType: NSAttributedString.DocumentType.html,
        .characterEncoding: String.Encoding.utf8.rawValue
    ]

    let mutable = (try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil))
        ?? NSMutableAttributedString(string: html)

    while mutable.length > 0 {
          let last = mutable.attributedSubstring(from: NSRange(location: mutable.length - 1, length: 1)).string
          if last == "\n" || last == "\r" || last == " " || last == "\t" {
              mutable.deleteCharacters(in: NSRange(location: mutable.length - 1, length: 1))
          } else { break }
      }
    
    let ps = NSMutableParagraphStyle()
    ps.alignment = isRTL ? .right : .left
    ps.baseWritingDirection = isRTL ? .rightToLeft : .leftToRight
    ps.paragraphSpacing = 0
    ps.paragraphSpacingBefore = 0

    let range = NSRange(location: 0, length: mutable.length)
    mutable.addAttributes([
        .font: baseFont,
        .paragraphStyle: ps,
        .foregroundColor: textColor
    ], range: range)

    return mutable
}






import SwiftUI
import SwiftSoup

// MARK: - Models
struct HTMLElement: Identifiable {
    let id = UUID()
    let type: ElementType
}

enum ElementType {
    case text(AttributedString)
    case list([ListItem])
    case table([[String]])
}

struct ListItem: Identifiable {
    let id = UUID()
    let text: String
}

// MARK: - Main View
struct HTMLDescriptionView: View {
    let html: String
    var baseFontSize: CGFloat = 13
    
    
    
    private var isArabic: Bool {
        Constants.shared.isAR
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(parseHTML(html)) { element in
                renderElement(element)
            }
        }

    }

    // MARK: - Renderers (Broken down for Compiler efficiency)
    @ViewBuilder
    private func renderElement(_ element: HTMLElement) -> some View {
        switch element.type {
        case .text(let attrStr):
            renderTextView(attrStr)
        case .list(let items):
            renderListView(items)
        case .table(let rows):
            renderTableView(rows)
        }
    }

    @ViewBuilder
    private func renderTextView(_ str: AttributedString) -> some View {
        Text(str)
//            .textModifier(.extraBold, 16, .black222222)
            .multilineTextAlignment( (str.isArabic && Constants.shared.isAR ) ? .leading : ((!str.isArabic && !Constants.shared.isAR ) ? .leading: .trailing) )
    }

    @ViewBuilder
    private func renderListView(_ items: [ListItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .textModifier(.extraBold, 14, .black222222)
                    Text(item.text)
                        .textModifier(.bold, 13, .black222222)
                    Spacer(minLength: 0)
                }
                .environment(\.layoutDirection,  item.text.isArabic  ? .rightToLeft : .leftToRight)
                
            }
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func renderTableView(_ rows: [[String]]) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                let rowData = rows[rowIndex]
                HStack(spacing: 0) {
                    ForEach(0..<rowData.count, id: \.self) { columnIndex in
                        let cellText = rowData[columnIndex]
                        Text(cellText)
                            .font(.custom(AppFonts.shared.name(rowIndex == 0 ? .bold : .plain), size: baseFontSize - 1))
                            .padding(10)
                            .frame(maxWidth: .infinity, minHeight: 40, alignment:  .leading)
                            .background(rowIndex % 2 == 0 ? Color(hex: "F2F3F7") : Color(hex: "FCFCFD"))
                            .border(Color.gray.opacity(0.15), width: 0.5)
                    }
                }
            }
        }
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .padding(.vertical, 8)
    }

    // MARK: - HTML Parsing Logic
    private func parseHTML(_ html: String) -> [HTMLElement] {
        var parsedElements: [HTMLElement] = []
        do {
            let doc = try SwiftSoup.parse(html)
            guard let body = doc.body() else { return [] }

            for node in body.children() {
                let tagName = node.tagName()

                if tagName == "table" {
                    let rows = parseTable(node)
                    parsedElements.append(HTMLElement(type: .table(rows)))
                } else if tagName == "ul" || tagName == "ol" {
                    let items = parseList(node)
                    parsedElements.append(HTMLElement(type: .list(items)))
                } else {
                    let alignment: TextAlignment = .leading
                    if let attrStr = parseFormattedText(node) {
                        parsedElements.append(HTMLElement(type: .text(attrStr)))
                    }
                }
            }
        } catch {
            print("SwiftSoup Error: \(error)")
        }
        return parsedElements
    }

    private func parseFormattedText(_ element: Element) -> AttributedString? {
        var combined = AttributedString("")

        do {
            let tagName = element.tagName()
            let parentIsBold = ["h1","h2","h3","strong","b"].contains(tagName)

            // ✅ Define size per heading level
            let headingSize: CGFloat = {
                switch tagName {
                case "h1": return baseFontSize + 8
                case "h2": return baseFontSize + 6
                case "h3": return baseFontSize + 4
                default:   return baseFontSize
                }
            }()

            for node in element.getChildNodes() {
                var segmentText = ""
                var isBold = parentIsBold
                var segmentSize = headingSize   // ✅ inherit parent heading size

                if let textNode = node as? TextNode {
                    segmentText = textNode.getWholeText()
                } else if let childElement = node as? Element {
                    segmentText = try childElement.text()
                    let childTag = childElement.tagName()
                    if ["strong","b","h1","h2","h3"].contains(childTag) {
                        isBold = true
                        // ✅ Also apply heading size for nested heading tags
                        switch childTag {
                        case "h1": segmentSize = baseFontSize + 8
                        case "h2": segmentSize = baseFontSize + 6
                        case "h3": segmentSize = baseFontSize + 4
                        default: break
                        }
                    }
                }

                if !segmentText.isEmpty {
                    var segment = AttributedString(segmentText)
                    segment.font = .custom(
                        AppFonts.shared.name(isBold ? .bold : .plain),
                        size: segmentSize   // ✅ Use correct size
                    )
                    segment.foregroundColor = Color(hex: isBold ? "222222" : "404553")
                    combined += segment
                }
            }
        } catch { return nil }

        return combined.characters.count > 0 ? combined : nil
    }

    private func parseTable(_ element: Element) -> [[String]] {
        var tableData: [[String]] = []
        do {
            let rows = try element.select("tr")
            for row in rows {
                let cols = try row.select("td").map { try $0.text().trimmingCharacters(in: .whitespacesAndNewlines) }
                if !cols.isEmpty { tableData.append(cols) }
            }
        } catch { }
        return tableData
    }

    private func parseList(_ element: Element) -> [ListItem] {
        do {
            return try element.select("li").map { ListItem(text: try $0.text()) }
        } catch { return [] }
    }
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}


import NaturalLanguage

extension String {
    /// Detects if the text is predominantly Arabic
    var isArabic: Bool {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(self)
        return recognizer.dominantLanguage == .arabic
    }
   
}

import NaturalLanguage

extension AttributedString {
    var isArabic: Bool {
        // 1. Convert the AttributedString content to a standard String
        let plainText = String(self.characters)
        
        // 2. Use NaturalLanguage to check the dominant language
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(plainText)
        return recognizer.dominantLanguage == .arabic
    }
}
