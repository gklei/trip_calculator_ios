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
   @Binding var refresh: Bool
   
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
                  .foregroundColor(.secondary)
            }
            .frame(height: 60)
         }
         .onDelete(perform: viewModel.onDelete)
      }
      .itemAlert(
         isPresented: $showNewItemAlert,
         NewItemAlert(
            title: "New Expense",
            message: "Create a new item",
            action: {
               guard let name = $0, let amount = $1 else { return }
               viewModel.onAdd(name: name, amount: amount)
         })
      )
      .onAppear(perform: viewModel.getItems)
      .onDisappear {
         refresh.toggle()
      }
      .navigationBarTitle(viewModel.navigationBarTitle, displayMode: .inline)
      .navigationBarItems(trailing: addButton)
   }
}

extension ExpenseItemListView {
   class ViewModel: ObservableObject {
      let student: Student
      @Published var items: [ExpenseItem] = []
      private var disposables = Set<AnyCancellable>()
      
      var navigationBarTitle: String {
         return student.name
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
         guard offsets.count == 1 else { return }
         let offset = offsets.first!
         let item = items[offset]
         API.deleteExpenseItem(id: item.id)
            .sink { (_) in
            } receiveValue: { _ in
               self.getItems()
            }
            .store(in: &disposables)
      }
   }
}
