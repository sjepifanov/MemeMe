//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Sergei on 24/05/15.
//  Copyright (c) 2015 Sergei. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
  
  @IBOutlet weak var memeDetailImage: UIImageView!
  @IBOutlet weak var deleteButton: UIBarButtonItem!
  
  var meme: Meme!
  let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
  
  override func viewDidLoad() {
    super.viewDidLoad()
    memeDetailImage.image = meme.memedImage
  }
  
  @IBAction func deleteAction(sender: AnyObject) {
    if let index = find(appDelegate.memes, meme) {
      appDelegate.memes.removeAtIndex(index)
    }
    if let navigationcontroller = self.navigationController {
     navigationcontroller.popToRootViewControllerAnimated(true)
    }
  }
  
  @IBAction func openInImageEditor(sender: AnyObject) {
    let storyboard = UIStoryboard (name: "Main", bundle: nil)
    let imagePickerController = storyboard.instantiateViewControllerWithIdentifier("imagePickerController") as! MemeEditorViewController
    self.hidesBottomBarWhenPushed = false
    imagePickerController.hidesBottomBarWhenPushed = true
    imagePickerController.meme = meme
    if let navigationcontroller = self.navigationController {
      navigationcontroller.pushViewController(imagePickerController, animated: true)
    }
  }
  
}
