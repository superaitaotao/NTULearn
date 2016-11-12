//
//  NTULearnFetcher.swift
//  NewNTULearn
//
//  Created by shutao xu on 12/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Foundation

let userAgents = ["Mozilla/5.0 (Windows NT 6.1; WOW64; rv:41.0) Gecko/20100101 Firefox/41.0",
              "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36",
              "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36",
              "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36",
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11) AppleWebKit/601.1.56 (KHTML, like Gecko) Version/9.0 Safari/601.1.56",
              "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36",
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/601.2.7 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.7",
              "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko]"]

enum FetchResult {
    case error(Error)
    case success(Data)
}

class NTULearnFetcher{
    let baseUrl = "https://ntulearn.ntu.edu.sg"
    let userName = "sxu00"
    let password = "Galaxy1234#"
    let session: URLSession = URLSession.shared

    func logIn(handler: @escaping (FetchResult) -> Void) {
        print("logging in ...")
        var logInRequest = URLRequest(url: URL(string: baseUrl + "/webapps/login")!);
        let postString = "user_id=\(userName)&password=\(password)"
        logInRequest.httpMethod = "POST"
        logInRequest.httpBody  = postString.data(using: String.Encoding.utf8, allowLossyConversion: false)
        logInRequest.allHTTPHeaderFields = ["User-Agent" : userAgents[Int(arc4random_uniform(UInt32(userAgents.count)))]]
        session.dataTask(with: logInRequest, completionHandler: { (data, response, error) -> Void in
            if (data == nil) {
                handler(FetchResult.error(error!))
            } else {
                handler(FetchResult.success(data!))
            }
        }).resume()
    }
}
