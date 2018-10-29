//
//  ViewAnimation.swift
//  iZalo
//
//  Created by CPU11613 on 10/29/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import UIKit
class ViewAnimation {
    public class func transitionY(view: UIView, isMovingDown: Bool, distance: CGFloat) -> CGRect {
        print("start \(view.frame)")
        if isMovingDown {
            print("down")
            UIView.animate(withDuration: 0.5, animations: {
                view.frame = view.frame.offsetBy(dx: 0, dy: distance)
            
            }, completion: nil)
            
        }
        else {
            print("up")
            UIView.animate(withDuration: 0.5, animations: {
                view.frame = view.frame.offsetBy(dx: 0, dy: -distance)
            }, completion: nil)
        }
        print("end \(view.frame)")
        return view.frame
    }
}
