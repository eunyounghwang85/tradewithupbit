//
//  Presenter + SharedDataModel.swift
//  Tradewithupbit
//
//  Created by heyht on 3/6/24.
//

import Foundation

// MARK: codemodels
extension SharedDataModel {
    func fetchData() {
       
        Task {
            do {
                let models =  try await requestManager.getmarketAll()
                await MainActor.run {
                    // 뷰에서 쓰므로 mainsync 를 잡아 줘야 함
                    self.marketCodes = models
                }
            } catch  {
                await MainActor.run {
                    self.marketCodes.removeAll()
                }
            }
        }
    }
}



