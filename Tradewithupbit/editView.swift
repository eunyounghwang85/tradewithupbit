//
//  editView.swift
//  Tradewithupbit
//
//  Created by heyht on 2/26/24.
//

import SwiftUI

enum hlocalizeTest : String, Identifiable, CaseIterable{
    var id: Self{self}
    
    case getMarketbtnText
    case getMarketlableText
    
    // MARK: LocalizedStringResource 추가 해줘야함
    var title : String {
        return self.rawValue.localized
    }
    /*if #available(iOS 16, *) {
        var title : LocalizedStringResource {
            switch self {
            case .getMarketbtnText:
                return "시세정보"
            case .getMarketlableText:
                return "시세정보 를 보려면 누르시오"
            }
        }
    }else{
        var title : String {
            switch self {
            case .getMarketbtnText:
                return "시세정보"
            case .getMarketlableText:
                return "시세정보 를 보려면 누르시오"
            }
        }
    }*/
}
/*
@main
struct mockupComponentApp: App {
  var body: some Scene {
    WindowGroup {
        editView()
    }
  }
}
*/

struct editView: View {
 //   @Binding var detailMarket : marketCode?
   
    @State private var isFollowed = false
    var title = "heyTitle".localized
    @Binding var stack : NavigationPath
    @Binding var detailMarket : marketCode?
    @State private var backgroundColor : Color = .green
 
    var body: some View {
        HStack{
            VStack {
                Button(action: {
                    isFollowed = !isFollowed
                    actionItem()
                }, label:{
                    Text(hlocalizeTest.getMarketbtnText.title)
                        .font(.largeTitle)
                        .padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
                    /* .background(
                          
                                           ZStack {
                                                RoundedRectangle(
                                                    cornerRadius: 20,
                                                    style: .continuous
                                                )
                                                .fill(isFollowed ? .clear : .pink.opacity(0.6))
                                                RoundedRectangle(
                                                    cornerRadius: 20,
                                                    style: .continuous
                                                )
                                                .stroke(.white, lineWidth: 2)
                                            }
                                        )*/
                }).background(Color.pink.opacity(0.6))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .background(in:.capsule)
                    //.background(ignoresSafeAreaEdges: .all)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading:backButton(title: detailMarket?.korean_name ?? ""){
                        Task{
                            stack.removeLast()
                        }
                    })
                
            }
            Text("testt")
        }.environment(\.layoutDirection, .rightToLeft)
        //detailMarket?.korean_name ?? ""
    }
    
    func actionItem(){
        guard let codes = detailMarket?.market else {
            
            stack = .init() // 최초 화면으로 돌아가기
            return
        }
        
        WebSocketManager.shared.sendMesseage([codes])
        stack.removeLast()
    }
    
}

#Preview {
    editView(stack:.constant(NavigationPath()), detailMarket:.constant(nil)).environment(\.locale, .init(identifier: "ko"))
}
