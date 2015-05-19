//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Sergei on 19/05/15.
//  Copyright (c) 2015 Sergei. All rights reserved.
//

import UIKit

//, UITextFieldDelegate

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {

  // MARK: Outlets
  @IBOutlet weak var topTextField: UITextField!
  @IBOutlet weak var bottomTextField: UITextField!
  @IBOutlet weak var albumButton: UIBarButtonItem!
  @IBOutlet weak var cameraButton: UIBarButtonItem!
  @IBOutlet weak var actionButton: UIBarButtonItem!
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var imageView: UIImageView!
  
  //MARK: Declarations
  
  let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

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
    scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    // Top and bottom insets for Nav and Tool bars
    // Seems like it's affecting scrollViewFrame when done here. Try in ViewDidLoad insead.
    scrollView.contentInset=UIEdgeInsetsMake(64.0,0.0,44.0,0.0)

  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
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
  
  // MARK: Actions
  
  @IBAction func albumButton(sender: AnyObject) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.sourceType = .PhotoLibrary
    self.presentViewController(imagePickerController, animated: true, completion: nil)

  }
  
  @IBAction func cameraButton(sender: AnyObject) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    //select source type for UIImagePickerController
    imagePickerController.sourceType = .Camera
    self.presentViewController(imagePickerController, animated: true, completion: nil)
  }
  
  @IBAction func actionButton(sender: AnyObject) {
  }
  @IBAction func cancelButton(sender: AnyObject) {
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

  // MARK: Image Picker Controller Delegates methods
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    println("imagePicker delegate")
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
      
      // Dismiss UIImagePickerController when selection is made
      dismissViewControllerAnimated(true, completion: nil)
      
      imageView.image = image
      println("imageView frame: \(imageView.frame.size)")
      println("contentView frame: \(contentView.frame.size)")
      println("scrollView frame: \(scrollView.frame.size)")
      
      
      // TODO: Zoom is not working. AutoLayout issue maybe!
      scrollView.contentSize = image.size
      
      let scrollViewFrame = scrollView.frame
      let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
      let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
      let minScale = min(scaleWidth, scaleHeight)
      
      scrollView.minimumZoomScale = minScale
      
      scrollView.maximumZoomScale = 1
      scrollView.zoomScale = minScale

      println("imageView frame: \(imageView.frame.size)")
      println("contentView frame: \(contentView.frame.size)")
      println("scrollView frame: \(scrollView.frame.size)")
      
    }
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    // Dismiss on cancel
    println("imagePicker dismissed")
    dismissViewControllerAnimated(true, completion: nil)
  }

  // MARK: Scroll View Delegates
  
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return imageView
  }
  
  func scrollViewDidZoom(scrollView: UIScrollView) {
    centerScrollViewContents()
  }
  
  func centerScrollViewContents() {
    
    let boundsSize = scrollView.bounds.size
    var contentsFrame = imageView.frame
    
    if contentsFrame.size.width < boundsSize.width {
      
      contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
    } else {
      contentsFrame.origin.x = 0
    }
    
    if contentsFrame.size.height < boundsSize.height {
      contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
    } else {
      contentsFrame.origin.y = 0
    }
    
    imageView.frame = contentsFrame
    
  }

  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

