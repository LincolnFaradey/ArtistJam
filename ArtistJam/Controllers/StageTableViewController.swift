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
    
    lazy var dateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateFormat = "LLLL dd, yyyy HH:mm"
        
        return df
        }()
    
    let coreDataStack = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
    lazy var fetchedResultController: NSFetchedResultsController = {
            let fetchRequest = NSFetchRequest(entityName: "Event")
            let descriptor = NSSortDescriptor(key: "date", ascending: false)
            
            fetchRequest.sortDescriptors = [descriptor]
            fetchRequest.fetchBatchSize = 10
            fetchRequest.relationshipKeyPathsForPrefetching = ["imageData"]
            
            let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                managedObjectContext: self.coreDataStack.context,
                sectionNameKeyPath: "date", cacheName: nil)
            
            fetchedResultController.delegate = self
            return fetchedResultController
        }()
    
    private static let today = NSDate()
    
    var category: StageLoaderOpertion.Category = .Today {
        didSet {
            update()
        }
    }
    
    lazy var operationQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
//        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground(self)
        
        self.tableView.rowHeight = 210
        
        self.refreshControl?.tintColor = UIColor.darkGrayColor()
        self.refreshControl?.layer.zPosition = 1
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "composeBarButtonWasPressed:")

//        NSNotificationCenter.defaultCenter().addObserverForName("PrivateContextSaved", object: nil, queue: nil, usingBlock: { notification in
//            dispatch_async(dispatch_get_main_queue(), { [weak self] in
//                print(notification.name)
//                self?.fetch()
//                self?.tableView.reloadData()
//            })
//        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        update()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        operationQueue.cancelAllOperations()
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
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: PostTableViewCell, indexPath: NSIndexPath) -> PostTableViewCell {
        let event = fetchedResultController.objectAtIndexPath(indexPath) as! Event
        
        cell.titleLabel.text = event.title
        cell.descriptionLabel.text = event.details
        cell.dateLabel.text = dateFormatter.stringFromDate(event.date!)
        cell.stageImageView.image = UIImage(named: "placeholder")
        
        if let image = event.imageData?.thumbnailImage() {
            cell.stageImageView.image = image
        } else if !cell.loading {
            let (loader, filter) = cell.imageOperations(postEntity: event, coreDataStack: coreDataStack)
            
            filter.addDependency(loader)
            operationQueue.addOperations([loader, filter], waitUntilFinished: false)
        }
        
        return cell
    }

    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! PostTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
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
        self.fetchedResultController.fetchRequest.predicate = self.category.predicate()
        let stageLoadOperation = StageLoaderOpertion(category: category)
        
        let title = self.category.rawValue.capitalizedString
        self.stageTopBarButton.setTitle(title, forState: .Normal)
        
        print("Updating...")
        stageLoadOperation.completionBlock = {
            NSOperationQueue.mainQueue().addOperationWithBlock({ [weak self] in
                self?.refreshControl?.endRefreshing()
                self?.fetch()
                self?.tableView.reloadData()
            })
        }
        
        operationQueue.cancelAllOperations()
        operationQueue.addOperation(stageLoadOperation)
    }

    
    func fetch() {
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        self.tableView.reloadData()
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        update()
    }
    
    @IBAction func showActionSheet(sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let todayAction = UIAlertAction(title: "Today", style: .Default) {[unowned self] _ in
            self.category = .Today
        }
        
        let comingAction = UIAlertAction(title: "Coming", style: .Default) {[unowned self] _ in
            self.category = .Coming
        }
        
        let newAction = UIAlertAction(title: "New", style: .Default) {[unowned self] _ in
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
        let alertController = UIAlertController(title: nil, message: "What do you want to create?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let eventAction = UIAlertAction(title: "Event", style: UIAlertActionStyle.Default) { [unowned self] _ in
            self.performSegueWithIdentifier("stageToEventSegue", sender: self)
        }
        let newsAction = UIAlertAction(title: "News", style: UIAlertActionStyle.Default) { [unowned self] _ in
            self.performSegueWithIdentifier("stageToNewsSegue", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: nil)
        alertController.addAction(eventAction)
        alertController.addAction(newsAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
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
                tableView.reloadSections(NSIndexSet(index: indexPath!.section), withRowAnimation: .Automatic)
            case .Insert:
                tableView.insertSections(NSIndexSet(index:newIndexPath!.section), withRowAnimation: .Automatic)
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
