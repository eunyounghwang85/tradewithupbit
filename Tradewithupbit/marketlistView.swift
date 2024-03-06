//
//  marketlistView.swift
//  Tradewithupbit
//
//  Created by heyht on 3/5/24.
//

import SwiftUI


struct marketlistView: View {
    
    @StateObject private var model  = SharedDataModel.shared
   
    var body: some View {
        NavigationView {
            List(model.marketCodes){
                market in
                Text(market.korean_name)
            }
            // 안에 위치
            .navigationBarTitle("마켓종목")
        }.onAppear(perform: {
            model.fetchData()
        })
    }
}

#Preview {
    marketlistView()
}
