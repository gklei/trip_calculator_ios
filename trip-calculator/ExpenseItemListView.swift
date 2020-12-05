//
//  ExpenseItemListView.swift
//  trip-calculator
//
//  Created by Gregory Klein on 12/5/20.
//

import SwiftUI

struct ExpenseItemListView: View {
   let student: Student
   
   var body: some View {
      List {
         ForEach(student.expenseItems) { item in
            HStack {
               Text(item.name)
               Spacer()
               Text("$\(item.amount, specifier: "%.2f")")
            }
         }
      }
   }
}
