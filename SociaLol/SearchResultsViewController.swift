//
//  SearchResultsViewController.swift
//  SociaLol
//
//  Created by Jose Piñero on 3/17/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController {
    
    var sections: [[AnyObject]] = []
    var sectionsNames: [String] = []
    
    var recentMatches: [RecentMatch]!
    var rankedInfo: RankedInfo!
    var topChampions: [TopChampion]!
    
    let brownColor = UIColor(red: 25/255.0, green: 32/255.0, blue: 41/255.0, alpha: 0.5)
    let grayColor = UIColor(red: 34/255.0, green: 41/255.0, blue: 48/255.0, alpha: 1.0)
    
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyLabel.hidden = !sectionsNames.isEmpty
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
    
    func foundRecentMatches(summoner: Summoner, matches: [RecentMatch]) {
        // Store new info
        recentMatches = matches
        
        RiotAPIClient.sharedInstance().getSummonerRankStats(summoner, successHandler: foundRankedInfo, errorHandler: searchError)
    }
    
    func foundRankedInfo(summoner: Summoner, info: RankedInfo) {
        // Store new info
        rankedInfo = info
        
        RiotAPIClient.sharedInstance().getSummonerTopChampions(summoner, successHandler: foundTopChampions, errorHandler: searchError)
    }
    
    func foundTopChampions(summoner: Summoner, champions: [TopChampion]) {
        // Store new info
        topChampions = champions
        
        // Push next VC
        let profile = storyboard?.instantiateViewControllerWithIdentifier("SummonerProfileViewController") as! SummonerProfileViewController
       
        profile.summoner = summoner
        profile.recentMatches = recentMatches
        profile.rankedInfo = rankedInfo
        profile.topChampions = topChampions
        
        SpecialActivityIndicator.sharedInstance().hide()
        profile.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profile, animated: true)
    }
    
    func searchError(errorMsg: String) {
        SpecialActivityIndicator.sharedInstance().hide()
        
        // Notify the user about the error
        showGeneralAlert("Error", message: errorMsg, buttonTitle: "Ok")
    }
    
    @IBAction func backAction(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
}

extension SearchResultsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let info = sections[indexPath.section][indexPath.row]
        
        if let summoner = info as? Summoner {
            let cell = tableView.dequeueReusableCellWithIdentifier("summonerCell") as! SummonerTableViewCell
            cell.backgroundColor = indexPath.row % 2 == 0 ? brownColor : grayColor
            cell.setUp(summoner)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("championCell") as! ChampionTableViewCell
        cell.backgroundColor = indexPath.row % 2 == 0 ? brownColor : grayColor
        cell.setUp(info as! Champion)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsNames[section]
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
}

extension SearchResultsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let summoner = sections[indexPath.section][indexPath.row] as? Summoner {
        
            SpecialActivityIndicator.sharedInstance().show(view, msg: "Fetching info...")
            RiotAPIClient.sharedInstance().getSummonerRecentMatches(summoner, successHandler: foundRecentMatches, errorHandler: searchError)
            
        } else if let champion = sections[indexPath.section][indexPath.row] as? Champion {
            
            // Push next VC
            let profile = storyboard?.instantiateViewControllerWithIdentifier("ChampionProfileViewController") as! ChampionProfileViewController
            
            profile.champion = champion
            
            profile.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(profile, animated: true)
        }
    }
    
}