//
//  ImgurComApi.swift
//  CheerUp
//
//  Created by stefan on 08/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import Moya
import Alamofire


///imgur.com API definition for moya
///replace with simpler alamofire call?
enum ImgurComApi{
    case search(query: String, page: Int)
}

extension ImgurComApi : TargetType{
    var baseURL: URL {
        return URL(string: "https://api.imgur.com/3")!
    }
    
    var path: String {
        switch self {
        case .search(let page):
            return "/gallery/search/\(page)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .search:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .search(let query):
            return ["q":query]
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
        case .search:
            return .request
        }
    }
}
