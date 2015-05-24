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
  
  var meme: Meme!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    memeDetailImage.image = meme.memedImage
  }
  
}
