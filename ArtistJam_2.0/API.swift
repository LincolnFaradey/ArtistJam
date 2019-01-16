//
//  API.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 2/9/16.
//  Copyright © 2016 Andrei Nechaev. All rights reserved.
//

//static NSString *ACCOUNT_ID = @"0175-1086-4679";
//static NSString *POOL_ID = @"eu-west-1:da1d6cdf-4cf6-480c-ad14-8cdec1357a20";
//static NSString *UNAUTH_ROLE = @"arn:aws:iam::017510864679:role/Cognito_ajcognitoUnauth_Role";

let baseURL = URL(string: "https://www.artistjam.net/")!
enum Route {
    case SignIn
    case SignUp
    case Logout
    case Stage(String)
    case News(String)
    case Like(Int)
    case Unlike(Int)
    
    func url() -> URL? {
        switch self {
            case .SignIn:
                return baseURL.appendingPathComponent("/auth/signin")
            case .SignUp:
                return baseURL.appendingPathComponent("/auth/signup")
            case .Logout:
                return baseURL.appendingPathComponent("/auth/logout")
            case .Stage(let addr):
                return baseURL.appendingPathComponent("/stage/\(addr)")
            case .News(let addr):
                return baseURL.appendingPathComponent("/feed/news/\(addr)")
            case .Like(let id):
                return baseURL.appendingPathComponent("/news/like/\(id)")
            case .Unlike(let id):
                return baseURL.appendingPathComponent("/news/unlike/\(id)")
        }
    }
    
    static func scheme() -> String {
        return "https"
    }
    
    static func host() -> String {
        return "www.artistjam.net"
    }
    
    func path() -> String {
        switch self {
            case .SignIn:
                return "/auth/signin"
            case .SignUp:
                return "/auth/signup"
            case .Logout:
                return "/auth/logout"
            case .Stage(let addr):
                return "/stage/\(addr)"
            case .News(let addr):
                return "/feed/news/\(addr)"
            case .Like(let id):
                return "/news/like/\(id)"
            case .Unlike(let id):
                return "/news/unlike/\(id)"
        }
    }
}

func constPlist() -> [String: String] {
    let bundle = Bundle.main.path(forResource: "const", ofType: "plist")
    let dict = NSDictionary(contentsOfFile: bundle!)
    return dict as! [String: String]
}

func poolID() -> String {
    return constPlist()["pool_id"]!
}

func bucket() -> String {
    return constPlist()["bucket"]!
}


