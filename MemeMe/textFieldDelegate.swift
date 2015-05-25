//
//  textFieldDelegate.swift
//  MemeMe
//
//  Created by Sergei on 19/05/15.
//  Copyright (c) 2015 Sergei. All rights reserved.
//

import Foundation
import UIKit

class textFieldDelegate: NSObject,  UITextFieldDelegate {
  
  func textFieldDidBeginEditing(textField: UITextField) {
    println("begin editing: \(textField.tag)")
    // Clear textField of preset text.
    if textField.text == "TOP" || textField.text == "BOTTOM" {
      textField.text = ""
    }
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    // Set preset text if text field is empty. topTextField tag is 0 bottomTextField tag is 1
    if textField.text.isEmpty && textField.tag == 0 {
      textField.text = "TOP"
    } else if textField.text.isEmpty && textField.tag == 1{
      textField.text = "BOTTOM"
    }
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    // Force all characters to be uppercase, no matter what.
    let lowercaseCharacters = NSCharacterSet.lowercaseLetterCharacterSet()
    if let lowercaseRange = string.rangeOfCharacterFromSet(lowercaseCharacters) {
      let uppercaseString = string.uppercaseString
      if textField.text.isEmpty {
        // Updates return button; forces cursor to the end
        textField.text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: uppercaseString)
      } else {
        // Preserves cursor location; doesn't update return button
        let beginning = textField.beginningOfDocument
        let start = textField.positionFromPosition(beginning, offset: range.location)!
        let end = textField.positionFromPosition(start, offset: range.length)!
        let range = textField.textRangeFromPosition(start, toPosition: end)
        textField.replaceRange(range, withText: uppercaseString)
      }
      return false
    } else {
      return true
    }
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    return true;
  }

  
}