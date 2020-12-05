//
//  ExpenseItemListView.swift
//  trip-calculator
//
//  Created by Gregory Klein on 12/5/20.
//

import SwiftUI
import Combine

struct ExpenseItemListView: View {
   @ObservedObject var viewModel: ViewModel
   @State var showNewItemAlert = false
   
   @State private var editMode = EditMode.inactive
   private var addButton: some View {
      Button(action: {
         showNewItemAlert = true
      }) {
         Image(systemName: "plus")
      }
   }
   
   var body: some View {
      List {
         ForEach(viewModel.items) { item in
            HStack {
               Text(item.name)
               Spacer()
               Text("$\(item.amount, specifier: "%.2f")")
            }
         }
         .onDelete(perform: viewModel.onDelete)
      }
      .itemAlert(
         isPresented: $showNewItemAlert,
         NewItemAlert(title: "Item Name", message: "Enter a new item", action: { (name, amount) in
            guard let name = name, let amount = amount else { return }
            viewModel.onAdd(name: name, amount: amount)
         })
      )
      .onAppear(perform: {
         viewModel.getItems()
      })
      .edgesIgnoringSafeArea(.top)
      .navigationBarTitle("Expense Items", displayMode: .inline)
      .navigationBarItems(
         trailing: addButton
      )
   }
}

extension ExpenseItemListView {
   class ViewModel: ObservableObject {
      let student: Student
      @Published var items: [ExpenseItem] = []
      private var disposables = Set<AnyCancellable>()
      
      var totalView: some View {
         HStack {
            Text("TOTAL")
            Spacer()
            Text("$\(items.reduce(0, { $0 + $1.amount }), specifier: "%.2f")")
         }
      }
      
      init(student: Student) {
         self.student = student
      }
      
      func getItems() {
         API.getExpenseItems(studentID: student.id)
            .sink { (_) in
            } receiveValue: { (list) in
               self.items = list.expenseItems
            }
            .store(in: &disposables)
      }
      
      func onAdd(name: String, amount: Float) {
         let item = CreateExpenseItem(name: name, amount: amount)
         API.createExpenseItem(studentID: student.id, item: item)
            .sink { (_) in
            } receiveValue: { _ in
               self.getItems()
            }
            .store(in: &disposables)
      }
      
      func onDelete(offsets: IndexSet) {
      }
   }
}
