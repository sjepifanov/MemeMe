//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Sergei on 19/05/15.
//  Copyright (c) 2015 Sergei. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {

  // MARK: Outlets
  
  @IBOutlet weak var topTextField: UITextField!
  @IBOutlet weak var bottomTextField: UITextField!
  @IBOutlet weak var albumButton: UIBarButtonItem!
  @IBOutlet weak var cameraButton: UIBarButtonItem!
  @IBOutlet weak var actionButton: UIBarButtonItem!
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var toolBar: UIToolbar!
  
  //MARK: Declarations
  
  // Define appDelegate to hold shared data structure.
  let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
  
  // Data object from Meme Detail View.
  var meme: Meme!
  
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

    cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
    
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
    
    scrollView.delegate = self
    scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
    // Set maximum zoom scale to image original size
    scrollView.maximumZoomScale = 1
    
    // Enable user interaction to recognize touches and gestures
    imageView.userInteractionEnabled = true
    
    // Initialize Gesture Recognizer
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideBarsOnTouch:")
    tapGestureRecognizer.numberOfTapsRequired = 1
    
    // Add Gesture Recognizer to image view
    imageView.addGestureRecognizer(tapGestureRecognizer)
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let _ = meme {
      imageView.image = meme.originalImage
      topTextField.text = meme.topText
      bottomTextField.text = meme.bottomText
      setMinimumZoomForCurrentFrame(meme.originalImage.size)
      setMaxZoomToPresentPicture(meme.originalImage.size)
      centerScrollViewContents()
      meme = nil
    }
    
    // Enable action button when picture is loaded.
    actionButton.enabled = actionButtonState()
    
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
    
    actionController.completionWithItemsHandler = {action, result, object, error in
      if result{
        self.save()
        
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        let tableViewController = storyboard.instantiateViewControllerWithIdentifier("MemeTableViewController") as! MemeTableViewController
        self.hidesBottomBarWhenPushed = false
        tableViewController.hidesBottomBarWhenPushed = false
        if let navigationcontroller = self.navigationController {
          navigationcontroller.pushViewController(tableViewController, animated: true)
        }
      }
    }
  }
  
  @IBAction func cancelButton(sender: AnyObject) {
    var storyboard = UIStoryboard (name: "Main", bundle: nil)
    let tableViewController = storyboard.instantiateViewControllerWithIdentifier("MemeTableViewController") as! MemeTableViewController
    self.hidesBottomBarWhenPushed = false
    tableViewController.hidesBottomBarWhenPushed = false
    if let navigationcontroller = self.navigationController {
      navigationcontroller.pushViewController(tableViewController, animated: true)
    }
  }
  
  // MARK: Methods
  
  // MARK: (Un)Subscribe to UIKeyboardWillShow(Hide)Notification
  
  /**
  Add observer for NSNotificationCenter notifications:
  
  UIKeyboardWillShow(Hide)Notification
  
  selector: "keyboardWillShow:", "keyboardWillHide:"
  */
  func subscribeToKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
  }
  
  /**
  Remove observer for NSNotificationCenter notifications:
  
  UIKeyboardWillShow(Hide)Notification
  */
  func unsubscribeFromKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }
  
  
  // MARK: Selectors for notifications
  
  /**
  Slide view frame up by height of on screen keyboard frame.
  
  :param: notification: (NSNotification)
  */
  func keyboardWillShow(notification: NSNotification) {
    
    if bottomTextField.isFirstResponder(){
      view.frame.origin.y -= getKeyboardHeight(notification)
    }
  }
  
  /**
  Slide view frame down when keyboard is off screen.
  
  :param: notification: (NSNotification)
  
  */
  func keyboardWillHide(notification: NSNotification) {
    view.frame.origin.y = 0.0
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
  
  // MARK: Image Picker Controller Delegates methods.
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {

    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
      
      // Dismiss UIImagePickerController when selection is made.
      dismissViewControllerAnimated(true, completion: nil)
      
      imageView.image = image
      
      imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height)
      
      // Set minimum zoom scale.
      scrollView.maximumZoomScale = 1
      setMinimumZoomForCurrentFrame(imageView.frame.size)
      scrollView.zoomScale = scrollView.minimumZoomScale
      
      // Set zoom scale so image will appear fullscreen.
      setMaxZoomToPresentPicture(image.size)
      
      // Move Scroll view to horizontal center point.
      scrollView.setContentOffset(CGPoint(x: imageView.frame.size.width / 2, y: 0) , animated: true)
      
      // Center content
      scrollViewDidZoom(scrollView)
    }
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: Scroll View Delegates and Methods
  
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return imageView
  }
  
  
  /**
  Set minimum Zoom Level for current frame.
  */
  func setMinimumZoomForCurrentFrame(imageViewFrameSize: CGSize){
    let imageSize = imageViewFrameSize
    let scrollSize = scrollView.bounds.size
    let scaleWidth = scrollSize.width / imageSize.width
    let scaleHeight = scrollSize.height / imageSize.height
    let minScale = min(scaleWidth, scaleHeight)
    
    scrollView.minimumZoomScale = minScale
  }
  
  /**
  Set Zoom Level for current frame so image fill the screen.
  */
  func setMaxZoomToPresentPicture(imageSize: CGSize) {
    let scrollSize = scrollView.bounds.size
    let imageSize = imageSize
    let scaleWidth = scrollSize.width / imageSize.width
    let scaleHeight = scrollSize.height / imageSize.height
    let maxScale = max(scaleWidth, scaleHeight)

    scrollView.zoomScale = maxScale
  }
  
  
  func scrollViewDidZoom(scrollView: UIScrollView) {
    centerScrollViewContents()
  }
  
  func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
    
    // If image is smaller than the screen make scrollView insets to move the image around screen
    var screenWidth = UIScreen.mainScreen().bounds.size.width
    var screenHeight = UIScreen.mainScreen().bounds.size.height
    var viewWidth = imageView.frame.size.width
    var viewHeight = imageView.frame.size.height

    var x: CGFloat = 0
    var y: CGFloat = 0
    
    if(viewWidth < screenWidth) {
      x = screenWidth / 2
    }
    if(viewHeight < screenHeight) {
      y = screenHeight / 2
    }
    
    self.scrollView.contentInset = UIEdgeInsetsMake(y, x, y, x);
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
  }
  
  func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
  }
  
  /**
  Center scrollView content when it's smaller than screen size
  */
  func centerScrollViewContents() {
    let excessiveWidth = max(0.0, scrollView.bounds.size.width - scrollView.contentSize.width)
    let excessiveHeight = max(0.0, scrollView.bounds.size.height - scrollView.contentSize.height)
    let insetX = excessiveWidth / 2.0
    let insetY = excessiveHeight / 2.0
    
    scrollView.contentInset = UIEdgeInsetsMake(
    max(insetY, 0.0),
    max(insetX, 0.0),
    max(insetY, 0.0),
    max(insetX, 0.0)
    )

  }
  
  // MARK: Creating and saving Meme methods
  
  /**
  Create memed image by capturing current view frame.
  */
  func generateMemedImage() -> UIImage {

    // Hide navigation bar and toolbar
    hideBars()
    
    // Capture view frame
    UIGraphicsBeginImageContext(self.view.frame.size)
    self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
    let imageMemed: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    // Unhide navigation bar and toolbar.
    hideBars()
    
    return imageMemed
  }
  
  /**
  Save meme information to Meme struct
  */
  
  func save(){
    var imageMemed = generateMemedImage()
    
    //create meme object
    var meme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, originalImage: imageView.image!, memedImage: imageMemed)
    appDelegate.memes.append(meme)
  }
  
  /**
  Set state for action button. Return true when image is loaded.
  
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
  

  func hideBarsOnTouch(recognizer: UITapGestureRecognizer) {
      hideBars()
  }
  
  /**
  Hide Navigation Bar and ToolBar
  
  :param: recognizer UITapGestureREcognizer
  */
  func hideBars() {
    if let navigationController = self.navigationController {
      navigationController.setNavigationBarHidden(navigationController.navigationBarHidden == false, animated: false) //or animated: false
    toolBar.hidden = toolBar.hidden ? false : true
    }
  }
  
}

