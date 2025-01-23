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
    var subscriptionPlans: [SubscriptionModelData] { viewModel.subscriptionPlans }
    var body: some View {
        ZStack {
 
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading...".localized())
                        .foregroundColor(.white)
                        .progressViewStyle(WithBackgroundProgressViewStyle())
                    Spacer()
                }
            }
            else{
                ProgressView().hidden()
                if subscriptionPlans.isEmpty {
                    VStack {
                        Spacer()
                        Text("No subscription found".localized())
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
                        Text("اختر خطة الإشتراك المناسبة لك".localized())
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
                                    
                                }
                                
                            }
                            VStack(spacing: 12) {
                                Text("جميع خطط الاشتراك في دافع تتضمن خصائص هائلة مخصصة لاحتياجاتك اليومية".localized())
                                    .textModifier(.plain, 15, .gray666666)
                                HStack {
                                    Image(.greenCheckMark)
                                    Text("لوحة تحكم كامله لنشاطك التجاري")
                                        .textModifier(.plain, 15, .black010202)
                                    Spacer()
                                }
                                HStack {
                                    Image(.greenCheckMark)
                                    Text("قائمة بكل عمليات البيع والشراء")
                                        .textModifier(.plain, 15, .black010202)
                                    Spacer()
                                }
                                HStack {
                                    Image(.greenCheckMark)
                                    Text("تقارير المكاسب والربح")
                                        .textModifier(.plain, 15, .black010202)
                                    Spacer()
                                }
                                if selectedIndex == nil  {
                                    ReusableButton(buttonText: "ابدأ الان", isEnabled: false, buttonColor: .gray) {
                                    }
                                    .padding(.top)
                                }
                                else {
                                    ReusableButton(buttonText: "ابدأ الان", isEnabled: true, buttonColor: .yellow) {
                                    }
                                    .padding(.top)
                                }
                                
                            }
                            .padding(.top,10)
                        }
                        .padding()
                    }
                }
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
