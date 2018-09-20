//
//  BaseVC.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import Toast

class BaseVC: UIViewController {
    
    open func showToast(message: String) {
        self.view.makeToast(message, duration: 3.0, position: CSToastPositionCenter)
    }
    
    open func showLoading(withStatus show: Bool) {
        if show {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .indeterminate
            hud.label.text = "Loading"
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    open func handleError(error: Error) {
//        if let networkError = error as? NetworkError {
//            switch networkError.errorType {
//            case .NoInternetConnection:
//                self.showToast(message: "No connection, please try again")
//
//            default:
//                self.showToast(message: error.localizedDescription)
//            }
//        } else
        if let parseDataError = error as? ParseDataError {
            self.showToast(message: parseDataError.errorMessage)
        }
//        } else if let validateError = error as? ValidateError {
//            self.showToast(message: validateError.message)
//        } else {
//            self.showToast(message: error.localizedDescription)
//        }
    }
//
//    func selectScreen(doingVisit: DoingVisit, step: Int, screens: [Int]) -> UIViewController {
//        switch (screens[step % 5]) {
//        case 0:
//            return Question1VC.instance(doingVisit: doingVisit, step: step, screens: screens)
//
//        case 1:
//            return Question2VC.instance(doingVisit: doingVisit, step: step, screens: screens)
//
//        case 2:
//            return Question3VC.instance(doingVisit: doingVisit, step: step, screens: screens)
//
//        case 3:
//            return Question4VC.instance(doingVisit: doingVisit, step: step, screens: screens)
//
//        default:
//            return Question5VC.instance(doingVisit: doingVisit, step: step, screens: screens)
//        }
//    }
}
