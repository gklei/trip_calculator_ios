//
//  API.swift
//  trip-calculator
//
//  Created by Gregory Klein on 12/3/20.
//

import Combine
import Foundation

// MARK: - Student
struct Student: Codable, Identifiable {
   let id: Int
   let name: String
   let totalExpenseAmount: Float
   let expenseItems: [ExpenseItem]
   
   enum CodingKeys: String, CodingKey {
      case id, name
      case totalExpenseAmount = "total_expense_amount"
      case expenseItems = "expense_items"
   }
}

// MARK: - StudentList
struct StudentList: Codable {
   let students: [Student]
}

// MARK: - ExpenseItem
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

// MARK: - ExpenseItemList
struct ExpenseItemList: Codable {
   let totalAmount: Float
   let expenseItems: [ExpenseItem]
   
   enum CodingKeys: String, CodingKey {
      case totalAmount = "total_amount"
      case expenseItems = "expense_items"
   }
}

// MARK: - MessageResponse
struct MessageResponse: Codable {
   let message: String
   enum CodingKeys: String, CodingKey {
      case message
   }
}

// MARK: - StudentTransactions
struct StudentTransactions: Codable {
    let totalAmount: Int
    let averageAmount: Double
    let txns: [String]

    enum CodingKeys: String, CodingKey {
        case totalAmount = "total_amount"
        case averageAmount = "average_amount"
        case txns
    }
}

struct Agent {
   struct Response<T> {
      let value: T
      let response: URLResponse
   }
   
   func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<Response<T>, Error> {
      return URLSession.shared
         .dataTaskPublisher(for: request)
         .tryMap { result -> Response<T> in
            let value = try JSONDecoder().decode(T.self, from: result.data)
            return Response(value: value, response: result.response)
         }
         .receive(on: DispatchQueue.main)
         .eraseToAnyPublisher()
   }
}

enum API {
   static let agent = Agent()
   static let base = URL(string: "http://127.0.0.1:5000/")!
}

extension API {
   static func getStudents() -> AnyPublisher<StudentList, Error> {
      var request = URLRequest(
         url: base.appendingPathComponent("students"),
         cachePolicy: .useProtocolCachePolicy,
         timeoutInterval: 10.0
      )
      request.httpMethod = "GET"
      request.allHTTPHeaderFields = ["Content-Type": "application/json"]
      return agent.run(request)
         .map(\.value)
         .eraseToAnyPublisher()
   }
   
   static func getExpenseItems(studentID: Int) -> AnyPublisher<ExpenseItemList, Error> {
      var request = URLRequest(
         url: base.appendingPathComponent("expense/\(studentID)"),
         cachePolicy: .useProtocolCachePolicy,
         timeoutInterval: 10.0
      )
      request.httpMethod = "GET"
      request.allHTTPHeaderFields = ["Content-Type": "application/json"]
      return agent.run(request)
         .map(\.value)
         .eraseToAnyPublisher()
   }
   
   static func deleteStudent(id: Int) -> AnyPublisher<StudentList, Error> {
      var request = URLRequest(
         url: base.appendingPathComponent("student/\(id)"),
         cachePolicy: .useProtocolCachePolicy,
         timeoutInterval: 10.0
      )
      request.httpMethod = "DELETE"
      request.allHTTPHeaderFields = ["Content-Type": "application/json"]
      return agent.run(request)
         .map(\.value)
         .eraseToAnyPublisher()
   }
   
   static func createStudent(name: String) -> AnyPublisher<Student, Error> {
      let encoder = JSONEncoder()
      guard let postData = try? encoder.encode(["name": name]) else { fatalError() }
      
      var request = URLRequest(
         url: base.appendingPathComponent("student"),
         cachePolicy: .useProtocolCachePolicy,
         timeoutInterval: 10.0
      )
      request.httpMethod = "POST"
      request.allHTTPHeaderFields = ["Content-Type": "application/json"]
      request.httpBody = postData
      return agent.run(request)
         .map(\.value)
         .eraseToAnyPublisher()
   }
   
   static func createExpenseItem(studentID: Int, item: CreateExpenseItem) -> AnyPublisher<ExpenseItem, Error> {
      let encoder = JSONEncoder()
      guard let postData = try? encoder.encode(item) else { fatalError() }
      
      var request = URLRequest(
         url: base.appendingPathComponent("expense/\(studentID)"),
         cachePolicy: .useProtocolCachePolicy,
         timeoutInterval: 10.0
      )
      request.httpMethod = "POST"
      request.allHTTPHeaderFields = ["Content-Type": "application/json"]
      request.httpBody = postData
      return agent.run(request)
         .map(\.value)
         .eraseToAnyPublisher()
   }
   
   static func deleteExpenseItem(id: Int) -> AnyPublisher<MessageResponse, Error> {
      var request = URLRequest(
         url: base.appendingPathComponent("expense/\(id)"),
         cachePolicy: .useProtocolCachePolicy,
         timeoutInterval: 10.0
      )
      request.httpMethod = "DELETE"
      request.allHTTPHeaderFields = ["Content-Type": "application/json"]
      return agent.run(request)
         .map(\.value)
         .eraseToAnyPublisher()
   }
   
   static func getTransactions() -> AnyPublisher<StudentTransactions, Error> {
      var request = URLRequest(
         url: base.appendingPathComponent("calculate"),
         cachePolicy: .useProtocolCachePolicy,
         timeoutInterval: 10.0
      )
      request.httpMethod = "GET"
      request.allHTTPHeaderFields = ["Content-Type": "application/json"]
      return agent.run(request)
         .map(\.value)
         .eraseToAnyPublisher()
   }
}
