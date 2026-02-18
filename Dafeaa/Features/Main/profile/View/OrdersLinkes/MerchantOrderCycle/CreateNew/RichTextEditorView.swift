//
//  RichTextEditorView.swift
//  Dafeaa
//
//  Created by AMNY on 08/01/2026.
//
import SwiftUI
import UIKit

// MARK: - Usage:

struct RichTextEditorView: View {
    @Binding var attributedText: NSAttributedString
    var placeholder: String = ""
    @FocusState private var isFocused: Bool
    @StateObject private var viewModel = RichTextViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Formatting Toolbar at top
            FormattingToolbar(viewModel: viewModel)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
            
            // Text Editor
            RichTextEditorRepresentable(
                attributedText: $attributedText,
                placeholder: placeholder,
                viewModel: viewModel
            )
            .frame(minHeight: 160)
        }
        .background(Color(.grayF6F6F6))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color(.primary) : Color.clear, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .focused($isFocused)
    }
}

// MARK: - View Model
class RichTextViewModel: ObservableObject {
    @Published var styleTitle: String = "Normal"
    @Published var isBold: Bool = false
    @Published var isItalic: Bool = false
    @Published var isUnderline: Bool = false
    @Published var isBulletList: Bool = false
    @Published var isNumberedList: Bool = false
    
    weak var textView: UITextView?
    var placeholder: String = ""
    var attributedTextBinding: Binding<NSAttributedString>?
    private var currentNumberInList: Int = 1
    
    func toggleBold() {
        isBold.toggle()
        applyCurrentFormatting()
    }
    
    func toggleItalic() {
        isItalic.toggle()
        applyCurrentFormatting()
    }
    
    func toggleUnderline() {
        isUnderline.toggle()
        applyCurrentFormatting()
    }
    
    func toggleBulletList() {
        isBulletList.toggle()
        if isBulletList {
            isNumberedList = false
            insertBullet()
        }
    }
    
    func toggleNumberedList() {
        isNumberedList.toggle()
        if isNumberedList {
            isBulletList = false
            currentNumberInList = 1
            insertNumber()
        }
    }
    
    func applyCurrentFormatting() {
        guard let tv = textView else { return }
        guard !isShowingPlaceholder() else { return }
        
        // Get current font size from style
        let fontSize: CGFloat = switch styleTitle {
        case "H1": 28
        case "H2": 22
        case "H3": 18
        default: 16
        }
        
        // Build font with bold/italic traits
        var traits: UIFontDescriptor.SymbolicTraits = []
        if isBold {
            traits.insert(.traitBold)
        }
        if isItalic {
            traits.insert(.traitItalic)
        }
        
        let baseFont = UIFont.systemFont(ofSize: fontSize)
        let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits) ?? baseFont.fontDescriptor
        let font = UIFont(descriptor: descriptor, size: fontSize)
        
        // Apply to typing attributes
        var attrs = tv.typingAttributes
        attrs[.font] = font
        attrs[.foregroundColor] = UIColor.label
        
        // Apply underline
        if isUnderline {
            attrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
        } else {
            attrs.removeValue(forKey: .underlineStyle)
        }
        
        tv.typingAttributes = attrs
        
        // If there's a selection, apply to selected text
        if tv.selectedRange.length > 0 {
            let range = tv.selectedRange
            let mutable = NSMutableAttributedString(attributedString: tv.attributedText)
            let safe = safeRange(range, length: mutable.length)
            
            mutable.addAttribute(.font, value: font, range: safe)
            
            if isUnderline {
                mutable.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: safe)
            } else {
                mutable.removeAttribute(.underlineStyle, range: safe)
            }
            
