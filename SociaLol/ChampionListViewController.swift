//
//  ChampionListViewController.swift
//  SociaLol
//
//  Created by Jose Piñero on 4/16/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import UIKit
import EZSwiftExtensions

class ChampionListViewController: UIViewController {

    var sections: [[Champion]] = []
    var sectionNames: [String] = []
    var sectionIndex: [Character: Int] = [:]
    
    let brownColor = UIColor(red: 25/255.0, green: 32/255.0, blue: 41/255.0, alpha: 0.5)
    let grayColor = UIColor(red: 34/255.0, green: 41/255.0, blue: 48/255.0, alpha: 1.0)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getChampionList()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
    
    func getChampionList() {
        SpecialActivityIndicator.sharedInstance().show(view, msg: "Downloading info")
        RiotAPIClient.sharedInstance().getAllChampions(foundChampions, errorHandler: searchError)
    }
    
    func foundChampions(champions: [Champion]) {
        SpecialActivityIndicator.sharedInstance().hide()
        processChampions(champions)
        
        emptyLabel.hidden = !champions.isEmpty
        tableView.reloadData()
    }
    
    func searchError(errorMsg: String) {
        // Notify the user about the error
        SpecialActivityIndicator.sharedInstance().hide()
        showGeneralAlert("Error", message: errorMsg, buttonTitle: "Ok")
    }
    
    func processChampions(champions: [Champion]) {
        // Sort the champions by name
        let sortedChampions = champions.sort()
        
        for champion in sortedChampions {
            let championName = champion.name
            if let index = sectionIndex[championName[championName.startIndex]] {
                sections[index].append(champion)
            } else {
                let char = championName.uppercaseString[championName.startIndex]
                sectionIndex[char] = sections.count
                sectionNames.append(char.toString)
                sections.append([champion])
            }
        }
    }
    
}

extension ChampionListViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("championCell") as! ChampionTableViewCell
        cell.backgroundColor = indexPath.row % 2 == 0 ? brownColor : grayColor
        cell.setUp(sections[indexPath.section][indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(r: 34, g: 41, b: 48)
        header.textLabel!.textColor = UIColor.whiteColor()
    }
    
}

extension ChampionListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Push next VC
        let profile = storyboard?.instantiateViewControllerWithIdentifier("ChampionProfileViewController") as! ChampionProfileViewController
        
        profile.champion = sections[indexPath.section][indexPath.row]
        
        profile.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profile, animated: true)
    }
    
}