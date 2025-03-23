//
//  StaticPagesView.swift
//  Dafeaa
//
//  Created by AMNY on 12/10/2024.
//

import SwiftUI

struct StaticPagesView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = MoreVM()
    var pageTitle :String{
        switch type {
        case .aboutApp :
            return "About Dafeaa".localized()
        case .privacyPolicy :
            return "Privacy Policy".localized()
        case .termsAndCondition :
            return "Terms & Conditions".localized()
        }
    }
    var content :String?{
        switch type {
        case .aboutApp :
           return viewModel.staticData?.about ?? ""
        case .privacyPolicy :
            return viewModel.staticData?.privacy ?? ""
        case .termsAndCondition :
            return viewModel.staticData?.terms ?? ""
        }

    }
    @State private var _dataContainer :  NSAttributedString?// = NSAttributedString(string: "")
    @Binding var type :StaticPages

    var body: some View {
        ZStack{
            VStack(spacing: 20){
                VStack{
                    NavigationBarView(title: pageTitle){
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    HTMLTextView(htmlText: content ?? "")
                        .padding([.leading,.trailing,.bottom],24)
                    
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
        }.edgesIgnoringSafeArea(.bottom)
            .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)

        .onAppear(){
            switch type {
            case .aboutApp :
                viewModel.getStaticPages(type: "settings/about")
            case .privacyPolicy :
                viewModel.getStaticPages(type: "settings/privacy")
            case .termsAndCondition :
                viewModel.getStaticPages(type: "settings/terms")
            }
            AppState.shared.swipeEnabled = true
        }
        
    }
}

struct StaticPagesView_Previews: PreviewProvider {
    static var previews: some View {
        @State var type = StaticPages.aboutApp
        StaticPagesView(type: $type)
    }
}
enum StaticPages{
    case aboutApp, termsAndCondition, privacyPolicy
}

struct HTMLTextView: UIViewRepresentable {
    var htmlText: String
    var font : UIFont = UIFont(name: AppFonts.shared.name(.plain), size: 14) ?? .systemFont(ofSize: 14)
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
         if let attributedString = htmlText.attributedStringFromHTML {
             // Apply the custom font
             let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
             mutableAttributedString.addAttributes(
                 [.font: font],
                 range: NSRange(location: 0, length: mutableAttributedString.length)
             )
             uiView.attributedText = mutableAttributedString
         }
     }
}

extension String {
    var attributedStringFromHTML: NSAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            // Create attributed string from HTML
            let attributedString = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
            
            // Create a paragraph style with right alignment
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = Constants.shared.isAR ? .right:.left

            
            // Apply the paragraph style to the entire attributed string
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
            
            return attributedString
        } catch {
            print("Error creating attributed string from HTML: \(error)")
            return nil
        }
    }
}
