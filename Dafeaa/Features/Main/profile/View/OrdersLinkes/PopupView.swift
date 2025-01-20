//
//  PopupView.swift
//  Dafeaa
//
//  Created by AMNY on 19/01/2025.
//

import SwiftUI


// Example of how to use PopupView
struct PopupViewExample: View {
    @State private var showPopup = true  // Control popup visibility

    var body: some View {
        VStack {
            Button("Show Popup") {
                showPopup = true  // Show popup on button press
            }
        }
        .popup(
          isPresented: $showPopup,
          buttonTitle: "Submit",
          buttonColor: .blue,
          showCloseButton: true,
          showMainButton: true, // Set to false to hide the button
          buttonAction: {
            print("Button tapped!")
          }
        ) {
          Text("This is the popup content")
            .padding()
        }
    }
}

#Preview {
    PopupViewExample()
}




struct PopupView<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    let showMainButton: Bool?
    let buttonTitle: String?
    let buttonColor: Color?
    let showCloseButton: Bool
    let buttonAction: (() -> Void)?

    init(
        isPresented: Binding<Bool>,
        buttonTitle: String? = nil,
        buttonColor: Color? = nil,
        showCloseButton: Bool,
        showMainButton: Bool? = true,
        buttonAction: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.buttonTitle = buttonTitle
        self.buttonColor = buttonColor
        self.showCloseButton = showCloseButton
        self.showMainButton = showMainButton
        self.buttonAction = buttonAction
        self.content = content()
    }

    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                // Popup content container
                VStack(spacing: 20) {
                    VStack {
                      VStack {
                        content


                        if showMainButton == true {
                            
                            ReusableButton(buttonText: buttonTitle ?? "", isEnabled: true) {
                                buttonAction?()
                            }
                            .padding()
                           
                        }
                      }
                      .padding(.vertical, 20)

                    }
                    .background(Color.white)
                    .cornerRadius(9)
                    .padding(.horizontal, 20)

                    .shadow(radius: 10)
                    .transition(AnyTransition.opacity.combined(with: .scale)) // Fade and scale
                    .scaleEffect(isPresented ? 1 : 0.5) // Start smaller and scale up
                    .opacity(isPresented ? 1 : 0) // Fade in and out
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: isPresented) // Bounce animation
                    .frame(maxWidth: .infinity)

                    if showCloseButton {
                        Button {
                            withAnimation {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 20,height: 20)
                                .foregroundColor(.primary)
                        }
                    }
                }

            }
        }
    }
}

extension View {
    func popup<Content: View>(
        isPresented: Binding<Bool>,
        buttonTitle: String? = nil,
        buttonColor: Color? = nil,
        showCloseButton: Bool,
        showMainButton: Bool? = true,
        buttonAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            self
            PopupView(
                isPresented: isPresented,
                buttonTitle: showMainButton == true ? buttonTitle : nil,
                buttonColor: showMainButton == true ? buttonColor : nil,
                showCloseButton: showCloseButton,
                showMainButton: showMainButton,
                buttonAction: showMainButton == true ? buttonAction : nil,
                content: content
            )
        }
    }
}
