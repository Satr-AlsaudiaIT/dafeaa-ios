//
//  TaxRecordBottomSheet.swift
//  Dafeaa
//
//  Created by AMNY on 25/02/2026.
//


import SwiftUI

struct TaxRecordBottomSheet: View {

    @ObservedObject var viewModel: MoreVM = MoreVM()
    @State var taxInput: String = ""
    @State var isEditTapped: Bool = false
    @FocusState private var isTaxFieldFocused: Bool  
    @Binding var dismiss: Bool
    var body: some View {
        ZStack {
            VStack(spacing: 20) {


                // Bottom sheet title
                Text("tax_record".localized())
                    .textModifier(.bold, 18, .black)
                    .padding(.top)
                // Input section
                VStack(alignment: .leading, spacing: 6) {

                    Text("tax_record".localized())
                        .textModifier(.plain, 14, .black)

                    HStack(spacing: 8) {
                        CustomMainTextField(text: $taxInput, placeHolder: "tax_record".localized(),keyBoardType: .numberPad)

                        if viewModel.isEditingTaxRecord {
                       
                            Button {
                                viewModel.deleteTaxRecord()
                            } label: {
                                Image(.trash)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.black)
                                    .padding(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                
                ReusableButton(
                    buttonText: viewModel.taxRecordNumber == "" ? "add_tax_record_number".localized() : "edit_tax_record_number".localized(),
                    isEnabled: taxInput != viewModel.taxRecordNumber,
                    action: {
                        viewModel.addOrEditTaxRecord(taxNumber: taxInput)
                    }
                )
                .padding(.horizontal, 24)
                .padding(.top, 40)


                Spacer()
            }

            // Loading overlay
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            }
        }
        .toastView(toast: $viewModel.toastSheet)
        .onAppear {
            taxInput = viewModel.taxRecordNumber
            isEditTapped = taxInput == "" ? true : false
        }
        .onChange(of: viewModel.taxRecordNumber) { _, newValue in
                dismiss = false
        }
    }
}

#Preview {
    TaxRecordBottomSheet(viewModel: MoreVM(), dismiss: .constant(false))
}
