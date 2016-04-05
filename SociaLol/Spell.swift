//
//  Spell.swift
//  SociaLol
//
//  Created by Jose Piñero on 3/18/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON

class Spell: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var imageGroup: String
    @NSManaged var imageName: String
    @NSManaged var cooldown: String
    @NSManaged var descript: String
    @NSManaged var champion: Champion
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(champion: Champion, dictionary: JSON, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Spell", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        name = dictionary["name"].stringValue
        imageGroup = dictionary["image"]["group"].stringValue
        imageName = dictionary["image"]["full"].stringValue
        descript = dictionary["sanitizedDescription"].stringValue
        cooldown = dictionary["cooldownBurn"].stringValue
        
        self.champion = champion
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