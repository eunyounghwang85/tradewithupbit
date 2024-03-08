//
//  depthView.swift
//  Tradewithupbit
//
//  Created by heyht on 3/7/24.
//

import SwiftUI

/*
@main
struct depthApp: App {
    
    @StateObject var model:SharedDataModel = SharedDataModel.shared
    
    var body: some Scene {
        WindowGroup{
            NavigationStack {
               // depthView().environmentObject(model) // ❎  depthView 안에서 NavigationLink 를 사용해서 다른 페이지에 진입해서 뷰모델에 접근하면, 크래시 유발
            }.environmentObject(model) // ✅ EnvironmentObject 를 주입할 때는, NavigationStack 의 영역 밖에서 주입해
        }
    }
}
 */

struct depthView : View {
    
    //@StateObject var model:SharedDataModel = SharedDataModel.shared
    //@State var list: [marketCode] = []
    
    
    var body: some View {

       Text("hellod")
    }
}


#Preview {
    depthView()
}


