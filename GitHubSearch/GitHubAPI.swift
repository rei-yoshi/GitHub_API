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
enum APIResult<Response>{
    case Success(Response)
    case Failure(Error)
}

enum HTTPMethod: String {
    case OPIONS
    case GET
    case HEAD
    case PUT
    case DELETE
    case TRACE
    case CONNECT
}

protocol APIEndpoint {
    var URL:NSURL { get }
    var method : HTTPMethod { get }
    var query  : Parameters? { get }
    var headers : Parameters? { get }
    associatedtype ResponseType : JSONDecodable
}

extension APIEndpoint {
    var method: HTTPMethod {
        return .GET
    }
    var query: Parameters? {
        return nil
    }
    var headers: Parameters? {
        return nil
    }
}



extension APIEndpoint {
    private var URLRequest: NSURLRequest {
        let components = NSURLComponents(url: URL as URL, resolvingAgainstBaseURL: true)
        components?.queryItems = query?.parameters.map(NSURLQueryItem.init) as [URLQueryItem]?
        let req = NSMutableURLRequest(url: components?.url ?? URL as URL)
        req.httpMethod = method.rawValue
        for case let (key, value?) in headers?.parameters ?? [:] {
            req.addValue(value, forHTTPHeaderField: key)
        }
        return req
    }
    func request(session: URLSession, callback: @escaping (APIResult<ResponseType>) -> Void) ->
        URLSessionDataTask {
            let task = session.dataTask(with: URLRequest as URLRequest) { (data, response, error) in
                if let e = error {
                    callback(.Failure(e))
                } else if let data = data {
                    do {
                        guard let dic = try JSONSerialization.jsonObject(with: data, options: [])
                            as? [String: AnyObject] else {
                                throw APIError.UnexpectedResponseType
                        }
                        let response = try ResponseType(JSON: JSONObject(JSON: dic))
                        callback(.Success(response))
                    } catch {
                        callback(.Failure(error))
                    }
                } else {
                    callback(.Failure(APIError.EmptyBody))
                }
            }
            task.resume()
            return task
    }
}

struct Parameters: ExpressibleByDictionaryLiteral {
    typealias Key = String
    typealias Value = String?
    private(set) var parameters: [Key: Value] = [:]
    
    init(dictionaryLiteral elements: (Parameters.Key, Parameters.Value)...) {
        for case let (key, value?) in elements {
            parameters[key] = value
        }
    }
}
