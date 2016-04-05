//
//  SearchViewController.swift
//  SociaLol
//
//  Created by Jose Piñero on 3/16/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    
    var searchedChampions: Bool = false
    var searchedRegions: Int = 0
    var champions: [Champion] = []
    var summoners: [Summoner] = []
    
    // MARK: - Shared Context
    
    lazy var sharedContext: NSManagedObjectContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup keyboard
        textField.delegate = self
        addKeyboardGestureRecognizer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setup button
        findButton.enabled = true
        
        // Clean searched data
        cleanSearchData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
    
    func cleanSearchData() {
        searchedChampions = false
        searchedRegions = 0
        champions = []
        summoners = []
    }
    
    func foundChampions(champions: [Champion]) {
        searchedChampions = true
        self.champions.appendContentsOf(champions)
        
        checkQueryEnded()
    }
    
    func foundSummoners(summoners: [Summoner]) {
        searchedRegions += 1
        self.summoners.appendContentsOf(summoners)
        
        checkQueryEnded()
    }
    
    func searchError(errorMsg: String) {
        
        // Enable the find button to search again
        findButton.enabled = true
        
        // Notify the user about the error
        showGeneralAlert("Error", message: errorMsg, buttonTitle: "Ok")
    }
    
    func checkQueryEnded() {
        // All searches finished
        if searchedRegions == LoL.Region.allValues.count && searchedChampions {
            
            // find button enabled again
            findButton.enabled = true
            
            // Push next VC
            let results = storyboard?.instantiateViewControllerWithIdentifier("SearchResultsViewController") as! SearchResultsViewController
            
            if !champions.isEmpty {
                results.sections.append(champions)
                results.sectionsNames.append("Champions")
            }
            
            if !summoners.isEmpty {
                results.sections.append(summoners)
                results.sectionsNames.append("Summoners")
            }
            
            results.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(results, animated: true)
        }
    }
    
    // MARK: actions

    @IBAction func findChampionOrPlayer(sender: UIButton) {
        
        // Check trimmed textfield
        let trimmedName = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if trimmedName.isEmpty {
            // ERROR EMPTY NAME FIELD
            showGeneralAlert("Error", message: "Name field is empty", buttonTitle: "Ok")
            return
        }
        
        // Disable find button to avoid multiple searchs
        findButton.enabled = false
        cleanSearchData()
        
        // Search Champions
        RiotAPIClient.sharedInstance().searchChampion(trimmedName, successHandler: foundChampions, errorHandler: searchError)
        
        // Search for summoner in every region
        for region in LoL.Region.allValues {
            RiotAPIClient.sharedInstance().searchSummoner(trimmedName, region: region, successHandler: foundSummoners, errorHandler: searchError)
        }
    }

}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide keyboard
        textField.resignFirstResponder()
        
        return true
    }
}