// BottomSheetModifier.swift

import SwiftUI

// MARK: - Detent Option
enum AppDetent {
    case fraction(CGFloat)
    case medium
    case large
    case height(CGFloat)
    
    func toUIKitDetent() -> UISheetPresentationController.Detent {
        switch self {
        case .fraction(let fraction):
            return .custom { context in
                context.maximumDetentValue * fraction
            }
        case .medium:
            return .medium()
        case .large:
            return .large()
        case .height(let height):
            return .custom { _ in height }
        }
    }
}

// MARK: - Presenter
struct BottomSheetPresenter<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let detents: [AppDetent]
    let content: () -> Content

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            guard uiViewController.presentedViewController == nil else { return }
            
            let hostingController = UIHostingController(rootView: content())
            
            hostingController.modalPresentationStyle = .pageSheet
            hostingController.modalTransitionStyle = .coverVertical

            if let sheet = hostingController.sheetPresentationController {
                sheet.detents = detents.map { $0.toUIKitDetent() }
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 24
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                sheet.delegate = context.coordinator
            }

            if let popover = hostingController.popoverPresentationController {
                popover.sourceView = uiViewController.view
                popover.sourceRect = CGRect(
                    x: uiViewController.view.bounds.midX,
                    y: uiViewController.view.bounds.maxY,
                    width: 0,
                    height: 0
                )
                popover.permittedArrowDirections = []
                popover.delegate = context.coordinator
            }

            hostingController.presentationController?.delegate = context.coordinator

            DispatchQueue.main.async {
                uiViewController.present(hostingController, animated: true)
            }

        } else {
            DispatchQueue.main.async {
                uiViewController.presentedViewController?.dismiss(animated: true)
            }
        }
    }

    // MARK: - Coordinator
    class Coordinator: NSObject,
                       UISheetPresentationControllerDelegate,
                       UIAdaptivePresentationControllerDelegate,
                       UIPopoverPresentationControllerDelegate {
        var parent: BottomSheetPresenter

        init(_ parent: BottomSheetPresenter) {
            self.parent = parent
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.isPresented = false
        }

        func adaptivePresentationStyle(
            for controller: UIPresentationController,
            traitCollection: UITraitCollection
        ) -> UIModalPresentationStyle {
            return .pageSheet
        }

        func adaptivePresentationStyle(
            for controller: UIPresentationController
        ) -> UIModalPresentationStyle {
            return .pageSheet
        }
    }
}

// MARK: - Modifier
struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let detents: [AppDetent]
    let content: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .background(
                BottomSheetPresenter(
                    isPresented: $isPresented,
                    detents: detents,
                    content: self.content
                )
            )
    }
}

// MARK: - View Extension
extension View {
    func appBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: [AppDetent] = [.medium],
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            BottomSheetModifier(
                isPresented: isPresented,
                detents: detents,
                content: content
            )
        )
    }
}
