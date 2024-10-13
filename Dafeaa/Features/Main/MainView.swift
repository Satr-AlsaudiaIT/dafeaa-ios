//
//  MainView.swift
//  Dafeaa
//
//  Created by AMNY on 11/10/2024.
//

import SwiftUI

struct MainView: View {
   
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                TabBarView()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        
    }
    
    
}

#Preview {
    MainView()
}
