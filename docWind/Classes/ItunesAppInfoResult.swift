//
//  ItunesAppInfoResult.swift
//  docWind
//
//  Created by Sarvad shetty on 8/14/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation


class ItunesAppInfoResult : NSObject, NSCoding{

    var advisories : [AnyObject]!
    var appletvScreenshotUrls : [AnyObject]!
    var artistId : Int!
    var artistName : String!
    var artistViewUrl : String!
    var artworkUrl100 : String!
    var artworkUrl512 : String!
    var artworkUrl60 : String!
    var bundleId : String!
    var contentAdvisoryRating : String!
    var currency : String!
    var currentVersionReleaseDate : String!
    var descriptionField : String!
    var features : [AnyObject]!
    var fileSizeBytes : String!
    var formattedPrice : String!
    var genreIds : [String]!
    var genres : [String]!
    var ipadScreenshotUrls : [AnyObject]!
    var isGameCenterEnabled : Bool!
    var isVppDeviceBasedLicensingEnabled : Bool!
    var kind : String!
    var languageCodesISO2A : [String]!
    var minimumOsVersion : String!
    var price : Int!
    var primaryGenreId : Int!
    var primaryGenreName : String!
    var releaseDate : String!
    var releaseNotes : String!
    var screenshotUrls : [String]!
    var sellerName : String!
    var supportedDevices : [String]!
    var trackCensoredName : String!
    var trackContentRating : String!
    var trackId : Int!
    var trackName : String!
    var trackViewUrl : String!
    var version : String!
    var wrapperType : String!


    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        artistId = dictionary["artistId"] as? Int
        artistName = dictionary["artistName"] as? String
        artistViewUrl = dictionary["artistViewUrl"] as? String
        artworkUrl100 = dictionary["artworkUrl100"] as? String
        artworkUrl512 = dictionary["artworkUrl512"] as? String
        artworkUrl60 = dictionary["artworkUrl60"] as? String
        bundleId = dictionary["bundleId"] as? String
        contentAdvisoryRating = dictionary["contentAdvisoryRating"] as? String
        currency = dictionary["currency"] as? String
        currentVersionReleaseDate = dictionary["currentVersionReleaseDate"] as? String
        descriptionField = dictionary["description"] as? String
        fileSizeBytes = dictionary["fileSizeBytes"] as? String
        formattedPrice = dictionary["formattedPrice"] as? String
        isGameCenterEnabled = dictionary["isGameCenterEnabled"] as? Bool
        isVppDeviceBasedLicensingEnabled = dictionary["isVppDeviceBasedLicensingEnabled"] as? Bool
        kind = dictionary["kind"] as? String
        minimumOsVersion = dictionary["minimumOsVersion"] as? String
        price = dictionary["price"] as? Int
        primaryGenreId = dictionary["primaryGenreId"] as? Int
        primaryGenreName = dictionary["primaryGenreName"] as? String
        releaseDate = dictionary["releaseDate"] as? String
        releaseNotes = dictionary["releaseNotes"] as? String
        sellerName = dictionary["sellerName"] as? String
        trackCensoredName = dictionary["trackCensoredName"] as? String
        trackContentRating = dictionary["trackContentRating"] as? String
        trackId = dictionary["trackId"] as? Int
        trackName = dictionary["trackName"] as? String
        trackViewUrl = dictionary["trackViewUrl"] as? String
        version = dictionary["version"] as? String
        wrapperType = dictionary["wrapperType"] as? String
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if artistId != nil{
            dictionary["artistId"] = artistId
        }
        if artistName != nil{
            dictionary["artistName"] = artistName
        }
        if artistViewUrl != nil{
            dictionary["artistViewUrl"] = artistViewUrl
        }
        if artworkUrl100 != nil{
            dictionary["artworkUrl100"] = artworkUrl100
        }
        if artworkUrl512 != nil{
            dictionary["artworkUrl512"] = artworkUrl512
        }
        if artworkUrl60 != nil{
            dictionary["artworkUrl60"] = artworkUrl60
        }
        if bundleId != nil{
            dictionary["bundleId"] = bundleId
        }
        if contentAdvisoryRating != nil{
            dictionary["contentAdvisoryRating"] = contentAdvisoryRating
        }
        if currency != nil{
            dictionary["currency"] = currency
        }
        if currentVersionReleaseDate != nil{
            dictionary["currentVersionReleaseDate"] = currentVersionReleaseDate
        }
        if descriptionField != nil{
            dictionary["description"] = descriptionField
        }
        if fileSizeBytes != nil{
            dictionary["fileSizeBytes"] = fileSizeBytes
        }
        if formattedPrice != nil{
            dictionary["formattedPrice"] = formattedPrice
        }
        if isGameCenterEnabled != nil{
            dictionary["isGameCenterEnabled"] = isGameCenterEnabled
        }
        if isVppDeviceBasedLicensingEnabled != nil{
            dictionary["isVppDeviceBasedLicensingEnabled"] = isVppDeviceBasedLicensingEnabled
        }
        if kind != nil{
            dictionary["kind"] = kind
        }
        if minimumOsVersion != nil{
            dictionary["minimumOsVersion"] = minimumOsVersion
        }
        if price != nil{
            dictionary["price"] = price
        }
        if primaryGenreId != nil{
            dictionary["primaryGenreId"] = primaryGenreId
        }
        if primaryGenreName != nil{
            dictionary["primaryGenreName"] = primaryGenreName
        }
        if releaseDate != nil{
            dictionary["releaseDate"] = releaseDate
        }
        if releaseNotes != nil{
            dictionary["releaseNotes"] = releaseNotes
        }
        if sellerName != nil{
            dictionary["sellerName"] = sellerName
        }
        if trackCensoredName != nil{
            dictionary["trackCensoredName"] = trackCensoredName
        }
        if trackContentRating != nil{
            dictionary["trackContentRating"] = trackContentRating
        }
        if trackId != nil{
            dictionary["trackId"] = trackId
        }
        if trackName != nil{
            dictionary["trackName"] = trackName
        }
        if trackViewUrl != nil{
            dictionary["trackViewUrl"] = trackViewUrl
        }
        if version != nil{
            dictionary["version"] = version
        }
        if wrapperType != nil{
            dictionary["wrapperType"] = wrapperType
        }
        return dictionary
    }

    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        advisories = aDecoder.decodeObject(forKey: "advisories") as? [AnyObject]
        appletvScreenshotUrls = aDecoder.decodeObject(forKey: "appletvScreenshotUrls") as? [AnyObject]
        artistId = aDecoder.decodeObject(forKey: "artistId") as? Int
        artistName = aDecoder.decodeObject(forKey: "artistName") as? String
        artistViewUrl = aDecoder.decodeObject(forKey: "artistViewUrl") as? String
        artworkUrl100 = aDecoder.decodeObject(forKey: "artworkUrl100") as? String
        artworkUrl512 = aDecoder.decodeObject(forKey: "artworkUrl512") as? String
        artworkUrl60 = aDecoder.decodeObject(forKey: "artworkUrl60") as? String
        bundleId = aDecoder.decodeObject(forKey: "bundleId") as? String
        contentAdvisoryRating = aDecoder.decodeObject(forKey: "contentAdvisoryRating") as? String
        currency = aDecoder.decodeObject(forKey: "currency") as? String
        currentVersionReleaseDate = aDecoder.decodeObject(forKey: "currentVersionReleaseDate") as? String
        descriptionField = aDecoder.decodeObject(forKey: "description") as? String
        features = aDecoder.decodeObject(forKey: "features") as? [AnyObject]
        fileSizeBytes = aDecoder.decodeObject(forKey: "fileSizeBytes") as? String
        formattedPrice = aDecoder.decodeObject(forKey: "formattedPrice") as? String
        genreIds = aDecoder.decodeObject(forKey: "genreIds") as? [String]
        genres = aDecoder.decodeObject(forKey: "genres") as? [String]
        ipadScreenshotUrls = aDecoder.decodeObject(forKey: "ipadScreenshotUrls") as? [AnyObject]
        isGameCenterEnabled = aDecoder.decodeObject(forKey: "isGameCenterEnabled") as? Bool
        isVppDeviceBasedLicensingEnabled = aDecoder.decodeObject(forKey: "isVppDeviceBasedLicensingEnabled") as? Bool
        kind = aDecoder.decodeObject(forKey: "kind") as? String
        languageCodesISO2A = aDecoder.decodeObject(forKey: "languageCodesISO2A") as? [String]
        minimumOsVersion = aDecoder.decodeObject(forKey: "minimumOsVersion") as? String
        price = aDecoder.decodeObject(forKey: "price") as? Int
        primaryGenreId = aDecoder.decodeObject(forKey: "primaryGenreId") as? Int
        primaryGenreName = aDecoder.decodeObject(forKey: "primaryGenreName") as? String
        releaseDate = aDecoder.decodeObject(forKey: "releaseDate") as? String
        releaseNotes = aDecoder.decodeObject(forKey: "releaseNotes") as? String
        screenshotUrls = aDecoder.decodeObject(forKey: "screenshotUrls") as? [String]
        sellerName = aDecoder.decodeObject(forKey: "sellerName") as? String
        supportedDevices = aDecoder.decodeObject(forKey: "supportedDevices") as? [String]
        trackCensoredName = aDecoder.decodeObject(forKey: "trackCensoredName") as? String
        trackContentRating = aDecoder.decodeObject(forKey: "trackContentRating") as? String
        trackId = aDecoder.decodeObject(forKey: "trackId") as? Int
        trackName = aDecoder.decodeObject(forKey: "trackName") as? String
        trackViewUrl = aDecoder.decodeObject(forKey: "trackViewUrl") as? String
        version = aDecoder.decodeObject(forKey: "version") as? String
        wrapperType = aDecoder.decodeObject(forKey: "wrapperType") as? String
    }

    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    @objc func encode(with aCoder: NSCoder)
    {
        if advisories != nil{
            aCoder.encode(advisories, forKey: "advisories")
        }
        if appletvScreenshotUrls != nil{
            aCoder.encode(appletvScreenshotUrls, forKey: "appletvScreenshotUrls")
        }
        if artistId != nil{
            aCoder.encode(artistId, forKey: "artistId")
        }
        if artistName != nil{
            aCoder.encode(artistName, forKey: "artistName")
        }
        if artistViewUrl != nil{
            aCoder.encode(artistViewUrl, forKey: "artistViewUrl")
        }
        if artworkUrl100 != nil{
            aCoder.encode(artworkUrl100, forKey: "artworkUrl100")
        }
        if artworkUrl512 != nil{
            aCoder.encode(artworkUrl512, forKey: "artworkUrl512")
        }
        if artworkUrl60 != nil{
            aCoder.encode(artworkUrl60, forKey: "artworkUrl60")
        }
        if bundleId != nil{
            aCoder.encode(bundleId, forKey: "bundleId")
        }
        if contentAdvisoryRating != nil{
            aCoder.encode(contentAdvisoryRating, forKey: "contentAdvisoryRating")
        }
        if currency != nil{
            aCoder.encode(currency, forKey: "currency")
        }
        if currentVersionReleaseDate != nil{
            aCoder.encode(currentVersionReleaseDate, forKey: "currentVersionReleaseDate")
        }
        if descriptionField != nil{
            aCoder.encode(descriptionField, forKey: "description")
        }
        if features != nil{
            aCoder.encode(features, forKey: "features")
        }
        if fileSizeBytes != nil{
            aCoder.encode(fileSizeBytes, forKey: "fileSizeBytes")
        }
        if formattedPrice != nil{
            aCoder.encode(formattedPrice, forKey: "formattedPrice")
        }
        if genreIds != nil{
            aCoder.encode(genreIds, forKey: "genreIds")
        }
        if genres != nil{
            aCoder.encode(genres, forKey: "genres")
        }
        if ipadScreenshotUrls != nil{
            aCoder.encode(ipadScreenshotUrls, forKey: "ipadScreenshotUrls")
        }
        if isGameCenterEnabled != nil{
            aCoder.encode(isGameCenterEnabled, forKey: "isGameCenterEnabled")
        }
        if isVppDeviceBasedLicensingEnabled != nil{
            aCoder.encode(isVppDeviceBasedLicensingEnabled, forKey: "isVppDeviceBasedLicensingEnabled")
        }
        if kind != nil{
            aCoder.encode(kind, forKey: "kind")
        }
        if languageCodesISO2A != nil{
            aCoder.encode(languageCodesISO2A, forKey: "languageCodesISO2A")
        }
        if minimumOsVersion != nil{
            aCoder.encode(minimumOsVersion, forKey: "minimumOsVersion")
        }
        if price != nil{
            aCoder.encode(price, forKey: "price")
        }
        if primaryGenreId != nil{
            aCoder.encode(primaryGenreId, forKey: "primaryGenreId")
        }
        if primaryGenreName != nil{
            aCoder.encode(primaryGenreName, forKey: "primaryGenreName")
        }
        if releaseDate != nil{
            aCoder.encode(releaseDate, forKey: "releaseDate")
        }
        if releaseNotes != nil{
            aCoder.encode(releaseNotes, forKey: "releaseNotes")
        }
        if screenshotUrls != nil{
            aCoder.encode(screenshotUrls, forKey: "screenshotUrls")
        }
        if sellerName != nil{
            aCoder.encode(sellerName, forKey: "sellerName")
        }
        if supportedDevices != nil{
            aCoder.encode(supportedDevices, forKey: "supportedDevices")
        }
        if trackCensoredName != nil{
            aCoder.encode(trackCensoredName, forKey: "trackCensoredName")
        }
        if trackContentRating != nil{
            aCoder.encode(trackContentRating, forKey: "trackContentRating")
        }
        if trackId != nil{
            aCoder.encode(trackId, forKey: "trackId")
        }
        if trackName != nil{
            aCoder.encode(trackName, forKey: "trackName")
        }
        if trackViewUrl != nil{
            aCoder.encode(trackViewUrl, forKey: "trackViewUrl")
        }
        if version != nil{
            aCoder.encode(version, forKey: "version")
        }
        if wrapperType != nil{
            aCoder.encode(wrapperType, forKey: "wrapperType")
        }
    }
}
