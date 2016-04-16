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
    
    struct Keys {
        static let Name = "name"
        static let SummonerLevel = "summonerLevel"
        static let ProfileIconId = "profileIconId"
        static let ID = "id"
    }
    
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
        id = dictionary[Keys.ID].intValue
        imageId = dictionary[Keys.ProfileIconId].intValue
        level = dictionary[Keys.SummonerLevel].intValue
        name = dictionary[Keys.Name].stringValue
        
        self.region = region
    }
    
    override func prepareForDeletion() {
        // Triggers the deletion of the stored image
        image = nil
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

