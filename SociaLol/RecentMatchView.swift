//
//  RecentMatchView.swift
//  SociaLol
//
//  Created by Jose Piñero on 4/4/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import UIKit

class RecentMatchView: UIView {
    
    var championPicture: UIImageView!
    var kdaLabel: UILabel!
    var winrateLabel: UILabel!
    var championName: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        championPicture = UIImageView(frame: CGRect(x: 15, y: 5, width: 50, height: 50))
        championPicture.contentMode = .ScaleToFill
        championPicture.hidden = true
        
        kdaLabel = UILabel(frame: CGRect(x: 5, y: 59, width: 70, height: 8))
        kdaLabel.textAlignment = .Center
        kdaLabel.textColor = UIColor.lightTextColor()
        kdaLabel.font = UIFont.systemFontOfSize(10.0)
        kdaLabel.hidden = true
        
        winrateLabel = UILabel(frame: CGRect(x: 5, y: 70, width: 70, height: 8))
        winrateLabel.textAlignment = .Center
        winrateLabel.textColor = UIColor.lightTextColor()
        winrateLabel.font = UIFont.systemFontOfSize(10.0)
        winrateLabel.hidden = true
        
        championName = UILabel(frame: CGRect(x: 15, y: 40, width: 50, height: 15))
        championName.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.85)
        championName.textAlignment = .Center
        championName.textColor = UIColor.lightTextColor()
        championName.font = UIFont.systemFontOfSize(10.0)
        championName.hidden = true
        
        
        addSubview(championPicture)
        addSubview(kdaLabel)
        addSubview(winrateLabel)
        addSubview(championName)
        
        backgroundColor = UIColor.clearColor()
        
        
        championPicture.image = UIImage(named: "profile-placeholder")
        kdaLabel.text = "1 / 2 / 3"
        winrateLabel.text = "Wins 60%"
        championName.text = "Leona"
        
    }
    
    func fillWithTopChampion(topChampion: TopChampion) {
        
        // Set up image
        if topChampion.champion.image != nil {
            championPicture.image = topChampion.champion.image!
        }
        else {
            // Start the task that will eventually download the image
            RiotAPIClient.sharedInstance().getImage(topChampion.champion.getImageUrl()) { image in
                
                // update the model, so that the infrmation gets cashed
                CoreDataStackManager.sharedInstance().managedObjectContext.performBlockAndWait {
                    topChampion.champion.image = image
                }
                
                // update the cell later, on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.championPicture.image = image
                }
            }
        }
        
        
        championName.text = topChampion.champion.name
        
        
        if topChampion.rankedInfo {
            kdaLabel.text = "\(round(topChampion.kills).toInt) / \(round(topChampion.deaths).toInt) / \(round(topChampion.assists).toInt)"
            winrateLabel.text = "Winrate \(round(topChampion.winRate * 100).toInt)%"
        } else {
            kdaLabel.text = "\(topChampion.championPoints)"
            winrateLabel.text = "Points"
        }
        
        championPicture.hidden = false
        championName.hidden = false
        kdaLabel.hidden = false
        winrateLabel.hidden = false
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    
}

