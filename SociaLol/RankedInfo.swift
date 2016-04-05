//
//  RankedInfo.swift
//  SociaLol
//
//  Created by Jose Piñero on 4/2/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import Foundation
import SwiftyJSON

struct RankedInfo {
    
    var soloLeagueInfo: LeagueInfo?
    var v3LeagueInfo: LeagueInfo?
    var v5LeagueInfo: LeagueInfo?
    
    init(dictionary: JSON) {
        
        for (summonerId, rankedInfo) in dictionary.dictionaryValue {
            for leagueInfo in rankedInfo.arrayValue {
                switch leagueInfo["queue"].stringValue {
                    case LoL.RankedQueues.Solo_5x5.rawValue:
                        soloLeagueInfo = LeagueInfo(dictionary: leagueInfo, summonerId: summonerId)
                    case LoL.RankedQueues.Team_5x5.rawValue:
                        v5LeagueInfo = LeagueInfo(dictionary: leagueInfo, summonerId: summonerId)
                    case LoL.RankedQueues.Team_3x3.rawValue:
                        v3LeagueInfo = LeagueInfo(dictionary: leagueInfo, summonerId: summonerId)
                    default:
                        break
                }
            }
        }
        
    }
}