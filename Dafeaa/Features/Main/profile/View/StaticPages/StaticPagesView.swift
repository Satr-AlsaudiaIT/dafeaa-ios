//
//  StaticPagesView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//
import SwiftUI
import SwiftSoup
import NaturalLanguage
import _Concurrency

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

// MARK: - HTML Parser (runs off main thread)
enum HTMLParser {
    static func parse(_ html: String, baseFontSize: CGFloat = 13) -> [HTMLElement] {
        var parsedElements: [HTMLElement] = []
        do {
            let doc = try SwiftSoup.parse(html)
            guard let body = doc.body() else { return [] }

            for node in body.children() {
                let tagName = node.tagName()

                if tagName == "table" {
                    let rows = parseTable(node)
                    if !rows.isEmpty {
                        parsedElements.append(HTMLElement(type: .table(rows)))
                    }
                } else if tagName == "ul" || tagName == "ol" {
                    let items = parseList(node)
                    if !items.isEmpty {
                        parsedElements.append(HTMLElement(type: .list(items)))
                    }
                } else {
                    if let attrStr = parseFormattedText(node, baseFontSize: baseFontSize) {
                        parsedElements.append(HTMLElement(type: .text(attrStr)))
                    }
                }
            }
        } catch {
            print("SwiftSoup Error: \(error)")
        }
        return parsedElements
    }

    static func parseFormattedText(_ element: Element, baseFontSize: CGFloat = 13) -> AttributedString? {
        var combined = AttributedString("")
        do {
            let tagName = element.tagName()
            let parentIsBold = ["h1", "h2", "h3", "strong", "b"].contains(tagName)
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
                var segmentSize = headingSize

                if let textNode = node as? TextNode {
                    segmentText = textNode.getWholeText()
                } else if let childElement = node as? Element {
                    segmentText = try childElement.text()
                    let childTag = childElement.tagName()
                    if ["strong", "b", "h1", "h2", "h3"].contains(childTag) {
                        isBold = true
                        switch childTag {
                        case "h1": segmentSize = baseFontSize + 8
                        case "h2": segmentSize = baseFontSize + 6
                        case "h3": segmentSize = baseFontSize + 4
                        default: break
                        }
                    }
                }

                let trimmed = segmentText.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    var segment = AttributedString(trimmed)
                    segment.font = .custom(
                        AppFonts.shared.name(isBold ? .bold : .plain),
                        size: segmentSize
                    )
                    segment.foregroundColor = Color(hex: isBold ? "222222" : "404553")
                    combined += segment
                }
            }
        } catch { return nil }

        return combined.characters.count > 0 ? combined : nil
    }

    static func parseTable(_ element: Element) -> [[String]] {
        var tableData: [[String]] = []
        do {
            let rows = try element.select("tr")
            for row in rows {
                let cols = try row.select("td").map {
                    try $0.text().trimmingCharacters(in: .whitespacesAndNewlines)
                }
                if !cols.isEmpty { tableData.append(cols) }
            }
        } catch {}
        return tableData
    }

    static func parseList(_ element: Element) -> [ListItem] {
        do {
            return try element.select("li").map { ListItem(text: try $0.text()) }
        } catch { return [] }
    }
}

// MARK: - Skeleton Loading
struct SkeletonRow: View {
    @State private var opacity: Double = 0.3

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(opacity))
                .frame(height: 14)
                .frame(maxWidth: .infinity)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(opacity))
                .frame(height: 10)
                .frame(maxWidth: 220, alignment: .trailing)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true)) {
                opacity = 0.65
            }
        }
    }
}

struct SkeletonView: View {
    var body: some View {
        VStack(alignment: .trailing, spacing: 20) {
            ForEach(0..<10, id: \.self) { i in
                SkeletonRow()
            }
        }
        .padding(.top, 16)
    }
}

// MARK: - Single Element Renderer
struct HTMLElementView: View {
    let element: HTMLElement
    var baseFontSize: CGFloat = 13

    var body: some View {
        switch element.type {
        case .text(let attrStr):
            renderText(attrStr)
        case .list(let items):
            renderList(items)
        case .table(let rows):
            renderTable(rows)
        }
    }

    @ViewBuilder
    private func renderText(_ str: AttributedString) -> some View {
        Text(str)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading )
//            .environment(\.layoutDirection, str.isArabic ? .rightToLeft : .leftToRight)
    }

    @ViewBuilder
    private func renderList(_ items: [ListItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .textModifier(.extraBold, 14, .black222222)
                    Text(item.text)
                        .textModifier(.bold, 13, .black222222)
                        
                    Spacer(minLength: 0)
                }
//                .environment(\.layoutDirection, item.text.isArabic ? .rightToLeft : .leftToRight)
            }
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func renderTable(_ rows: [[String]]) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                let rowData = rows[rowIndex]
                HStack(spacing: 0) {
                    ForEach(0..<rowData.count, id: \.self) { colIndex in
                        Text(rowData[colIndex])
                            .font(.custom(
                                AppFonts.shared.name(rowIndex == 0 ? .bold : .plain),
                                size: baseFontSize - 1
                            ))
                            .padding(10)
                            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                            .background(rowIndex % 2 == 0 ? Color(hex: "F2F3F7") : Color(hex: "FCFCFD"))
                            .border(Color.gray.opacity(0.15), width: 0.5)
                    }
                }
            }
        }
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.vertical, 8)
    }
}

