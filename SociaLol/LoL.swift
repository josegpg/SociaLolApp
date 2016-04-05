//
//  LoL.swift
//  AKCBLol
//
//  Created by Kirby Bryant on 5/19/15.
//  Copyright (c) 2015 AKCB. All rights reserved.
//

import Foundation

public class LoL {
    
    // MARK: Private Constants
    private let ChampionVersion = "1.2"
    private let CurrentGameVersion = "1.0"
    private let FeaturedGamesVersion = "1.0"
    private let GameVersion = "1.3"
    private let LeagueVersion = "2.5"
    private let LoLStaticDataVersion = "1.2"
    private let LoLStatusVersion = "1.0"
    private let MatchVersion = "2.2"
    private let MatchHistoryVersion = "2.2"
    private let StatsVersion = "1.3"
    private let SummonerVersion = "1.4"
    private let TeamVersion = "2.4"
    
    public var URL = ""
    
    public var api_key = ""
    let https = "https"
    
    var regionRawValue = ""
    var regionBaseURLRawValue = ""
    
    var components = NSURLComponents()
    var queryItems: [NSURLQueryItem] = []
    
    // MARK: Initializers
    
    public init(apiKey: String, region: Region?) {
        api_key = apiKey
        if let region = region {
            regionRawValue = region.rawValue
            regionBaseURLRawValue = getRegionBaseURL(region).rawValue
        }
    }
    
    public func setRegion(region: Region) {
        regionRawValue = region.rawValue
        regionBaseURLRawValue = getRegionBaseURL(region).rawValue
    }
    
    // MARK: Convenience Functions
    
    private func getRegionBaseURL(region: Region) -> RegionBaseURL {
        return RegionBaseURL(rawValue: "\(region.rawValue).api.pvp.net")!
    }
    
    private func setupComponents(scheme: String, hostString: String) {
        components.scheme = scheme
        components.host = hostString
    }
    
    private func addApiKeyQueryItemAndSetComponents() {
        let idQueryItem = NSURLQueryItem(name: "api_key", value: api_key)
        queryItems.append(idQueryItem)
        components.queryItems = queryItems
        queryItems = []
    }
    
    private func createURL(hostString: String) {
        setupComponents(https, hostString: hostString)
        addApiKeyQueryItemAndSetComponents()
        URL = components.URLString.stringByRemovingPercentEncoding!
    }
    
    // MARK: Champion Info
    
    public func getChampions(freeToPlay: Bool?) {
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(ChampionVersion)/champion")
        
        var ftpQueryItem = NSURLQueryItem(name: "freeToPlay", value: "false")
        if let FTP = freeToPlay {
            if FTP == true {
                ftpQueryItem = NSURLQueryItem(name: "freeToPlay", value: "true")
            }
        }
        
        queryItems.append(ftpQueryItem)
        
        createURL(hostString)
        
    }
    
    public func getChampion(championID: Int) {
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(ChampionVersion)/champion/\(championID)")
        
        createURL(hostString)
    }
    
    // MARK: Current Game
    
    public func getcurrentGame(platformID: PlatformID, summonerID: Int) {
        let hostString = String("\(regionBaseURLRawValue)/observer-mode/rest/consumer/getSpectatorGameInfo/\(platformID.rawValue)/\(summonerID)")
        
        createURL(hostString)
    }
    
    // MARK: Featured Games
    
    public func getFeaturedGames() {
        let hostString = String("\(regionBaseURLRawValue)/observer-mode/rest/featured")
        
        createURL(hostString)
    }
    
    // MARK: Recent Games
    
    public func getRecentGames(summonerID: Int) {
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(GameVersion)/game/by-summoner/\(summonerID)/recent")
        
        createURL(hostString)
    }
    
    // MARK: Leagues
    
    public func getLeagueInfo(summonerIDs: [Int]) {
        var hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(LeagueVersion)/league/by-summoner/")
        for id in summonerIDs {
            hostString = hostString + "\(id),"
        }
        hostString.removeAtIndex(hostString.endIndex.predecessor())
        
        createURL(hostString)
        
    }
    
    public func getLeagueInfoEntries(summonerIDs: [Int]) {
        var hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(LeagueVersion)/league/by-summoner/")
        for id in summonerIDs {
            hostString = hostString + "\(id),"
        }
        hostString.removeAtIndex(hostString.endIndex.predecessor())
        hostString += "/entry"
        
        createURL(hostString)
    }
    
