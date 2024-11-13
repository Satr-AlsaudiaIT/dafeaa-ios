//
//  ProcessesView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct ProcessesView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = ProcessesVM()
    var body: some View {
        
        //MARK: - upperView
        ZStack {
            VStack(spacing: 0) {
                NavigationBarView(title: "lastProcessAndPayment".localized())
                if viewModel.operationsList.isEmpty {
                    EmptyCostumeView()
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(0..<viewModel.operationsList.count,id: \.self){ index in
                                ProcessComponent(process: viewModel.operationsList[index])
                                    .onAppear {
                                        if index == viewModel.operationsList.count - 1 {
                                            loadMoreOrdersIfNeeded()
                                        }
                                    }
                            }
                        }
                        
                    }.padding(24)
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
        .onAppear(){viewModel.operations(skip: 0) }
    }
    
    private func loadMoreOrdersIfNeeded() {
        if viewModel.hasMoreData && !viewModel.isLoading {
            viewModel.operations(skip: viewModel.operationsList.count)
        }
    }
    
}
#Preview {
    ProcessesView()
}



