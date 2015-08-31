//
//  JobTableViewController.swift
//  OfertaPune
//
//  Created by Armend H on 21/08/15.
//  Copyright (c) 2015 Armend. All rights reserved.
//

import Foundation
import UIKit
import CoreData



class JobTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    let jobId = "ji"
    let jobTopId = "jti"
    let jobBottomId = "jbi"
    
    var id = 0
    var topId = 0
    var bottomId = 0
    
    var isFetching = false
    
    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    
    var managedObjectContext: NSManagedObjectContext? {
        get {
            if let delegate = appDelegate {
                return delegate.managedObjectContext
            }
            return nil
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController?
    var searchResultsController: NSFetchedResultsController?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveDefaults()
        
        searchDisplayController?.searchResultsTableView.registerClass(JobTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: allContactsFetchRequest(nil), managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        fetchedResultsController?.performFetch(nil)
        
        if !(self.id == 1){
            self.getJobs(self.id, forType:"shjob", shouldGetDesc:false)
        }
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.addPullToRefreshHandler {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                
                if !self.isFetching{
                    if(self.id != 0){
                    self.getJobs(self.topId, forType: "rjob", shouldGetDesc:false)
                    } else {
                    self.getJobs(self.id, forType:"shjob", shouldGetDesc:false)
                }
                    
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.pullToRefreshView?.stopAnimating()
                })
            })
        }
       
        
        tableView.addInfiniteScrollingWithHandler {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                
                if !self.isFetching{
                    if(!(self.bottomId<=1)){
                        self.getJobs(self.bottomId, forType: "shjob", shouldGetDesc:false)
                    }
                }
                dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                    self.tableView.infiniteScrollingView?.stopAnimating()
                    })
            })
        }
        
    }




    //MARK: UITableView Data Source and Delegate Functions
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return fetchedResultsControllerForTableView(tableView)?.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsControllerForTableView(tableView)?.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! JobTableViewCell
        
        if let job = fetchedResultsControllerForTableView(tableView)?.objectAtIndexPath(indexPath) as? Job {
            cell.kompania?.text = job.kompania
            cell.pozita?.text = job.pozita
            cell.qyteti?.text = job.qyteti
            cell.id?.text = getDate(job.skadimi)
            cell.logo?.sd_setImageWithURL(NSURL(string: job.imgurl), placeholderImage: UIImage(named:"placeholder.png"))
            
            
        }
        
        
        return cell
    }
    
    func getDate(date:String) -> String{

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let endDate = dateFormatter.dateFromString(date)
        
        let difference = endDate?.timeIntervalSinceNow
        
        let time = round(difference!)
        
        let (d,h,m,s) = durationsBySecond(seconds: Int(time))
        
        
        if (h < 1) {
            return "Afati ka skaduar"
        }
        
        if (d > 0) {
            return "\(d) ditë"
        }
        
        if (h > 0) {
            return "\(h) orë"
        }
        
        return date
        
    }
    
    func durationsBySecond(seconds s: Int) -> (days:Int,hours:Int,minutes:Int,seconds:Int) {
        return (s / (24 * 3600),(s % (24 * 3600)) / 3600, s % 3600 / 60, s % 60)
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    
    func getJobs(paramId: Int, forType:String, shouldGetDesc:Bool) {
        
        self.isFetching = true

        let kivaLoadURL = "http://oxygenapp.comeze.com/android_login_api/getjob.php?tag=job&jobtype=\(forType)&id=\(paramId)"
        
        let request = NSURLRequest(URL: NSURL(string: kivaLoadURL)!)
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                println(error!.localizedDescription)
            }
            
            // Parse JSON data
            self.parseJsonData(data!, getDesc: shouldGetDesc, getParam: paramId)
            self.isFetching = false
            
        })
        
        task.resume()
    }
    
    func parseJsonData(data: NSData, getDesc:Bool,  getParam:Int){
        
        var error:NSError?
        
        let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSArray

        if error != nil {
            println(error?.localizedDescription)
        } else {
        
        // Parse JSON data
        let jsonJobs = jsonResult as! [AnyObject]
       
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
                
                for jsonJob in jsonJobs {
                    
                    
                    var idStr = jsonJob["id"] as! String
                    var idNr = idStr.toInt()!
                    
                    if !getDesc{
                        
                        var job = NSEntityDescription.insertNewObjectForEntityForName("Job", inManagedObjectContext: managedObjectContext) as! Job
                        
                        job.kompania = jsonJob["kompania"] as! String
                        job.pozita = jsonJob["pozita"] as! String
                        job.qyteti = jsonJob["qyteti"] as! String
                        job.imgurl = jsonJob["imgurl"] as! String
                        job.tags = jsonJob["tags"] as! String
                        job.kontakt = jsonJob["kontakt"] as! String
                        job.orari = jsonJob["orari"] as! String
                        job.skadimi = jsonJob["skadimi"] as! String
                        
                        job.id = idNr
                        
                        if(id==0){
                            topId = idNr
                        }
                        id = idNr
                        
                        if(!(id>topId)){
                            bottomId = id-1
                        }else {
                            topId=id;
                        }
                        
                        self.getJobs(getParam, forType: "fjob", shouldGetDesc: true)
                        
                    } else {
                        
                        if let job = getJobFromDb(idNr) as? Job {
                        
                            job.pershkrimi = jsonJob["pershkrimi"] as! String
                        }
                        
                    }

                    }
                    
                dispatch_async(dispatch_get_main_queue(), {
                    
                   self.saveInDefaults()
                    
                    var e:NSError?
                    if managedObjectContext.save(&e) != true {
                        println("insert error: \(e!.localizedDescription)")
                    }
                })
                
                }
        }

    }
    
    func getJobFromDb(idNumber:Int)->AnyObject{

        var result:AnyObject?
    
        var fetchRequest = NSFetchRequest(entityName: "Job")
        
        fetchRequest.predicate = NSPredicate(format: "id = \(idNumber)")
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext{
            
            var e:NSError?
            
            if let results = managedObjectContext.executeFetchRequest(fetchRequest, error: &e) {
                   result = results[0]
            }
            
        }
        
        return result!
    }
    
    
    //MARK: NSFetchedResultsController Delegate Functions
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        let tableView = controller == fetchedResultsController ? self.tableView : searchDisplayController?.searchResultsTableView
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        let tableView = controller == fetchedResultsController ? self.tableView : searchDisplayController?.searchResultsTableView
        
        switch type {
        case NSFetchedResultsChangeType.Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
            break
        case NSFetchedResultsChangeType.Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
            break
        case NSFetchedResultsChangeType.Move:
            break
        case NSFetchedResultsChangeType.Update:
            break
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        let tableView = controller == fetchedResultsController ? self.tableView : searchDisplayController?.searchResultsTableView
        
        switch type {
        case NSFetchedResultsChangeType.Insert:
            tableView.insertRowsAtIndexPaths(NSArray(object: newIndexPath!) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
            break
        case NSFetchedResultsChangeType.Delete:
            tableView.deleteRowsAtIndexPaths(NSArray(object: indexPath!) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
            break
        case NSFetchedResultsChangeType.Move:
            tableView.deleteRowsAtIndexPaths(NSArray(object: indexPath!) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.insertRowsAtIndexPaths(NSArray(object: newIndexPath!) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Fade)
            break
        case NSFetchedResultsChangeType.Update:
            tableView.cellForRowAtIndexPath(indexPath!)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        let tableView = controller == fetchedResultsController ? self.tableView : searchDisplayController?.searchResultsTableView
        tableView.endUpdates()
    }

    
    //MARK: NSFetchRequest
    func fetchedResultsControllerForTableView(tableView: UITableView) -> NSFetchedResultsController? {
        return tableView == searchDisplayController?.searchResultsTableView ? searchResultsController : fetchedResultsController
    }
    
    func allContactsFetchRequest(predicate: NSPredicate?) -> NSFetchRequest {
        
        var fetchRequest = NSFetchRequest(entityName: "Job")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        return fetchRequest
    }

    
    // Save or retrieve user defaults
    
    func saveInDefaults(){
        userDefaults.setObject(id, forKey: jobId)
        userDefaults.setObject(topId, forKey: jobTopId)
        userDefaults.setObject(bottomId, forKey: jobBottomId)
        
    }
    
    func retrieveDefaults(){
        id = userDefaults.integerForKey(jobId)
        topId = userDefaults.integerForKey(jobTopId)
        bottomId = userDefaults.integerForKey(jobBottomId)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showJobDetail" {
            var indexPath:NSIndexPath?
            var job:Job?
            
            if (self.searchDisplayController!.active) {
                indexPath = self.searchDisplayController?.searchResultsTableView.indexPathForSelectedRow()
                job = searchResultsController?.objectAtIndexPath(indexPath!) as? Job
            } else {
                indexPath = self.tableView.indexPathForSelectedRow()
                job = fetchedResultsController?.objectAtIndexPath(indexPath!) as? Job
            }
            
            let destinationController = segue.destinationViewController as! JobDetailTableViewController
            destinationController.job = job
        }
    }
    

   }

extension JobTableViewController: UISearchBarDelegate, UISearchDisplayDelegate {
    
    func searchDisplayController(controller: UISearchDisplayController, willUnloadSearchResultsTableView tableView: UITableView) {
        searchResultsController?.delegate = nil
        searchResultsController = nil
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        
        let firstNamePredicate = NSPredicate(format: "kompania CONTAINS[cd] %@", searchString.lowercaseString)
        let lastNamePredicate = NSPredicate(format: "pozita CONTAINS[cd] %@", searchString.lowercaseString)
        let predicate = NSCompoundPredicate.orPredicateWithSubpredicates([firstNamePredicate, lastNamePredicate])
        
        
        searchResultsController = NSFetchedResultsController(fetchRequest: allContactsFetchRequest(predicate), managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        searchResultsController?.performFetch(nil)
        
        return true
    }
}