    public func getTeamLeagueInfo(teamIDs: [String]) {
        var hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(LeagueVersion)/league/by-team/")
        for id in teamIDs {
            hostString = hostString + "\(id),"
        }
        hostString.removeAtIndex(hostString.endIndex.predecessor())
        
        createURL(hostString)
    }
    
    public func getTeamLeagueInfoEntries(teamIDs: [String]) {
        var hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(LeagueVersion)/league/by-team/")
        for id in teamIDs {
            hostString = hostString + "\(id),"
        }
        hostString.removeAtIndex(hostString.endIndex.predecessor())
        hostString += "/entry"
        
        createURL(hostString)
    }
    
    public func getChallengerLeague(gameType: RankedQueues) {
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(LeagueVersion)/league/challenger")
        
        setupComponents(https, hostString: hostString)
        
        //let typeQueryItem = NSURLQueryItem(name: "type", value: gameType.rawValue)
        createURL(hostString)
    }
    
    public func getMasterLeague(gameType: RankedQueues) {
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(LeagueVersion)/league/master")
        
        setupComponents(https, hostString: hostString)
        
        //let typeQueryItem = NSURLQueryItem(name: "type", value: gameType.rawValue)
        createURL(hostString)
        
    }
    
    // MARK: Static Data
    
    public func getChampionList(champDataOptions: [ChampData]?) {
        
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/champion")
        
        if let champData = champDataOptions {
            var champOptions = ""
            for option in champData {
                champOptions += "\(option.rawValue),"
            }
            champOptions.removeAtIndex(champOptions.endIndex.predecessor())
            let champQueryItem = NSURLQueryItem(name: "champData", value: champOptions)
            queryItems.append(champQueryItem)
        }
        
        createURL(hostString)
        
    }
    
    public func getChampionData(id: Int, champDataOptions: [ChampData]?) {
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/champion/\(id)")
        
        if let champData = champDataOptions {
            var champOptions = ""
            for option in champData {
                champOptions += "\(option.rawValue),"
            }
            champOptions.removeAtIndex(champOptions.endIndex.predecessor())
            let champQueryItem = NSURLQueryItem(name: "champData", value: champOptions)
            queryItems.append(champQueryItem)
        }
        createURL(hostString)
    }
    
    public func getItemList(itemDataOptions: [ItemListData]?) {
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/item")
        
        var itemOptions = ""
        if let itemData = itemDataOptions {
            for option in itemData {
                itemOptions += "\(option.rawValue),"
            }
            itemOptions.removeAtIndex(itemOptions.endIndex.predecessor())
        }
        
        if !itemOptions.isEmpty {
            let itemQueryItem = NSURLQueryItem(name: "itemListData", value: itemOptions)
            queryItems.append(itemQueryItem)
            
        }
        createURL(hostString)
    }
    
    public func getItem(id: Int, itemDataOptions: [ItemData]?) {
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/item/\(id)")
        
        var itemOptions = ""
        if let itemData = itemDataOptions {
            for option in itemData {
                itemOptions += "\(option.rawValue),"
            }
            itemOptions.removeAtIndex(itemOptions.endIndex.predecessor())
        }
        
        if !itemOptions.isEmpty {
            let itemQueryItem = NSURLQueryItem(name: "itemData", value: itemOptions)
            queryItems.append(itemQueryItem)
            
        }
        
        createURL(hostString)
    }
    
    public func getLanguageStrings() {
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/language-strings")
        
        createURL(hostString)
    }
    
    public func getSupportedLanguages() {
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/languages")
        
        createURL(hostString)
    }
    
    public func getMapData() {
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/map")
        
        createURL(hostString)
    }
    
    public func getMasteryList(masteryDataOptions: [MasteryListData]?) {
        
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/mastery")
        
        if let masteryData = masteryDataOptions {
            var masteryOptions = ""
            for option in masteryData {
                masteryOptions += "\(option.rawValue),"
            }
            masteryOptions.removeAtIndex(masteryOptions.endIndex.predecessor())
            let masteryQueryItem = NSURLQueryItem(name: "masteryListData", value: masteryOptions)
            queryItems.append(masteryQueryItem)
        }
        createURL(hostString)
    }
    
