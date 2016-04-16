//
//  RiotAPIClient.swift
//  SociaLol
//
//  Created by Jose Piñero on 3/18/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import AlamofireImage
import CoreData

class RiotAPIClient: NSObject {
    
    let apiKey = "87785ede-42ac-4dd3-b62c-a6b070a40940"
    
    var allChampions: [Champion] = []
    var allItems: [Item] = []
    var allSummonerSpells: [SummonerSpell] = []
    
    var temporaryContext: NSManagedObjectContext!
    
    lazy var sharedContext: NSManagedObjectContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> RiotAPIClient {
        
        struct Singleton {
            static var sharedInstance = RiotAPIClient()
        }
        
        return Singleton.sharedInstance
    }
    
    override init() {
        super.init()
        
        // Fetch stored champions
        allChampions = fetchAllStoredChampions()
        allItems = fetchAllStoredItems()
        allSummonerSpells = fetchAllStoredSummonerSpells()
        
        // Set the temporary context
        temporaryContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = sharedContext.persistentStoreCoordinator
    }
    
    func fetchAllStoredChampions() -> [Champion] {
        let fetchRequest = NSFetchRequest(entityName: "Champion")
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Champion]
        } catch let error as NSError {
            print("Error in fetchAllChampions(): \(error)")
            return [Champion]()
        }
    }
    
    func fetchAllStoredItems() -> [Item] {
        let fetchRequest = NSFetchRequest(entityName: "Item")
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Item]
        } catch let error as NSError {
            print("Error in fetchAllItems(): \(error)")
            return [Item]()
        }
    }
    
    func fetchAllStoredSummonerSpells() -> [SummonerSpell] {
        let fetchRequest = NSFetchRequest(entityName: "SummonerSpell")
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [SummonerSpell]
        } catch let error as NSError {
            print("Error in fetchAllSummonerSpells(): \(error)")
            return [SummonerSpell]()
        }
    }
    
    func fetchAllStoredSummoners() -> [Summoner] {
        let fetchRequest = NSFetchRequest(entityName: "Summoner")
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Summoner]
        } catch let error as NSError {
            print("Error in fetchAllChampions(): \(error)")
            return [Summoner]()
        }
    }
    
    func getFavSummoners() -> [Summoner] {
        return fetchAllStoredSummoners()
    }
    
    func getStoredSummoner(summonerId: Int) -> Summoner? {
        let summoners = fetchAllStoredSummoners()
        for summoner in summoners {
            if summoner.id == summonerId {
                return summoner
            }
        }
        
        return nil
    }
    
    func searchSummoner(name: String, region: LoL.Region, successHandler: (players: [Summoner]) -> Void, errorHandler: (errorMsg: String) -> Void) {
        
        let lolHelper = LoL(apiKey: apiKey, region: region)
        lolHelper.getSummonerObject([name])
        
        Alamofire.request(.GET, lolHelper.URL, parameters: nil)
            .responseSwiftyJSON ({ (request, response, json, error) in
            
                if let _ = error {
                    
                    errorHandler(errorMsg: "Summoner search failed in region \(region)")
                    
                } else {
                    
                    var summoners: [Summoner] = []
                    for (_, summ) in json {
                        if summ["status_code"].intValue != 404 {
                            summoners.append(Summoner(dictionary: summ, region: region.rawValue, context: self.temporaryContext))
                        }
                    }
                    successHandler(players: summoners)
                    
                }
            })
    
    }
    
    func searchChampion(championId: Int) -> Champion {
        return allChampions.filter { champion in
            return champion.id == championId
        }.first!
    }
    
    func searchItem(itemId: Int) -> Item? {
        let items = allItems.filter { item in return item.id == itemId }
        if items.count == 0 {
            return nil
        }
        return items.first!
    }
    
    func searchSummonerSpell(summonerSpellId: Int) -> SummonerSpell {
        return allSummonerSpells.filter { spell in
            return spell.id == summonerSpellId
            }.first!
    }
    
    func searchChampion(name: String, successHandler: (champions: [Champion]) -> Void, errorHandler: (errorMsg: String) -> Void) {
        if allChampions.isEmpty {
            downloadChampions(errorHandler) {
                successHandler(champions: self.filterChampions(name))
            }
        } else {
            successHandler(champions: filterChampions(name))
        }
    }
    
    func filterChampions(name: String) -> [Champion] {
        return allChampions.filter { champion in
            let words = name.characters.split(" ").map(String.init)
            for word in words {
                if champion.name.containsString(word) {
                    return true
                }
            }
            
            return false
        }
    }
    
    func downloadChampions(errorHandler: ((errorMsg: String) -> Void)?, successHandler: (Void -> Void)?) {
        
        let lolHelper = LoL(apiKey: apiKey, region: LoL.Region.na)
        lolHelper.getChampionList([LoL.ChampData.all])
        //lolHelper.getAllChampions()
        
        Alamofire.request(.GET, lolHelper.URL, parameters: nil)
            .responseSwiftyJSON ({ (request, response, json, error) in
                
                if let _ = error {
                    // Report error if required
                    if let errorHandler = errorHandler {
                        errorHandler(errorMsg: "Champion search failed")
                    }
                } else {
                    
                    self.allChampions = []
                    for (_, champ) in json["data"].dictionaryValue {
                        let champion = Champion(dictionary: champ, context: self.sharedContext)
                        self.allChampions.append(champion)
                    }
                    
                    // Save the context
                    CoreDataStackManager.sharedInstance().saveContext()
                    
                    // Report success if required
                    if let successHandler = successHandler {
                        successHandler()
                    }
                }
                
            })
        
    }
    
    func downloadItems(errorHandler: ((errorMsg: String) -> Void)?, successHandler: (Void -> Void)?) {
        let lolHelper = LoL(apiKey: apiKey, region: LoL.Region.na)
        lolHelper.getItemList([LoL.ItemListData.all])
        
        Alamofire.request(.GET, lolHelper.URL, parameters: nil)
            .responseSwiftyJSON ({ (request, response, json, error) in
                
                if let _ = error {
                    // Report error if required
                    if let errorHandler = errorHandler {
                        errorHandler(errorMsg: "Item search failed")
                    }
                } else {
                    
                    self.allItems = []
                    for (_, item) in json["data"].dictionaryValue {
                        let newItem = Item(dictionary: item, context: self.sharedContext)
                        self.allItems.append(newItem)
                    }
                    
                    // Save the context
                    CoreDataStackManager.sharedInstance().saveContext()
                    
                    // Report success if required
                    if let successHandler = successHandler {
                        successHandler()
                    }
                }
                
            })
    }
    
    func downloadSummonerSpells(errorHandler: ((errorMsg: String) -> Void)?, successHandler: (Void -> Void)?) {
        let lolHelper = LoL(apiKey: apiKey, region: LoL.Region.na)
        lolHelper.getSummonerSpellList([LoL.SpellData.all])
        
        Alamofire.request(.GET, lolHelper.URL, parameters: nil)
            .responseSwiftyJSON ({ (request, response, json, error) in
                
                if let _ = error {
                    // Report error if required
                    if let errorHandler = errorHandler {
                        errorHandler(errorMsg: "Summoner Spells search failed")
                    }
                } else {
                    
                    self.allSummonerSpells = []
                    for (_, item) in json["data"].dictionaryValue {
                        let newItem = SummonerSpell(dictionary: item, context: self.sharedContext)
                        self.allSummonerSpells.append(newItem)
                    }
                    
                    // Save the context
                    CoreDataStackManager.sharedInstance().saveContext()
                    
                    // Report success if required
                    if let successHandler = successHandler {
                        successHandler()
                    }
                }
                
            })
    }
    
    func getImage(path: String, successHandler: (image: UIImage) -> Void) -> NSURLSessionTask {
        
        return
            Alamofire.request(.GET, path).responseImage { response in
                if let image = response.result.value {
                    successHandler(image: image.af_imageWithRoundedCornerRadius(2.0))
                }
            }
            .task
    }
    
    func getSummonerRecentMatches(summoner: Summoner, successHandler: (summoner: Summoner, matches: [RecentMatch]) -> Void, errorHandler: (errorMsg: String) -> Void) {
        
        let lolHelper = LoL(apiKey: apiKey, region: LoL.Region(rawValue: summoner.region))
        lolHelper.getRecentGames(Int(summoner.id))
        
        Alamofire.request(.GET, lolHelper.URL, parameters: nil)
            .responseSwiftyJSON ({ (request, response, json, error) in
                
                if let _ = error {
                    
                    errorHandler(errorMsg: "Summoner fetch info failed")
                    
                } else {
                    
                    let matches = json["games"].arrayValue.map {
                        RecentMatch(dictionary: $0, summonerId: Int(summoner.id), summonerName: summoner.name)
                    }
                    successHandler(summoner: summoner, matches: matches)
                }
            })
        
    }
    
    func getSummonerRankStats(summoner: Summoner, successHandler: (summoner: Summoner, info: RankedInfo) -> Void, errorHandler: (errorMsg: String) -> Void) {
        
        let lolHelper = LoL(apiKey: apiKey, region: LoL.Region(rawValue: summoner.region))
        lolHelper.getLeagueInfoEntries([Int(summoner.id)])
        
        Alamofire.request(.GET, lolHelper.URL, parameters: nil)
            .responseSwiftyJSON ({ (request, response, json, error) in
                
                if let _ = error {
                    
                    errorHandler(errorMsg: "Summoner fetch info failed")
                    
                } else {
                    
                    let rankedInfo = RankedInfo(dictionary: json)
                    successHandler(summoner: summoner, info: rankedInfo)
                    
                }
            })
        
    }
    
    func getSummonerTopChampions(summoner: Summoner, successHandler: (summoner: Summoner, topChampions: [TopChampion]) -> Void, errorHandler: (errorMsg: String) -> Void) {
        
        let lolHelper = LoL(apiKey: apiKey, region: LoL.Region(rawValue: summoner.region))
        lolHelper.getRankedStats(Int(summoner.id), season: nil)
        
        
        Alamofire.request(.GET, lolHelper.URL, parameters: nil)
            .responseSwiftyJSON ({ (request, response, json, error) in
                
                if let _ = error {
                    
                    errorHandler(errorMsg: "Summoner fetch info failed")
                    
                } else {
                    var topChampions: [TopChampion] = []
                    for session in json["champions"].arrayValue {
                        let championId = session["id"].intValue
                        
                        if championId != 0 {
                            let champion = self.searchChampion(championId)
                            let sessions = session["stats"]["totalSessionsPlayed"].doubleValue
                            let kills = session["stats"]["totalChampionKills"].doubleValue / sessions
                            let deaths = session["stats"]["totalDeathsPerSession"].doubleValue / sessions
                            let assists = session["stats"]["totalAssists"].doubleValue / sessions
                            let winRate = session["stats"]["totalSessionsWon"].doubleValue / sessions
                            
                            topChampions.append(TopChampion(champion: champion, kills: kills, deaths: deaths, assists: assists, winRate: winRate, usages: Int(sessions), championPoints: 0, rankedInfo: true))
                        }
                    }
                    
                    let top4Champions = topChampions.sort { $0.usages > $1.usages }.prefix(4)
                    
                    if !top4Champions.isEmpty {
                        successHandler(summoner: summoner, topChampions: Array(top4Champions))
                    } else {
                        // In case that there are not ranked champions then use top mastery champions
                        self.getSummonerTopChampionsAuxiliar(summoner, successHandler: successHandler, errorHandler: errorHandler)
                    }
                }
            })
        
    }
    
    func getSummonerTopChampionsAuxiliar(summoner: Summoner, successHandler: (summoner: Summoner, topChampions: [TopChampion]) -> Void, errorHandler: (errorMsg: String) -> Void) {
        
        let lolHelper = LoL(apiKey: apiKey, region: LoL.Region(rawValue: summoner.region))
        lolHelper.getTopChampions(Int(summoner.id), count: 4)
        
        
        Alamofire.request(.GET, lolHelper.URL, parameters: nil)
            .responseSwiftyJSON ({ (request, response, json, error) in
                
                if let _ = error {
                    
                    errorHandler(errorMsg: "Summoner fetch info failed")
                    
                } else {
                    var topChampions: [TopChampion] = []
                    for (index, champion) in json.arrayValue.enumerate() {
                        let championId = champion["championId"].intValue
                        let championPoints = champion["championPoints"].intValue
                        
                        if championId != 0 {
                            let champion = self.searchChampion(championId)
                            
                            topChampions.append(TopChampion(champion: champion, kills: 0, deaths: 0, assists: 0, winRate: 0, usages: 10-index, championPoints: championPoints, rankedInfo: false))
                        }
                    }
                    
                    let top4Champions = topChampions.sort { $0.usages > $1.usages }
                    
                    successHandler(summoner: summoner, topChampions: Array(top4Champions))
                }
        })
        
    }
    
}
