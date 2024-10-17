import Foundation
import SwiftUI

struct DatePickerTextField: UIViewRepresentable {
    private let textField = UITextField()
    private let datePicker = UIDatePicker()
    private let helper = Helper()
    public var currentIsMinDate : Bool = false
    public var placeholder: String
    @Binding public var date: Date?
    @Binding var isActive: Bool
    
    func makeUIView(context: Context) -> UITextField {
        if currentIsMinDate == true {
            let calendar = Calendar.current
            let today = Date()
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
                datePicker.minimumDate = tomorrow
            }
        }
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self.helper, action: #selector(self.helper.dateValueChanged), for: .valueChanged)
        datePicker.locale = Constants.shared.isAR ? Locale.init(identifier: "ar") : Locale.init(identifier: "en")
        
        textField.placeholder = placeholder
        
        textField.inputView = datePicker
        //textField.borderStyle = .roundedRect
        textField.font = font(.custom(AppFonts.shared.name(AppFontsTypes.plain), size: 15)) as? UIFont
        textField.textColor = .grayB5B5B5
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: helper, action: #selector(helper.doneButtonTapped))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        textField.inputAccessoryView = toolbar
        textField.textAlignment = Constants.shared.isAR ? .right:.left
        helper.onDateValueChanged = {
            date = datePicker.date
            isActive = true
        }
        
        helper.onDoneButtonTapped = {
            if date == nil {
                date = datePicker.date
            }
            self.isActive = false
            textField.resignFirstResponder()
        }
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if let selectedDate = date {
            uiView.text = selectedDate.formattedDate()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Helper {
        public var onDateValueChanged: (() -> Void)?
        public var onDoneButtonTapped: (() -> Void)?
        
        @objc func dateValueChanged() {
            onDateValueChanged?()
        }
        
        @objc func doneButtonTapped() {
            onDoneButtonTapped?()
        }
        
    }
    
    class Coordinator {}
}

