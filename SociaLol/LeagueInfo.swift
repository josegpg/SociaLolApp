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
    
    func getLeagueNumber() -> Int {
        var leagueValue = 0
        
        switch tier {
        case "Bronze":
            leagueValue += 2000
        case "Silver":
            leagueValue += 4000
        case "Gold":
            leagueValue += 5000
        case "Platinum":
            leagueValue += 6000
        case "Diamond":
            leagueValue += 7000
        case "Master":
            leagueValue += 8000
        case "Challenger":
            leagueValue += 10000
        default:
            leagueValue += 0
        }
        
        switch division {
        case "I":
            leagueValue += 500
        case "II":
            leagueValue += 400
        case "III":
            leagueValue += 300
        case "IV":
            leagueValue += 200
        case "V":
            leagueValue += 100
        default:
            leagueValue += 0
        }
        
        return leagueValue + leaguePoints
    }
}