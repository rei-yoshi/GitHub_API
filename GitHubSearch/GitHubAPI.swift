//
//  GitHubAPI.swift
//  GitHubSearch
//
//  Created by 吉田れい on 2019/08/28.
//  Copyright © 2019 吉田れい. All rights reserved.
//

import Foundation



enum APIError:Error {
    case EmptyBody
    case UnexpectedResponseType
}
enum HTTPMeehod: String {
    case OPIONS
    case GET
    case HEAD
    case PUT
    case 
}

struct JSONObject {
    
    let JSON: [String: AnyObject]
    
    func get<T>(key: String) throws -> T {
        guard let value = JSON[key] else {
            throw JSONDecodeError.MissingRequiredKey(key)
        }
        guard let typedValue = value as? T else {
            throw JSONDecodeError.UnexpectedType(key: key, expected: T, actual: value.dynamicType)
        }
        return typedValue
    }
    
}

struct User {
    let login: String
    let id: Int
    let avatarURL: NSURL
    let gravatarID: String
    let URL: NSURL
    let receivedEventsURL: NSURL
    let type: String
}

init (JSON:JSONObject) {
    guard
        self.login = JSON["login"] as? String,
        self.id = JSON["id"] as? Int,
        self.avatarURL = (JSON["avatar_url"] as? String).flatMap(NSURL.init(string:)),
        self.gravatarID = JSON["gravatar_id"] as? String,
        self.URL = (JSON["url"] as? String).flatMap(NSURL.init(string:)),
        self.receivedEventsURL = (JSON["received_events_url"] as? String).flatMap(NSURL.init(string:)),
        let type = JSON["type"] as? String
        else{
            return ()
    }
    
    self.login = login
    self.id = id
    self.avatarURL = avatarURL
    self.gravatarID = gravatarID
    self.URL = URL
    self.receivedEventsURL = receivedEventsURL
    self.type = type
}
