//
//  Loan.swift
//  OfertaPune
//
//  Created by Armend H on 21/08/15.
//  Copyright (c) 2015 Armend. All rights reserved.
//

import Foundation
import CoreData

class Job:NSManagedObject {
    
    @NSManaged var kompania:String!
    @NSManaged var pozita:String!
    @NSManaged var qyteti:String!
    @NSManaged var skadimi:String!
    @NSManaged var id:NSNumber!
    @NSManaged var orari:String!
    @NSManaged var kontakt:String!
    @NSManaged var pershkrimi:String!
    @NSManaged var imgurl:String!
    @NSManaged var tags:String!
    @NSManaged var isFavorite:NSNumber!
    
}