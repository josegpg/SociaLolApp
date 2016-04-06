//
//  Item.swift
//  SociaLol
//
//  Created by Jose Piñero on 4/5/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON

class Item: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var imageGroup: String
    @NSManaged var imageName: String
    @NSManaged var itemDescription: String
    @NSManaged var itemPlainDescription: String
    @NSManaged var cost: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: JSON, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Item", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        id = dictionary["id"].intValue
        itemDescription = dictionary["description"].stringValue
        itemPlainDescription = dictionary["sanitizedDescription"].stringValue
        cost = dictionary["gold"]["total"].intValue
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