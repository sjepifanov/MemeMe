//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Sergei on 24/05/15.
//  Copyright (c) 2015 Sergei. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
  
  // MARK: Outlets
  
  @IBOutlet var addButton: UIBarButtonItem!
  @IBOutlet var editButton: UIBarButtonItem!
  @IBOutlet var deleteButton: UIBarButtonItem!
  @IBOutlet var cancelButton: UIBarButtonItem!

  
  // MARK: Declarations
  
  let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
  // Declare empty array of type Meme to hold a copy of selected objects to delete
  var objectsToDelete = [Meme]()
  let cellIdentifier = "MemeTableViewCell"
  
  // MARK: Views
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    println("Table ViewDidLoad")
    self.tableView.allowsMultipleSelectionDuringEditing = true
    tableView.reloadData()
    
    // Switch to image Editor is there is no saved Memes
    if appDelegate.memes.count == 0{
      let imagePickerController = self.storyboard!.instantiateViewControllerWithIdentifier("imagePickerController") as! MemeEditorViewController
      imagePickerController.hidesBottomBarWhenPushed = true
      navigationController!.pushViewController(imagePickerController, animated: true)
    }
    
    // make our view consistent
    updateButtonsToMatchTableState()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
        println("Table ViewWillAppear")
  
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 80
    
    tableView.reloadData()
    
    // make our view consistent
    self.updateButtonsToMatchTableState()
  }

  
  // MARK: Actions for Add, Edit, Delete and Cancel buttons
  
  @IBAction func addAction(sender: AnyObject) {
    let imagePickerController = self.storyboard!.instantiateViewControllerWithIdentifier("imagePickerController") as! MemeEditorViewController
    imagePickerController.hidesBottomBarWhenPushed = true
    navigationController!.pushViewController(imagePickerController, animated: true)
  }
  
  @IBAction func deleteAction(sender: AnyObject) {
    
    let cancelTitle = "Cancel"
    let okTitle = "OK"
    var alertTitle = "Remove memes"
    var actionTitle = "Are you sure you want to remove these items?"
    
    if let indexPaths = tableView.indexPathsForSelectedRows() {
      if indexPaths.count == 1 {
        alertTitle = "Remove meme"
        actionTitle = "Are you sure you want to remove this item?"
      }
    }
    
    
    let alertController = UIAlertController(title: alertTitle, message: actionTitle, preferredStyle: UIAlertControllerStyle.Alert)
    
    let cancelAction = UIAlertAction(title: cancelTitle, style: UIAlertActionStyle.Default) {action in self.dismissViewControllerAnimated(true, completion: nil)}
    alertController.addAction(cancelAction)
    
    let okAction = UIAlertAction(title: okTitle, style: UIAlertActionStyle.Default) {action in self.deleteSelection()}
    alertController.addAction(okAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  @IBAction func editAction(sender: AnyObject) {
    tableView.setEditing(true, animated: true)
    
    // make our view consistent
    updateButtonsToMatchTableState()
  }
  
  @IBAction func cancelAction(sender: AnyObject) {
    tableView.setEditing(false, animated: true)
    
    // make our view consistent
    updateButtonsToMatchTableState()
  }
  
  // MARK: Table View Delegate methods
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return appDelegate.memes.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MemeTableViewCell
    let meme = appDelegate.memes[indexPath.row]
    
    // Set the name and image
    cell.topTextLabel?.text = meme.topText
    cell.bottomTextLabel?.text = meme.bottomText
    cell.cellImageView?.image = meme.memedImage
    
    return cell
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
    return true
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if tableView.editing{
      
      // Update the delete button's title based on how many items are selected.
      updateButtonsToMatchTableState()
    }else{
      let detailController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")! as! MemeDetailViewController
      detailController.meme = appDelegate.memes[indexPath.row]
      navigationController!.pushViewController(detailController, animated: true)
    }
  }
  
  override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    
    // Update the delete button's title based on how many items are selected.
    updateDeleteButtonTitle()
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == UITableViewCellEditingStyle.Delete{
      appDelegate.memes.removeAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
  }
  
  //MARK: Methods to delelte selected items and configure buttons state
  
  func deleteSelection() {
    
    // Unwrap indexPaths to check if rows are selected
    if let selectedRows = tableView.indexPathsForSelectedRows() {
      for selectedRow in selectedRows{
        objectsToDelete.append(appDelegate.memes[selectedRow.row])
      }
      // Find objects from temporary array in data source and delete them
      for object in objectsToDelete {
        if let index = find(appDelegate.memes, object){
          appDelegate.memes.removeAtIndex(index)
        }
      }
      
    }else{
      
      // Delete everything, delete the objects from data model.
      appDelegate.memes.removeAll(keepCapacity: false)
      
      // Tell the tableView that we deleted the objects.
      // Because we are deleting all the rows, just reload the current table section
      tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }
    
    // Exit editing mode after the deletion.
    tableView.setEditing(false, animated: true)
    updateButtonsToMatchTableState()
  }
  
  func updateButtonsToMatchTableState(){
    if tableView.editing{
      
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
    if let selectedRows = tableView.indexPathsForSelectedRows() {
      deleteButton.title = "Delete (\(selectedRows.count))"
      
      let allItemsAreSelected = selectedRows.count == appDelegate.memes.count ? true : false
      if allItemsAreSelected {self.deleteButton.title = "Delete All"}
    }else{
      deleteButton.title = "Delete All"
    }
  }
  
}