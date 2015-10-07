//
//  ANStageTableViewController.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/6/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

class StageTableViewController: UITableViewController, PostTableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var composeBarButton: UIBarButtonItem!
    @IBOutlet weak var stageTopBarButton: UIButton!
    
    let dateFormatter = NSDateFormatter()
    
    var fetchedResultController: NSFetchedResultsController!
    let coreDataStack = CoreDataStack()
    var category: Category = .Today {
        didSet {
            update()
        }
    }
    
    lazy var operationQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "LLLL dd, yyyy HH:mm"
        
        let fetchRequesst = NSFetchRequest(entityName: "Event")
        let dateDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequesst.sortDescriptors = [dateDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequesst, managedObjectContext: coreDataStack.context, sectionNameKeyPath: "title", cacheName: nil)
        fetchedResultController.delegate = self
        
        self.tableView.rowHeight = 210
        addGradientBackground(self)
        self.refreshControl?.tintColor = UIColor.darkGrayColor()
        self.refreshControl?.layer.zPosition = 1
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "composeBarButtonWasPressed:")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("momory warning recieved")
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let sections = fetchedResultController.sections else {
            return 0
        }
        
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("stageCell", forIndexPath: indexPath) as! PostTableViewCell
        
        let event = fetchedResultController.objectAtIndexPath(indexPath) as! Event
        cell.titleLabel.text = event.title
        cell.descriptionLabel.text = event.details
        cell.dateLabel.text = dateFormatter.stringFromDate(event.date!)
        
        if let image = event.imageData?.thumbnailImage() {
            cell.stageImageView.image = image
        } else {
            let operations = cell.loadImageFor(postEntity: event, atCoreDataStack: self.coreDataStack)
            
            operations.filter.addDependency(operations.loader)
            
            operationQueue.addOperation(operations.loader)
            operationQueue.addOperation(operations.filter)
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? PostTableViewCell {
            cell.delegate = self
            cell.indexPath = indexPath
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView .dequeueReusableCellWithIdentifier("stageCellHeader") as UITableViewCell?

        cell!.backgroundColor = UIColor(red:0.898,  green:0.886,  blue:0.886, alpha:0.4)
        cell!.layer.borderColor = UIColor(red:0.898,  green:0.886,  blue:0.886, alpha:1).CGColor
        cell!.layer.borderWidth = 0.8
        
        return cell;
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }
    
    func update() {
        let stageLoadOperation = StageLoaderOpertion(category: category)
        let title = self.category.rawValue.capitalizedString
        self.stageTopBarButton.setTitle(title, forState: .Normal)
        
        stageLoadOperation.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
//                NSTimer.scheduledTimerWithTimeInterval(0.2, target: self.refreshControl!, selector:"endRefreshing", userInfo: nil, repeats: false)
            })
        }
        
        let today = NSDate()
//        print(today + 1.day)
        switch category {
        case .Today:
            fetchedResultController.fetchRequest.predicate = NSPredicate(format: "date < %@ and date > %@", today + 1.day, today - 1.day)
        case .Coming:
            fetchedResultController.fetchRequest.predicate = NSPredicate(format: "date > %@", today + 1.day)
        default:
            fetchedResultController.fetchRequest.predicate = nil
        }
        
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        operationQueue.addOperation(stageLoadOperation)
    }
    
    func reload() {
        self.tableView.reloadData()
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        update()
    }
    
    @IBAction func showActionSheet(sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let todayAction = UIAlertAction(title: "Today", style: .Default) { _ in
            self.category = .Today
        }
        
        let comingAction = UIAlertAction(title: "Coming", style: .Default) { _ in
            self.category = .Coming
        }
        
        let newAction = UIAlertAction(title: "New", style: .Default) { _ in
            self.category = .New
        }
        
        actionSheet.addAction(todayAction)
        actionSheet.addAction(comingAction)
        actionSheet.addAction(newAction)
        
        let subview = actionSheet.view.subviews.first as UIView!
        let alertContentView = subview.subviews.first as UIView!
        alertContentView.backgroundColor = UIColor.clearColor()
        alertContentView.layer.cornerRadius = 8.0
        
        actionSheet.view.tintColor = UIColor(red:0.392,  green:0.380,  blue:0.380, alpha:1)
        self.presentViewController(actionSheet, animated: true) { () -> Void in

        }
    }
    
    @IBAction func composeBarButtonWasPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("stageToNewsSegue", sender: self)
    }
    
    
    //MARK: PostTableViewDelegate
    
    func addButtonWasPressed(sender: UIButton, index: NSIndexPath) {
        UIView.transitionWithView(sender, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromTop, animations: { () -> Void in
            sender.setImage(UIImage(named: "done"), forState: .Normal)
            }, completion: nil)
    }
    
    func facebookButtonWasPressed(sender: UIButton, index: NSIndexPath) {
        
    }
    
    func twitterButtonWasPressed(sender: UIButton, index: NSIndexPath) {
        
    }
    
    func likeButtonWasPressed(sender: UIButton, index: NSIndexPath) {
        UIView.transitionWithView(sender, duration: 0.5, options: UIViewAnimationOptions.TransitionCurlUp, animations: { () -> Void in
            sender.setImage(UIImage(named: "likeFilled"), forState: .Normal)
            
            }, completion: nil)
    }
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        switch type {
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Middle)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

//    //MARK: - UIScrollViewDelegate
//    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        print("scrolled")
//    }
}
