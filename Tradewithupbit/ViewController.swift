//
//  ViewController.swift
//  Tradewithupbit
//
//  Created by eunyoung hwang on 2021/02/16.
//

import UIKit
import SwiftUI




class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let editv = uiEditView.view else {
            return
        }
        editv.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(editv)
        var constrains:[NSLayoutConstraint] = [NSLayoutConstraint]()
        constrains.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[editv]-0-|", options: .alignAllCenterY, metrics:nil, views: ["editv":editv]))
        constrains.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[editv]-0-|", options: .alignAllCenterX, metrics:nil, views: ["editv":editv]))
        self.view.addConstraints(constrains)
    }
 
}
extension  ViewController {
    var uiEditView :  UIViewController {
        return UIHostingController(rootView: editView())
    }
}


