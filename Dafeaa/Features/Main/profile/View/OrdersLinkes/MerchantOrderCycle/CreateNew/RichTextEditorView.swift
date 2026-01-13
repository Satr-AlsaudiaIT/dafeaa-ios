//
//  RichTextEditorView.swift
//  Dafeaa
//
//  Created by AMNY on 08/01/2026.
//
import SwiftUI
import UIKit

// MARK: - Usage:
// RichTextEditorView(attributedText: $text, placeholder: "productDescription".localized())
// .dismissKeyboardOnTap()

struct RichTextEditorView: View {
    @Binding var attributedText: NSAttributedString
    var placeholder: String = ""
    @FocusState private var isFocused: Bool
    @State private var styleTitle: String = "Normal"

    var body: some View {
        RichTextEditorRepresentable(
            attributedText: $attributedText,
            placeholder: placeholder,
            styleTitle: $styleTitle
        )
        .frame(minHeight: 160)
        .focused($isFocused)
        .background(Color(.grayF6F6F6))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color(.primary) : Color.clear, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct RichTextEditorRepresentable: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    let placeholder: String
    @Binding var styleTitle: String

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.delegate = context.coordinator
        tv.isEditable = true
        tv.isScrollEnabled = true
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        context.coordinator.styleTitleBinding = $styleTitle
        context.coordinator.applyPlaceholderIfNeeded(textView: tv)
        context.coordinator.applyDefaultTypingStyle(to: tv) // important for next typing
        context.coordinator.setToolbar(on: tv)

        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.styleTitleBinding = $styleTitle

        // Don't override while user is typing
        guard !uiView.isFirstResponder else { return }

        if attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            context.coordinator.applyPlaceholderIfNeeded(textView: uiView)
            context.coordinator.applyDefaultTypingStyle(to: uiView)
        } else {
            uiView.attributedText = attributedText
            uiView.textColor = .label
        }

        // Make sure toolbar title stays in sync
        context.coordinator.setToolbar(on: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // MARK: - Coordinator
    final class Coordinator: NSObject, UITextViewDelegate {
        let parent: RichTextEditorRepresentable
        weak var activeTextView: UITextView?

        // keep current chosen style for typing + toolbar title
        var styleTitleBinding: Binding<String>?

        init(parent: RichTextEditorRepresentable) {
            self.parent = parent
        }

        // MARK: UITextViewDelegate
        func textViewDidBeginEditing(_ textView: UITextView) {
            activeTextView = textView

            // Remove placeholder on focus
            if isShowingPlaceholder(textView: textView) {
                textView.attributedText = NSAttributedString(string: "")
                textView.textColor = .label
                applyDefaultTypingStyle(to: textView)
            }

            setToolbar(on: textView)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                parent.attributedText = NSAttributedString(string: "")
                applyPlaceholderIfNeeded(textView: textView)
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            if isShowingPlaceholder(textView: textView) { return }
            parent.attributedText = textView.attributedText
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            // optional: you can later update toolbar selected state here
            // For now, keep toolbar title correct
            setToolbar(on: textView)
        }

        // MARK: Placeholder
        func applyPlaceholderIfNeeded(textView: UITextView) {
            guard !parent.placeholder.isEmpty else {
                textView.attributedText = parent.attributedText
                textView.textColor = .label
                return
            }

            if parent.attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.attributedText = NSAttributedString(
                    string: parent.placeholder,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                        .foregroundColor: UIColor.placeholderText
                    ]
                )
                textView.textColor = .placeholderText
            } else {
                textView.attributedText = parent.attributedText
                textView.textColor = .label
            }
        }

        private func isShowingPlaceholder(textView: UITextView) -> Bool {
            guard !parent.placeholder.isEmpty else { return false }
            return textView.textColor == .placeholderText && textView.text == parent.placeholder
        }

        // MARK: Default typing style based on chosen styleTitle
        func applyDefaultTypingStyle(to textView: UITextView) {
            let title = styleTitleBinding?.wrappedValue ?? "Normal"
            let font: UIFont = switch title {
            case "Heading 1": .boldSystemFont(ofSize: 28)
            case "Heading 2": .boldSystemFont(ofSize: 22)
            case "Heading 3": .boldSystemFont(ofSize: 18)
            default:          .systemFont(ofSize: 16)
            }
            textView.setTypingFont(font)
        }

