//
//  Application.swift
//  User
//
//  Created by CSS on 03/04/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import KWDrawerController

extension UIApplication {
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let drawer = base as? DrawerController {
            return topViewController(base: drawer.getViewController(for: .none))
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
}
