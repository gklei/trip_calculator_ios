//
//  trip_calculatorApp.swift
//  trip-calculator
//
//  Created by Gregory Klein on 12/3/20.
//

import SwiftUI

@main
struct trip_calculatorApp: App {
   var body: some Scene {
      WindowGroup {
         TabView {
            StudentListView()
               .tabItem {
                  Image(systemName: "list.dash")
                  Text("Students")
               }
               .edgesIgnoringSafeArea(.top)
            CalculateView()
               .tabItem {
                  Image(systemName: "dollarsign.circle")
                  Text("Calculate")
               }
         }
      }
   }
}
