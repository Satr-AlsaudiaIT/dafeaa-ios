//
//  WithdrawsView.swift
//  Dafeaa
//
//  Created by AMNY on 14/11/2024.
//

import SwiftUI

struct WithdrawsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = MoreVM()
    @State var heighlightedId: Int = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationBarView(title: "withdrawsProcess".localized()) {
                    presentationMode.wrappedValue.dismiss()
                }
                
                if viewModel.withdrawsData.isEmpty {
                    EmptyCostumeView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(0..<viewModel.withdrawsData.count, id: \.self) { index in
                                WithdrawComponent(process: viewModel.withdrawsData[index], heighlightedId: heighlightedId)
                                    .onAppear {
                                        if index == viewModel.withdrawsData.count - 1 {
                                            loadMoreOrdersIfNeeded()
                                        }
                                    }
                            }
                        }
                    }
                    .padding(24)
                }
            }
            
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
            viewModel.getWithDraws(skip: 0)
        }
    }
    
    private func loadMoreOrdersIfNeeded() {
        if viewModel.hasMoreData && !viewModel.isLoading {
            viewModel.getWithDraws(skip: viewModel.withdrawsData.count)
        }
    }
}
#Preview {
    WithdrawsView()
}


