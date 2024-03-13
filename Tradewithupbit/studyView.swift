//
//  studyView.swift
//  Tradewithupbit
//
//  Created by heyht on 3/12/24.
//

import SwiftUI
import Combine


struct customAppKey : EnvironmentKey{
    static var defaultValue: Color = .purple.opacity(0.2)
}
extension EnvironmentValues {
    var mainBackColor : Color {
        get{
            self[customAppKey.self]
        }
        set{
            self[customAppKey.self] = newValue
        }
    }
}
extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
struct textView : View {
    
    @Environment(\.mainBackColor) var titleColor
    
    var body: some View {
        Text("\(titleColor.description)")
            //.foregroundColor(titleColor)
            .shadow(color:titleColor,radius: -1)
            .font(.largeTitle)
            
    }
}
class textFieldOb :  ObservableObject {
   
    @Published var textFieldText : String = ""
    @Published var textIsValid: Bool = false
    
    var cancellables = Set<AnyCancellable>()
    
    
    init() {
        addTextFieldSubscriber()
    }
    
    func addTextFieldSubscriber() {
            $textFieldText
                .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
                .map { text -> Bool in
                    if text.count > 3 {
                        return true
                    }
                    return false
                }
            //            .assign(to: \.textIsValid, on: self)
                .sink(receiveValue: { [weak self] isValid in
                    self?.textIsValid = isValid
                })
                .store(in: &cancellables)
        }
    
    
}
struct studyView: View {
   
    @State private var mainColor : Color =  .purple.opacity(0.2)
   // @Environment(\.mainBackColor) var backgroundColor
    @StateObject var mytext  = textFieldOb()
    var textFieldText: String = ""
    var body: some View {
        ZStack{
         
            mainColor.edgesIgnoringSafeArea(.all)
            VStack{
             
               // Text("Hello, World!")
                textView().environment(\.mainBackColor, mainColor)
                Button("touch"){
                    mainColor = Color.random
                }.disabled(mytext.textIsValid)
                
                TextField("tt", text: $mytext.textFieldText)
                    .padding(40)
                    .font(.headline)
                
            }
        }
    }
}

#Preview {
    studyView()
}
