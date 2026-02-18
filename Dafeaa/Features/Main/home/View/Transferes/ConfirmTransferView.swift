//
//  ConfirmTransferView.swift
//  Dafeaa
//
//  Created by AMNY on 27/04/2025.
//

import SwiftUI

struct ConfirmTransferView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = HomeVM()
    
    // Sample data - replace with your actual data model
    @State var balance : String = ""
    @State var phoneNumber : String = "59999999"
    @State var amount : String = "0"
    @State var name = "A M"
    @State var fees: String = "0"
    @State var total : Double = 0
    @State private var isTransferSuccess: Bool = false
    @State private var isTransferFailed: Bool = false
    var body: some View {
        ZStack {
            VStack {
                // Navigation Bar
                NavigationBarView(title: "confirmTransfer") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Product Balance
                        HStack(alignment: .center, spacing: 4){
                            Text("availableBalance:".localized() )
                                .textModifier(.plain, 20, .black000000)
                            HStack {
                                Text("\(balance)")
                                    .textModifier(.plain, 20, .black222222)
                                Image(.riyal)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.black222222)
                                    .frame(width: 20)
                            }
                            .environment(\.layoutDirection, .rightToLeft)
                        }.padding(.bottom, 24)
                            
                        // Recipient Info Section
                        VStack(spacing: 24) {
                            // Phone Number
                            infoRow(title: "Phone Number", value: phoneNumber)
                            
                            // Name
                            infoRow(title: "Name", value: name)
                        }
                        .padding(.horizontal,24)
                        .padding(.vertical,16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.grayBDBDBD, lineWidth: 1)
                        )
                        .padding(1)
                        .background(Color.white)
                        .cornerRadius(8)
                        
                        // Transaction Details Section
                        VStack(spacing: 24) {
                            // Amount
                            
                            infoRow(title: "amount".localized(), value:  "\(String(format: "%.2f", Double(amount) ?? 0))", isPrice: true)
                            
                            // Fees
                            infoRow(title: "fees".localized(), value: fees, isPrice: true)
                                                        
                            // Total
                            infoRow(title: "total".localized(), value: "\(String(format: "%.2f", total))",isPrice: true, color: .black222222)
                        }
                        
                        .padding(.horizontal,24)
                        .padding(.vertical,16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.grayBDBDBD, lineWidth: 1)
                        ).padding(1)
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.top ,8)
                        Spacer()
                    }
                    .padding(24)
                }
                
                // Buttons
                VStack(spacing: 12) {
                    ReusableButton(buttonText: "confirmTransfer") {
                        // Handle transfer confirmation
                        viewModel.confirmTransfer(phone: phoneNumber.normalizePhoneNumber, amount: total)
                    }
                    
                    ReusableButton(
                        buttonText: "Cancel",
                        isEnabled: true,
                        buttonColor: .transparent,
                        borderColor: .black222222,
                        textColor: .black222222
                    ) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            
            // Loading Indicator
            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            }
        }
        .navigationBarHidden(true)
        .toastView(toast: $viewModel.toast)
        .onAppear{
            total = (Double(fees) ?? 0) + (Double(amount) ?? 0)
        }
        .onChange(of: viewModel.isTransferSuccess) { _, newValue in
            if newValue {
                isTransferSuccess = true
            }
        }
        .onChange(of: viewModel.isTransferFailed) { _, newValue in
            if newValue {
                isTransferFailed = true
            }
        }
        .navigationDestination(isPresented: $isTransferSuccess) {
            SuccessView(phoneNumber: phoneNumber,date: viewModel.transferData.createdAt ?? "" ,amount: amount, name: name,referenceNum: viewModel.transferData.transId ?? "")
        }
        .navigationDestination(isPresented: $isTransferFailed) {
            FailedView(phoneNumber: phoneNumber,date: viewModel.transferData.createdAt ?? "" ,amount: amount, name: name, referenceNum: viewModel.transferData.transId ?? "")
        }
    }
    
    // Helper view for info rows
    private func infoRow(title: String, value: String, isPrice: Bool = false, color: Color = .gray8B8C86) -> some View {
        HStack {
            Text(title.localized())
                .textModifier(.plain, 16, color)
            Spacer()
            HStack{
                Text(value)
                    .textModifier(.plain, 16, color)
                if isPrice {
                    Image(.riyal)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(color)
                    .frame(width: 20)}
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }
    
}

#Preview {
    ConfirmTransferView()
}
