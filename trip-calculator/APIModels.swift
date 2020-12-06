//
//  APIModels.swift
//  trip-calculator
//
//  Created by Gregory Klein on 12/5/20.
//

import Foundation

struct Student: Codable, Identifiable {
   let id: Int
   let name: String
   let totalExpenseAmount: Float
   let expenseItems: [ExpenseItem]?
   
   enum CodingKeys: String, CodingKey {
      case id, name
      case totalExpenseAmount = "total_expense_amount"
      case expenseItems = "expense_items"
   }
}

struct StudentList: Codable {
   let students: [Student]
}

struct ExpenseItem: Codable, Identifiable {
   let id: Int
   let name: String
   let studentID: Int
   let amount: Float
   let studentName: String
   
   enum CodingKeys: String, CodingKey {
      case id, name, amount
      case studentID = "student_id"
      case studentName = "student_name"
   }
}

struct CreateExpenseItem: Codable {
   let name: String
   let amount: Float
   
   enum CodingKeys: String, CodingKey {
      case name, amount
   }
}

struct ExpenseItemList: Codable {
   let totalAmount: Float
   let expenseItems: [ExpenseItem]
   
   enum CodingKeys: String, CodingKey {
      case totalAmount = "total_amount"
      case expenseItems = "expense_items"
   }
}

struct MessageResponse: Codable {
   let message: String
   enum CodingKeys: String, CodingKey {
      case message
   }
}

struct StudentTransactions: Codable {
   struct Transaction: Codable, Identifiable {
      let from, to: Student
      let amount: Double
      let id = UUID()
   }
   
   let totalAmount, averageAmount: Double
   let txns: [Transaction]
   
   enum CodingKeys: String, CodingKey {
      case totalAmount = "total_amount"
      case averageAmount = "average_amount"
      case txns
   }
}
