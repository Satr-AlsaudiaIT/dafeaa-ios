//
//  AddOfferViewNew.swift
//  Dafeaa
//
//  Created by AMNY on 16/06/2025.
//

// AddOfferViewNew.swift

import SwiftUI

struct AddOfferViewNew: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = OrdersVM()
    
    @State var goToAddOffer = false
    @State private var deliveryPrice: String = ""
    @State private var tax: String = ""
    @FocusState private var focusedField: FormField?
    @State var navigateToAddProduct: Bool = false
    @State var productsAdding: [[String: Any]] = []
    @State var selectedImage: UIImage?
    @State var imageURL: String?
    @State var name: String = ""
    @State var description: String = ""
    @State var quantity: String = ""
    
    @State private var selectedProductImage: [UIImage] = []
    @State private var isShowingImagesSheet = false
    @State private var isShowingCameraPicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isShowingImagesPicker = false
    
    @State var price: String = ""
    @State var offerPrice: String = ""
    @State private var showOfferPriceTextField: Bool = false
    
    @State private var descriptionAttributed = NSAttributedString(string: "")
    @State private var weight = ""
    @State private var length = ""
    @State private var width = ""
    @State private var height = ""

    @State private var selectedDeliveryDate: Date? = nil
    @State private var showDatePicker: Bool = false

    @State private var isFreeShipping: Bool = false
    @State private var selectedShippingCompanies: [ShippingCompany] = []
    @State private var isShippingDropDownOpen: Bool = false
    @State private var hasIncludedTax: Bool = false
    @State private var taxRecord: String = ""
    @State private var showTaxBottomSheet: Bool = false
    @State private var hasRecord: Bool = false
    
    private var daysNumber: String {
        guard let date = selectedDeliveryDate else { return "" }
        return "\(daysFromNow(date))"
    }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                VStack {
                    NavigationBarView(title: "offerContent") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                    ScrollView {
                        VStack(spacing: 17) {
                            VStack(spacing: 8) {
                                CustomMainTextField(text: $name, placeHolder: "Name", showHeader: true)
                                    .focused($focusedField, equals: .name)
                                    .id(FormField.name)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("productDescription".localized())
                                        .textModifier(.plain, 14, .black)
                                    RichTextEditorView(
                                        attributedText: $descriptionAttributed,
                                        placeholder: "productDescription".localized()
                                    )
                                }
                            }
                            
                            CustomMainTextField(
                                text: $price,
                                placeHolder: "productPrice",
                                keyBoardType: .decimalPad,
                                fieldType: .price,
                                showHeader: true
                            )
                            .focused($focusedField, equals: .price)
                            .id(FormField.price)
                            
                            if showOfferPriceTextField {
                                CustomMainTextField(
                                    text: $offerPrice,
                                    placeHolder: "offerPrice",
                                    keyBoardType: .decimalPad,
                                    fieldType: .price,
                                    showHeader: true
                                )
                                .focused($focusedField, equals: .offerPrice)
                                .id(FormField.offerPrice)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                                .animation(.easeInOut(duration: 0.3), value: showOfferPriceTextField)
                            }

                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showOfferPriceTextField.toggle()
                                }
                            } label: {
                                HStack {
                                    Text(showOfferPriceTextField ? "hide_discount?".localized() : "apply_discount?".localized())
                                        .textModifier(.plain, 14, .primaryF9CE29)
                                        .underline()
                                    Spacer()
                                }
                                .padding(.top, -10)
                            }

                            // MARK: - Images Grid
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible()), count: 4),
                                spacing: 10
                            ) {
                                if selectedProductImage.count < 4 {
                                    // ✅ Add Image Button — triggers camera/library choice
                                    Button {
                                        ActionSheetHelper.show(
                                            title: "chooseUploadImage".localized(),
                                            message: "",
                                            confirmTitle: "cameraUpload".localized(),
                                            cancelTitle: "PhotoLibrary".localized(),
                                            isDestructive: false,
                                            onConfirm: {
                                                isShowingCameraPicker = true
                                            },
                                            onCancel: {
                                                isShowingImagesSheet = true
                                            }
                                        )
                                    } label: {
                                        ZStack {
                                            Rectangle()
                                                .fill(Color(.primaryF9CE29).opacity(0.1))
                                                .cornerRadius(10)
                                                .frame(
                                                    width: (UIScreen.main.bounds.width - 80) / 4,
                                                    height: (UIScreen.main.bounds.width - 80) / 4
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(
                                                            style: StrokeStyle(lineWidth: 2, dash: [8])
                                                        )
                                                        .foregroundColor(Color(.primaryF9CE29))
                                                )
                                            VStack {
                                                Spacer()
                                                Image(systemName: "plus")
                                                    .foregroundColor(Color(.gray979797))
                                                Text("Image".localized())
                                                    .textModifier(.plain, 12, .gray979797)
                                                Spacer()
                                            }
                                        }
                                        .frame(
                                            width: (UIScreen.main.bounds.width - 80) / 4,
                                            height: (UIScreen.main.bounds.width - 80) / 4
                                        )
                                    }
                                    // ✅ Library picker (multi)
                                    .sheet(isPresented: $isShowingImagesSheet) {
                                        ImagePickerMultiSelection(
                                            sourceType: .photoLibrary,
                                            isMultiSelection: true,
                                            selectedImages: Binding(
                                                get: { [] },
                                                set: { newImages in
                                                    let remaining = 4 - selectedProductImage.count
                                                    let toAdd = Array(newImages.prefix(remaining))
                                                    selectedProductImage.append(contentsOf: toAdd)
                                                }
                                            ),
                                            selectionNumber: 4 - selectedProductImage.count
                                        )
                                    }
                                    // ✅ Camera picker (single)
                                    .sheet(isPresented: $isShowingCameraPicker) {
                                        SingleCameraPickerView { image in
                                            if selectedProductImage.count < 4 {
                                                selectedProductImage.append(image)
                                            }
                                        }
                                    }
                                }
                                
                                // Existing images
                                ForEach(0..<selectedProductImage.count, id: \.self) { index in
                                    ZStack {
                                        Image(uiImage: selectedProductImage[index])
                                            .resizable()
                                            .frame(
                                                width: (UIScreen.main.bounds.width - 80) / 4,
                                                height: (UIScreen.main.bounds.width - 80) / 4
                                            )
                                            .aspectRatio(contentMode: .fill)
                                            .cornerRadius(15)
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Button {
                                                    selectedProductImage.remove(at: index)
                                                } label: {
                                                    Image(systemName: "multiply.circle")
                                                        .resizable()
                                                        .foregroundColor(.black)
                                                        .frame(width: 17, height: 17)
                                                        .scaledToFit()
                                                        .shadow(radius: 10)
                                                }
                                                .padding(.top, -7)
                                                .padding(.trailing, -7)
                                            }
                                            Spacer()
                                        }
                                    }
                                    .frame(
                                        width: (UIScreen.main.bounds.width - 80) / 4,
                                        height: (UIScreen.main.bounds.width - 80) / 4
                                    )
                                }
                            }
                            .padding([.leading, .trailing], 10)

                            // MARK: - Dimensions
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    CustomMainTextField(
                                        text: $weight,
                                        placeHolder: "Weight",
                                        keyBoardType: .decimalPad,
                                        fieldType: .weight,
                                        showHeader: true
                                    )
                                    .focused($focusedField, equals: .weight)
                                    .id(FormField.weight)
                                    
                                    CustomMainTextField(
                                        text: $length,
                                        placeHolder: "Length",
                                        keyBoardType: .decimalPad,
                                        fieldType: .dimensional,
                                        showHeader: true
                                    )
                                    .focused($focusedField, equals: .length)
                                    .id(FormField.length)
                                }
                                HStack(spacing: 12) {
                                    CustomMainTextField(
                                        text: $width,
                                        placeHolder: "Width",
                                        keyBoardType: .decimalPad,
                                        fieldType: .dimensional,
                                        showHeader: true
                                    )
                                    .focused($focusedField, equals: .width)
                                    .id(FormField.width)
                                    
                                    CustomMainTextField(
                                        text: $height,
                                        placeHolder: "Height",
                                        keyBoardType: .decimalPad,
                                        fieldType: .dimensional,
                                        showHeader: true
                                    )
                                    .focused($focusedField, equals: .height)
                                    .id(FormField.height)
                                }
                            }

                            ShippingCompanyDropdownMulti(
                                titleKey: "shipping_companies_required".localized(),
                                selected: $selectedShippingCompanies,
                                isOpen: $isShippingDropDownOpen
                            )

                            // MARK: - Date Picker Field
                            VStack(alignment: .leading, spacing: 4) {
                                Text("delivery_date".localized())
                                    .textModifier(.plain, 14, .black)

                                Button {
                                    showDatePicker = true
                                } label: {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.primaryF9CE29)
                                            .frame(width: 20, height: 20)
                                        Text(selectedDeliveryDate != nil
                                             ? formattedDate(selectedDeliveryDate!)
                                             : "select_delivery_date".localized())
                                            .textModifier(
                                                .plain, 14,
                                                selectedDeliveryDate != nil ? .black222222 : .grayB5B5B5
                                            )
                                        Spacer()
                                        if let date = selectedDeliveryDate {
                                            Text("\(daysFromNow(date)) " + "days".localized())
                                                .textModifier(.plain, 13, .primaryF9CE29)
                                        }
                                    }
                                    .frame(height: 48)
                                    .padding(.horizontal, 20)
                                    .background(Color(.grayF6F6F6))
                                    .cornerRadius(5)
                                }
                            }

                            // MARK: - Free Shipping
                            HStack {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isFreeShipping.toggle()
                                    }
                                } label: {
                                    checkBoxButton(text: "free_shipping", isSelected: $isFreeShipping)
                                }
                                .buttonStyle(.plain)
                                Spacer()
                            }

                            // MARK: - Tax
                            HStack {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        hasIncludedTax.toggle()
                                    }
                                } label: {
                                    checkBoxButton(text: "hasTax", isSelected: $hasIncludedTax)
                                }
                                .buttonStyle(.plain)
                                Spacer()
                                if viewModel.taxRecordNumber == "" && hasIncludedTax {
                                    Button {
                                        showTaxBottomSheet = true
                                    } label: {
                                        Text("addTaxRecordNumber".localized())
                                            .textModifier(.plain, 14, .primaryF9CE29)
                                    }
                                }
                            }
                        }
                        .animation(.easeOut(duration: 0.25), value: focusedField)
                        .onTapGesture {
                            hideKeyboard()
                            isShippingDropDownOpen = false
                        }
                        .navigationDestination(isPresented: $navigateToAddProduct) {
                            AddProductView(productsAdding: $productsAdding)
                        }
                    }
                    .padding(24)

                    ReusableButton(buttonText: "saveBtn", action: {
                        viewModel.validateCreateOfferLinkV3(
                            name: name,
                            descriptionAttributed: descriptionAttributed,
                            price: price,
                            offerPrice: offerPrice,
                            haveOfferPrice: showOfferPriceTextField,
                            images: selectedProductImage,
                            weight: weight,
                            length: length,
                            width: width,
                            height: height,
                            shippingCompanies: selectedShippingCompanies,
                            plannedShippingDateAndTime: daysNumber,
                            isShipmentFree: isFreeShipping,
                            hasTaxRecord: hasIncludedTax
                        )
                    })
                    .padding(24)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Done".localized()) { hideKeyboard() }
                    Spacer()
                    Button { showPerviousTextField() } label: {
                        Image(systemName: "chevron.up").foregroundColor(.blue)
                    }
                    Button { showNextTextField() } label: {
                        Image(systemName: "chevron.down").foregroundColor(.blue)
                    }
                }
            }

            if viewModel.isLoading {
                ProgressView("Loading...".localized())
                    .foregroundColor(.white)
                    .progressViewStyle(WithBackgroundProgressViewStyle())
            } else if viewModel.isFailed {
                ProgressView().hidden()
            }
            
            if showDatePicker {
                datePickerDialog
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .toastView(toast: $viewModel.toast)
        .navigationBarHidden(true)
        .onAppear {
            AppState.shared.swipeEnabled = true
            viewModel.getTaxRecord()
        }
        .onChange(of: showTaxBottomSheet) { _, new in
            if !new { viewModel.getTaxRecord() }
        }
        .onReceive(viewModel.$_isCreateOrderSuccess) { value in
            if value { self.presentationMode.wrappedValue.dismiss() }
        }
        .sheet(isPresented: $showTaxBottomSheet) {
            TaxRecordBottomSheet(taxInput: viewModel.taxRecordNumber, dismiss: $showTaxBottomSheet)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Date Picker Dialog
    @ViewBuilder
    private var datePickerDialog: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { showDatePicker = false }

            VStack(spacing: 0) {
                InlineDatePickerView(
                    selectedDate: Binding(
                        get: { selectedDeliveryDate ?? minSelectableDate },
                        set: { selectedDeliveryDate = $0 }
                    ),
                    minDate: minSelectableDate
                )
                .padding(.horizontal, 8)
                .padding(.top, 8)

                Divider()

                HStack {
                    Button {
                        showDatePicker = false
                    } label: {
                        Text("ok".localized())
                            .textModifier(.bold, 16, .primaryF9CE29)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                    }
                    Spacer()
                }
            }
            .onAppear {
                if selectedDeliveryDate == nil {
                    selectedDeliveryDate = minSelectableDate
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.70)
            .background(Color.white)
            .cornerRadius(14)
            .padding(.horizontal, 16)
            .shadow(color: .black.opacity(0.15), radius: 20)
        }
    }

    // MARK: - Date Helpers
    private var minSelectableDate: Date {
        Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
    }

    private func daysFromNow(_ date: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: today, to: target).day ?? 0
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: Constants.shared.isAR ? "ar" : "en")
        return formatter.string(from: date)
    }

    // MARK: - Keyboard Navigation
    func showNextTextField() {
        switch focusedField {
        case .name:       focusedField = .price
        case .price:      focusedField = showOfferPriceTextField ? .offerPrice : .weight
        case .offerPrice: focusedField = .weight
        case .weight:     focusedField = .length
        case .length:     focusedField = .width
        case .width:      focusedField = .height
        case .height:     focusedField = nil
        default:          focusedField = nil
        }
    }

    func showPerviousTextField() {
        switch focusedField {
        case .height:     focusedField = .width
        case .width:      focusedField = .length
        case .length:     focusedField = .weight
        case .weight:     focusedField = showOfferPriceTextField ? .offerPrice : .price
        case .offerPrice: focusedField = .price
        case .price:      focusedField = .name
        case .name:       focusedField = nil
        default:          focusedField = nil
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }

    enum FormField {
        case name, description, quantity, price, offerPrice, weight, length, width, height
    }
}

// MARK: - Single Camera Picker
struct SingleCameraPickerView: UIViewControllerRepresentable {
    var onImageCaptured: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.modalPresentationStyle = .overFullScreen
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: SingleCameraPickerView

        init(_ parent: SingleCameraPickerView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Preview
#Preview {
    AddOfferViewNew()
}

struct checkBoxButton : View {
    let text: String
    @Binding var isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color(.primaryF9CE29) : Color.white)
                    .frame(width: 18, height: 18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(Color(.primaryF9CE29), lineWidth: 1.5)
                    )
                if isSelected {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            }
            .padding(.leading,2)
            Text(text.localized())
                .textModifier(.plain, 14, .black)
            Spacer()
        }

    }
    
}

