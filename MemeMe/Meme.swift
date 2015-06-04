//
//  Meme.swift
//  MemeMe
//
//  Created by Sergei on 19/05/15.
//  Copyright (c) 2015 Sergei. All rights reserved.
//

import Foundation
import UIKit

func == (lhs: Meme, rhs: Meme) -> Bool {
  if lhs.topText == rhs.topText &&
    lhs.bottomText == rhs.bottomText &&
    lhs.originalImage == rhs.originalImage &&
    lhs.memedImage == rhs.memedImage {
      return true
  } else {
    return false
  }
}

/**
Meme Data Structure

:param: topText: (String)
:param: bottomText: (String)
:param: originalImage: (UIImage)
:param: memedImage: (UIImage)
*/
struct Meme: Equatable {
  let topText: String
  let bottomText: String
  let originalImage: UIImage
  let memedImage: UIImage
}

