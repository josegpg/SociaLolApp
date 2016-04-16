//
//  RecentActivityViewController.swift
//  SociaLol
//
//  Created by Jose Piñero on 4/16/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import UIKit
import EZSwiftExtensions

class RecentActivityViewController: UIViewController {

    var favoriteSummoners: [Summoner] = []
    var friendsActivities: Set<RecentMatch> = []
    var sortedFriendActivities: [RecentMatch] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshRecentGames()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
    
    func refreshRecentGames() {
        // Refresh favorite summoners
        favoriteSummoners = RiotAPIClient.sharedInstance().getFavSummoners()
        
        ez.runThisInMainThread { () -> Void in
            self.friendsActivities.removeAll()
            self.sortedFriendActivities.removeAll()
        }
        
        fetchRecentGames()
    }
    
    func fetchRecentGames() {
        for summoner in favoriteSummoners {
            RiotAPIClient.sharedInstance().getSummonerRecentMatches(summoner, successHandler: foundRecentMatches, errorHandler: searchError)
        }
    }
    
    func foundRecentMatches(summoner: Summoner, recentMatches: [RecentMatch]) {
        ez.runThisInMainThread { () -> Void in
            for match in recentMatches {
                self.friendsActivities.insert(match)
            }
            
            self.sortedFriendActivities = self.friendsActivities.sort()
            self.tableView.reloadData()
        }
    }
    
    func searchError(errorMsg: String) {
        // Notify the user about the error
        showGeneralAlert("Error", message: errorMsg, buttonTitle: "Ok")
    }
    
    @IBAction func refreshDataAction(sender: UIButton) {
        fetchRecentGames()
    }

}

extension RecentActivityViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedFriendActivities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("matchCell") as! RecentMatchTableViewCell
        
        cell.setUp(sortedFriendActivities[indexPath.row])
        cell.addSummonerName(sortedFriendActivities[indexPath.row].summonerName)
        
        return cell
    }
}