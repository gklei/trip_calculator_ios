//
//  NewItemAlert.swift
//  trip-calculator
//
//  Created by Gregory Klein on 12/5/20.
//

import UIKit
import SwiftUI

extension UIAlertController {
   convenience init(alert: NewItemAlert) {
      self.init(title: alert.title, message: alert.message, preferredStyle: .alert)
      addTextField { $0.placeholder = "Name" }
      addTextField { $0.placeholder = "Amount"; $0.keyboardType = .decimalPad }
      addAction(UIAlertAction(title: alert.cancel, style: .cancel) { _ in
         alert.action(nil, nil)
      })
      let textField1 = self.textFields?.first
      let textField2 = self.textFields?.last
      addAction(UIAlertAction(title: alert.accept, style: .default) { _ in
         alert.action(textField1?.text, Float(textField2?.text ?? ""))
      })
   }
}

struct ItemAlertWrapper<Content: View>: UIViewControllerRepresentable {
   @Binding var isPresented: Bool
   let alert: NewItemAlert
   let content: Content
   
   func makeUIViewController(context: UIViewControllerRepresentableContext<ItemAlertWrapper>) -> UIHostingController<Content> {
      UIHostingController(rootView: content)
   }
   
   final class Coordinator {
      var alertController: UIAlertController?
      init(_ controller: UIAlertController? = nil) {
         self.alertController = controller
      }
   }
   
   func makeCoordinator() -> Coordinator {
      return Coordinator()
   }
   
   
   func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<ItemAlertWrapper>) {
      uiViewController.rootView = content
      if isPresented && uiViewController.presentedViewController == nil {
         var alert = self.alert
         alert.action = {
            self.isPresented = false
            self.alert.action($0, $1)
         }
         context.coordinator.alertController = UIAlertController(alert: alert)
         
         DispatchQueue.main.async {
            uiViewController.present(context.coordinator.alertController!, animated: true)
         }
      }
      if !isPresented && uiViewController.presentedViewController == context.coordinator.alertController {
         uiViewController.dismiss(animated: true)
      }
   }
}

public struct NewItemAlert {
   public var title: String
   public var message: String
   public var accept: String = "OK"
   public var cancel: String = "Cancel"
   public var action: (String?, Float?) -> ()
}

extension View {
   public func itemAlert(isPresented: Binding<Bool>, _ alert: NewItemAlert) -> some View {
      ItemAlertWrapper(isPresented: isPresented, alert: alert, content: self)
   }
}

