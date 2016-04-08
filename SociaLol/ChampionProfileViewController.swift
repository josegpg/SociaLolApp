//
//  ChampionProfileViewController.swift
//  SociaLol
//
//  Created by Jose Piñero on 4/6/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import UIKit

class ChampionProfileViewController: UIViewController {

    // HEADER
    @IBOutlet weak var championImage: UIImageView!
    @IBOutlet weak var championBackground: UIImageView!
    @IBOutlet weak var championName: UILabel!
    @IBOutlet weak var championAttributes: UILabel!
    
    // STATS
    @IBOutlet weak var adBar: StatBarView!
    @IBOutlet weak var lifeBar: StatBarView!
    @IBOutlet weak var apBar: StatBarView!
    @IBOutlet weak var difficultyBar: StatBarView!
    
    var champion: Champion!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up interface
        setUpHeader()
        setUpFeatures()
    }
    
    func setUpHeader() {
        championName.text = champion.name
        championAttributes.text = champion.tags.map { String($0) }.joinWithSeparator(", ")
        
        championImage.image = champion.image
        
        // SET UP PROFILE PICTURE
        var profileImage = UIImage(named: "profile-placeholder")
        if champion.image != nil {
            profileImage = champion.image!
        }
        else {
            // Start the task that will eventually download the image
            RiotAPIClient.sharedInstance().getImage(champion.getImageUrl()) { image in
                
                // update the model, so that the infrmation gets cashed
                CoreDataStackManager.sharedInstance().managedObjectContext.performBlockAndWait {
                    self.champion.image = image
                }
                
                // update the cell later, on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.championImage.image = image
                }
            }
        }
        
        championImage.image = profileImage
        
        // SET UP PROFILE BACKGROUND
        
        if champion.splash != nil {
            championBackground.image = champion.splash!
        }
        else {
            // Start the task that will eventually download the image
            RiotAPIClient.sharedInstance().getImage(champion.getSplashUrl()) { image in
                
                // update the model, so that the infrmation gets cashed
                CoreDataStackManager.sharedInstance().managedObjectContext.performBlockAndWait {
                    self.champion.splash = image
                }
                
                // update the cell later, on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.championBackground.image = image
                }
            }
        }
    }
    
    func setUpFeatures() {
        adBar.drawWithStyle(StatBarView.StatBarType.AdBar, barValue: CGFloat(champion.attack), annimationDelay: 0.0)
        lifeBar.drawWithStyle(StatBarView.StatBarType.LifeBar, barValue: CGFloat(champion.defense), annimationDelay: 0.1)
        apBar.drawWithStyle(StatBarView.StatBarType.ApBar, barValue: CGFloat(champion.magic), annimationDelay: 0.2)
        difficultyBar.drawWithStyle(StatBarView.StatBarType.DifficultyBar, barValue: CGFloat(champion.difficulty), annimationDelay: 0.3)
    }
    
    @IBAction func backAction(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
}