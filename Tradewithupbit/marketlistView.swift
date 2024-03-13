//
//  marketlistView.swift
//  Tradewithupbit
//
//  Created by heyht on 3/5/24.
//

import SwiftUI


struct marketlistView: View {
    
    @StateObject private var model  = SharedDataModel.shared
    @State var stack: NavigationPath = NavigationPath()
   // @State private var list = SharedDataModel.shared.marketCodes
   /* @SceneStorage("selectedItem") private var selectedItem: String?
    var selectedID: Binding<marketCode?> {
        Binding<marketCode?>(
            get: {
                return model.marketCodes.first(where: {$0.id == selectedItem})
            },
            set: { selectedItem = $0?.id }
        )
    }*/

    @State private var pushNextView = false
    var title:String = "마켓종목"
  
    var body: some View {
        NavigationStack(path: $stack){ // rootview
            List(model.marketCodes){ market in
               // Text(market.korean_name)
                NavigationLink(
                    market.korean_name,
                    value: market
                )
                .navigationDestination(for: marketCode.self) { market in
                    editView(stack:$stack, detailMarket:.constant(market))
                        
                    
                }.padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
                /*.gesture(TapGesture().onEnded {
                    presentedMarket.append(market)
                })*/
                /*.onChange(of: presentedMarket) { _ in
                    
                    guard let selected = presentedMarket.last else { return }
                  
                    
                }*/
                
            }
            .navigationBarTitle(title)
            .onAppear {

                SharedDataModel.shared.fetchData()

            }
        }
       
      /*  NavigationView {
            List(model.marketCodes){
                market in
                
                NavigationLink(
                    destination: editView(),
                    tag: selectedID.wrappedValue ?? marketCode.init("test"),
                    selection: selectedID){
                        Text(market.korean_name)
                    }
            
            }
            .navigationViewStyle(.stack)
            // 안에 위치
            .navigationBarTitle("마켓종목")
        }.onAppear(perform: {
            model.fetchData()
        })
       */
    }
}

#Preview {
    marketlistView()
}


struct backButton :  View {
 //   @StateObject var back : backbuttonTitle  = backbuttonTitle("")
    @State var title : String = ""
    @State var toback: (() -> Void)? = nil
    var body: some View {
        Button{
            toback?()
        }label: {
            HStack {
                Image(systemName: "chevron.left") // 화살표 Image
                    .aspectRatio(contentMode: .fit)
                Text(title)
            }
        }
    }
}
/*
class backbuttonTitle :  ObservableObject {
    var title:String = ""
    init(_ title: String) {
        self.title = title
    }
    
}
*/
