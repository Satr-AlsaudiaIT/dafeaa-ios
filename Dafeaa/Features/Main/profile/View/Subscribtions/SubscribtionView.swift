//
//  SubscribtionView.swift
//  Dafeaa
//
//  Created by AMNY on 21/10/2024.
//

import SwiftUI

struct SubscribtionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var selectedIndex: Int? = nil
    @State var selectedSubscriptionData: SubscriptionModelData? = nil
    @StateObject var viewModel = MoreVM()
    @State var isLoading = false
    @State var showConfirmationPopUpView: Bool = false
    var subscriptionPlans: [SubscriptionModelData] { viewModel.subscriptionPlans }
    @State var  subPlanId : Int = (GenericUserDefault.shared.getValue(Constants.shared.subPlanId) as? Int ?? 0)
    var body: some View {
        ZStack {
 
                if subscriptionPlans.isEmpty {
                    VStack {
                        Spacer()
                        Text("no_subscription_found_message".localized())
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                    }
                }
                else {
                    VStack(alignment: .leading) {
                        HStack {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    self.presentationMode.wrappedValue.dismiss()
                                    
                                }
                            }) {
                                Image(.arrowRight)
                                    .resizable()
                                    .frame(width: 32,height: 32)
                                    .foregroundColor(.black222222)
                            }
                            Spacer()
                            
                        }
                        .padding(.horizontal)
                        Text("choose_plane_title".localized())
                            .textModifier(.plain, 19, .black222222)
                            .padding(.top)
                            .padding(.horizontal)
                        ScrollView {
                            if subscriptionPlans.count != 0 {
                                let count = subscriptionPlans.count
                                ForEach(0..<count, id: \.self) { index in
                                    let subscriptionPlan = subscriptionPlans[index]
                                    SubscriptionCell(
                                        isSelected: selectedIndex == index,
                                        subscriptionData: subscriptionPlan
                                    )
                                    .onTapGesture {
                                        if selectedIndex == index {
                                            selectedIndex = nil
                                            selectedSubscriptionData = nil
                                        } else {
                                            selectedIndex = index
                                            selectedSubscriptionData = subscriptionPlan
                                        }
                                    }
                                    .onAppear{
                                        if subscriptionPlan.id == subPlanId {
                                            selectedIndex = index
                                            selectedSubscriptionData = subscriptionPlan
                                        }
                                    }
                                    
                                }
                                
                            }
                            VStack(spacing: 12) {
                                Text("subscription_plans_features_title".localized())
                                    .textModifier(.plain, 15, .gray666666)
                                HStack {
                                    Image(.greenCheckMark)
                                    Text("dashboard_title".localized())
                                        .textModifier(.plain, 15, .black010202)
                                    Spacer()
                                }
                                HStack {
                                    Image(.greenCheckMark)
                                    Text("transactions_list_title".localized())
                                        .textModifier(.plain, 15, .black010202)
                                    Spacer()
                                }
                                HStack {
                                    Image(.greenCheckMark)
                                    Text("profit_reports_title".localized())
                                        .textModifier(.plain, 15, .black010202)
                                    Spacer()
                                }
                                if selectedIndex == nil || selectedSubscriptionData?.id == subPlanId {
                                    ReusableButton(buttonText: "start_now_button", isEnabled: false, buttonColor: .gray) {
                                    }
                                    .padding(.top)
                                }
                                else {
                                    
                                    ReusableButton(buttonText: "start_now_button", isEnabled: true, buttonColor: .yellow) {
                                        showConfirmationPopUpView = true
                                    }
                                    .padding(.top)
                                }
                                
                            }
                            .padding(.top,10)
                        }
                        .padding()
                    }
                }
            
            if showConfirmationPopUpView {
                ZStack {
                    Color.black.opacity(0.2)
                    VStack {
                        Spacer()
                       
                            ZStack {
                                Color(.white)
                                VStack (spacing: 20){
                                    HStack {
                                        Text("subscription_popup_title".localized())
                                            .textModifier(.plain, 16, .gray666666)
                                        Spacer()
                                    }
                                    .padding(.top)
                                    Text("subscription_popup_body".localized())
                                        .textModifier(.plain, 14, .gray666666)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil)
                                    HStack {
                                        Spacer()
                                        Button {
                                            showConfirmationPopUpView = false
                                        } label: {
                                            Text ("Cancel".localized())
                                                .textModifier(.plain, 14, .gray666666)
                                        }
                                        .padding(.trailing, 20)
                                        Button {
                                            viewModel.selectSubscriptionPlan(id: selectedSubscriptionData?.id  ?? 0)
                                        } label: {
                                            Text ("subscription_confirmation_button".localized())
                                                .textModifier(.plain, 14, .green026C34)
                                        }
                                    }
                                }
                                .padding(20)
                            }
                            .frame(width: UIScreen.main.bounds.width - 40)
                            .cornerRadius(15)
                            .fixedSize()
                            
                        
                        Spacer()
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showConfirmationPopUpView = false
                }
            }
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading...".localized())
                        .foregroundColor(.white)
                        .progressViewStyle(WithBackgroundProgressViewStyle())
                    Spacer()
                }
            }
            else {
                ProgressView().hidden()
            }
        }
        .onChange(of: viewModel.isLoading, { _, newValue in
            isLoading = newValue
        })
        .navigationBarHidden(true)
        .onChange(of: selectedSubscriptionData) { _ , newSelection in
            // Reflect changes when a new subscription is selected
            print("Selected Subscription: \(String(describing: newSelection))")
        }
        .onAppear{
            viewModel.getSubscriptionPlans()
        }
        .toastView(toast: $viewModel.toast)
        .onChange(of: viewModel._subSuccess) { oldValue, newValue in
            if newValue {
                showConfirmationPopUpView = false
                viewModel._subSuccess = false
            }
        }
    }
}

#Preview {
    SubscribtionView()
}


//let mokData: [SubscribtionModelData] = [
//    SubscribtionModelData(id: 1, price: 99, percentage: 0, forUse: "ر.س/شهري", description: "مشاريع متوسطة (100-500 منتج)"),
//    SubscribtionModelData(id: 1, price: 199, percentage: 0, forUse: "ر.س/شهري", description: "مشاريع متوسطة (100-500 منتج)"),
//    SubscribtionModelData(id: 1, price: 199, percentage: 0, forUse: "ر.س/شهري", description: "مشاريع متوسطة (100-500 منتج)"),
//    SubscribtionModelData(id: 1, price: 399, percentage: 0, forUse: "ر.س/شهري", description: "مشاريع متوسطة (100-500 منتج)"),
//    SubscribtionModelData(id: 1, price: 0, percentage: 4.9, forUse: "ر.س/شهري", description: "مشاريع متوسطة (100-500 منتج)"),
//]
