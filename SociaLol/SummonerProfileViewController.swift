//
//  SummonerProfileViewController.swift
//  SociaLol
//
//  Created by Jose Piñero on 4/2/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import UIKit
import CoreData
import EZSwiftExtensions
import SwiftyJSON

class SummonerProfileViewController: UIViewController {
    
    // HEADER OUTLETS
    
    @IBOutlet weak var summonerPicture: UIImageView!
    @IBOutlet weak var summonerBackground: UIImageView!
    
    @IBOutlet weak var summonerName: UILabel!
    @IBOutlet weak var summonerRegion: UILabel!
    @IBOutlet weak var summonerLevel: UILabel!
    
    @IBOutlet weak var favButton: UIButton!
    
    // AVERAGE STATS
    
    @IBOutlet weak var killsLabel: UILabel!
    @IBOutlet weak var deathsLabel: UILabel!
    @IBOutlet weak var assistsLabel: UILabel!
    @IBOutlet weak var goldLabel: UILabel!
    @IBOutlet weak var minionsLabel: UILabel!
    @IBOutlet weak var winrateLabel: UILabel!
    
    // TOP CHAMPIONS OUTLETS
    
    @IBOutlet weak var topChampion1: TopChampionSummaryView!
    @IBOutlet weak var topChampion2: TopChampionSummaryView!
    @IBOutlet weak var topChampion3: TopChampionSummaryView!
    @IBOutlet weak var topChampion4: TopChampionSummaryView!
    
    // RANKED SECTIONS OUTLETS

    @IBOutlet weak var soloLeagueImage: UIImageView!
    @IBOutlet weak var v5LeagueImage: UIImageView!
    @IBOutlet weak var v3LeagueImage: UIImageView!
    
    @IBOutlet weak var soloLeagueName: UILabel!
    @IBOutlet weak var v5LeagueName: UILabel!
    @IBOutlet weak var v3LeagueName: UILabel!
    
    @IBOutlet weak var soloLeaguePoints: UILabel!
    @IBOutlet weak var v5LeaguePoints: UILabel!
    @IBOutlet weak var v3LeaguePoints: UILabel!
    
    // Stored properties
    var storedSummoner: Summoner?
    var summoner: Summoner!
    var recentMatches: [RecentMatch]!
    var rankedInfo: RankedInfo!
    var topChampions: [TopChampion]!
    
    // MARK: - Shared Context
    
    lazy var sharedContext: NSManagedObjectContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up interface
        setUpHeader()
        setUpAverages()
        setUpTopChampions()
        setUpRankedInfo()
        
        // Set up fav button
        if let storedSummoner = RiotAPIClient.sharedInstance().getStoredSummoner(Int(summoner.id)) {
            self.storedSummoner = storedSummoner
        }
        
        favButton.selected = storedSummoner != nil
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
    
    func setUpHeader() {
        summonerName.text = summoner.name
        summonerRegion.text = LoL.regionNames[summoner.region]
        summonerLevel.text = "Level \(summoner.level)"
        
        summonerPicture.image = summoner.image
        
        // SET UP PROFILE PICTURE
        var profileImage = UIImage(named: "profile-placeholder")
        if summoner.image != nil {
            profileImage = summoner.image!
        }
        else {
            // Start the task that will eventually download the image
            RiotAPIClient.sharedInstance().getImage(summoner.getImageUrl()) { image in
                
                // update the model, so that the infrmation gets cashed
                CoreDataStackManager.sharedInstance().managedObjectContext.performBlockAndWait {
                    self.summoner.image = image
                }
                
                // update the cell later, on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.summonerPicture.image = image
                }
            }
        }
        
        summonerPicture.image = profileImage
        
        // SET UP PROFILE BACKGROUND
        var champion = RiotAPIClient.sharedInstance().allChampions.first!
        if !topChampions.isEmpty {
            champion = topChampions.first!.champion
        }
        