            tv.attributedText = mutable
            attributedTextBinding?.wrappedValue = tv.attributedText
            tv.selectedRange = range
        }
    }
    
    func insertBullet() {
        guard let tv = textView else { return }
        guard !isShowingPlaceholder() else { return }
        tv.insertTextAtCursor("• ")
        attributedTextBinding?.wrappedValue = tv.attributedText
    }
    
    func insertNumber() {
        guard let tv = textView else { return }
        guard !isShowingPlaceholder() else { return }
        tv.insertTextAtCursor("\(currentNumberInList). ")
        currentNumberInList += 1
        attributedTextBinding?.wrappedValue = tv.attributedText
    }
    
    func handleNewLine() -> Bool {
        guard let tv = textView else { return false }
        
        // Check if we're in a list mode
        if isBulletList {
            if isCurrentLineEmptyListItem(textView: tv, prefix: "• ") {
                removeCurrentLineListPrefix(textView: tv, prefix: "• ")
                isBulletList = false
                return true
            } else {
                // Insert newline first, then bullet
                tv.insertNewLineWithCurrentAttributes()
                tv.insertTextAtCursor("• ")
                attributedTextBinding?.wrappedValue = tv.attributedText
                return true
            }
        } else if isNumberedList {
            if isCurrentLineEmptyListItem(textView: tv, prefixPattern: #"^\d+\.\s$"#) {
                removeCurrentLineListPrefix(textView: tv, prefixPattern: #"^\d+\.\s"#)
                isNumberedList = false
                currentNumberInList = 1
                return true
            } else {
                // Insert newline first, then number
                tv.insertNewLineWithCurrentAttributes()
                tv.insertTextAtCursor("\(currentNumberInList). ")
                currentNumberInList += 1
                attributedTextBinding?.wrappedValue = tv.attributedText
                return true
            }
        }
        
        return false
    }
    
    private func isCurrentLineEmptyListItem(textView: UITextView, prefix: String) -> Bool {
        let text = textView.text ?? ""
        let cursorPosition = textView.selectedRange.location
        
        var lineStart = cursorPosition
        while lineStart > 0 && text[text.index(text.startIndex, offsetBy: lineStart - 1)] != "\n" {
            lineStart -= 1
        }
        
        let lineStartIndex = text.index(text.startIndex, offsetBy: lineStart)
        let cursorIndex = text.index(text.startIndex, offsetBy: cursorPosition)
        let currentLine = String(text[lineStartIndex..<cursorIndex])
        
        return currentLine == prefix
    }
    
    private func isCurrentLineEmptyListItem(textView: UITextView, prefixPattern: String) -> Bool {
        let text = textView.text ?? ""
        let cursorPosition = textView.selectedRange.location
        
        var lineStart = cursorPosition
        while lineStart > 0 && text[text.index(text.startIndex, offsetBy: lineStart - 1)] != "\n" {
            lineStart -= 1
        }
        
        let lineStartIndex = text.index(text.startIndex, offsetBy: lineStart)
        let cursorIndex = text.index(text.startIndex, offsetBy: cursorPosition)
        let currentLine = String(text[lineStartIndex..<cursorIndex])
        
        if let regex = try? NSRegularExpression(pattern: prefixPattern) {
            let range = NSRange(currentLine.startIndex..., in: currentLine)
            return regex.firstMatch(in: currentLine, range: range) != nil
        }
        
        return false
    }
    
    private func removeCurrentLineListPrefix(textView: UITextView, prefix: String) {
        let text = textView.text ?? ""
        let cursorPosition = textView.selectedRange.location
        
        var lineStart = cursorPosition
        while lineStart > 0 && text[text.index(text.startIndex, offsetBy: lineStart - 1)] != "\n" {
            lineStart -= 1
        }
        
        let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
        let prefixRange = NSRange(location: lineStart, length: prefix.count)
        mutable.deleteCharacters(in: prefixRange)
        
        textView.attributedText = mutable
        textView.selectedRange = NSRange(location: lineStart, length: 0)
        attributedTextBinding?.wrappedValue = textView.attributedText
    }
    
    private func removeCurrentLineListPrefix(textView: UITextView, prefixPattern: String) {
        let text = textView.text ?? ""
        let cursorPosition = textView.selectedRange.location
        
        var lineStart = cursorPosition
        while lineStart > 0 && text[text.index(text.startIndex, offsetBy: lineStart - 1)] != "\n" {
            lineStart -= 1
        }
        
        let lineStartIndex = text.index(text.startIndex, offsetBy: lineStart)
        let cursorIndex = text.index(text.startIndex, offsetBy: cursorPosition)
        let currentLine = String(text[lineStartIndex..<cursorIndex])
        
        if let regex = try? NSRegularExpression(pattern: prefixPattern),
           let match = regex.firstMatch(in: currentLine, range: NSRange(currentLine.startIndex..., in: currentLine)) {
            let prefixLength = match.range.length
            
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
            let prefixRange = NSRange(location: lineStart, length: prefixLength)
            mutable.deleteCharacters(in: prefixRange)
            
            textView.attributedText = mutable
            textView.selectedRange = NSRange(location: lineStart, length: 0)
            attributedTextBinding?.wrappedValue = textView.attributedText
        }
    }
    
    func applyStyle(title: String) {
        styleTitle = title
        applyCurrentFormatting()
    }
    
    private func safeRange(_ range: NSRange, length: Int) -> NSRange {
        let loc = max(0, min(range.location, length))
        let maxLen = max(0, length - loc)
        let len = max(0, min(range.length, maxLen))
        return NSRange(location: loc, length: len)
    }
    
    private func isShowingPlaceholder() -> Bool {
        guard let tv = textView else { return false }
        guard !placeholder.isEmpty else { return false }
        return tv.textColor == .placeholderText && tv.text == placeholder
    }
}

