//
//  CalculateView.swift
//  trip-calculator
//
//  Created by Gregory Klein on 12/5/20.
//

import SwiftUI
import Combine

struct CalculateView: View {
   @StateObject var viewModel = ViewModel()
    var body: some View {
      NavigationView {
         Form {
            Section(header: Text("Overview")) {
               List {
                  HStack {
                     Text("Total spent")
                     Spacer()
                     Text("$\(viewModel.totalSpent, specifier: "%.2f")")
                  }
                  HStack {
                     Text("Average cost")
                     Spacer()
                     Text("$\(viewModel.averageCost, specifier: "%.2f")")
                  }
               }
            }
            Section(header: Text("Transactions")) {
               List {
                  ForEach(viewModel.transactions.txns) { txn in
                     HStack {
                        Text(txn.from.name)
                        Image(systemName: "arrow.right.circle.fill")
                           .foregroundColor(.green)
                           .padding([.leading, .trailing], 6)
                        Text(txn.to.name)
                        Spacer()
                        Text("$\(txn.amount, specifier: "%.2f")")
                     }
                  }
               }
            }
         }
         .listStyle(PlainListStyle())
         .onAppear(perform: {
            viewModel.getTransactions()
         })
         .navigationBarTitle("Calculate")
      }
    }
}

extension CalculateView {
   class ViewModel: ObservableObject {
      @Published var transactions: StudentTransactions = StudentTransactions(totalAmount: 0, averageAmount: 0, txns: [])
      private var disposables = Set<AnyCancellable>()
      
      var averageCost: Double {
         return transactions.averageAmount
      }
      
      var totalSpent: Double {
         return transactions.totalAmount
      }
      
      func getTransactions() {
         API.getTransactions()
            .sink { (_) in
            } receiveValue: { (result) in
               self.transactions = result
            }
            .store(in: &disposables)
      }
   }
}

struct CalculateView_Previews: PreviewProvider {
    static var previews: some View {
        CalculateView()
    }
}
