//
//  UIViewControllerExtension.swift
//  OnTheMap
//
//  Created by Jose Piñero on 1/28/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showGeneralAlert(title:String, message:String, buttonTitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: buttonTitle, style: .Default, handler: nil)
        alert.addAction(dismissAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func addKeyboardGestureRecognizer() {
        //Looks for single or multiple taps in order to close keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}