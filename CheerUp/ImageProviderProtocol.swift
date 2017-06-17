//
//  ImageProviderProtocol.swift
//  CheerUp
//
//  Created by stefan on 08/02/2017.
//  Copyright © 2017 stefan. All rights reserved.
//

import Result

///a generic completion handler with a result type (T) and an error type (E)
typealias CompletionHandler<T, E> = (_ image: T?, _ error: E?) -> Void

///defines a protocol every image provider must implement
///makes it easier to add/replace imageProviders
protocol ImageProviderProtocol {
    func getRandomImage(onCompletion completionHandler: @escaping CompletionHandler<Image, NetworkError>, ignoreMaxNumberOfRequests: Bool)
}