    public func getMastery(id: Int, masteryDataOptions: [MasteryData]?) {
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/mastery/\(id)")
        
        if let masteryData = masteryDataOptions {
            var masteryOptions = ""
            for option in masteryData {
                masteryOptions += "\(option.rawValue),"
            }
            masteryOptions.removeAtIndex(masteryOptions.endIndex.predecessor())
            let masteryQueryItem = NSURLQueryItem(name: "masteryData", value: masteryOptions)
            queryItems.append(masteryQueryItem)
        }
        createURL(hostString)
    }
    
    public func getRealmData() {
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/realm")
        
        createURL(hostString)
    }
    
    public func getRuneList(runeDataOptions: [RuneListData]?) {
        
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/rune")
        
        var runeOptions = ""
        if let runeData = runeDataOptions {
            for option in runeData {
                runeOptions += "\(option.rawValue),"
            }
            runeOptions.removeAtIndex(runeOptions.endIndex.predecessor())
        }
        
        if !runeOptions.isEmpty {
            let runeQueryItem = NSURLQueryItem(name: "runeListData", value: runeOptions)
            queryItems.append(runeQueryItem)
            
        }
        createURL(hostString)
    }
    
    public func getRune(id: Int, runeDataOptions: [RuneData]?) {
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/rune/\(id)")
        
        var runeOptions = ""
        if let runeData = runeDataOptions {
            for option in runeData {
                runeOptions += "\(option.rawValue),"
            }
            runeOptions.removeAtIndex(runeOptions.endIndex.predecessor())
        }
        
        if !runeOptions.isEmpty {
            let runeQueryItem = NSURLQueryItem(name: "runeData", value: runeOptions)
            queryItems.append(runeQueryItem)
            
        }
        
        createURL(hostString)
    }
    
    public func getSummonerSpellList(spellDataOptions: [SpellData]?) {
        
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/summoner-spell")
        
        var spellOptions = ""
        if let spellData = spellDataOptions {
            for option in spellData {
                spellOptions += "\(option.rawValue),"
            }
            spellOptions.removeAtIndex(spellOptions.endIndex.predecessor())
        }
        
        if !spellOptions.isEmpty {
            let spellQueryItem = NSURLQueryItem(name: "spellData", value: spellOptions)
            queryItems.append(spellQueryItem)
            
        }
        
        createURL(hostString)
    }
    
    public func getSummonerSpell(id: Int, spellDataOptions: [SpellData]?) {
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/summoner-spell/\(id)")
        
        var spellOptions = ""
        if let spellData = spellDataOptions {
            for option in spellData {
                spellOptions += "\(option.rawValue),"
            }
            spellOptions.removeAtIndex(spellOptions.endIndex.predecessor())
        }
        
        if !spellOptions.isEmpty {
            let spellQueryItem = NSURLQueryItem(name: "spellData", value: spellOptions)
            queryItems.append(spellQueryItem)
            
        }
        createURL(hostString)
    }
    
    public func getVersions() {
        let hostString = String("\(RegionBaseURL.global.rawValue)/api/lol/static-data/\(regionRawValue)/v\(LoLStaticDataVersion)/versions")
        
        createURL(hostString)
    }
    
    // MARK: Shard Status
    public func getShards() {
        let hostString = String("status.leagueoflegends.com/shards")
        setupComponents("http", hostString: hostString)
        URL = components.URLString.stringByRemovingPercentEncoding!
    }
    
    public func getShardStatus() {
        let hostString = String("status.leagueoflegends.com/shards/\(regionRawValue)")
        setupComponents("http", hostString: hostString)
        URL = components.URLString.stringByRemovingPercentEncoding!
        
    }
    
    // MARK: Match Info
    
    public func getMatch(id: Int, includeTimeline: Bool) {
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(MatchVersion)/match/\(id)")
        
        
        var timelineQueryItem = NSURLQueryItem(name: "includeTimeline", value: "false")
        if includeTimeline == true {
            timelineQueryItem = NSURLQueryItem(name: "includeTimeline", value: "true")
        }
        
        queryItems.append(timelineQueryItem)
        
        createURL(hostString)
        
    }
    
    // MARK: Match History
    
