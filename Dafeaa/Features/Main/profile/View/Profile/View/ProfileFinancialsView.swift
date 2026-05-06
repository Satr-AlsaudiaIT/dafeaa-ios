import SwiftUI

struct ProfileFinancialsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = FinancialsVM()
    
    @FocusState private var focusedField: FinancialFormField?
    @State private var keyboardHeight: CGFloat = 0
    
    @State private var isIncomeSourceOpen: Bool? = false
    @State private var isIncomeRangeOpen: Bool? = false
    @State private var isTaxResidencyOpen: Bool? = false
    @State private var isPepOpen: Bool? = false
    
    @State private var incomeSourceText: String = ""
    @State private var incomeRangeText: String = ""
    @State private var taxResidencyText: String = ""
    @State private var pepText: String = ""
    
    @State private var incomeSourceOptions: [String] = []
    @State private var incomeRangeOptions: [String] = []
    @State private var yesNoOptions: [String] = []
    
    @State private var hasAttemptedSubmit: Bool = false

    var isEditMode: Bool {
        return viewModel.financialData != nil
    }

    var hasChanged: Bool {
        guard let data = viewModel.financialData else { return true }
        
        let originalSource = viewModel.incomeSources.first(where: { $0.id == data.incomeSource })?.label ?? ""
        let originalRange = viewModel.incomeRanges.first(where: { $0.id == data.incomeRange })?.label ?? ""
        let originalTax = (data.taxResidency == true) ? "yes".localized() : "no".localized()
        let originalPep = (data.isPep == true) ? "yes".localized() : "no".localized()
        
        return incomeSourceText != originalSource ||
               incomeRangeText != originalRange ||
               taxResidencyText != originalTax ||
               pepText != originalPep
    }

    var isFormValid: Bool {
        return !incomeSourceText.isEmpty &&
               !incomeRangeText.isEmpty &&
               !taxResidencyText.isEmpty &&
               !pepText.isEmpty
    }

    var isSaveButtonEnabled: Bool {
        if isEditMode {
            return hasChanged && isFormValid
        } else {
            return true
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationBarView(title: "financials".localized()) {
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            Text("financials".localized())
                                .textModifier(.bold, 18, .black222222)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("* " + "income_source".localized())
                                    .textModifier(.plain, 14, .black222222)
                                
                                DropdownSearchTF(
                                    placeHolder: "select_income_source".localized(),
                                    isOpen: $isIncomeSourceOpen,
                                    text: $incomeSourceText,
                                    title: "income_source".localized(),
                                    options: $incomeSourceOptions,
                                    submitLabel: .done,
                                    titleSize: 14,
                                    isSearchable:false
                                    
                                )
                                .focused($focusedField, equals: .incomeSource)
                                .onChange(of: incomeSourceText) { _, newValue in
                                    if let match = viewModel.incomeSources.first(where: { $0.label == newValue }) {
                                        viewModel.selectedIncomeSource = match
                                    }
                                }
                                
                                if hasAttemptedSubmit && incomeSourceText.isEmpty {
                                    Text("required_field".localized())
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 8)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("* " + "income_range".localized())
                                    .textModifier(.plain, 14, .black222222)
                                
                                DropdownSearchTF(
                                    placeHolder: "select_income_range".localized(),
                                    isOpen: $isIncomeRangeOpen,
                                    text: $incomeRangeText,
                                    title: "income_range".localized(),
                                    options: $incomeRangeOptions,
                                    submitLabel: .done,
                                    titleSize: 14,
                                    isSearchable:false
                                )
                                .focused($focusedField, equals: .incomeRange)
                                .onChange(of: incomeRangeText) { _, newValue in
                                    if let match = viewModel.incomeRanges.first(where: { $0.label == newValue }) {
                                        viewModel.selectedIncomeRange = match
                                    }
                                }
                                
                                if hasAttemptedSubmit && incomeRangeText.isEmpty {
                                    Text("required_field".localized())
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 8)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("* " + "tax_residency_question".localized())
                                    .textModifier(.plain, 14, .black222222)
                                
                                DropdownSearchTF(
                                    placeHolder: "select".localized(),
                                    isOpen: $isTaxResidencyOpen,
                                    text: $taxResidencyText,
                                    title: "tax_residency_question".localized(),
                                    options: $yesNoOptions,
                                    submitLabel: .done,
                                    titleSize: 14,
                                    isSearchable:false
                                )
                                .focused($focusedField, equals: .taxResidency)
                                .onChange(of: taxResidencyText) { _, newValue in
                                    viewModel.taxResidency = (newValue == "yes".localized())
                                }
                                
                                if hasAttemptedSubmit && taxResidencyText.isEmpty {
                                    Text("required_field".localized())
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 8)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("* " + "pep_question".localized())
                                    .textModifier(.plain, 14, .black222222)
                                
                                DropdownSearchTF(
                                    placeHolder: "select".localized(),
                                    isOpen: $isPepOpen,
                                    text: $pepText,
                                    title: "pep_question".localized(),
                                    options: $yesNoOptions,
                                    submitLabel: .done,
                                    titleSize: 14,
                                    isSearchable:false
                                )
                                .focused($focusedField, equals: .pep)
                                .onChange(of: pepText) { _, newValue in
                                    viewModel.isPep = (newValue == "yes".localized())
                                }
                                
                                if hasAttemptedSubmit && pepText.isEmpty {
                                    Text("required_field".localized())
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 8)
                                }
                            }
                            
                        }
                        .padding(.top, 24)
                        .padding(.horizontal, 24)
                        .padding(.bottom, keyboardHeight + 80)
                    }
                    .onChange(of: focusedField) { oldField, newField in
                        withAnimation {
                            if let newField = newField {
                                proxy.scrollTo(newField, anchor: .center)
                            }
                        }
                    }
                }
                
                ReusableButton(buttonText: "saveBtn".localized(), isEnabled: isSaveButtonEnabled) {
                    hasAttemptedSubmit = true
                    if isFormValid {
                        viewModel.updateFinancialInfo(isEditMode: isEditMode)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            }
        }
        .onAppear {
            viewModel.getFinancialInfo()
            incomeSourceOptions = viewModel.incomeSources.map { $0.label }
            incomeRangeOptions = viewModel.incomeRanges.map { $0.label }
            yesNoOptions = ["yes".localized(), "no".localized()]
            subscribeToKeyboardEvents(keyboardHeight: keyboardHeight)
        }
        .onDisappear {
            unsubscribeFromKeyboardEvents()
        }
        .onReceive(viewModel.$financialData) { data in
            if let data = data, data.isCompleted == true {
                if let source = viewModel.incomeSources.first(where: { $0.id == data.incomeSource }) {
                    viewModel.selectedIncomeSource = source
                    incomeSourceText = source.label
                }
                
                if let range = viewModel.incomeRanges.first(where: { $0.id == data.incomeRange }) {
                    viewModel.selectedIncomeRange = range
                    incomeRangeText = range.label
                }
                
                let taxValue = data.taxResidency ?? false
                viewModel.taxResidency = taxValue
                taxResidencyText = taxValue ? "yes".localized() : "no".localized()
                
                let pepValue = data.isPep ?? false
                viewModel.isPep = pepValue
                pepText = pepValue ? "yes".localized() : "no".localized()
            }
        }
        .onReceive(viewModel.$isSuccess) { success in
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if isEditMode {
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        NavigationUtil.popToPreviousTwoViewControllers()
                    }
                }
            }
        }
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Done".localized()) { hideKeyboard() }
                Spacer()
                Button(action: { showPreviousField() }) {
                    Image(systemName: "chevron.up").foregroundColor(.blue)
                }
                Button(action: { showNextField() }) {
                    Image(systemName: "chevron.down").foregroundColor(.blue)
                }
            }
        }
    }
    
    enum FinancialFormField { case incomeSource, incomeRange, taxResidency, pep }
    
    func showNextField() {
        switch focusedField {
        case .incomeSource: focusedField = .incomeRange
        case .incomeRange: focusedField = .taxResidency
        case .taxResidency: focusedField = .pep
        default: focusedField = nil
        }
    }
    
    func showPreviousField() {
        switch focusedField {
        case .pep: focusedField = .taxResidency
        case .taxResidency: focusedField = .incomeRange
        case .incomeRange: focusedField = .incomeSource
        default: focusedField = nil
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
