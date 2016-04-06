//
//  RecentMatch.swift
//  SociaLol
//
//  Created by Jose Piñero on 4/2/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import SwiftyJSON

struct RecentMatch {
    
    var championId: Int
    var date: Int64 // createDate
    var spellId1: Int // spell1
    var spellId2: Int // spell2
    var matchType: String // subType
    
    // STATS stats
    var assists: Int
    var kills: Int //championsKilled
    var deaths: Int // numDeaths
    var gold: Int // goldEarned
    var level: Int
    var minions: Int // minionsKilled
    var duration: Int // timePlayed
    var win: Bool
    
    var itemId0: Int // item0
    var itemId1: Int // item1
    var itemId2: Int // item2
    var itemId3: Int // item3
    var itemId4: Int // item4
    var itemId5: Int // item5
    var itemId6: Int // item6
    
    init(dictionary: JSON) {
        championId = dictionary["championId"].intValue
        date = dictionary["createDate"].int64Value
        spellId1 = dictionary["spell1"].intValue
        spellId2 = dictionary["spell2"].intValue
        matchType = dictionary["subType"].stringValue
        
        assists = dictionary["stats"]["assists"].intValue
        kills = dictionary["stats"]["championsKilled"].intValue
        deaths = dictionary["stats"]["numDeaths"].intValue
        gold = dictionary["stats"]["goldEarned"].intValue
        level = dictionary["stats"]["level"].intValue
        minions = dictionary["stats"]["minionsKilled"].intValue + dictionary["stats"]["neutralMinionsKilled"].intValue
        duration = dictionary["stats"]["timePlayed"].intValue
        win = dictionary["stats"]["win"].boolValue
        
        itemId0 = dictionary["stats"]["item0"].intValue
        itemId1 = dictionary["stats"]["item1"].intValue
        itemId2 = dictionary["stats"]["item2"].intValue
        itemId3 = dictionary["stats"]["item3"].intValue
        itemId4 = dictionary["stats"]["item4"].intValue
        itemId5 = dictionary["stats"]["item5"].intValue
        itemId6 = dictionary["stats"]["item6"].intValue
        
    }
}