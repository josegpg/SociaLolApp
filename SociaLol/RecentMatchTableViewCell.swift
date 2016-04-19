//
//  RecentMatchView.swift
//  SociaLol
//
//  Created by Jose Piñero on 4/4/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import UIKit
import EZSwiftExtensions

class RecentMatchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var championImage: UIImageView!
    @IBOutlet weak var kdaLabel: UILabel!
    @IBOutlet weak var goldLabel: UILabel!
    @IBOutlet weak var minionsLabel: UILabel!
    
    @IBOutlet weak var spell1Image: UIImageView!
    @IBOutlet weak var spell2Image: UIImageView!
    @IBOutlet weak var item1Image: UIImageView!
    @IBOutlet weak var item2Image: UIImageView!
    @IBOutlet weak var item3Image: UIImageView!
    @IBOutlet weak var item4Image: UIImageView!
    @IBOutlet weak var item5Image: UIImageView!
    @IBOutlet weak var item6Image: UIImageView!
    @IBOutlet weak var item7Image: UIImageView!
    
    @IBOutlet weak var gameTypeLabel: UILabel!
    @IBOutlet weak var gameResultLabel: UILabel!
    @IBOutlet weak var gameDurationLabel: UILabel!
    @IBOutlet weak var gameDateLabel: UILabel!
    
    func setUp(recentMatch: RecentMatch) {
        // SETUP LABELS
        kdaLabel.text = "\(recentMatch.kills)/\(recentMatch.deaths)/\(recentMatch.assists)"
        goldLabel.text = formatGold(Double(recentMatch.gold))
        minionsLabel.text = "\(recentMatch.minions)"
        
        // SETUP GAME TYPE LABEL
        let gameType = recentMatch.matchType.characters.split("_").map { String($0).lowercaseString.capitalizeFirst }.joinWithSeparator(" ")
        gameTypeLabel.text = gameType
        
        // SETUP DATE LABEL
        let date = NSDate(timeIntervalSince1970: Double(recentMatch.date) / 1000.0)
        gameDateLabel.text = date.timePassed()
        
        // SETUP DURATION LABEL
        gameDurationLabel.text = "\(recentMatch.duration/60):\(String(format: "%02d",recentMatch.duration%60))"
        
        // SETUP RESULT LABEL
        gameResultLabel.text = recentMatch.win ? "Win" : "Loss"
        gameResultLabel.textColor = recentMatch.win ? UIColor.greenColor() : UIColor.redColor()
        
        // SET UP ITEMS IMAGE VIEWS
        let itemIds = [recentMatch.itemId0, recentMatch.itemId1, recentMatch.itemId2, recentMatch.itemId3, recentMatch.itemId4, recentMatch.itemId5, recentMatch.itemId6]
        
        let itemImageViews = [item1Image, item2Image, item3Image, item4Image, item5Image, item6Image, item7Image]
        let items = itemIds.map { RiotAPIClient.sharedInstance().searchItem($0) }
        
        for (index, item) in items.enumerate() {
            setItemImageView(itemImageViews[index], withItem: item)
        }
        
        // SET UP SPELLS IMAGE VIEWS
        setSpellImageView(spell1Image, withSpell: RiotAPIClient.sharedInstance().searchSummonerSpell(recentMatch.spellId1))
        setSpellImageView(spell2Image, withSpell: RiotAPIClient.sharedInstance().searchSummonerSpell(recentMatch.spellId2))
        
        // SET UP CHAMPION IMAGE VIEW
        setChampionImageView(championImage, withChampion: RiotAPIClient.sharedInstance().searchChampion(recentMatch.championId))
        
    }
    
    func addSummonerName(name: String, region: String) {
        gameTypeLabel.text = "\(name)(\(region)) - \(gameTypeLabel.text!)"
    }
    
    func setItemImageView(imageView: UIImageView, withItem item: Item!) {
        
        if item == nil {
            return
        }
        
        // SET UP IMAGE
        imageView.image = nil
        var imageToSet = UIImage(named: "noitem")!
        
        if item.image != nil {
            imageToSet = item.image!
        }
            
        else {
            
            // Start the task that will eventually download the image
            let _ = RiotAPIClient.sharedInstance().getImage(item.getImageUrl()) { image in
                
                // update the model, so that the infrmation gets cashed
                CoreDataStackManager.sharedInstance().managedObjectContext.performBlockAndWait {
                    item.image = image
                }
                
                // update the cell later, on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.image = image
                }
            }
            
            // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
            //self.tasksToCancelifCellIsReused?.append(task)
        }
        
        imageView.image = imageToSet
        
    }
    
    func setSpellImageView(imageView: UIImageView, withSpell spell: SummonerSpell) {
        
        // SET UP IMAGE
        imageView.image = nil
        var imageToSet = UIImage(named: "noitem")!
        
        if spell.image != nil {
            imageToSet = spell.image!
        }
            
        else {
            
            // Start the task that will eventually download the image
            let _ = RiotAPIClient.sharedInstance().getImage(spell.getImageUrl()) { image in
                
                // update the model, so that the infrmation gets cashed
                CoreDataStackManager.sharedInstance().managedObjectContext.performBlockAndWait {
                    spell.image = image
                }
                
                // update the cell later, on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.image = image
                }
            }
            
            // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
            //self.tasksToCancelifCellIsReused?.append(task)
        }
        
        imageView.image = imageToSet
    }
    
    func setChampionImageView(imageView: UIImageView, withChampion champion: Champion) {
        
        // SET UP IMAGE
        imageView.image = nil
        var imageToSet = UIImage(named: "profile-placeholder")!
        
        if champion.image != nil {
            imageToSet = champion.image!
        }
            
        else {
            
            // Start the task that will eventually download the image
            let _ = RiotAPIClient.sharedInstance().getImage(champion.getImageUrl()) { image in
                
                // update the model, so that the infrmation gets cashed
                CoreDataStackManager.sharedInstance().managedObjectContext.performBlockAndWait {
                    champion.image = image
                }
                
                // update the cell later, on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.image = image
                }
            }
            
            // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
            //self.tasksToCancelifCellIsReused?.append(task)
        }
        
        imageView.image = imageToSet
    }
}

