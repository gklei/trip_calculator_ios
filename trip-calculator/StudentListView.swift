//
//  ContentView.swift
//  trip-calculator
//
//  Created by Gregory Klein on 12/3/20.
//

import SwiftUI
import Combine

struct StudentListView: View {
   @State var disposables = Set<AnyCancellable>()
   @StateObject var viewModel = ViewModel()
   @State var showNewActivityAlert: Bool = false
   @State private var editMode = EditMode.inactive
   
   private var addButton: some View {
      switch editMode {
      case .inactive: return AnyView(Button(action: {
         showNewActivityAlert = true
      }) { Image(systemName: "plus") })
      default: return AnyView(EmptyView())
      }
   }
   
   var body: some View {
      let refreshBinding = Binding(
         get: { return false },
         set: { _ in self.viewModel.getStudents() }
      )
      NavigationView {
         VStack {
            List {
               ForEach(viewModel.students) { student in
                  StudentRowView(student: student, refresh: refreshBinding)
                     .frame(height: 60)
               }
               .onDelete(perform: viewModel.onDelete)
            }
            .navigationBarTitle("Trip Calculator")
            .navigationBarItems(
               leading: EditButton().disabled(viewModel.students.count == 0 && editMode == .inactive),
               trailing: addButton
            )
            .listStyle(PlainListStyle())
            .environment(\.editMode, $editMode)
         }
      }
      .onAppear(perform: viewModel.getStudents)
      .alert(
         isPresented: $showNewActivityAlert,
         NewStudentAlert(
            title: "New Student",
            message: "Enter a student name",
            placeholder: "Name",
            action: {
               guard let name = $0 else { return }
               viewModel.onAdd(name: name)
            })
      )
   }
}

extension StudentListView {
   class ViewModel: ObservableObject {
      @Published var students: [Student] = []
      private var disposables = Set<AnyCancellable>()
      
      func getStudents() {
         API.getStudents()
            .sink { (_) in
            } receiveValue: { (list) in
               self.students = list.students
            }
            .store(in: &disposables)
      }
      
      func onAdd(name: String) {
         API.createStudent(name: name)
            .sink { (_) in
            } receiveValue: { _ in
               self.getStudents()
            }
            .store(in: &disposables)
      }
      
      func onDelete(offsets: IndexSet) {
         guard offsets.count == 1 else { return }
         let offset = offsets.first!
         let student = students[offset]
         API.deleteStudent(id: student.id)
            .sink { (_) in
            } receiveValue: { (list) in
               self.students = list.students
            }
            .store(in: &disposables)
      }
   }
}

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
      StudentListView()
   }
}
