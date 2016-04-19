//
//  FriendListViewController.swift
//  SociaLol
//
//  Created by Jose Piñero on 4/18/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import UIKit
import EZSwiftExtensions

class FriendListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var allFriends: [Summoner] = []
    var sortedFriends: [Summoner] = []
    var friendsByRegion: [String: [Int]] = [:]
    var rankedInfoById: [Int: RankedInfo] = [:]
    
    var recentMatches: [RecentMatch]!
    var topChampions: [TopChampion]!
    
    let brownColor = UIColor(red: 122/255.0, green: 111/255.0, blue: 102/255.0, alpha: 0.5)
    let grayColor = UIColor(red: 34/255.0, green: 41/255.0, blue: 48/255.0, alpha: 1.0)
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshFriendsInfo()
    }
    
    func refreshFriendsInfo() {
        // Refresh favorite summoners
        allFriends = RiotAPIClient.sharedInstance().getFavSummoners()
        
        for region in LoL.Region.allValues {
            friendsByRegion[region.rawValue] = []
        }
        
        for summoner in allFriends {
            friendsByRegion[summoner.region]?.append(Int(summoner.id))
        }
        
        getInfoFromRegionAtIndex(0)
    }
    
    func getInfoFromRegionAtIndex(regionIndex: Int) {
        var curIndex = regionIndex
        
        while curIndex < LoL.Region.allValues.count {
            let region = LoL.Region.allValues[curIndex]
            let summonersList = friendsByRegion[region.rawValue]!
            if !summonersList.isEmpty {
                RiotAPIClient.sharedInstance().getSummonersRankStats(summonersList, region: region.rawValue, successHandler: foundRankInfos, errorHandler: searchError, regionIndex: curIndex)
                break
            } else {
                curIndex += 1
            }
        }
        
        if curIndex == LoL.Region.allValues.count {
            ez.runThisInMainThread { () -> Void in
                self.sortedFriends = self.allFriends.sort { summoner1, summoner2 in
                    return self.rankedInfoById[Int(summoner1.id)]!.getSoloQueuePoints() > self.rankedInfoById[Int(summoner2.id)]!.getSoloQueuePoints()
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    func foundRankInfos(summoners: [Int], rankedInfos: [RankedInfo], regionIndex: Int) {
        ez.runThisInMainThread { () -> Void in
            for (index, summonerId) in summoners.enumerate() {
                self.rankedInfoById[summonerId] = rankedInfos[index]
            }
            
            self.getInfoFromRegionAtIndex(regionIndex + 1)
        }
    }
    
    func foundRecentMatches(summoner: Summoner, matches: [RecentMatch]) {
        // Store new info
        recentMatches = matches
        
        RiotAPIClient.sharedInstance().getSummonerTopChampions(summoner, successHandler: foundTopChampions, errorHandler: searchError)
    }
    
    func foundTopChampions(summoner: Summoner, champions: [TopChampion]) {
        // Store new info
        topChampions = champions
        
        // Push next VC
        let profile = storyboard?.instantiateViewControllerWithIdentifier("SummonerProfileViewController") as! SummonerProfileViewController
        
        profile.summoner = summoner
        profile.recentMatches = recentMatches
        profile.rankedInfo = rankedInfoById[Int(summoner.id)]
        profile.topChampions = topChampions
        
        profile.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profile, animated: true)
    }
    
    func searchError(errorMsg: String) {
        // Notify the user about the error
        showGeneralAlert("Error", message: errorMsg, buttonTitle: "Ok")
    }
    
    @IBAction func refreshDataAction(sender: UIButton) {
        refreshFriendsInfo()
    }
}

extension FriendListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedFriends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("summonerCell") as! SummonerTableViewCell
        let summoner = sortedFriends[indexPath.row]
        cell.backgroundColor = indexPath.row % 2 == 0 ? brownColor : grayColor
        cell.setUp(summoner)
        cell.setUpRankedInfo(rankedInfoById[Int(summoner.id)]!)
        
        return cell
    }
    
}

extension FriendListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        RiotAPIClient.sharedInstance().getSummonerRecentMatches(sortedFriends[indexPath.row], successHandler: foundRecentMatches, errorHandler: searchError)
    }
    
}