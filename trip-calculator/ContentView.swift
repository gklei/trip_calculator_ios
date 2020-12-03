//
//  ContentView.swift
//  trip-calculator
//
//  Created by Gregory Klein on 12/3/20.
//

import SwiftUI
import Combine

class ViewModel: ObservableObject {
   @Published var studentList: StudentList = StudentList(students: [])
   private var disposables = Set<AnyCancellable>()
   
   func getStudents() {
      API.getStudents()
         .sink { (_) in
         } receiveValue: { (list) in
            self.studentList = list
         }
         .store(in: &disposables)
   }
}

struct ContentView: View {
   @State var disposables = Set<AnyCancellable>()
   @StateObject var viewModel = ViewModel()
   
   var body: some View {
      NavigationView {
         List {
            ForEach(viewModel.studentList.students) { student in
               Text(student.name)
            }
         }
         .navigationBarTitle("Trip Calculator")
      }
      .onAppear(perform: {
         viewModel.getStudents()
      })
   }
}

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
      ContentView()
   }
}
