//
//  imagePickerDelegate.swift
//  MemeMe
//
//  Created by Sergei on 19/05/15.
//  Copyright (c) 2015 Sergei. All rights reserved.
//

import Foundation
import UIKit

class imagePickerDelegate: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    println("imagePicker delegate")
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
      
      // Dismiss UIImagePickerController when selection is made
      dismissViewControllerAnimated(true, completion: nil)
      
    }
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    // Dismiss on cancel
    println("imagePicker dismissed")
    dismissViewControllerAnimated(true, completion: nil)
  }

}
