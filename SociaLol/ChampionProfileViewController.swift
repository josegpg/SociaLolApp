//
//  ChampionProfileViewController.swift
//  SociaLol
//
//  Created by Jose Piñero on 4/6/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import UIKit
import EZSwiftExtensions

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
    
    // SPELLS
    @IBOutlet weak var spellSectionHeight: NSLayoutConstraint!
    @IBOutlet weak var spellsView: UIView!
    
    // HISTORY
    @IBOutlet weak var historySectionHeight: NSLayoutConstraint!
    @IBOutlet weak var historyView: UIView!
    
    // TIPS
    @IBOutlet weak var tipSectionHeight: NSLayoutConstraint!
    @IBOutlet weak var tipView: UIView!
    
    // COUNTER TIPS
    @IBOutlet weak var counterTipSectionHeight: NSLayoutConstraint!
    @IBOutlet weak var counterView: UIView!
    
    var champion: Champion!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up interface
        setUpHeader()
        setUpFeatures()
        setUpSpells()
        setUpHistory()
        setUpTips()
        setUpCounterTips()
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
    
    func setUpSpells() {
        let passiveView = getPassiveView(champion.passive, coordinateY: 25.0, width: ez.screenWidth-14)
        var initialY: CGFloat = 25.0 + passiveView.frame.height
        
        spellsView.addSubview(passiveView)
        
        for spell in champion.spells {
            let spellView = getSpellView(spell, coordinateY: initialY, width: ez.screenWidth-14)
            
            spellsView.addSubview(spellView)
            initialY += spellView.frame.height
        }
        
        spellSectionHeight.constant = initialY
    }
    
    func getSpellView(spell: Spell, coordinateY: CGFloat, width: CGFloat) -> UIView {
        let separatorView = UIView(frame: CGRectMake(10, 0, width-20, 1))
        let spellImage = UIImageView(frame: CGRectMake(10, 10, 40, 40))
        let spellName = UILabel(x: 55, y: 10, w: 200, h: 20, fontSize: 15)
        let spellCooldown = UILabel(x: 55, y: 30, w: 200, h: 20, fontSize: 13)
        let descriptionLabel = UILabel(x: 10, y: 55, w: width-20, h: 50, fontSize: 13)
        
        spellName.text = spell.name
        spellName.textColor = UIColor.lightTextColor()
        spellCooldown.text = "Cooldown: \(spell.cooldown)"
        spellCooldown.textColor = UIColor.lightTextColor()
        descriptionLabel.text = spell.descript
        descriptionLabel.textColor = UIColor.lightTextColor()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.fitHeight()
        
        separatorView.backgroundColor = UIColor.lightTextColor()
        setSpellImageView(spellImage, withSpell: spell)
        
        let spellView = UIView(x: 0, y: coordinateY, w: 300, h: descriptionLabel.frame.height + 65)
        spellView.addSubview(separatorView)
        spellView.addSubview(spellImage)
        spellView.addSubview(spellName)
        spellView.addSubview(spellCooldown)
        spellView.addSubview(descriptionLabel)
        
        return spellView
    }
    
    func getPassiveView(passive: Passive, coordinateY: CGFloat, width: CGFloat) -> UIView {
        let spellImage = UIImageView(frame: CGRectMake(10, 10, 40, 40))
        let spellName = UILabel(x: 55, y: 10, w: 200, h: 20, fontSize: 15)
        let passiveLabel = UILabel(x: 55, y: 30, w: 200, h: 20, fontSize: 12)
        let descriptionLabel = UILabel(x: 10, y: 55, w: width-20, h: 50, fontSize: 13)
        
        spellName.text = passive.name
        spellName.textColor = UIColor.lightTextColor()
        passiveLabel.text = "Passive"
        passiveLabel.textColor = UIColor.lightTextColor()
        descriptionLabel.text = passive.descript
        descriptionLabel.textColor = UIColor.lightTextColor()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.fitHeight()
        
        setPassiveImageView(spellImage, withPassive: passive)
        
        let spellView = UIView(x: 0, y: coordinateY, w: 300, h: descriptionLabel.frame.height + 65)
        spellView.addSubview(spellImage)
        spellView.addSubview(spellName)
        spellView.addSubview(passiveLabel)
        spellView.addSubview(descriptionLabel)
        
        return spellView
    }
    
    func setSpellImageView(imageView: UIImageView, withSpell spell: Spell) {
        
        // SET UP IMAGE
        imageView.image = nil
        var imageToSet = UIImage(named: "noitem")!
        
        if spell.image != nil {
            
            imageToSet = spell.image!
            
        } else {
            
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
        }
        
        imageView.image = imageToSet
    }
    
    func setPassiveImageView(imageView: UIImageView, withPassive passive: Passive) {
        
        // SET UP IMAGE
        imageView.image = nil
        var imageToSet = UIImage(named: "noitem")!
        
        if passive.image != nil {
            
            imageToSet = passive.image!
            
        } else {
            
            // Start the task that will eventually download the image
            let _ = RiotAPIClient.sharedInstance().getImage(passive.getImageUrl()) { image in
                
                // update the model, so that the infrmation gets cashed
                CoreDataStackManager.sharedInstance().managedObjectContext.performBlockAndWait {
                    passive.image = image
                }
                
                // update the cell later, on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.image = image
                }
            }
        }
        
        imageView.image = imageToSet
    }
    
    func setUpHistory() {
        let historyLabel = UILabel(x: 10, y: 25, w: ez.screenWidth-34, h: 20, fontSize: 13)
        let attrStr = try! NSAttributedString(
            data: champion.blurb.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        historyLabel.text = attrStr.string
        historyLabel.numberOfLines = 0
        historyLabel.fitHeight()
        historyLabel.textColor = UIColor.lightTextColor()
        
        historyView.addSubview(historyLabel)
        historySectionHeight.constant = 25 + historyLabel.frame.height + 10
    }
    
    func setUpTips() {
        let tipsLabel = UILabel(x: 10, y: 25, w: ez.screenWidth-34, h: 20, fontSize: 13)
        let tipStr = "- " + champion.allyTips.map { String($0) }.joinWithSeparator("\n\n- ")
        
        tipsLabel.text = tipStr
        tipsLabel.numberOfLines = 0
        tipsLabel.textColor = UIColor.lightTextColor()
        tipsLabel.fitHeight()
        
        
        tipView.addSubview(tipsLabel)
        tipSectionHeight.constant = 25 + tipsLabel.frame.height + 10
    }
    
    func setUpCounterTips() {
        let tipsLabel = UILabel(x: 10, y: 25, w: ez.screenWidth-34, h: 20, fontSize: 13)
        let tipStr = "- " + champion.enemyTips.map { String($0) }.joinWithSeparator("\n\n- ")
        
        tipsLabel.text = tipStr
        tipsLabel.numberOfLines = 0
        tipsLabel.textColor = UIColor.lightTextColor()
        tipsLabel.fitHeight()
        
        
        counterView.addSubview(tipsLabel)
        counterTipSectionHeight.constant = 25 + tipsLabel.frame.height + 10
    }
    
    @IBAction func backAction(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
}