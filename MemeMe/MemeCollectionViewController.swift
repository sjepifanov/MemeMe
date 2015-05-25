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
  
  // MARK: Outlets
  @IBOutlet var addButton: UIBarButtonItem!
  @IBOutlet var editButton: UIBarButtonItem!
  @IBOutlet var deleteButton: UIBarButtonItem!
  @IBOutlet var cancelButton: UIBarButtonItem!
  
  
  // MARK: Declarations
  var selecting: Bool = false {
    didSet {
      collectionView?.allowsMultipleSelection = selecting
      // Clear previous selection if any
      collectionView?.selectItemAtIndexPath(nil, animated: true, scrollPosition: .None)
    }
  }
  var objectsToDelete = [Meme]()
  
  //MARK: View
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    println("Collection ViewWillAppear")
    self.collectionView?.reloadData()
    updateButtonsToMatchTableState()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    println("Collection ViewWillDisappear")
    if selecting {
      self.selecting = !selecting
    }
    // make our view consistent
    updateButtonsToMatchTableState()
  }
  
  // MARK: Add, Delete, Edit, Cancel Actions
  
  @IBAction func addAction(sender: AnyObject) {
    let imagePickerController = self.storyboard!.instantiateViewControllerWithIdentifier("imagePickerController") as! MemeEditorViewController
    imagePickerController.hidesBottomBarWhenPushed = true
    navigationController!.pushViewController(imagePickerController, animated: true)
  }
  
  @IBAction func editAction(sender: AnyObject) {
    // Switch selecting state
    self.selecting = !selecting
    updateButtonsToMatchTableState()
  }
  
  @IBAction func deleteAction(sender: AnyObject) {
    // Preparing UIAlertController to present the alert on deletion
    let cancelTitle = "Cancel"
    let okTitle = "OK"
    var alertTitle = "Remove villains"
    var actionTitle = "Are you sure you want to remove these items?"
    
    if let indexPaths = collectionView?.indexPathsForSelectedItems() {
      if indexPaths.count == 1 {
        alertTitle = "Remove villain"
        actionTitle = "Are you sure you want to remove this item?"
      }
    }
    
    let alertController = UIAlertController(title: alertTitle, message: actionTitle, preferredStyle: UIAlertControllerStyle.Alert)
    
    let cancelAction = UIAlertAction(title: cancelTitle, style: UIAlertActionStyle.Default) {action in  self.dismissViewControllerAnimated(true, completion: nil)}
    alertController.addAction(cancelAction)
    
    let okAction = UIAlertAction(title: okTitle, style: UIAlertActionStyle.Default) {action in  self.deleteSelection()}
    alertController.addAction(okAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  @IBAction func cancelAction(sender: AnyObject) {
    self.selecting = !selecting
    collectionView?.reloadSections(NSIndexSet(index: 0))
    updateButtonsToMatchTableState()
  }

  // MARK: Collection View Delegates
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return appDelegate.memes.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
    let meme = appDelegate.memes[indexPath.row]
    cell.memeCellImage?.image = meme.memedImage
    
    // Check if cell is actually selected and set cell alpha value accordingly
    if cell.selected {
      cell.alpha = 0.5
    }else{
      cell.alpha = 1.0
    }
    
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if selecting {
      let cell = collectionView.cellForItemAtIndexPath(indexPath)
      //Change cell alpha value
      cell?.alpha = 0.5
      updateButtonsToMatchTableState()
      
    }else{
    let detailController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")! as! MemeDetailViewController
    detailController.meme = appDelegate.memes[indexPath.row]
    navigationController!.pushViewController(detailController, animated: true)
    }
  }

  //MARK: Methods to delelte selected items and configure buttons state
  
  func deleteSelection() {
    // Get selected items paths from collection View
    // Unwrapping here is not really necessary as .indexPathsForSelectedItems() returns empty array if no rows are selected and not nil.
    if let selectedRows = collectionView?.indexPathsForSelectedItems() as? [NSIndexPath]{
      // Check if rows are selected
      if !selectedRows.isEmpty {
        // Create temporary array of selected items
        for selectedRow in selectedRows{
          objectsToDelete.append(appDelegate.memes[selectedRow.row])
        }
        // Find objects from temporary array in data source and delete them
        for object in objectsToDelete {
          if let index = find(appDelegate.memes, object){
            appDelegate.memes.removeAtIndex(index)
          }
        }
        collectionView?.deleteItemsAtIndexPaths(selectedRows)
        // Clear temporary array just in case
        objectsToDelete.removeAll(keepCapacity: false)
        
      }else{
        
        // Delete everything, delete the objects from data model.
        appDelegate.memes.removeAll(keepCapacity: false)
        collectionView?.reloadSections(NSIndexSet(index: 0))
      }
      self.selecting = !selecting
      updateButtonsToMatchTableState()
    }
  }
  
  func updateButtonsToMatchTableState(){
    if selecting {
      
      // Show the option to cancel the edit.
      navigationItem.rightBarButtonItem = cancelButton
      
      updateDeleteButtonTitle()
      
      // Show the delete button.
      navigationItem.leftBarButtonItem = deleteButton
    }else{
      
      // Not in editing mode.
      navigationItem.leftBarButtonItem = addButton
      
      // Show the edit button, but disable the edit button if there's nothing to edit.
      editButton.enabled = appDelegate.memes.isEmpty ? false : true
      navigationItem.rightBarButtonItem = editButton
    }
  }
  
  func updateDeleteButtonTitle(){
    
    // Update the delete button's title, based on how many items are selected
    if let selectedRows = collectionView?.indexPathsForSelectedItems() as? [NSIndexPath]{
      
      let allItemsAreSelected = selectedRows.count == appDelegate.memes.count ? true : false
      let noItemsAreSelected = selectedRows.isEmpty
      
      if allItemsAreSelected || noItemsAreSelected {
        deleteButton.title = "Delete All"
      }else{
        deleteButton.title = "Delete (\(selectedRows.count))"
      }
    }
  }


}