        // MARK: Toolbar
        func setToolbar(on textView: UITextView) {
            let tb = UIToolbar()
            tb.sizeToFit()

            let styleItem = makeStyleMenuItem(textView: textView)

            let bold = UIBarButtonItem(image: UIImage(systemName: "bold"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(toggleBold))

            let italic = UIBarButtonItem(image: UIImage(systemName: "italic"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(toggleItalic))

            let underline = UIBarButtonItem(image: UIImage(systemName: "underline"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(toggleUnderline))

            let link = UIBarButtonItem(image: UIImage(systemName: "link"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(addLink))

            let numbered = UIBarButtonItem(image: UIImage(systemName: "list.number"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(insertNumberedItem))

            let bullets = UIBarButtonItem(image: UIImage(systemName: "list.bullet"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(insertBullet))

            let clear = UIBarButtonItem(title: "Tx",
                                        style: .plain,
                                        target: self,
                                        action: #selector(clearFormatting))

            let done = UIBarButtonItem(title: "Done".localized(),
                                       style: .done,
                                       target: self,
                                       action: #selector(doneTapped))

            let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

            tb.items = [
                styleItem,
                flex,
                bold, italic, underline,
                link,
                numbered, bullets,
                clear,
                flex,
                done
            ]

            textView.inputAccessoryView = tb
            textView.reloadInputViews()
        }

        private func makeStyleMenuItem(textView: UITextView) -> UIBarButtonItem {
            let current = styleTitleBinding?.wrappedValue ?? "Normal"

            func applyStyle(title: String, font: UIFont) {
                // If selection exists -> apply to selection
                if textView.selectedRange.length > 0 {
                    textView.applyFont(font)
                }
                // Always apply to next typing
                textView.setTypingFont(font)

                parent.attributedText = textView.attributedText
                styleTitleBinding?.wrappedValue = title

                // Refresh toolbar title + checkmarks
                setToolbar(on: textView)
            }

            let menu = UIMenu(title: "", children: [
                UIAction(title: "Heading 1", state: current == "Heading 1" ? .on : .off) { _ in
                    applyStyle(title: "Heading 1", font: .boldSystemFont(ofSize: 28))
                },
                UIAction(title: "Heading 2", state: current == "Heading 2" ? .on : .off) { _ in
                    applyStyle(title: "Heading 2", font: .boldSystemFont(ofSize: 22))
                },
                UIAction(title: "Heading 3", state: current == "Heading 3" ? .on : .off) { _ in
                    applyStyle(title: "Heading 3", font: .boldSystemFont(ofSize: 18))
                },
                UIAction(title: "Normal", state: current == "Normal" ? .on : .off) { _ in
                    applyStyle(title: "Normal", font: .systemFont(ofSize: 16))
                }
            ])

            // Title shows currently selected style (like your screenshot) [file:91]
            return UIBarButtonItem(
                title: current,
                image: UIImage(systemName: "chevron.up.chevron.down"),
                primaryAction: nil,
                menu: menu
            )
        }

        // MARK: Toolbar actions
        @objc private func doneTapped() {
            activeTextView?.resignFirstResponder()
        }

        @objc private func toggleBold() {
            guard let tv = activeTextView, !isShowingPlaceholder(textView: tv) else { return }

            if tv.selectedRange.length > 0 {
                tv.toggleTrait(.traitBold)                // selection
            } else {
                tv.toggleTypingTrait(.traitBold)          // next typing via typingAttributes [web:94]
            }
            parent.attributedText = tv.attributedText
        }

        @objc private func toggleItalic() {
            guard let tv = activeTextView, !isShowingPlaceholder(textView: tv) else { return }

            if tv.selectedRange.length > 0 {
                tv.toggleTrait(.traitItalic)
            } else {
                tv.toggleTypingTrait(.traitItalic)        // next typing [web:94]
            }
            parent.attributedText = tv.attributedText
        }

        @objc private func toggleUnderline() {
            guard let tv = activeTextView, !isShowingPlaceholder(textView: tv) else { return }

            if tv.selectedRange.length > 0 {
                tv.toggleUnderline()
            } else {
                tv.toggleTypingUnderline()                 // next typing [web:94]
            }
            parent.attributedText = tv.attributedText
        }

        @objc private func insertBullet() {
            guard let tv = activeTextView, !isShowingPlaceholder(textView: tv) else { return }
            tv.insertTextAtCursor("• ")
            parent.attributedText = tv.attributedText
        }

        @objc private func insertNumberedItem() {
            guard let tv = activeTextView, !isShowingPlaceholder(textView: tv) else { return }
            tv.insertTextAtCursor("1. ")
            parent.attributedText = tv.attributedText
        }

        @objc private func clearFormatting() {
            guard let tv = activeTextView, !isShowingPlaceholder(textView: tv) else { return }

            if tv.selectedRange.length > 0 {
                tv.clearFormatting()
            } else {
                tv.clearTypingFormatting()
            }

            parent.attributedText = tv.attributedText
        }

        @objc private func addLink() {
            guard let tv = activeTextView, !isShowingPlaceholder(textView: tv) else { return }
            guard tv.selectedRange.length > 0 else { return }
            tv.applyLink(url: URL(string: "https://")!)
            parent.attributedText = tv.attributedText
        }
    }
}

// MARK: - UITextView formatting helpers
private extension UITextView {
    func insertTextAtCursor(_ text: String) {
        let range = selectedRange
        let mutable = NSMutableAttributedString(attributedString: attributedText ?? NSAttributedString(string: ""))

        // use current typing attributes for inserted text
        let insertion = NSAttributedString(string: text, attributes: typingAttributes)
        mutable.insert(insertion, at: min(max(0, range.location), mutable.length))

        attributedText = mutable
        selectedRange = NSRange(location: range.location + text.count, length: 0)
    }

    // Apply to selection
    func toggleUnderline() {
        let range = selectedRange
        guard range.length > 0 else { return }

        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let safe = safeRange(range, length: mutable.length)

        var isUnderlined = true
        mutable.enumerateAttribute(.underlineStyle, in: safe) { value, _, stop in
            if (value as? Int ?? 0) == 0 { isUnderlined = false; stop.pointee = true }
        }

        mutable.addAttribute(.underlineStyle, value: isUnderlined ? 0 : NSUnderlineStyle.single.rawValue, range: safe)
        attributedText = mutable
    }

    // Apply to selection
    func toggleTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
        let range = selectedRange
        guard range.length > 0 else { return }

        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let safe = safeRange(range, length: mutable.length)

        mutable.enumerateAttribute(.font, in: safe) { value, subRange, _ in
            let current = (value as? UIFont) ?? (self.font ?? .systemFont(ofSize: 16))
            var traits = current.fontDescriptor.symbolicTraits
            if traits.contains(trait) { traits.remove(trait) } else { traits.insert(trait) }
            let desc = current.fontDescriptor.withSymbolicTraits(traits) ?? current.fontDescriptor
            let newFont = UIFont(descriptor: desc, size: current.pointSize)
            mutable.addAttribute(.font, value: newFont, range: subRange)
        }

        attributedText = mutable
    }

    // Apply font to selection
    func applyFont(_ font: UIFont) {
        let range = selectedRange
        guard range.length > 0 else { return }

        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let safe = safeRange(range, length: mutable.length)
        mutable.addAttribute(.font, value: font, range: safe)
        attributedText = mutable
    }

    func applyLink(url: URL) {
        let range = selectedRange
        guard range.length > 0 else { return }

        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let safe = safeRange(range, length: mutable.length)
        mutable.addAttribute(.link, value: url, range: safe)
        attributedText = mutable
    }

    func clearFormatting() {
        let range = selectedRange
        guard range.length > 0 else { return }

        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let safe = safeRange(range, length: mutable.length)

        mutable.removeAttribute(.font, range: safe)
        mutable.removeAttribute(.underlineStyle, range: safe)
        mutable.removeAttribute(.link, range: safe)

        mutable.addAttribute(.font, value: self.font ?? .systemFont(ofSize: 16), range: safe)
        attributedText = mutable
    }

    // MARK: typingAttributes (next typing) [web:94]
    func setTypingFont(_ font: UIFont) {
        var attrs = typingAttributes
        attrs[.font] = font
        typingAttributes = attrs
    }

    func toggleTypingTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
        var attrs = typingAttributes
        let currentFont = (attrs[.font] as? UIFont) ?? (self.font ?? .systemFont(ofSize: 16))

        var traits = currentFont.fontDescriptor.symbolicTraits
        if traits.contains(trait) { traits.remove(trait) } else { traits.insert(trait) }

        let desc = currentFont.fontDescriptor.withSymbolicTraits(traits) ?? currentFont.fontDescriptor
        let newFont = UIFont(descriptor: desc, size: currentFont.pointSize)

        attrs[.font] = newFont
        typingAttributes = attrs
    }

    func toggleTypingUnderline() {
        var attrs = typingAttributes
        let current = (attrs[.underlineStyle] as? Int) ?? 0
        attrs[.underlineStyle] = (current == 0) ? NSUnderlineStyle.single.rawValue : 0
        typingAttributes = attrs
    }

    func clearTypingFormatting() {
        var attrs = typingAttributes
        attrs.removeValue(forKey: .underlineStyle)
        attrs.removeValue(forKey: .link)

        // keep current font if exists, else default
        if attrs[.font] == nil {
            attrs[.font] = self.font ?? .systemFont(ofSize: 16)
        }
        typingAttributes = attrs
    }

    private func safeRange(_ range: NSRange, length: Int) -> NSRange {
        let loc = max(0, min(range.location, length))
        let maxLen = max(0, length - loc)
        let len = max(0, min(range.length, maxLen))
        return NSRange(location: loc, length: len)
    }
}