    public func getMatchHistory(summonerId: Int, championIds: [Int]?, rankedQueues: [RankedQueues]?, beginIndex: Int?, endIndex: Int?) {
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(MatchHistoryVersion)/matchhistory/\(summonerId)")
        
        if let championIdsList = championIds {
            var champions = ""
            for champion in championIdsList {
                champions += "\(champion),"
            }
            champions.removeAtIndex(champions.endIndex.predecessor())
            let championQueryItem = NSURLQueryItem(name: "championIds", value: champions)
            queryItems.append(championQueryItem)
        }
        
        if let queuesList = rankedQueues {
            var rankedQueues = ""
            for queues in queuesList {
                rankedQueues += "\(queues.rawValue),"
            }
            rankedQueues.removeAtIndex(rankedQueues.endIndex.predecessor())
            let queuesQueryItem = NSURLQueryItem(name: "rankedQueues", value: rankedQueues)
            queryItems.append(queuesQueryItem)
        }
        
        if let beginIndex = beginIndex {
            let beginIndexQueryItem = NSURLQueryItem(name: "beginIndex", value: "\(beginIndex)")
            queryItems.append(beginIndexQueryItem)
        }
        
        if let endIndex = endIndex {
            let endIndexQueryItem = NSURLQueryItem(name: "endIndex", value: "\(endIndex)")
            queryItems.append(endIndexQueryItem)
        }
        
        createURL(hostString)
        
    }
    
    // MARK: Stats
    
    public func getRankedStats(summonerId: Int, season: SEASON?) {
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(StatsVersion)/stats/by-summoner/\(summonerId)/ranked")
        
        if let seasonParameter = season {
            let seasonQueryItem = NSURLQueryItem(name: "season", value: "\(seasonParameter.rawValue)")
            queryItems.append(seasonQueryItem)
        }
        createURL(hostString)
    }
    
    public func getPlayerStatsSummary(summonerId: Int, season: SEASON?) {
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(StatsVersion)/stats/by-summoner/\(summonerId)/summary")
        
        if let seasonParameter = season {
            let seasonQueryItem = NSURLQueryItem(name: "season", value: "\(seasonParameter.rawValue)")
            queryItems.append(seasonQueryItem)
        }
        createURL(hostString)
    }
    
    // MARK: Summoner Info
    
    public func getSummonerObject(summonerName: [String]) {
        var nameString = ""
        for names in summonerName {
            let prunedString = names.stringByReplacingOccurrencesOfString(" ", withString: "")
            nameString += "\(prunedString),"
        }
        if !nameString.isEmpty {
            nameString.removeAtIndex(nameString.endIndex.predecessor())
        }
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(SummonerVersion)/summoner/by-name/\(nameString)")
        
        createURL(hostString)
    }
    
    public func getSummonerObject(summonerIds: [Int]) {
        var idString = ""
        for id in summonerIds {
            idString += "\(id),"
        }
        if !idString.isEmpty {
            idString.removeAtIndex(idString.endIndex.predecessor())
        }
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(SummonerVersion)/summoner/\(idString)")
        
        createURL(hostString)
    }
    
    public func getMasteryPages(summonerIds: [Int]) {
        var idString = ""
        for id in summonerIds {
            idString += "\(id),"
        }
        if !idString.isEmpty {
            idString.removeAtIndex(idString.endIndex.predecessor())
        }
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(SummonerVersion)/summoner/\(idString)/masteries")
        
        createURL(hostString)
    }
    
    public func getSummonerNames(summonerIds: [Int]) {
        var idString = ""
        for id in summonerIds {
            idString += "\(id),"
        }
        if !idString.isEmpty {
            idString.removeAtIndex(idString.endIndex.predecessor())
        }
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(SummonerVersion)/summoner/\(idString)/name")
        
        createURL(hostString)
    }
    
    public func getRunePages(summonerIds: [Int]) {
        var idString = ""
        for id in summonerIds {
            idString += "\(id),"
        }
        if !idString.isEmpty {
            idString.removeAtIndex(idString.endIndex.predecessor())
        }
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(SummonerVersion)/summoner/\(idString)/runes")
        
        createURL(hostString)
    }
    
    // MARK: Teams Info
    
    public func getTeams(summonerIds: [Int]) {
        var idString = ""
        for id in summonerIds {
            idString += "\(id),"
        }
        if !idString.isEmpty {
            idString.removeAtIndex(idString.endIndex.predecessor())
        }
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(TeamVersion)/team/by-summoner/\(idString)")
        
        createURL(hostString)
    }
    