// MARK: - HTMLDescriptionView (main view — name preserved for all call sites)
struct HTMLDescriptionView: View {
    let html: String
    var baseFontSize: CGFloat = 13

    @State private var parsedElements: [HTMLElement] = []
    @State private var isParsing: Bool = true

    var body: some View {
        Group {
            if isParsing {
                SkeletonView()
            } else if parsedElements.isEmpty {
                Text("No content available".localized())
                    .textModifier(.plain, 14, .gray979797)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 14) {
                        ForEach(parsedElements) { element in
                            HTMLElementView(element: element, baseFontSize: baseFontSize)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .task {
            guard !html.isEmpty else {
                isParsing = false
                return
            }
            let elements = await _Concurrency.Task.detached(priority: .userInitiated) {
                HTMLParser.parse(html, baseFontSize: baseFontSize)
            }.value

            await MainActor.run {
                self.parsedElements = elements
                self.isParsing = false
            }
        }
        // Re-parse if html changes (e.g. after API response arrives)
        .onChange(of: html) { _, newHTML in
            guard !newHTML.isEmpty else { return }
            isParsing = true
            _Concurrency.Task {
                let elements = await _Concurrency.Task.detached(priority: .userInitiated) {
                    HTMLParser.parse(newHTML, baseFontSize: baseFontSize)
                }.value
                await MainActor.run {
                    self.parsedElements = elements
                    self.isParsing = false
                }
            }
        }
    }
}

// MARK: - HTMLDescriptionPreviewView (single line, unchanged)
struct HTMLDescriptionPreviewView: View {
    let html: String
    var baseFontSize: CGFloat = 13
    var truncationMode: Text.TruncationMode = .tail

    var body: some View {
        Text(extractPlainText(from: html))
            .textModifier(.bold, baseFontSize, .black222222)
            .lineLimit(1)
            .truncationMode(truncationMode)
            .environment(\.layoutDirection, html.isArabic ? .rightToLeft : .leftToRight)
    }

    private func extractPlainText(from html: String) -> String {
        do {
            let doc = try SwiftSoup.parse(html)
            guard let body = doc.body() else { return "" }
            let text = try body.text()
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        } catch {
            return ""
        }
    }
}

// MARK: - StaticPagesView (unchanged structure)
struct StaticPagesView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = MoreVM()

    @Binding var type: StaticPages

    var pageTitle: String {
        switch type {
        case .aboutApp:          return "About Dafeaa".localized()
        case .privacyPolicy:     return "Privacy Policy".localized()
        case .termsAndCondition: return "Terms & Conditions".localized()
        }
    }

    var content: String? {
        switch type {
        case .aboutApp:          return viewModel.staticData?.about ?? ""
        case .privacyPolicy:     return viewModel.staticData?.privacy ?? ""
        case .termsAndCondition: return viewModel.staticData?.terms ?? ""
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationBarView(title: pageTitle) {
                    presentationMode.wrappedValue.dismiss()
                }

                // Same call site as before — just HTMLDescriptionView
                HTMLDescriptionView(html: content ?? "")
                    .padding([.leading, .trailing, .bottom], 24)

                Spacer()
            }

            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            } else if viewModel.isFailed {
                ProgressView()
                    .hidden()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .onAppear {
            switch type {
            case .aboutApp:
                viewModel.getStaticPages(type: "settings/about")
            case .privacyPolicy:
                viewModel.getStaticPages(type: "settings/privacy")
            case .termsAndCondition:
                viewModel.getStaticPages(type: "settings/terms")
            }
            AppState.shared.swipeEnabled = true
        }
    }
}

// MARK: - Enum
enum StaticPages {
    case aboutApp, termsAndCondition, privacyPolicy
}

// MARK: - Preview
struct StaticPagesView_Previews: PreviewProvider {
    static var previews: some View {
        @State var type = StaticPages.aboutApp
        StaticPagesView(type: $type)
    }
}

// MARK: - String + Arabic Detection
extension String {
    var isArabic: Bool {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(self)
        return recognizer.dominantLanguage == .arabic
    }
}

// MARK: - AttributedString + Arabic Detection
extension AttributedString {
    var isArabic: Bool {
        let plainText = String(self.characters)
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(plainText)
        return recognizer.dominantLanguage == .arabic
    }
}

// MARK: - Color Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
