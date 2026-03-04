//
//  FridayBlockingDatePicker.swift
//  Dafeaa
//
//  Created by AMNY on 04/03/2026.
//

import SwiftUI
import UIKit

// MARK: - FridayBlockingDatePicker
class FridayBlockingDatePicker: UIDatePicker {
    
    private var observer: NSKeyValueObservation?
    private weak var collectionView: UICollectionView?
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        setupCollectionViewObserver()
    }
    
    private func setupCollectionViewObserver() {
        guard let cv = findCollectionView(in: self) else { return }
        self.collectionView = cv
        
        // Observe contentOffset — fires when user swipes to next/prev month
        observer = cv.observe(\.contentOffset, options: [.new]) { [weak self] _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self?.grayOutFridays()
            }
        }
        
        // Initial gray
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.grayOutFridays()
        }
    }
    
    private func grayOutFridays() {
        guard let cv = collectionView else {
            if let cv = findCollectionView(in: self) {
                self.collectionView = cv
                setupCollectionViewObserver()
            }
            return
        }

        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())

        for cell in cv.visibleCells {
            guard let label = findDayLabel(in: cell),
                  let text = label.text,
                  let day = Int(text),
                  day >= 1 && day <= 31 else {
                resetCell(cell)
                continue
            }

            if let indexPath = cv.indexPath(for: cell),
               let date = dateFromIndexPath(indexPath, collectionView: cv, day: day) {

                let weekday = Calendar.current.component(.weekday, from: date)
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)

                if weekday == 6 {
                    // ── Friday: gray + disabled ──
                    label.textColor = UIColor.systemGray3
                    cell.isUserInteractionEnabled = false
                    removeTodayBorder(from: cell)
                } else {
                    // ── Normal day: reset ──
                    label.textColor = UIColor.label
                    cell.isUserInteractionEnabled = true

                    // ── Today: teal circle border ──
                    if dateComponents.year == todayComponents.year &&
                       dateComponents.month == todayComponents.month &&
                       dateComponents.day == todayComponents.day {
                        applyTodayBorder(to: cell)
                    } else {
                        removeTodayBorder(from: cell)
                    }
                }
            } else {
                resetCell(cell)
            }
        }
    }

    // MARK: - Today Border
    private func applyTodayBorder(to cell: UICollectionViewCell) {
        cell.contentView.layer.sublayers?
            .filter { $0.name == "todayCircle" }
            .forEach { $0.removeFromSuperlayer() }

        let size: CGFloat = 36
        let circleLayer = CALayer()
        circleLayer.name = "todayCircle"
        circleLayer.borderColor = UIColor(red: 0.2, green: 0.6, blue: 0.7, alpha: 1.0).cgColor
        circleLayer.borderWidth = 1.5
        circleLayer.cornerRadius = size / 2
        circleLayer.frame = CGRect(
            x: (cell.contentView.bounds.width - size) / 2,
            y: (cell.contentView.bounds.height - size) / 2,
            width: size,
            height: size
        )
        cell.contentView.layer.addSublayer(circleLayer)
    }

    private func removeTodayBorder(from cell: UICollectionViewCell) {
        cell.contentView.layer.sublayers?
            .filter { $0.name == "todayCircle" }
            .forEach { $0.removeFromSuperlayer() }
    }

    private func dateFromIndexPath(_ indexPath: IndexPath, collectionView: UICollectionView, day: Int) -> Date? {
        // Calculate which month this cell belongs to based on visible rect
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visibleCells = collectionView.visibleCells.sorted { a, b in
            collectionView.indexPath(for: a)!.item < collectionView.indexPath(for: b)!.item
        }
        
        // Find the month/year label visible in the picker header
        if let headerLabel = findMonthYearLabel(in: self),
           let headerText = headerLabel.text {
            return parseMonthYear(from: headerText, day: day)
        }
        return nil
    }
    
    private func parseMonthYear(from text: String, day: Int) -> Date? {
        let formatter = DateFormatter()
        let locales = ["en_US", "ar", "ar_SA"]
        let formats = ["MMMM yyyy", "MMM yyyy", "MMMM، yyyy", "yyyy MMMM"]
        
        for locale in locales {
            formatter.locale = Locale(identifier: locale)
            for format in formats {
                formatter.dateFormat = format
                if let parsed = formatter.date(from: text) {
                    var components = Calendar.current.dateComponents([.year, .month], from: parsed)
                    components.day = day
                    return Calendar.current.date(from: components)
                }
            }
        }
        return nil
    }
    
    private func findMonthYearLabel(in view: UIView) -> UILabel? {
        // The month/year label is typically large and bold
        for subview in view.subviews {
            if let label = subview as? UILabel,
               let text = label.text, !text.isEmpty,
               Int(text) == nil,
               text.count > 3 {
                return label
            }
            if let found = findMonthYearLabel(in: subview) { return found }
        }
        return nil
    }
    
    private func resetCell(_ cell: UICollectionViewCell) {
        cell.isUserInteractionEnabled = true
        if let label = findDayLabel(in: cell) {
            label.textColor = UIColor.label
        }
    }
    
    private func findCollectionView(in view: UIView) -> UICollectionView? {
        for subview in view.subviews {
            if let cv = subview as? UICollectionView { return cv }
            if let cv = findCollectionView(in: subview) { return cv }
        }
        return nil
    }
    
    private func findDayLabel(in view: UIView) -> UILabel? {
        for subview in view.subviews {
            if let label = subview as? UILabel,
               let text = label.text, Int(text) != nil { return label }
            if let label = findDayLabel(in: subview) { return label }
        }
        return nil
    }
    
    deinit {
        observer?.invalidate()
    }
}


// MARK: - InlineDatePickerView
struct InlineDatePickerView: UIViewRepresentable {
    @Binding var selectedDate: Date
    let minDate: Date

    func makeUIView(context: Context) -> FridayBlockingDatePicker {
        let picker = FridayBlockingDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.minimumDate = minDate
        picker.tintColor = UIColor(resource: .primaryF9CE29)
        picker.locale = Locale(identifier: Constants.shared.isAR ? "ar" : "en")
        picker.date = selectedDate
        picker.addTarget(
            context.coordinator,
            action: #selector(Coordinator.dateChanged(_:)),
            for: .valueChanged
        )

        // ── Force gray on first render ──
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            picker.setNeedsLayout()
            picker.layoutIfNeeded()
        }

        return picker
    }

    func updateUIView(_ uiView: FridayBlockingDatePicker, context: Context) {
        if uiView.date != selectedDate {
            uiView.date = selectedDate
        }
        uiView.locale = Locale(identifier: Constants.shared.isAR ? "ar" : "en")
        DispatchQueue.main.async {
            uiView.setNeedsLayout()
            uiView.layoutIfNeeded()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject {
        var parent: InlineDatePickerView
        init(_ parent: InlineDatePickerView) { self.parent = parent }

        @objc func dateChanged(_ picker: FridayBlockingDatePicker) {
            let selected = picker.date
            if Calendar.current.component(.weekday, from: selected) == 6 {
                let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selected)!
                picker.setDate(nextDay, animated: false)
                parent.selectedDate = nextDay
            } else {
                parent.selectedDate = selected
            }
            // Re-apply gray after selection changes displayed month
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                picker.setNeedsLayout()
                picker.layoutIfNeeded()
            }
        }
    }
}
