//
// AddEditIBANView.swift
// Dafeaa
//
// Created by AMNY on 01/01/2026.
//

import SwiftUI

struct AddEditIBANView: View {
    @Binding var ibanToEdit: IBANData?
    @Binding var showPopup: Bool
    @ObservedObject var viewModel: IBANVM
    
    @State private var ibanNumber: String = ""
    @State private var accountName: String = ""
    @State private var ibanError: String = ""
    @State private var nameError: String = ""
    @State private var hasAttemptedSubmit: Bool = false
    @FocusState private var focusedField: IBANFormField?
    
    var isEditMode: Bool {
        ibanToEdit != nil
    }
    
    var isFormValid: Bool {
        !ibanNumber.isEmpty &&
        ibanNumber.isValidSaudiIBAN &&
        !accountName.isEmpty
    }
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showPopup = false
                }
            
            // MARK: - Popup Content
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Spacer()
                    
                    Text(isEditMode ? "Edit IBAN".localized() : "Add New IBAN".localized())
                        .textModifier(.plain, 20, .black1E1E1E)
                    
                    Spacer()
                    
                    Button(action: {
                        showPopup = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray979797)
                            .font(.system(size: 18))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                
                Divider()
                
                // MARK: - Form Fields
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        CustomMainTextField(
                            text: $ibanNumber,
                            placeHolder: "IBAN Number"
                        )
                        .focused($focusedField, equals: .ibanNumber)
                        .onChange(of: ibanNumber) { _, newValue in
                            validateIBANLive(newValue)
                        }
                        
                        if !ibanError.isEmpty {
                            Text(ibanError)
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                                .padding(.leading, 8)
                        }
                    }
                    
                    // Account Name Field with Error
                    VStack(alignment: .leading, spacing: 4) {
                        CustomMainTextField(
                            text: $accountName,
                            placeHolder: "Account Name"
                        )
                        .focused($focusedField, equals: .accountName)
                        .onChange(of: accountName) { _, newValue in
                            validateNameLive(newValue)
                        }
                        
                        if !nameError.isEmpty {
                            Text(nameError)
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                                .padding(.leading, 8)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                Spacer()
                
                // MARK: - Confirm Button
                ReusableButton(
                    buttonText: "Confirm",
                    isEnabled: isFormValid,
                    buttonColor: .black
                ) {
                    hasAttemptedSubmit = true
                    validateAndSubmit()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .frame(width: UIScreen.main.bounds.width - 48)
            .frame(height: 380)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .onAppear {
            setData()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Done".localized()) {
                    hideKeyboard()
                }
                Spacer()
                Button(action: {
                    showPreviousTextField()
                }, label: {
                    Image(systemName: "chevron.up").foregroundColor(.blue)
                })
                Button(action: {
                    showNextTextField()
                }, label: {
                    Image(systemName: "chevron.down").foregroundColor(.blue)
                })
            }
        }
    }
    
    // MARK: - Live Validation
    private func validateIBANLive(_ value: String) {
        if hasAttemptedSubmit || !value.isEmpty {
            if value.isEmpty {
                ibanError = "ibanValidation".localized()
            } else if !value.isValidSaudiIBAN {
                ibanError = "invalidSaudiIBAN".localized()
            } else {
                ibanError = ""
            }
        }
    }
    
    private func validateNameLive(_ value: String) {
        if hasAttemptedSubmit || !value.isEmpty {
            if value.isEmpty {
                nameError = "accountNameValidation".localized()
            } else {
                nameError = ""
            }
        }
    }
    
    // MARK: - Validate and Submit
    private func validateAndSubmit() {
        validateIBANLive(ibanNumber)
        validateNameLive(accountName)
        
        if isFormValid {
            viewModel.validateIBAN(
                id: ibanToEdit?.id,
                iban: ibanNumber,
                name: accountName
            )
        }
    }
    
    // MARK: - Set Data for Edit Mode
    private func setData() {
        if let iban = ibanToEdit {
            ibanNumber = iban.iban ?? ""
            accountName = iban.name ?? ""
        }
    }
    
    // MARK: - Keyboard Navigation
    private func showNextTextField() {
        switch focusedField {
        case .ibanNumber:
            focusedField = .accountName
        default:
            focusedField = nil
        }
    }
    
    private func showPreviousTextField() {
        switch focusedField {
        case .accountName:
            focusedField = .ibanNumber
        default:
            focusedField = nil
        }
    }
}

enum IBANFormField {
    case ibanNumber
    case accountName
}

#Preview {
    AddEditIBANView(ibanToEdit: .constant(nil), showPopup: .constant(false), viewModel: IBANVM())
}
