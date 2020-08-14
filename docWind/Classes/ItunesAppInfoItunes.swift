//
//  ItunesAppInfoItunes.swift
//  docWind
//
//  Created by Sarvad shetty on 8/14/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation


class ItunesAppInfoItunes : NSObject, NSCoding{

    var resultCount : Int!
    var results : [ItunesAppInfoResult]!


    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        resultCount = dictionary["resultCount"] as? Int
        results = [ItunesAppInfoResult]()
        if let resultsArray = dictionary["results"] as? [[String:Any]]{
            for dic in resultsArray{
                let value = ItunesAppInfoResult(fromDictionary: dic)
                results.append(value)
            }
        }
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if resultCount != nil{
            dictionary["resultCount"] = resultCount
        }
        if results != nil{
            var dictionaryElements = [[String:Any]]()
            for resultsElement in results {
                dictionaryElements.append(resultsElement.toDictionary())
            }
            dictionary["results"] = dictionaryElements
        }
        return dictionary
    }

    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        resultCount = aDecoder.decodeObject(forKey: "resultCount") as? Int
        results = aDecoder.decodeObject(forKey: "results") as? [ItunesAppInfoResult]
    }

    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    @objc func encode(with aCoder: NSCoder)
    {
        if resultCount != nil{
            aCoder.encode(resultCount, forKey: "resultCount")
        }
        if results != nil{
            aCoder.encode(results, forKey: "results")
        }
    }
}
