//
//  LeagueInfo.swift
//  SociaLol
//
//  Created by Jose Piñero on 4/2/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import SwiftyJSON

struct LeagueInfo {

    var tier: String
    var division: String
    var leaguePoints: Int
    
    init() {
        tier = "Unranked"
        division = ""
        leaguePoints = 0
    }
    
    init(dictionary: JSON, summonerId: String) {
        
        tier = LeagueInfo.getLeagueName(dictionary["tier"].stringValue)
        division = ""
        leaguePoints = 0
        
        for entry in dictionary["entries"].arrayValue {
            if entry["playerOrTeamId"].stringValue == summonerId {
                division = entry["division"].stringValue
                leaguePoints = entry["leaguePoints"].intValue
            }
        }
        
    }
    
    static func getLeagueName(rawValue: String) -> String {
        return rawValue.lowercaseString.capitalizedString
    }
    
    func getLeagueCompleteName() -> String {
        if tier == "Challenger" || tier == "Master" {
            return tier
        }
        return "\(tier) \(division)"
    }
    
    func getLeagueImageTitle() -> String {
        return "\(tier.lowercaseString)_\(division.lowercaseString)"
    }
}