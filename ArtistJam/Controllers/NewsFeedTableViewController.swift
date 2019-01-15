//
//  ANNewsFeedTableViewController.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/13/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

class NewsFeedTableViewController: UITableViewController, PostTableViewDelegate , NSFetchedResultsControllerDelegate {

    let coreDataStack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    var selectedPost: Post!
    
    lazy var fetchedResultController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let fetchRequesst = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
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
    
    lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 2
            return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 210
        self.addGradientBackground()
        self.refreshControl?.tintColor = UIColor.black
        self.refreshControl?.layer.zPosition = 1
        
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        //        self.tableView.estimatedRowHeight = 210.0
        
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operationQueue.cancelAllOperations()
//        operationQueue.waitUntilAllOperationsAreFinished()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultController.sections![section] as NSFetchedResultsSectionInfo
        
        return sectionInfo.numberOfObjects
    }
    
    let identifier = "newsCell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! PostTableViewCell
        return configureCell(cell: cell, indexPath: indexPath)
    }

    
    func configureCell(cell: PostTableViewCell, indexPath: IndexPath) -> PostTableViewCell {
        let news = fetchedResultController.object(at: indexPath) as! News
        
        cell.titleLabel.text = news.title
        cell.descriptionLabel.text = news.details
        cell.likesCounterLabel.text = news.likes?.stringValue
        cell.stageImageView.image = UIImage(named: "placeholder")
        if let _ = news.liked {} else {
            news.liked = NSNumber(value: false)
        }
        
        cell.likeButton.setImage(UIImage(named: news.liked!.boolValue ? "likeFilled" : "likeEmpty"), for: .normal)
        
        if let image = news.imageData?.thumbnailImage() {
            cell.stageImageView.image = image
        } else if !cell.loading {
            let (loader, filter) = cell.imageOperations(postEntity: news, coreDataStack: coreDataStack)
            
            filter.addDependency(loader)
            
            operationQueue.addOperations([loader, filter], waitUntilFinished: false)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! PostTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedPost = fetchedResultController.object(at: indexPath) as! News
        self.performSegue(withIdentifier: "newsToDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newsToDetails" {
            let vc = segue.destination as! DetailsViewController
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
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }

        operationQueue.addOperation(newsLoader)
    }
    
    //MARK: ANStageTableViewDelegate
    func addButtonWasPressed(sender: UIButton, index: IndexPath) {
        UIView.transition(with: sender, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromTop, animations: { () -> Void in
            sender.setImage(UIImage(named: "done"), for: .normal)
            }, completion: nil)
    }
    
    func facebookButtonWasPressed(sender: UIButton, index: IndexPath) {
        
    }
    
    func twitterButtonWasPressed(sender: UIButton, index: IndexPath) {
        
    }
    
    // TODO: create operation for performance reason
    var task: URLSessionDataTask?
    func likeButtonWasPressed(sender: UIButton, index: IndexPath) {
        
        let news = fetchedResultController.object(at: index) as! News
        
        let liked = news.liked!.boolValue
        let likes = news.likes!.intValue
        
        task?.cancel()
        
        let url: URL
        if liked {
            news.likes = NSNumber(value: likes - 1)
            url = Route.Unlike(news.webID!.intValue).url()!
        } else {
            news.likes = NSNumber(value: likes + 1)
            url = Route.Like(news.webID!.intValue).url()!
            
        }
        print("URL - \(url)")
        task = URLSession.shared.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            let json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
            print("liked response - \(json)")
        })
        task?.resume()
        
        news.liked = NSNumber(value: !liked)
        self.coreDataStack.saveContext()
        
        UIView.transition(with: sender, duration: 0.1, options: UIView.AnimationOptions.transitionFlipFromRight,
                          animations: {
                            sender.setImage(UIImage(named: news.liked!.boolValue ? "likeFilled" : "likeEmpty"), for: .normal)
                        }, completion: nil)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates() 
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .update:
            tableView.reloadRows(at: [indexPath! as IndexPath], with: UITableView.RowAnimation.automatic)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: UITableView.RowAnimation.automatic)
            default:
                return
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
