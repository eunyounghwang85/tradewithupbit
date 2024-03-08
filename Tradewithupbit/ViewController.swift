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
        guard let editv = uimarketNavigation.view else {
            return
        }
       // self.view = editv
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
        //marketCode()
        return UIHostingController(rootView: editView(detailMarket:.constant(nil)))
    }
    
    var uimarketNavigation:  UINavigationController {
        // main을 navigation 으로 구성 하므로 UIkit 타입을 일치시켜준다.
        return UINavigationController(rootViewController:uimarketRootView)
    }
    
    var uimarketRootView :  UIViewController {
        return UIHostingController(rootView: marketlistView())
    }
}


