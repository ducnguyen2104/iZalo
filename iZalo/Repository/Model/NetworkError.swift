//
//  NetworkError.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

public enum NetworkErrorType: Int {
    case NoError = 999
    
    case NoInternetConnection
    
    case RequestTimeOut
    
    case ClientError
    
    case ServerError
}

public class NetworkError: Error {
    
    public let error: NSError
    public var errorType = NetworkErrorType.NoError
    public var errorMessage = ""
    public var errorCode = -1
    public var errorData: [String: AnyObject] = [:]
    
    init(domain: String, code: Int, userInfo dict: [String : Any]?) {
        self.error = NSError(domain: domain, code: code, userInfo: dict)
    }
    
    static func handleError(response: HTTPURLResponse?, data: Data?, error: Error) -> NetworkError {
        let nsError = error as NSError
        
        let err = NetworkError(domain: nsError.domain, code: nsError.code, userInfo: nsError.userInfo)
        
        guard nsError.isNoInternetConnectionError() == false else {
            err.errorType = NetworkErrorType.NoInternetConnection
            err.errorMessage = "No Internet Connection"
            return err
        }
        
        guard !nsError.isRequestTimeOutError() else {
            err.errorType = NetworkErrorType.RequestTimeOut
            err.errorMessage = "Request Time Out"
            return err
        }
        
        guard let res = response else {
            err.errorType = NetworkErrorType.NoInternetConnection
            err.errorMessage = "No Internet Connection"
            return err
        }
        
        guard !res.isServerError() else {
            err.errorType = NetworkErrorType.ServerError
            err.errorCode = res.statusCode
            err.errorMessage = "Server Error"
            
            guard let responseData = data else {
                return err
            }
            
            do {
                err.errorData = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as! [String : AnyObject]
            } catch {
                
            }
            
            return err
        }
        
        guard !res.isClientError() else {
            err.errorType = NetworkErrorType.ClientError
            err.errorCode = res.statusCode
            err.errorMessage = "Client Error"
            
            guard let responseData = data else {
                return err
            }
            
            do {
                err.errorData = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as! [String : AnyObject]
            } catch {
                
            }
            
            return err
        }
        
        return err
    }
}

extension NSError {
    
    func isNoInternetConnectionError() -> Bool {
        return (self.domain == NSURLErrorDomain && (self.code == NSURLErrorNotConnectedToInternet || self.code == NSURLErrorNetworkConnectionLost || self.code == NSURLErrorCannotConnectToHost))
    }
    
    func isRequestTimeOutError() -> Bool {
        return self.code == NSURLErrorTimedOut
    }
}

extension HTTPURLResponse {
    
    func isClientError() -> Bool {
        return self.statusCode >= 400 && self.statusCode <= 499
    }
    
    func isServerError() -> Bool {
        return self.statusCode >= 500 && self.statusCode <= 599
    }
}
