//
//  StudentRowView.swift
//  trip-calculator
//
//  Created by Gregory Klein on 12/5/20.
//

import SwiftUI

struct StudentRowView: View {
   let student: Student
   @Binding var refresh: Bool
   
   var body: some View {
      NavigationLink(
         destination: ExpenseItemListView(
            viewModel: ExpenseItemListView.ViewModel(student: student),
            refresh: $refresh
         )
      ) {
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
