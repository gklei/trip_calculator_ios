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
         List {
            ForEach(viewModel.transactions, id: \.self) { txn in
               Text(txn)
            }
         }
         .listStyle(PlainListStyle())
         .onAppear(perform: {
            viewModel.getTransactions()
         })
         .navigationBarTitle("Transactions")
      }
    }
}

extension CalculateView {
   class ViewModel: ObservableObject {
      @Published var transactions: [String] = []
      private var disposables = Set<AnyCancellable>()
      
      func getTransactions() {
         API.getTransactions()
            .sink { (_) in
            } receiveValue: { (result) in
               self.transactions = result.txns
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
