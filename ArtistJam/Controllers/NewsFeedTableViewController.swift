//
//  ANNewsFeedTableViewController.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/13/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

class NewsFeedTableViewController: UITableViewController, PostTableViewDelegate , NSFetchedResultsControllerDelegate {

    let coreDataStack = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
    var selectedPost: Post!
    
    lazy var fetchedResultController: NSFetchedResultsController = {
            let fetchRequesst = NSFetchRequest(entityName: "News")
            let descriptor = NSSortDescriptor(key: "title", ascending: false)
            
            fetchRequesst.sortDescriptors = [descriptor]
            fetchRequesst.fetchBatchSize = 8
            fetchRequesst.relationshipKeyPathsForPrefetching = ["imageData"]
        
            let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequesst,
                managedObjectContext: self.coreDataStack.context,
                sectionNameKeyPath: nil, cacheName: nil)
            fetchedController.delegate = self
            
            return fetchedController
        }()
    
    lazy var operationQueue: NSOperationQueue = {
            let queue = NSOperationQueue()
            queue.maxConcurrentOperationCount = 1
            return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 210
        addGradientBackground(self)
        self.refreshControl?.tintColor = UIColor.blackColor()
        self.refreshControl?.layer.zPosition = 1
        
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        //        self.tableView.estimatedRowHeight = 210.0
        
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("NewsContextSaved", object: nil, queue: nil, usingBlock: { notification in
            dispatch_async(dispatch_get_main_queue(), {
                do {
                    try self.fetchedResultController.performFetch()
                    print("fetched")
                } catch let error as NSError {
                    print("Error: \(error.localizedDescription)")
                }
            })
        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        operationQueue.cancelAllOperations()
        operationQueue.waitUntilAllOperationsAreFinished()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultController.sections![section] as NSFetchedResultsSectionInfo
        
        return sectionInfo.numberOfObjects
    }
    
    let identifier = "newsCell"
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! PostTableViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    
    func configureCell(cell: PostTableViewCell, indexPath: NSIndexPath) -> PostTableViewCell {
        let news = fetchedResultController.objectAtIndexPath(indexPath) as! News
        
        cell.titleLabel.text = news.title
        cell.descriptionLabel.text = news.details
        cell.likesCounterLabel.text = news.likes?.stringValue
        cell.stageImageView.image = UIImage(named: "placeholder")
        if let _ = news.liked {} else {
            news.liked = NSNumber(bool: false)
        }
        
        cell.likeButton.setImage(UIImage(named: news.liked!.boolValue ? "likeFilled" : "likeEmpty"), forState: .Normal)
        
        if let image = news.imageData?.thumbnailImage() {
            cell.stageImageView.image = image
        } else if !cell.loading {
            let (loader, filter) = cell.imageOperations(postEntity: news, coreDataStack: coreDataStack)
            
            filter.addDependency(loader)
            
            operationQueue.addOperation(loader)
            operationQueue.addOperation(filter)
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! PostTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedPost = fetchedResultController.objectAtIndexPath(indexPath) as! News
        self.performSegueWithIdentifier("newsToDetails", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newsToDetails" {
            let vc = segue.destinationViewController as! DetailsViewController
            vc.post = selectedPost
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        update()
    }
    
    func update() {
        operationQueue.cancelAllOperations()
        let newsLoader = NewsLoaderOperatrion()
        newsLoader.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), {
                self.refreshControl?.endRefreshing()
            })
        }
        operationQueue.addOperation(newsLoader)
    }
    
    //MARK: ANStageTableViewDelegate
    func addButtonWasPressed(sender: UIButton, index: NSIndexPath) {
        UIView.transitionWithView(sender, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromTop, animations: { () -> Void in
            sender.setImage(UIImage(named: "done"), forState: .Normal)
            }, completion: nil)
    }
    
    func facebookButtonWasPressed(sender: UIButton, index: NSIndexPath) {
        
    }
    
    func twitterButtonWasPressed(sender: UIButton, index: NSIndexPath) {
        
    }
    
    // TODO: create operation for performance reason
    var task: NSURLSessionDataTask?
    func likeButtonWasPressed(sender: UIButton, index: NSIndexPath) {
        
        let news = fetchedResultController.objectAtIndexPath(index) as! News
        
        let liked = news.liked!.boolValue
        let likes = news.likes!.intValue
        
        task?.cancel()
        
        let url: NSURL
        if liked {
            news.likes = NSNumber(int: likes - 1)
            url = NSURL(string: "\(ADDRESS)/news/unlike/\(news.webID!.stringValue)")!
        } else {
            news.likes = NSNumber(int: likes + 1)
            url = NSURL(string: "\(ADDRESS)/news/like/\(news.webID!.stringValue)")!
            
        }
        print("URL - \(url)")
        task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            print("liked response - \(json)")
        })
        task?.resume()
        
        news.liked = NSNumber(bool: !liked)
        self.coreDataStack.saveContext()
        UIView.transitionWithView(sender, duration: 0.1, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: { _ in
        
            sender.setImage(UIImage(named: news.liked!.boolValue ? "likeFilled" : "likeEmpty"), forState: .Normal)
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
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            default:
                return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}
