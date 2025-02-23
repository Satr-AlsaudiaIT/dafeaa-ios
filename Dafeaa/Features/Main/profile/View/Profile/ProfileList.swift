//
//  ProfileList.swift
//  Dafeaa
//
//  Created by AMNY on 23/02/2025.
//

import SwiftUI

struct ProfileList: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var selectedAddressId: Int = Constants.selectedAddressId
    @State private var selectedAddress: String = Constants.selectedAddress
    
    var body: some View {
        ZStack{
            VStack {
                NavigationBarView(title: "profile"){
                    self.presentationMode.wrappedValue.dismiss()
                }

                VStack() {
                    VStack(spacing: 16) {
                        NavigationLinkComponent(
                            destination: ProfileDetailView(),
                            label: "profile",
                            image: Image(.iconProfile)
                        )
                        
                        NavigationLinkComponent(
                            destination: SavedAddressesView(selectedAddressId: $selectedAddressId, selectedAddress: $selectedAddress),
                            label: "Saved Addresses",
                            image: Image(.iconAddress)
                        )
                        
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
    
}

#Preview {
    ProfileList()
}