    public func getTeams(teamIds: [String]) {
        var idString = ""
        for id in teamIds {
            idString += "\(id),"
        }
        if !idString.isEmpty {
            idString.removeAtIndex(idString.endIndex.predecessor())
        }
        let hostString = String("\(regionBaseURLRawValue)/api/lol/\(regionRawValue)/v\(TeamVersion)/team/\(idString)")
        
        createURL(hostString)
    }
    
    public func getTopChampions(summonerId: Int, count: Int) {
        let countQueryItem = NSURLQueryItem(name: "count", value: "\(count)")
        queryItems.append(countQueryItem)
        
        let hostString = String("\(regionBaseURLRawValue)/championmastery/location/\(regionPlatformId[regionRawValue]!)/player/\(summonerId)/topchampions")
        
        createURL(hostString)
    }
    
    public static func getImage(group: String, imageName: String) -> String {
        return "https://ddragon.leagueoflegends.com/cdn/6.5.1/img/\(group)/\(imageName)"
    }
    
    public static func getProfileImage(id: Int) -> String {
        return "https://ddragon.leagueoflegends.com/cdn/6.6.1/img/profileicon/\(id).png"
    }
    
    // MARK: Enum Constants
    
    public enum ChampData:String {
        case
        all = "all",
        allytips = "allytips",
        altimages = "altimages",
        blurb = "blurb",
        enemytips = "enemytips",
        image = "image",
        info = "info",
        lore = "lore",
        partype = "partype",
        passive = "passive",
        recommended = "recommended",
        skins = "skins",
        spells = "spells",
        stats = "stats",
        tags = "tags"
    }
    
    public enum ItemData: String {
        case
        all = "all",
        colloq = "colloq",
        consumeOnFull = "consumeOnFull",
        consumed = "consumed",
        depth = "depth",
        from = "from",
        gold = "gold",
        groups = "groups",
        hideFromAll = "hideFromAll",
        image = "image",
        inStore = "inStore",
        into = "into",
        requiredChampion = "requiredChampion",
        sanitizedDescription = "sanitizedDescription",
        specialRecipe = "specialRecipe",
        stacks = "stacks",
        stats = "stats",
        tags = "tags",
        tree = "tree"
    }
    
    public enum ItemListData: String {
        case
        all = "all",
        colloq = "colloq",
        consumeOnFull = "consumeOnFull",
        consumed = "consumed",
        depth = "depth",
        from = "from",
        gold = "gold",
        groups = "groups",
        hideFromAll = "hideFromAll",
        image = "image",
        inStore = "inStore",
        into = "into",
        mapts = "maps",
        requiredChampion = "requiredChampion",
        sanitizedDescription = "sanitizedDescription",
        specialRecipe = "specialRecipe",
        stacks = "stacks",
        stats = "stats",
        tags = "tags",
        tree = "tree"
    }
    
    public enum MasteryListData: String {
        case
        all = "all",
        image = "image",
        masteryTree = "masteryTree",
        prereq = "prereq",
        ranks = "ranks",
        sanitizedDescription = "sanitizedDescription",
        tree = "tree"
    }
    
    public enum MasteryData: String {
        case
        all = "all",
        image = "image",
        masteryTree = "masteryTree",
        prereq = "prereq",
        ranks = "ranks",
        sanitizedDescription = "sanitizedDescription"
    }
    
    public enum RuneListData: String {
        case
        all = "all",
        basic = "basic",
        colloq = "colloq",
        consumeOnFull = "consumeOnFull",
        consumed = "consumed",
        depth = "depth",
        from = "from",
        gold = "gold",
        hideFromAll = "hideFromAll",
        image = "image",
        inStore = "inStore",
        into = "into",
        maps = "maps",
        requiredChampion = "requiredChampion",
        sanitizedDescription = "sanitizedDescription",
        specialRecipe = "specialRecipe",
        stacks = "stacks",
        stats = "stats",
        tags = "tags"
    }
    
    public enum RuneData: String {
        case
        all = "all",
        colloq = "colloq",
        consumeOnFull = "consumeOnFull",
        consumed = "consumed",
        depth = "depth",
        from = "from",
        gold = "gold",
        hideFromAll = "hideFromAll",
        image = "image",
        inStore = "inStore",
        into = "into",
        maps = "maps",
        requiredChampion = "requiredChampion",
        sanitizedDescription = "sanitizedDescription",
        specialRecipe = "specialRecipe",
        stacks = "stacks",
        stats = "stats",
        tags = "tags"
    }
    
