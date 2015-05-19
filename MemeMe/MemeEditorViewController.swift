//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Sergei on 19/05/15.
//  Copyright (c) 2015 Sergei. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UITextFieldDelegate {

  // MARK: Outlets
  @IBOutlet weak var topTextField: UITextField!
  @IBOutlet weak var bottomTextField: UITextField!
  @IBOutlet weak var albumButton: UIBarButtonItem!
  @IBOutlet weak var cameraButton: UIBarButtonItem!
  @IBOutlet weak var actionButton: UIBarButtonItem!
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  
  //MARK: Declarations
  let textDelegate = textFieldDelegate()
  
  let memeTextAttributes = [
    NSStrokeColorAttributeName : UIColor.blackColor(),
    NSForegroundColorAttributeName : UIColor.whiteColor(),
    NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    NSStrokeWidthAttributeName : -3.0
  ]
  
  //MARK: View
  override func viewDidLoad() {
    super.viewDidLoad()

  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)

    // TODO: Enable when image is pickec from source. May also check if text has been edited in text fields
    //actionButton.enabled = imageEditorView.image ? true : false
    
    // Set textField text attributes.
    topTextField.defaultTextAttributes = memeTextAttributes
    bottomTextField.defaultTextAttributes = memeTextAttributes
    
    // Set textField delegate
    topTextField.delegate = textDelegate
    bottomTextField.delegate = textDelegate
    
    // Set textFields text alignment.
    topTextField.textAlignment = .Center
    bottomTextField.textAlignment = .Center
    
    // Set border style
    topTextField.borderStyle = .None
    bottomTextField.borderStyle = .None
    
    // Set empty textField text
    topTextField.text = "TOP"
    bottomTextField.text = "BOTTOM"
    
    subscribeToKeyboardNotifications()
    
    
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    unsubscribeFromKeyboardNotifications()
  }
  
  // MARK: Methods
  
  // MARK: (Un)Subscribe to UIKeyboardWillShow(Hide)Notification
  
  /**
  Add observer for NSNotificationCenter notifications:
  
  UIKeyboardWillShow(Hide)Notification
  
  selector: "keyboardWillShow:", "keyboardWillHide:"
  */
  func subscribeToKeyboardNotifications() {
    println("Subscribed")
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
  }
  
  /**
  Remove observer for NSNotificationCenter notifications:
  
  UIKeyboardWillShow(Hide)Notification
  */
  func unsubscribeFromKeyboardNotifications() {
    println("Unsubscribed")
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }

  
  // MARK: Selectors for notifications
  
  // TODO: Text is covered by Navigation bar in Landscape. May hide toolbar to allow more space.
  // TODO: If keyboard is on screen and device rotated view did not slide down correctly. Either disallow rotation while editing. Dismiss keyboard or recalculate spece instead of using previous value.
  /**
  Slide view frame up by height of on screen keyboard frame.
  
  :param: notification: (NSNotification)
  */
  func keyboardWillShow(notification: NSNotification) {
    println("Show: got notification")
    println(self.view.frame.origin.y)
    if bottomTextField.isFirstResponder(){
      view.frame.origin.y -= getKeyboardHeight(notification)
      println(self.view.frame.origin.y)
    }
  }
  
  /**
  Slide view frame down by height of on screen keyboard frame.
  
  :param: notification: (NSNotification)
  
  */
  func keyboardWillHide(notification: NSNotification) {
    println("Hide: got notification")
    println(self.view.frame.origin.y)
    view.frame.origin.y = 0.0
    //if bottomTextField.isFirstResponder(){
    //  self.view.frame.origin.y += getKeyboardHeight(notification)
    //  println(self.view.frame.origin.y)
    //}
  }
  
  /**
  Return height of on screen keyboard frame when keyboard slides into view.
  
  :param: notification: (NSNotification)
  
  :returns: CGFloat Height of on screen keyboard frame.
  */
  func getKeyboardHeight(notification: NSNotification) -> CGFloat {
    let userInfo = notification.userInfo
    let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue //of CGRect
    return keyboardSize.CGRectValue().height
  }


  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

