//
//  SummonerShort.swift
//  SociaLol
//
//  Created by Jose Piñero on 3/25/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON

class Summoner: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var imageId: NSNumber
    @NSManaged var name: String
    @NSManaged var level: NSNumber
    @NSManaged var region: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: JSON, region: String, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Summoner", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        id = dictionary["id"].intValue
        imageId = dictionary["profileIconId"].intValue
        level = dictionary["summonerLevel"].intValue
        name = dictionary["name"].stringValue
        
        self.region = region
    }
    
    func getImageUrl() -> String {
        return LoL.getProfileImage(Int(imageId))
    }
    
    func getImageId() -> String {
        return "profile-\(imageId)"
    }
    
    var image: UIImage? {
        get { return RiotAPIClient.Caches.imageCache.imageWithIdentifier(getImageId()) }
        set { RiotAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: getImageId()) }
    }
    
}