    public enum SpellData: String {
        case
        all = "all",
        cooldown = "cooldown",
        cooldownBurn = "cooldownBurn",
        cost = "cost",
        costBurn = "costBurn",
        costType = "costType",
        effect = "effect",
        effectBurn = "effectBurn",
        image = "image",
        key = "key",
        leveltip = "leveltip",
        maxrank = "maxrank",
        modes = "modes",
        range = "range",
        rangeBurn = "rangeBurn",
        resource = "resource",
        sanitizedDescription = "sanitizedDescription",
        sanitizedTooltip = "sanitizedTooltip",
        tooltip = "tooltip",
        vars = "vars"
    }
    
    public enum Region: String {
        case
        br = "br",
        eune = "eune",
        euw = "euw",
        kr = "kr",
        lan = "lan",
        las = "las",
        na = "na",
        oce = "oce",
        tr = "tr",
        ru = "ru"
        
        static let allValues = [br, eune, euw, kr, lan, las, na, oce, tr, ru]
    }
    
    static var regionNames: [String: String] = [
        Region.br.rawValue : "Brazil",
        Region.eune.rawValue : "Europe Nordic & East",
        Region.euw.rawValue : "Europe West",
        Region.kr.rawValue : "Republic of Korea",
        Region.lan.rawValue : "Latin America North",
        Region.las.rawValue : "Latin America South",
        Region.na.rawValue : "North America",
        Region.oce.rawValue : "Oceania",
        Region.tr.rawValue : "Turkey",
        Region.ru.rawValue : "Russia"
    ]
    
    var regionPlatformId: [String: PlatformID] = [
        Region.br.rawValue : PlatformID.BR1,
        Region.eune.rawValue : PlatformID.EUN1,
        Region.euw.rawValue : PlatformID.EUW1,
        Region.kr.rawValue : PlatformID.KR,
        Region.lan.rawValue : PlatformID.LA1,
        Region.las.rawValue : PlatformID.LA2,
        Region.na.rawValue : PlatformID.NA1,
        Region.oce.rawValue : PlatformID.OC1,
        Region.tr.rawValue : PlatformID.TR1,
        Region.ru.rawValue : PlatformID.RU
    ]
    
    public enum RankedQueues:String {
        case
        Solo_5x5 = "RANKED_SOLO_5x5",
        Team_3x3 = "RANKED_TEAM_3x3",
        Team_5x5 = "RANKED_TEAM_5x5"
    }
    
    public enum SEASON:String {
        case
        three = "SEASON3",
        four2014 = "SEASON2014",
        five2015 = "SEASON2015"
    }
    
    public enum RegionBaseURL: String {
        case
        br = "br.api.pvp.net",
        eune = "eune.api.pvp.net",
        euw = "euw.api.pvp.net",
        kr = "kr.api.pvp.net",
        lan = "lan.api.pvp.net",
        las = "las.api.pvp.net",
        na = "na.api.pvp.net",
        oce = "oce.api.pvp.net",
        tr = "tr.api.pvp.net",
        ru = "ru.api.pvp.net",
        global = "global.api.pvp.net"
        
    }
    
    public enum PlatformID: String {
        case
        NA1 = "NA1",
        BR1 = "BR1",
        LA1 = "LA1",
        LA2 = "LA2",
        OC1 = "OC1",
        EUN1 = "EUN1",
        TR1 = "TR1",
        RU = "RU",
        EUW1 = "EUW1",
        KR = "KR"
    }
    
}

// MARK: - URLStringConvertible

/**
Types adopting the `URLStringConvertible` protocol can be used to construct URL strings, which are then used to construct URL requests.
*/
public protocol URLStringConvertible {
    /**
     A URL that conforms to RFC 2396.
     Methods accepting a `URLStringConvertible` type parameter parse it according to RFCs 1738 and 1808.
     See http://tools.ietf.org/html/rfc2396
     See http://tools.ietf.org/html/rfc1738
     See http://tools.ietf.org/html/rfc1808
     */
    var URLString: String { get }
}

extension String: URLStringConvertible {
    public var URLString: String {
        return self
    }
}

extension NSURL: URLStringConvertible {
    public var URLString: String {
        return absoluteString
    }
}

extension NSURLComponents: URLStringConvertible {
    public var URLString: String {
        return URL!.URLString
    }
}