// MARK: - Formatting Toolbar
struct FormattingToolbar: View {
    @ObservedObject var viewModel: RichTextViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Style Menu
            Menu {
                Button(action: {
                    viewModel.applyStyle(title: "Normal")
                }) {
                    HStack {
                        Text("Normal")
                        if viewModel.styleTitle == "Normal" {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button(action: {
                    viewModel.applyStyle(title: "H3")
                }) {
                    HStack {
                        Text("H3")
                        if viewModel.styleTitle == "H3" {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button(action: {
                    viewModel.applyStyle(title: "H2")
                }) {
                    HStack {
                        Text("H2")
                        if viewModel.styleTitle == "H2" {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button(action: {
                    viewModel.applyStyle(title: "H1")
                }) {
                    HStack {
                        Text("H1")
                        if viewModel.styleTitle == "H1" {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.styleTitle)
                        .font(.system(size: 14))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.systemBackground))
                .cornerRadius(6)
            }
            
            Spacer(minLength: 0)
            
            // Bold Button
            Button(action: { viewModel.toggleBold() }) {
                Image(systemName: "bold")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(viewModel.isBold ? .white : .primary)
                    .frame(width: 32, height: 32)
                    .background(viewModel.isBold ? Color.blue : Color(.systemBackground))
                    .cornerRadius(6)
            }
            
            // Italic Button
            Button(action: { viewModel.toggleItalic() }) {
                Image(systemName: "italic")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(viewModel.isItalic ? .white : .primary)
                    .frame(width: 32, height: 32)
                    .background(viewModel.isItalic ? Color.blue : Color(.systemBackground))
                    .cornerRadius(6)
            }
            
            // Underline Button
            Button(action: { viewModel.toggleUnderline() }) {
                Image(systemName: "underline")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(viewModel.isUnderline ? .white : .primary)
                    .frame(width: 32, height: 32)
                    .background(viewModel.isUnderline ? Color.blue : Color(.systemBackground))
                    .cornerRadius(6)
            }
            
            // Bullet List Button
            Button(action: { viewModel.toggleBulletList() }) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(viewModel.isBulletList ? .white : .primary)
                    .frame(width: 32, height: 32)
                    .background(viewModel.isBulletList ? Color.blue : Color(.systemBackground))
                    .cornerRadius(6)
            }
            
            // Numbered List Button
            Button(action: { viewModel.toggleNumberedList() }) {
                Image(systemName: "list.number")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(viewModel.isNumberedList ? .white : .primary)
                    .frame(width: 32, height: 32)
                    .background(viewModel.isNumberedList ? Color.blue : Color(.systemBackground))
                    .cornerRadius(6)
            }
        }
    }
}

// MARK: - UIViewRepresentable
struct RichTextEditorRepresentable: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    let placeholder: String
    @ObservedObject var viewModel: RichTextViewModel

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.delegate = context.coordinator
        tv.isEditable = true
        tv.isScrollEnabled = true
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        tv.font = UIFont.systemFont(ofSize: 16)

        viewModel.textView = tv
        viewModel.placeholder = placeholder
        viewModel.attributedTextBinding = $attributedText
        
        context.coordinator.applyPlaceholderIfNeeded(textView: tv)
        
        // Set initial typing attributes
        context.coordinator.updateTypingAttributes(textView: tv)

        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        viewModel.textView = uiView
        viewModel.placeholder = placeholder
        viewModel.attributedTextBinding = $attributedText

        guard !uiView.isFirstResponder else { return }

        if attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            context.coordinator.applyPlaceholderIfNeeded(textView: uiView)
        } else {
            uiView.attributedText = attributedText
            uiView.textColor = .label
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UITextViewDelegate {
        let viewModel: RichTextViewModel

        init(viewModel: RichTextViewModel) {
            self.viewModel = viewModel
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            viewModel.textView = textView

            if isShowingPlaceholder(textView: textView) {
                textView.attributedText = NSAttributedString(string: "")
                textView.textColor = .label
                updateTypingAttributes(textView: textView)
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewModel.attributedTextBinding?.wrappedValue = NSAttributedString(string: "")
                applyPlaceholderIfNeeded(textView: textView)
            }
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            // Check if user pressed return/enter
            if text == "\n" {
                // First check if in list mode
                if viewModel.handleNewLine() {
                    return false // List mode handled it
                }
                
                // Not in list mode - insert newline preserving current typing attributes
                textView.insertNewLineWithCurrentAttributes()
                viewModel.attributedTextBinding?.wrappedValue = textView.attributedText
                return false // We handled it manually
            }
            return true
        }

        func textViewDidChange(_ textView: UITextView) {
            if isShowingPlaceholder(textView: textView) { return }
            
            // If text is now empty, ensure typing attributes are preserved
            if textView.text.isEmpty || textView.attributedText.length == 0 {
                updateTypingAttributes(textView: textView)
            }
            
            viewModel.attributedTextBinding?.wrappedValue = textView.attributedText
        }
        
        func updateTypingAttributes(textView: UITextView) {
            // Build the typing attributes based on current view model state
            let fontSize: CGFloat = switch viewModel.styleTitle {
            case "H1": 28
            case "H2": 22
            case "H3": 18
            default: 16
            }
            
            var traits: UIFontDescriptor.SymbolicTraits = []
            if viewModel.isBold {
                traits.insert(.traitBold)
            }
            if viewModel.isItalic {
                traits.insert(.traitItalic)
            }
            
            let baseFont = UIFont.systemFont(ofSize: fontSize)
            let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits) ?? baseFont.fontDescriptor
            let font = UIFont(descriptor: descriptor, size: fontSize)
            
            var attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.label
            ]
            
            if viewModel.isUnderline {
                attrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            
            textView.typingAttributes = attrs
        }

        func applyPlaceholderIfNeeded(textView: UITextView) {
            guard !viewModel.placeholder.isEmpty else {
                if let binding = viewModel.attributedTextBinding {
                    textView.attributedText = binding.wrappedValue
                }
                textView.textColor = .label
                return
            }

            if let binding = viewModel.attributedTextBinding,
               binding.wrappedValue.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.attributedText = NSAttributedString(
                    string: viewModel.placeholder,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                        .foregroundColor: UIColor.placeholderText
                    ]
                )
                textView.textColor = .placeholderText
            } else if let binding = viewModel.attributedTextBinding {
                textView.attributedText = binding.wrappedValue
                textView.textColor = .label
            }
        }

        private func isShowingPlaceholder(textView: UITextView) -> Bool {
            guard !viewModel.placeholder.isEmpty else { return false }
            return textView.textColor == .placeholderText && textView.text == viewModel.placeholder
        }
    }
}

// MARK: - UITextView formatting helpers
extension UITextView {
    func insertTextAtCursor(_ text: String) {
        let range = selectedRange
        let mutable = NSMutableAttributedString(attributedString: attributedText ?? NSAttributedString(string: ""))

        let insertion = NSAttributedString(string: text, attributes: typingAttributes)
        mutable.insert(insertion, at: min(max(0, range.location), mutable.length))

        attributedText = mutable
        selectedRange = NSRange(location: range.location + text.count, length: 0)
    }
    
    func insertNewLineWithCurrentAttributes() {
        let range = selectedRange
        let mutable = NSMutableAttributedString(attributedString: attributedText ?? NSAttributedString(string: ""))
        
        // Insert plain newline character without any formatting that would affect previous line
        let newline = NSAttributedString(string: "\n", attributes: [
            .font: typingAttributes[.font] ?? UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ])
        mutable.insert(newline, at: min(max(0, range.location), mutable.length))
        
        attributedText = mutable
        selectedRange = NSRange(location: range.location + 1, length: 0)
    }
}
