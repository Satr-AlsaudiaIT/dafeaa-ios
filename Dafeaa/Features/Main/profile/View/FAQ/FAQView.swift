//
//  FAQView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//


import SwiftUI

struct FAQView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = MoreVM()
        @State var expandedAnswer :Int = -1
    @State var loadMore = false
    
    var body: some View {
        
        ZStack(alignment: .bottom){
            VStack(spacing: 20){
                VStack{
                    NavigationBarView(title: "FAQNavTitle"){
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                    if (viewModel.questionList.count ) == 0 {
                        EmptyCostumeView()
                        
                    } else {
                        ScrollView(.vertical,showsIndicators: false){
                            ScrollViewReader{value in
                                LazyVStack (spacing: 10) {
                                    ForEach(0..<(viewModel.questionList.count),id: \.self){ index in
                                        VStack(alignment: .leading,spacing: 10) {
                                            Button(action:
                                                    {
                                                withAnimation {
                                                    if self.expandedAnswer == viewModel.questionList[index].id ?? -1{
                                                        self.expandedAnswer =  -1
                                                    }else {
                                                        self.expandedAnswer = viewModel.questionList[index].id ?? -1
                                                    }
                                                    
                                                }
                                            }){
                                                HStack (alignment: .center){
                                                    Text(viewModel.questionList[index].question ?? "")
                                                        .textModifier(.plain, 14, .black292D32)
                                                        .frame(height:23)
                                                    Spacer()
                                                    Image(systemName:  self.expandedAnswer == viewModel.questionList[index].id ?? -1 ? "chevron.down" : "chevron.up")
                                                        .frame(width: 5,height: 10)
                                                        .foregroundColor(.grayB5B5B5)
                                                }.frame(maxWidth: .infinity)
                                            }
                                            .padding(.horizontal,24)

                                            
                                            if self.expandedAnswer == viewModel.questionList[index].id ?? -1 {
                                                
                                                Text(viewModel.questionList[index].answer ?? "" )
                                                   .textModifier(.plain, 14, .gray919191)
                                                   .multilineTextAlignment(Constants.shared.isAR ? .leading:.trailing )
                                                   .padding(.horizontal,24)
                                            } else {
                                                Divider()
                                            }
                                        }
                                        .onAppear {
                                                if index == viewModel.questionList.count - 1 &&  self.loadMore{
                                                    
                                                    viewModel.questions(skip:  viewModel.questionList.count){loadMore in
                                                        self.loadMore = loadMore
                                                        
                                                    }
                                                }
                                            }
                                        
                                    }
                                }
                            }
                        }
                        .padding(.vertical,24)
                        
                    }
                    
                    Spacer()
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
            .onAppear(){
//                viewModel.questions(skip: 0){loadMore in
                    self.loadMore = loadMore
//                }
                AppState.shared.swipeEnabled = true
            }
        
    }
}

#Preview {
    FAQView()
}
