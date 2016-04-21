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
    var firstRequestArrived: Bool = false
    var shownError: Bool = false
    var msgError: String = ""
    var finishedRequests: Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshRecentGames()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
    
    func refreshRecentGames() {
        // Refresh favorite summoners
        favoriteSummoners = RiotAPIClient.sharedInstance().getFavSummoners()
        
        fetchRecentGames()
    }
    
    func fetchRecentGames() {
        firstRequestArrived = false
        finishedRequests = 0
        shownError = false
        
        SpecialActivityIndicator.sharedInstance().show(view, msg: "Loading matches")
        for summoner in favoriteSummoners {
            RiotAPIClient.sharedInstance().getSummonerRecentMatches(summoner, successHandler: foundRecentMatches, errorHandler: searchError)
        }
    }
    
    func foundRecentMatches(summoner: Summoner, recentMatches: [RecentMatch]) {
        finishedRequests += 1
        
        ez.runThisInMainThread { () -> Void in
            
            if !self.firstRequestArrived {
                self.firstRequestArrived = true
                
                self.friendsActivities.removeAll()
                self.sortedFriendActivities.removeAll()
            }
            
            for match in recentMatches {
                self.friendsActivities.insert(match)
            }
            
            self.checkQueryFinished()
        }
    }
    
    func searchError(errorMsg: String) {
        finishedRequests += 1
        shownError = true
        msgError = errorMsg
    }
    
    func checkQueryFinished() {
        if finishedRequests == favoriteSummoners.count && !shownError {
            SpecialActivityIndicator.sharedInstance().hide()
            
            sortedFriendActivities = friendsActivities.sort()
            emptyLabel.hidden = !friendsActivities.isEmpty
            tableView.reloadData()
        }
        
        if finishedRequests == favoriteSummoners.count && shownError {
            SpecialActivityIndicator.sharedInstance().hide()
            
            // Notify the user about the error
            showGeneralAlert("Error", message: msgError, buttonTitle: "Ok")
        }
    }
    
    @IBAction func refreshDataAction(sender: UIButton) {
        refreshRecentGames()
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
        
        let recentMatch = sortedFriendActivities[indexPath.row]
        cell.setUp(recentMatch)
        cell.addSummonerName(recentMatch.summonerName, region: recentMatch.summonerRegion.uppercaseString)
        
        return cell
    }
}