//
//  QRSelectionBottomSheet.swift
//  Dafeaa
//
//  Created by AMNY on 23/04/2026.
//


import SwiftUI

struct QRSelectionBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var showGenerateQR: Bool
    @Binding var showScanQR: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Text("pay_or_receive_qr".localized())
                .textModifier(.bold, 20, .black222222)
                .padding(.top, 16)
            
                Button {
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showGenerateQR = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(.qrcodecolored)
                            .resizable()
                            .frame(width: 24,height: 24)
                        
                        Text("generate_qr".localized())
                            .textModifier(.bold, 14, .black222222)
                        
                        Spacer()
                        
                        Image(systemName: Constants.shared.isAR ? "chevron.left" :  "chevron.right")
                            .foregroundColor(.black000000)
                    }
                    .padding(.horizontal,16)
                    .padding(.vertical,12)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(.grayF9F9F9)
                            .stroke(Color.grayEDEDED, lineWidth: 1)
                    )
                }
                
                Button {
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showScanQR = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        
                        Image(.scan)
                            .resizable()
                            .frame(width: 24,height: 24)
                        
                        Text("scan_qr".localized())
                            .textModifier(.bold, 14, .black222222)
                        
                        Spacer()
                        
                        Image(systemName: Constants.shared.isAR ? "chevron.left" :  "chevron.right")
                            .foregroundColor(.black000000)
                            
                    }
                    .padding(.horizontal,16)
                    .padding(.vertical,12)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(.grayF9F9F9)
                            .stroke(Color.grayEDEDED, lineWidth: 1)
                    )
                }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
    }
}
