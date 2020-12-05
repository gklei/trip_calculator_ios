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
      NavigationView {
         List {
            ForEach(viewModel.students) { student in
               StudentRowView(student: student)
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
      .onAppear(perform: {
         viewModel.getStudents()
      })
      .alert(
         isPresented: $showNewActivityAlert,
         TextAlert(title: "Student Name", message: "Enter a new name", action: { (result) in
            guard let name = result else { return }
            viewModel.onAdd(name: name)
         })
      )
   }
}

struct StudentRowView: View {
   let student: Student
   
   var body: some View {
      NavigationLink(destination: ExpenseItemListView(viewModel: ExpenseItemListView.ViewModel(student: student))) {
         HStack {
            VStack(alignment: .leading) {
               Text(student.name)
               Text("\(student.expenseItems?.count ?? 0) Items")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
            }
            Spacer()
            Text("$\(student.totalExpenseAmount, specifier: "%.2f")")
         }
      }
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
         withAnimation {
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
}

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
      StudentListView()
   }
}
