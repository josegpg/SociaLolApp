//
//  ChampionTableViewCell.swift
//  SociaLol
//
//  Created by Jose Piñero on 3/26/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import UIKit

class ChampionTableViewCell : TaskCancelingTableViewCell {
    
    @IBOutlet weak var championImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rolesLabel: UILabel!
    
    func setUp(champion: Champion) {
        // SET UP LABELS
        nameLabel.text = champion.name
        rolesLabel.text = champion.tags.map { String($0) }.joinWithSeparator(",")
        
        // SET UP IMAGE
        
        championImage.image = nil
        var profileImage = UIImage(named: "profile-placeholder")!
        profileImage = profileImage.af_imageWithRoundedCornerRadius(2.0)
        
        if champion.image != nil {
            profileImage = champion.image!
            self.taskToCancelifCellIsReused = nil
        }
            
        else {
            
            // Start the task that will eventually download the image
            let task = RiotAPIClient.sharedInstance().getImage(champion.getImageUrl()) { image in
                
                // update the model, so that the infrmation gets cashed
                CoreDataStackManager.sharedInstance().managedObjectContext.performBlockAndWait {
                    champion.image = image
                }
                
                // update the cell later, on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.championImage.image = image
                }
            }
            
            // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
            self.taskToCancelifCellIsReused = task
        }
        
        championImage.image = profileImage
    }
}