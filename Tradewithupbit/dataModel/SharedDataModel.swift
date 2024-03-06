//
//  SharedDataModel.swift
//  Tradewithupbit
//
//  Created by heyht on 3/4/24.
//

import Foundation


// 관찰자 역할 부여
class SharedDataModel : ObservableObject {
    static let shared : SharedDataModel = SharedDataModel()
   
    @Published var marketCodes = [marketCode]()
   
}


