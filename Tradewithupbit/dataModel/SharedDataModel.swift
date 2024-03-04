//
//  SharedDataModel.swift
//  Tradewithupbit
//
//  Created by heyht on 3/4/24.
//

import Foundation


// 관찰자 역할 부여
class SharedDataModel : ObservableObject {
    @Published var marketCodes = [marketCode]()
    
}
