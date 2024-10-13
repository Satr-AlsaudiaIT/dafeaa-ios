//
//  NavigationUtil.swift
//  
//
//  Created by M.Magdy on 24/09/2023.
//  Copyright © 2023  Nura. All rights reserved.
//

import UIKit
struct NavigationUtil {
    static func popToRootView() {
        findNavigationController(viewController: UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController)?
            .popToRootViewController(animated: true)
    }
    static func navigateToSecondViewController() {
            guard let navigationController = findNavigationController(viewController: UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController),
                  let secondViewController = navigationController.viewControllers[safe: 1] else {
                return
            }
            
            navigationController.popToViewController(secondViewController, animated: true)
        }
    static func popToPreviousTwoViewControllers() {
            guard let navigationController = findNavigationController(viewController: UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController),
                  navigationController.viewControllers.count >= 3 else {
                return
            }
            let targetViewController = navigationController.viewControllers[navigationController.viewControllers.count - 3]
            navigationController.popToViewController(targetViewController, animated: true)
        }
static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }
if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }
return nil
    }
    
}
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
