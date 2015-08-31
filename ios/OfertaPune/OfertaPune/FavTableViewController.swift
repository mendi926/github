//
//  FavTableViewController.swift
//  OfertaPune
//
//  Created by Armend H on 21/08/15.
//  Copyright (c) 2015 Armend. All rights reserved.
//

import UIKit
import CoreData

class FavTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var fetchResultController:NSFetchedResultsController!

    override func viewDidLoad() {
        super.viewDidLoad()
        var fetchRequest = NSFetchRequest(entityName: "Job")
        let sortDescriptor = NSSortDescriptor(key:"id", ascending:false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "isFavorite=true")
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext{
            
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            
            fetchResultController.delegate = self
            
            var e:NSError?
            var result = fetchResultController.performFetch(&e)
            
            if result != true {
                println(e?.localizedDescription)
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = fetchResultController.sections?.count
        return numberOfSections!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = fetchResultController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    func configureCell(cell:JobTableViewCell, atIndexPath indexPath:NSIndexPath){
        var job = fetchResultController.objectAtIndexPath(indexPath) as! Job
        cell.kompania?.text = job.kompania
        cell.pozita?.text = job.pozita
        cell.qyteti?.text = job.qyteti
        cell.id?.text = getDate(job.skadimi)
        cell.logo?.sd_setImageWithURL(NSURL(string: job.imgurl), placeholderImage: UIImage(named:"placeholder.png"))    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! JobTableViewCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        
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
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
        self.tableView.reloadData()
        
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case NSFetchedResultsChangeType.Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            if let _newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([_newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        case .Delete:
            if let _indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([_indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        case .Update:
            if let _indexPath = indexPath {
                tableView.reloadRowsAtIndexPaths([_indexPath], withRowAnimation: .Fade)

            }
            
        default:
            tableView.reloadData()
            
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showJobDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow(){
                let destinationController = segue.destinationViewController as! JobDetailTableViewController
                destinationController.job = fetchResultController.objectAtIndexPath(indexPath) as! Job
            }
        }
    }

}
