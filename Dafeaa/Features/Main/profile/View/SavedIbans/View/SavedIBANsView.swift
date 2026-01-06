//
//  SavedIBANsView.swift
//  Dafeaa
//
//  Created by AMNY on 01/01/2026.
//

import SwiftUI

struct SavedIBANsView: View {
    @StateObject var viewModel = IBANVM()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showAddEditSheet = false
    @State private var ibanToEdit: IBANData?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                NavigationBarView(title: "Saved IBANs".localized()) {
                    presentationMode.wrappedValue.dismiss()
                }
                
                // MARK: - Content
                VStack(alignment: .center, spacing: 24) {
                    if viewModel.ibanList.isEmpty {
                        EmptyCostumeView()
                        ReusableButton(buttonText: "addNewIBAN".localized()) {
                            ibanToEdit = nil
                            showAddEditSheet = true
                        }
                    } else {
                        ibanListView
                    }
                }
                .padding(24)
            }
            
            
            if showAddEditSheet {
                AddEditIBANView(ibanToEdit: $ibanToEdit,showPopup: $showAddEditSheet, viewModel: viewModel)
            }
            // MARK: - Loading Indicator
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            } else if viewModel.isFailed {
                ProgressView()
                    .hidden()
            }
        }
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.getIBANs()
        }
        .onChange(of: viewModel._isSuccess) { _, newValue in
            if newValue {
                showAddEditSheet = false
                viewModel._isSuccess = false
            }
        }
//        .sheet(isPresented: $showAddEditSheet) {
//            AddEditIBANView(ibanToEdit: $ibanToEdit, viewModel: viewModel)
//                .presentationDetents([.height(400)])
//                .presentationDragIndicator(.visible)
//        }

    }
    
    // MARK: - IBAN List View
    private var ibanListView: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.ibanList.indices, id: \.self) { index in
                        let ibanItem = viewModel.ibanList[index]
                        ibanRow(for: ibanItem)
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.bottom, 80)
            }
            
            VStack {
                Spacer()
                ReusableButton(buttonText: "addNewIBAN".localized()) {
                    ibanToEdit = nil
                    showAddEditSheet = true
                }
            }
        }
    }
    
    // MARK: - IBAN Row
    private func ibanRow(for iban: IBANData) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.black).opacity(0.1), lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground)))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("IBAN Number".localized() + ": \(iban.iban ?? "")")
                            .textModifier(.plain, 14, .black1E1E1E)
                        
                        Text("Account Name".localized() + ": \(iban.name ?? "")")
                            .textModifier(.plain, 12, .gray979797)
                    }
                    
                    Spacer()
                    
                    // Edit Button
                    Button(action: {
                        ibanToEdit = iban
                        showAddEditSheet = true
                    }) {
                        Image(.editIcon)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 8)
                    
                    // Delete Button
                    Button(action: {
                        deleteIBAN(iban)
                    }) {
                        Image(.trash)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Delete IBAN Function
    private func deleteIBAN(_ iban: IBANData) {
        viewModel.deleteIBAN(id: iban.id ?? 0)
    }
}

#Preview {
    SavedIBANsView()
}
