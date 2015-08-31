//
//  JobDetailTableViewController.swift
//  OfertaPune
//
//  Created by Armend H on 21/08/15.
//  Copyright (c) 2015 Armend. All rights reserved.
//

import UIKit

class JobDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var favButton: UIButton!
    var job:Job!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 57.0
        tableView.rowHeight = UITableViewAutomaticDimension
        

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateFav()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 7
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! JobDetailTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = "Kompania"
            cell.valueLabel.text = job.kompania
        case 1:
            cell.fieldLabel.text = "Pozita"
            cell.valueLabel.text = job.pozita
        case 2:
            cell.fieldLabel.text = "Qyteti"
            cell.valueLabel.text  = job.qyteti
        case 3:
            cell.fieldLabel.text = "Skadimi"
            cell.valueLabel.text  = job.skadimi
        case 4:
            cell.fieldLabel.text = "Orari"
            cell.valueLabel.text  = job.orari
        case 5:
            cell.fieldLabel.text = "Kontakt"
            cell.valueLabel.text  = job.kontakt
            
        case 6:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
            
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
            
            
        }
        
        cell.textView.text = job.pershkrimi
        
        return cell
    }
    
    

    @IBAction func toggleFavorite(sender: AnyObject) {
        
        if let boolFav = job.isFavorite{
        
        job.isFavorite = !(boolFav as Bool)
        
        } else {
            job.isFavorite = true
        }
        
        updateFav()
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext{
            
            var e:NSError?
            if managedObjectContext.save(&e) != true {
                println("insert error: \(e!.localizedDescription)")
            }
        
        }
    }
    
    func updateFav(){
        
        if let isFavorite = job.isFavorite{
            
            let imgStr = isFavorite.boolValue ? "faved.png" : "unfaved.png"
            
            favButton.setImage(UIImage(named: imgStr), forState: UIControlState.Normal)
        }
    }

}
