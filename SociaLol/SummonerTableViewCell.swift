//
//  SummonerTableViewCell.swift
//  SociaLol
//
//  Created by Jose Piñero on 3/26/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import UIKit

class SummonerTableViewCell : TaskCancelingTableViewCell {
    
    @IBOutlet weak var summonerImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    // Ranked info
    @IBOutlet weak var rankedBadge: UIImageView!
    @IBOutlet weak var rankedPtsLabel: UILabel!
    @IBOutlet weak var rankedNameLabel: UILabel!
    
    func setUp(summoner: Summoner) {
        // SET UP LABELS
        nameLabel.text = summoner.name
        regionLabel.text = LoL.regionNames[summoner.region]
        levelLabel.text = "Level \(summoner.level)"
        
        // SET UP IMAGE
        
        summonerImage.image = nil
        var profileImage = UIImage(named: "profile-placeholder")!
        profileImage = profileImage.af_imageWithRoundedCornerRadius(2.0)
        
        if summoner.image != nil {
            profileImage = summoner.image!
            self.taskToCancelifCellIsReused = nil
        }
            
        else {
            
            // Start the task that will eventually download the image
            let task = RiotAPIClient.sharedInstance().getImage(summoner.getImageUrl()) { image in
                
                // update the model, so that the infrmation gets cashed
                CoreDataStackManager.sharedInstance().managedObjectContext.performBlockAndWait {
                    summoner.image = image
                }
                
                // update the cell later, on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.summonerImage.image = image
                }
            }
            
            // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
            self.taskToCancelifCellIsReused = task
        }
        
        summonerImage.image = profileImage
    }
    
    func setUpRankedInfo(rankedInfo: RankedInfo?) {
        if let soloInfo = rankedInfo?.soloLeagueInfo {
            rankedBadge.image = UIImage(named: soloInfo.getLeagueImageTitle())
            rankedNameLabel.text = soloInfo.getLeagueCompleteName()
            rankedPtsLabel.text = "\(soloInfo.leaguePoints) Pts"
            rankedPtsLabel.hidden = false
        } else {
            rankedNameLabel.text = "Unranked"
            rankedBadge.image = UIImage(named: "provisional")
            rankedPtsLabel.hidden = true
        }
    }
}