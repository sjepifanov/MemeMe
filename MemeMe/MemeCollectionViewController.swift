//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Sergei on 24/05/15.
//  Copyright (c) 2015 Sergei. All rights reserved.
//

import UIKit


class MemeCollectionViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    collectionView?.delegate = self
    self.collectionView?.reloadData()
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return appDelegate.memes.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
    let meme = appDelegate.memes[indexPath.row]
    cell.memeCellImage?.image = meme.memedImage
    
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let detailController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")! as! MemeDetailViewController
    detailController.meme = appDelegate.memes[indexPath.row]
    navigationController!.pushViewController(detailController, animated: true)
  }
}