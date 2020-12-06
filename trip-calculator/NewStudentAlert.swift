//
//  TextAlert.swift
//  trip-calculator
//
//  Created by Gregory Klein on 12/5/20.
//

import UIKit
import SwiftUI

extension UIAlertController {
   convenience init(alert: NewStudentAlert) {
      self.init(title: alert.title, message: alert.message, preferredStyle: .alert)
      addTextField { $0.placeholder = alert.placeholder }
      addAction(UIAlertAction(title: alert.cancel, style: .cancel) { _ in
         alert.action(nil)
      })
      let textField = self.textFields?.first
      addAction(UIAlertAction(title: alert.accept, style: .default) { _ in
         alert.action(textField?.text)
      })
   }
}

struct AlertWrapper<Content: View>: UIViewControllerRepresentable {
   @Binding var isPresented: Bool
   let alert: NewStudentAlert
   let content: Content
   
   func makeUIViewController(context: UIViewControllerRepresentableContext<AlertWrapper>) -> UIHostingController<Content> {
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
   
   
   func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<AlertWrapper>) {
      uiViewController.rootView = content
      if isPresented && uiViewController.presentedViewController == nil {
         var alert = self.alert
         alert.action = {
            self.isPresented = false
            self.alert.action($0)
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

public struct NewStudentAlert {
   public var title: String
   public var message: String
   public var placeholder: String = ""
   public var accept: String = "OK"
   public var cancel: String = "Cancel"
   public var action: (String?) -> ()
}

extension View {
   public func alert(isPresented: Binding<Bool>, _ alert: NewStudentAlert) -> some View {
      AlertWrapper(isPresented: isPresented, alert: alert, content: self)
   }
}
