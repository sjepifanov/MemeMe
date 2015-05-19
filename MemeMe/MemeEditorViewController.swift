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
  @IBOutlet weak var toolBar: UIToolbar!
  
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
    
    // Enable user interaction to recognize touches and gestures
    imageView.userInteractionEnabled = true
    
    // Initialize Gesture Recognizer
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideBars:")
    tapGestureRecognizer.numberOfTapsRequired = 1
    
    // Add Gesture Recognizer to image view
    imageView.addGestureRecognizer(tapGestureRecognizer)

  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)

    // TODO: Enable when image is pickecd from source. May also check if text has been edited in text fields
    actionButton.enabled = actionButtonState()

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
    let memedImage = generateMemedImage()
    let actionController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
    self.presentViewController(actionController, animated: true, completion: nil)
    
    //could be set in short form: actionController.completionWithItemsHandler = {action, result, object, error in }
    actionController.completionWithItemsHandler = {
      (activityType: String!, completed: Bool, returnedItems: [AnyObject]!, activityError:NSError!) in
      if completed{
        println("completed action \(activityType)")
        self.save()
        
        // TODO: Create Table View Controller
        //let tableViewController = self.storyboard!.instantiateViewControllerWithIdentifier("tableViewController") as! MemeTableViewController
        //self.navigationController!.pushViewController(tableViewController, animated: true)
        
      }else{
        println("something wrong: \(activityType)")
      }
    }
    //actionController.completionWithItemsHandler = {action, result, object, error in }
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
      // TODO: Scroll View fram in Landscape is off. Redo Autolayout.
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

  // MARK: Scroll View Delegates and Methods
  
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

  // MARK: Creating and saving Meme methods
  
  /**
  Create memed image by capturing current view frame.
  */
  func generateMemedImage() -> UIImage {
    // Hide navigation bar and toolbar
    navigationController?.setNavigationBarHidden(true, animated: false)
    toolBar.hidden = true
    
    // Capture view frame
    UIGraphicsBeginImageContext(self.view.frame.size)
    self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
    let imageMemed: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    // Unhide navigation bar and toolbar
    navigationController?.setNavigationBarHidden(false, animated: false)
    toolBar.hidden = false
    
    return imageMemed
  }
  
  /**
  Save meme information to Meme struct
  */
  
  func save(){
    var imageMemed = generateMemedImage()
    
    //create meme object
    var meme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, originalImage: imageView.image!, memedImage: imageMemed)
    
    //Add meme to the memes array in Application Delegate (AppDelegate.swift)
    let object = UIApplication.sharedApplication().delegate
    let appDelegate = object as! AppDelegate
    appDelegate.memes.append(meme)
  }

  /**
  Set state for action button
  
  :returns: Bool
  */
  func actionButtonState() -> Bool{
    if let _ = imageView.image{
      return true
    }else{
      return false
    }
  }
  
  
  // MARK: Hide bars for Gesture Recognizer
  
  /**
  Hide Navigation Bar and ToolBar
  
  :param: recognizer UITapGestureREcognizer
  */
  func hideBars(recognizer: UITapGestureRecognizer) {
    navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: false) //or animated: false
    toolBar.hidden = toolBar.hidden ? false : true
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

