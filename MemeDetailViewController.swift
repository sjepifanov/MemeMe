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
  }
  
  @IBAction func openInImageEditor(sender: AnyObject) {
    performSegueWithIdentifier("imagePickerController", sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let imagePickerController = storyboard?.instantiateViewControllerWithIdentifier("imagePickerController") as! MemeEditorViewController
    imagePickerController.meme = meme
    if let navigationController = self.navigationController {
      navigationController.pushViewController(imagePickerController, animated: true)
    }
    
  }
}
