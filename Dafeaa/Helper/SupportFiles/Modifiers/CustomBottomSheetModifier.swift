//
//  CustomBottomSheetModifier.swift
//  Dafeaa
//
//  Created by AMNY on 23/04/2026.
//
import SwiftUI

enum CustomSheetDetent: Equatable {
    case medium
    case large
    case fraction(CGFloat)
    case height(CGFloat)
    
    func getHeight() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        switch self {
        case .medium: return screenHeight * 0.5
        case .large: return screenHeight * 0.9
        case .fraction(let fraction): return screenHeight * fraction
        case .height(let h): return h
        }
    }
}

struct CustomBottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var detents: [CustomSheetDetent]
    var isDismissOnBackgroundTap: Bool = true
    @ViewBuilder var sheetContent: () -> SheetContent
    
    @State private var showBackground = false
    @State private var showSheet = false
    @State private var currentHeight: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                ZStack {
                    Color.black
                        .opacity(showBackground ? 0.3 : 0)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if isDismissOnBackgroundTap { closeSheet() }
                        }
                    
                    if showSheet {
                        VStack(spacing: 0) {
                            Spacer()
                            VStack(spacing: 0) {
                                VStack {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(width: 40, height: 5)
                                        .padding(.top, 12)
                                        .padding(.bottom, 8)
                                }
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in dragOffset = value.translation.height }
                                        .onEnded { value in
                                            let finalHeight = currentHeight - value.translation.height
                                            let sortedHeights = detents.map { $0.getHeight() }.sorted()
                                            if value.translation.height > 50 && finalHeight < (sortedHeights.first ?? 0) * 0.8 {
                                                closeSheet()
                                            } else {
                                                let targetHeight = sortedHeights.min(by: { abs($0 - finalHeight) < abs($1 - finalHeight) }) ?? currentHeight
                                                withAnimation(.spring(response: 0.15, dampingFraction: 0.85)) {
                                                    currentHeight = targetHeight
                                                    dragOffset = 0
                                                }
                                            }
                                        }
                                )
                                
                                sheetContent()
                                
                                Spacer(minLength: 0)
                            }
                            .frame(height: max(0, currentHeight - dragOffset), alignment: .top)
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 600 : .infinity)
                            .background(Color.white)
                            .clipShape(RoundedCornerShape(radius: 24, corners: [.topLeft, .topRight]))
                            .shadow(radius: 10)
                            .transition(.move(edge: .bottom))
                        }
                        .ignoresSafeArea(edges: .bottom)
                    }
                }
                .presentationBackground(.clear)
                .onAppear {
                    currentHeight = detents.first?.getHeight() ?? 0
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.85)) {
                        showSheet = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showBackground = true
                        }
                    }
                }
            }
    }
    
    private func closeSheet() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            showSheet = false
            showBackground = false
            isPresented = false
            dragOffset = 0
        }
    }
}

extension View {
    func customBottomSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        detents: [CustomSheetDetent] = [.medium],
        isDismissOnBackgroundTap: Bool = true,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        self.modifier(CustomBottomSheetModifier(isPresented: isPresented, detents: detents, isDismissOnBackgroundTap: isDismissOnBackgroundTap, sheetContent: content))
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
