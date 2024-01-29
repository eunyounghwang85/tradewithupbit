//
//  ViewController.swift
//  Tradewithupbit
//
//  Created by eunyoung hwang on 2021/02/16.
//

import UIKit





class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        WebSocketManager.shared.socket?.onEvent =  {
            [weak self] e in
            guard let self  =  self else { return }
            Log(String(describing: e))
        }
    }

}

