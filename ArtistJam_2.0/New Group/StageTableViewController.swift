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
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "LLLL dd, yyyy HH:mm"
        
        return df
        }()
    
    let coreDataStack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    lazy var fetchedResultController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
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
    
    lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addGradientBackground()
        
        self.tableView.rowHeight = 210
        
        self.refreshControl?.tintColor = UIColor.darkGray
        self.refreshControl?.layer.zPosition = 1
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.compose, target: self, action: Selector(("composeBarButtonWasPressed:")))

//        NSNotificationCenter.defaultCenter().addObserverForName("PrivateContextSaved", object: nil, queue: nil, usingBlock: { notification in
//            dispatch_async(dispatch_get_main_queue(), { [weak self] in
//                print(notification.name)
//                self?.fetch()
//                self?.tableView.reloadData()
//            })
//        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operationQueue.cancelAllOperations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("momory warning recieved")
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultController.sections else {
            return 0
        }
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stageCell", for: indexPath as IndexPath) as! PostTableViewCell
        return configureCell(cell: cell, indexPath: indexPath)
    }
    
    func configureCell(cell: PostTableViewCell, indexPath: IndexPath) -> PostTableViewCell {
        let event = fetchedResultController.object(at: indexPath) as! Event
        
        cell.titleLabel.text = event.title
        cell.descriptionLabel.text = event.details
        cell.dateLabel.text = dateFormatter.string(from: event.date! as Date)
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! PostTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stageCellHeader") as UITableViewCell?
        
        cell!.backgroundColor = UIColor(red:0.898,  green:0.886,  blue:0.886, alpha:0.4)
        cell!.layer.borderColor = UIColor(red:0.898,  green:0.886,  blue:0.886, alpha:1).cgColor
        cell!.layer.borderWidth = 0.8
        
        return cell;
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }
    
    func update() {
        self.fetchedResultController.fetchRequest.predicate = self.category.predicate()
        let stageLoadOperation = StageLoaderOpertion(category: category)
        
        let title = self.category.rawValue.capitalized
        self.stageTopBarButton.setTitle(title, for: .normal)
        
        print("Updating...")
        stageLoadOperation.completionBlock = {
            OperationQueue.main.addOperation({ [weak self] in
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
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let todayAction = UIAlertAction(title: "Today", style: .default) {[unowned self] _ in
            self.category = .Today
        }
        
        let comingAction = UIAlertAction(title: "Coming", style: .default) {[unowned self] _ in
            self.category = .Coming
        }
        
        let newAction = UIAlertAction(title: "New", style: .default) {[unowned self] _ in
            self.category = .New
        }
        
        actionSheet.addAction(todayAction)
        actionSheet.addAction(comingAction)
        actionSheet.addAction(newAction)
        
        let subview = actionSheet.view.subviews.first!
        let alertContentView = subview.subviews.first!
        alertContentView.backgroundColor = UIColor.clear
        alertContentView.layer.cornerRadius = 8.0
        
        actionSheet.view.tintColor = UIColor(red:0.392,  green:0.380,  blue:0.380, alpha:1)
        self.present(actionSheet, animated: true) { () -> Void in

        }
    }
    
    @IBAction func composeBarButtonWasPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: "What do you want to create?", preferredStyle: UIAlertController.Style.actionSheet)
        let eventAction = UIAlertAction(title: "Event", style: UIAlertAction.Style.default) { [unowned self] _ in
            self.performSegue(withIdentifier: "stageToEventSegue", sender: self)
        }
        let newsAction = UIAlertAction(title: "News", style: UIAlertAction.Style.default) { [unowned self] _ in
            self.performSegue(withIdentifier: "stageToNewsSegue", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: nil)
        alertController.addAction(eventAction)
        alertController.addAction(newsAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: PostTableViewDelegate
    
    func addButtonWasPressed(sender: UIButton, index: IndexPath) {
        UIView.transition(with: sender, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromTop, animations: { () -> Void in
            sender.setImage(UIImage(named: "done"), for: .normal)
            }, completion: nil)
    }
    
    func facebookButtonWasPressed(sender: UIButton, index: IndexPath) {
        
    }
    
    func twitterButtonWasPressed(sender: UIButton, index: IndexPath) {
        
    }
    
    func likeButtonWasPressed(sender: UIButton, index: IndexPath) {
        UIView.transition(with: sender, duration: 0.5, options: UIView.AnimationOptions.transitionCurlUp, animations: { () -> Void in
            sender.setImage(UIImage(named: "likeFilled"), for: .normal)
            
            }, completion: nil)
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .update:
            tableView.reloadSections(IndexSet(integer: indexPath!.section), with: .automatic)
        case .insert:
            tableView.insertSections(IndexSet(integer:newIndexPath!.section), with: .automatic)
            default:
                return
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

//    //MARK: - UIScrollViewDelegate
//    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        print("scrolled")
//    }
}
