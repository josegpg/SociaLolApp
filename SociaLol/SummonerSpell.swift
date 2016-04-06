//
//  SummonerSpell.swift
//  SociaLol
//
//  Created by Jose Piñero on 4/6/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON

class SummonerSpell: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var imageGroup: String
    @NSManaged var imageName: String
    @NSManaged var spellDescription: String
    @NSManaged var cooldown: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: JSON, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("SummonerSpell", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        id = dictionary["id"].intValue
        spellDescription = dictionary["description"].stringValue
        cooldown = dictionary["cooldown"].arrayValue.first!.intValue
        imageGroup = dictionary["image"]["group"].stringValue
        imageName = dictionary["image"]["full"].stringValue
        name = dictionary["name"].stringValue
        
    }
    
    override func prepareForDeletion() {
        // Triggers the deletion of the stored image
        image = nil
    }
    
    func getImageUrl() -> String {
        return LoL.getImage(imageGroup, imageName: imageName)
    }
    
    func getImageId() -> String {
        return "\(imageGroup)-\(imageName)"
    }
    
    var image: UIImage? {
        get { return RiotAPIClient.Caches.imageCache.imageWithIdentifier(getImageId()) }
        set { RiotAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: getImageId()) }
    }
    
}