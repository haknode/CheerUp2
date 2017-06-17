//
//  GiphyComApi.swift
//  CheerUp
//
//  Created by stefan on 30/01/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import Moya
import Alamofire

///giphy.com API definition for moya
///replace with simpler alamofire call?
enum GiphyComApi{
    case random(apiKey: String, tags: [String], rating: String)
}

extension GiphyComApi : TargetType{
    var baseURL: URL {
        return URL(string: "http://api.giphy.com/v1/gifs")!
    }
    
    var path: String {
        switch self {
        case .random(let apiKey, let tags, let rating):
            return "/random?api_key=\(apiKey)&tag=\(tags.joined(separator: "+"))&rating=\(rating)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .random:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        default:
            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding{
        switch self {
        default:
            return URLEncoding.default
        }
    }
    
    var sampleData: Data {
        switch self {
        default:
            return "no sample data available".data(using: .utf8)!
        }
    }
    
    var task: Task {
        switch self {
        case .random:
            return .request
        }
    }
}
