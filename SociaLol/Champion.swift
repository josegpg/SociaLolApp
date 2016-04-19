//
//  Champion.swift
//  SociaLol
//
//  Created by Jose Piñero on 3/18/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON

class Champion: NSManagedObject, Comparable {
    
    @NSManaged var id: NSNumber
    @NSManaged var allyTips: NSArray
    @NSManaged var enemyTips: NSArray
    @NSManaged var blurb: String
    @NSManaged var key: String
    @NSManaged var imageGroup: String
    @NSManaged var imageName: String
    @NSManaged var difficulty: NSNumber
    @NSManaged var attack: NSNumber
    @NSManaged var defense: NSNumber
    @NSManaged var magic: NSNumber
    @NSManaged var name: String
    @NSManaged var title: String
    @NSManaged var passive: Passive
    @NSManaged var spells: [Spell]
    @NSManaged var tags: NSArray
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: JSON, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Champion", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        // Dictionary
        id = dictionary["id"].intValue
        blurb = dictionary["lore"].stringValue
        key = dictionary["key"].stringValue
        imageGroup = dictionary["image"]["group"].stringValue
        imageName = dictionary["image"]["full"].stringValue
        difficulty = dictionary["info"]["difficulty"].intValue
        attack = dictionary["info"]["attack"].intValue
        defense = dictionary["info"]["defense"].intValue
        magic = dictionary["info"]["magic"].intValue
        name = dictionary["name"].stringValue
        title = dictionary["title"].stringValue
        
        let _ = Passive(champion: self, dictionary: dictionary["passive"], context: context)
        let _ = dictionary["spells"].arrayValue.map { Spell(champion: self, dictionary: $0, context: context) }
        
        tags = dictionary["tags"].arrayValue.map { $0.stringValue }
        allyTips = dictionary["allytips"].arrayValue.map { $0.stringValue }
        enemyTips = dictionary["enemytips"].arrayValue.map { $0.stringValue }
    }
    
    override func prepareForDeletion() {
        // Triggers the deletion of the stored image
        image = nil
        splash = nil
    }
    
    func getImageUrl() -> String {
        return LoL.getImage(imageGroup, imageName: imageName)
    }
    
    func getImageId() -> String {
        return "\(imageGroup)-\(imageName)"
    }
    
    func getSplashId() -> String {
        return "splash-\(key)"
    }
    
    func getSplashUrl() -> String {
        return "http://ddragon.leagueoflegends.com/cdn/img/champion/splash/\(key)_0.jpg"
    }
    
    var image: UIImage? {
        get { return RiotAPIClient.Caches.imageCache.imageWithIdentifier(getImageId()) }
        set { RiotAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: getImageId()) }
    }
    
    var splash: UIImage? {
        get { return RiotAPIClient.Caches.imageCache.imageWithIdentifier(getSplashId()) }
        set { RiotAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: getSplashId()) }
    }
    
}

func <(lhs: Champion, rhs: Champion) -> Bool {
    return lhs.name < rhs.name
}
