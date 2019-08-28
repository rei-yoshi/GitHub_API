//
//  GitHub_URL.swift
//  GitHubSearch
//
//  Created by 吉田れい on 2019/08/28.
//  Copyright © 2019 吉田れい. All rights reserved.
//

import Foundation

protocol GitHubEndpoint: APIEndpoint{
    var path :String{ get }
}
private let GitHubURL = NSURL(string: "https://api.github.com/")!

extension GitHubEndpoint {
    var URL: NSURL{
        return NSURL(string: path, relativeTo:GitHubURL as URL)!
    }
    var headers: [String: String]? {
        return [
            "Accept": "application/vnd.github.v3+json",
        ]
    }
}

/**
 - SeeAlso:https://developer.github.com/v3/search/#search-issues-and-pull-requests
 */

 struct SearchIssues: GitHubEndpoint {
    var path = "search/issues"
    var query: [String:String]? {
        return [
            "q"    : searchQuery,
            "page" : String(page),
        ]
    }
    typealias ResponseType = SearchResult<Issue>
    
    let searchQuery: String
    let page: Int
    init(searchQuery: String, page: Int) {
        self.searchQuery = searchQuery
        self.page = page
    }
}




/**
 Parse ISO 8601 format date string
 - SeeAlso: https://developer.github.com/v3/#schema
 */
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) as Calendar?
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    return formatter
}()

struct FormattedDateConverter: JSONValueConverter {
    typealias FromType = String
    typealias ToType = NSDate
    
    private let dateFormatter: DateFormatter
    
    func convert(key: String, value: FromType) throws -> DateConverter.ToType {
        guard let date = dateFormatter.date(from: value) else {
            throw JSONDecodeError.UnexpectedValue(key: key, value: value, message: "Invalid date format for '\(String(describing: dateFormatter.dateFormat)  )'")
        }
        return date as DateConverter.ToType
    }
}


/**
 Search result data
 - SeeAlso: https://developer.github.com/v3/search/
 */
struct SearchResult<ItemType: JSONDecodable>: JSONDecodable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [ItemType]
    
    init(JSON: JSONObject) throws {
        self.totalCount = try JSON.get(key: "total_count")
        self.incompleteResults = try JSON.get(key: "incomplete_results")
        self.items = try JSON.get(key: "items")
    }
}


//各パラメータを宣言し、イニシャライザを使用して初期化

struct Comment: JSONDecodable {
    let id: Int
    let url: URL
    let html_url: URL
    let body: String
   // let user: User
    let created_at: Date
    let updated_at: Date
    
    init(JSON: JSONObject) throws {
        self.id = try JSON.get(key:"id")
        self.url = try JSON.get(url)
        self.html_url = try JSON.get(key :"html_url")
        self.body = try JSON.get(key :"body")
        self.user = try JSON.get(key :"user")
        self.created_at = try JSON.get(key :"created_at", converter: FormattedDateConverter(dateFormatter: dateFormatter))
        self.updated_at = try JSON.get(key :"updated_at", converter: FormattedDateConverter(dateFormatter: dateFormatter))
    }
}




struct Issue : JSONDecodable {
    let URL:URL
    let repository_url:URL
    let labels_url:String
    let comments_url:URL
    let events_url:URL
    let html_url:URL
    let id:Int
    let node_id:Int
    let number :Int
    let title:String
    //let user :User
    let login:String
    let avatar_id:String
    
    init(JSON : JSONObject) throws {
        self.URL = try JSON.get(key : "URL")
        self.repository_url=try JSON.get("")
        
    }
    
    
    
}