        if champion.splash != nil {
            summonerBackground.image = champion.splash!
        }
        else {
            // Start the task that will eventually download the image
            RiotAPIClient.sharedInstance().getImage(champion.getSplashUrl()) { image in
                
                // update the model, so that the infrmation gets cashed
                CoreDataStackManager.sharedInstance().managedObjectContext.performBlockAndWait {
                    champion.splash = image
                }
                
                // update the cell later, on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.summonerBackground.image = image
                }
            }
        }
            
    }
    
    func setUpAverages() {
        var averageKills = 0.0
        var averageDeaths = 0.0
        var averageAssists = 0.0
        var averageGold = 0.0
        var averageMinions = 0.0
        var wins = 0.0

        for match in recentMatches {
            averageKills += match.kills.toDouble
            averageDeaths += match.deaths.toDouble
            averageAssists += match.assists.toDouble
            averageGold += match.gold.toDouble
            averageMinions += match.minions.toDouble
            wins += match.win ? 1 : 0
        }
        
        averageKills = !recentMatches.isEmpty ? round(averageKills/recentMatches.count.toDouble) : 0
        averageDeaths = !recentMatches.isEmpty ? round(averageDeaths/recentMatches.count.toDouble) : 0
        averageAssists = !recentMatches.isEmpty ? round(averageAssists/recentMatches.count.toDouble) : 0
        averageGold = !recentMatches.isEmpty ? round(averageGold/recentMatches.count.toDouble) : 0
        averageMinions = !recentMatches.isEmpty ? round(averageMinions/recentMatches.count.toDouble) : 0
        wins = !recentMatches.isEmpty ? round(wins/recentMatches.count.toDouble * 100) : 0

        killsLabel.text = "\(averageKills.toInt)"
        deathsLabel.text = "\(averageDeaths.toInt)"
        assistsLabel.text = "\(averageAssists.toInt)"
        goldLabel.text = formatGold(averageGold)
        minionsLabel.text = "\(averageMinions.toInt)"
        winrateLabel.text = "\(wins.toInt)%"
    }
    
    func setUpTopChampions() {
        let championViews = [topChampion1, topChampion2, topChampion3, topChampion4]
        
        for (index, topChampion) in topChampions.enumerate() {
            championViews[index].fillWithTopChampion(topChampion)
        }
    }
    
    func setUpRankedInfo() {
        if let soloInfo = rankedInfo.soloLeagueInfo {
            soloLeagueImage.image = UIImage(named: soloInfo.getLeagueImageTitle())
            soloLeagueName.text = soloInfo.getLeagueCompleteName()
            soloLeaguePoints.text = "\(soloInfo.leaguePoints) Pts"
        } else {
            soloLeagueName.text = "Unranked"
            soloLeaguePoints.hidden = true
        }
        
        if let v3Info = rankedInfo.v3LeagueInfo {
            v3LeagueImage.image = UIImage(named: v3Info.getLeagueImageTitle())
            v3LeagueName.text = v3Info.getLeagueCompleteName()
            v3LeaguePoints.text = "\(v3Info.leaguePoints) Pts"
        } else {
            v3LeagueName.text = "Unranked"
            v3LeaguePoints.hidden = true
        }
        
        if let v5Info = rankedInfo.v5LeagueInfo {
            v5LeagueImage.image = UIImage(named: v5Info.getLeagueImageTitle())
            v5LeagueName.text = v5Info.getLeagueCompleteName()
            v5LeaguePoints.text = "\(v5Info.leaguePoints) Pts"
        } else {
            v5LeagueName.text = "Unranked"
            v5LeaguePoints.hidden = true
        }
    }
    
    @IBAction func backAction(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func addToFavoritesAction(sender: UIButton) {
        
        if sender.selected {
            
            sharedContext.deleteObject(storedSummoner!)
            storedSummoner = nil
            
        } else {
            let dictionary = [
                Summoner.Keys.ID : summoner.id,
                Summoner.Keys.Name : summoner.name,
                Summoner.Keys.ProfileIconId : summoner.imageId,
                Summoner.Keys.SummonerLevel : summoner.level
            ]
            
            self.storedSummoner = Summoner(dictionary: JSON(dictionary), region: summoner.region, context: sharedContext)
            
        }
        
        CoreDataStackManager.sharedInstance().saveContext()
        sender.selected = !sender.selected
    }

}

extension SummonerProfileViewController: UITableViewDelegate {
    
}

extension SummonerProfileViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentMatches.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("matchCell") as! RecentMatchTableViewCell
        
        cell.setUp(recentMatches[indexPath.row])
        
        return cell
    }
}

public func formatGold(gold: Double) -> String {
    var vGold = gold
    if vGold > 1000 {
        vGold = vGold/1000.0
        
        return String(format: "%.1fK", vGold)
    }
    
    return gold.toString
}