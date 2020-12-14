//
//  DocWindFManager.swift
//  docWind
//
//  Created by Sarvad shetty on 7/2/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Main protocol
protocol DocWindFManager {
    func fileURL() -> URL
    func reset()
    func savePdf(urlString: String, direcName: String?, fileName: String) -> Bool
    func showSavedPdf(direcName: String?, fileName: String) -> (Bool, String)
//    func pdfFileAlreadySaved(direcName: String?, fileName:String) -> Bool
    func pdfAlreadySaved(directory url: String?, fileName: String, fileurl urlString: String?) -> Bool
    func creatingDirectory(direcName: String) -> Bool
    func createSubDirectory(direcName: String) -> (Bool, String)
//    func createSubSubDirectory(headName: URL, newDirecName: String) -> (Bool, String)
    func renameFile(oldPath: String, newName: String) -> (Bool, String)
//    func savePdfWithDataContent(pdfData: Data, pdfName: String, direcName: String?) -> (Bool, String)
    func saveFileWithPDFContent(pdfData: Data, pdfName: String, directoryRef: String?) -> (Bool, String)
    func savePdfWithSubFolder(pdfData: Data, pdfName: String, subDir: String) -> (Bool, String)
    func deleteSavedPdf(direcName: String?, fileName: String) -> Bool
    func deleteSavedFolder(folderName: String) -> Bool
    func createPDF(images:[UIImage], maxSize:Int, quality:Int, pdfPathUrl: URL?) -> NSData?
}

//MARK: - Extension
extension DocWindFManager {
    /// START OF EXTENSION
    
    var containerUrl: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("DocWind")
    }
    
    func reset() {
        do {
            try FileManager.default.removeItem(atPath: containerUrl!.path)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fileURL() -> URL {
        return (FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("DocWind"))!
    }
    
    func savePdfWithSubFolder(pdfData: Data, pdfName: String, subDir: String) -> (Bool, String) {
        var status = false
        var path = ""
        
        let direcPath = URL(string: subDir)!
        print("File Manager Path: ------> \(direcPath)")
        let pdfName = "\(pdfName)"
        print("Pdf name to save: -------> \(pdfName)")
        let pdfData = pdfData
        
        
        let actualSavingFilePath = direcPath.appendingPathComponent((pdfName.removingPercentEncoding != nil) ? pdfName.removingPercentEncoding! : pdfName, isDirectory: false)
        print("Actiual saved path --------> \(actualSavingFilePath)")
        // before saving check if filename already exists
//        if self.pdfFileAlreadySaved(direcName: "\(direcPath)", fileName: pdfName) {
//            // already saved
//            status = false
//            print("❌ PDF ALREADY SAVED BEFORE")
//        } else {
//            // not saved
//            // start writing
//            do {
//                try pdfData.write(to: actualSavingFilePath, options: .atomic)
//                print("✅ SAVED PDF SUCCESSFULLY")
//                print(actualSavingFilePath)
//                path = "\(actualSavingFilePath)"
//                print(path)
//
//                status = true
//            } catch {
//                print("❌ PDF COULD'NT BE SAVED ")
//                print("////reason: \(error.localizedDescription)")
//                status = false
//            }
//        }
        
        return (status, path)
    }
    
    func renameFile(oldPath: String, newName: String) -> (Bool, String) {
        var status = false
        var path = ""
        
        guard let oldDirecURL = URL(string: oldPath) else { fatalError("couldnt get oldDirecURL") }
        print("ORIGINAL PATH -----> \(oldDirecURL)")
        let oldPathURLExcludingFileName = oldDirecURL.deletingLastPathComponent()
        print("AFTER DELETING LAST COMPONENT -----> \(oldPathURLExcludingFileName)")
        let newPathURLIncludingNewFileName = oldPathURLExcludingFileName.appendingPathComponent(newName, isDirectory: false)
        print("AFTER APPENDING NEW PATH ----> \(newPathURLIncludingNewFileName)")
        
        do {
            try FileManager.default.moveItem(at: oldDirecURL, to: newPathURLIncludingNewFileName)
            status = true
            path = newPathURLIncludingNewFileName.absoluteString
        } catch {
            status = false
            print("❌ ERROR RENAMING FILE: \(error.localizedDescription)")
        }
        
        return (status, path)
    }
    
    /// saving pdf file to documents directory
    /// - Parameters:
    ///   - pdfData: data of pdf to store
    ///   - pdfName: pdf name
    ///   - directoryRef: folder reference to store file in
    /// - Returns: state of the completion of executing
    func saveFileWithPDFContent(pdfData: Data, pdfName: String, directoryRef: String?) -> (Bool, String) {
        var status = false
        var path = ""
        
        // getting the main directory file URL
        guard let resourceURL = containerUrl else { fatalError("error getting container URL") }
        
        if directoryRef == nil {
            // when nothing is specified, saving in main is assumed
            
            let actualPDFName = pdfName
            print("PDF NAME TO BE SAVED: \(actualPDFName) ---!") // contains .pdf
            
            let actualPDFData = pdfData
            print("PDF does contain data: \(!actualPDFData.isEmpty)")
            
            // getting final saving path
            let newSavingPath = resourceURL.appendingPathComponent(actualPDFName, isDirectory: false)
            print("FINAL SAVING PATH: \(newSavingPath)")
            
            print(resourceURL.path)
            // to check if the file is already saved before
            if self.pdfAlreadySaved(directory: resourceURL.path, fileName: actualPDFName, fileurl: newSavingPath.path) {
                // found file
                status = false
                print("❌ PDF ALREADY SAVED BEFORE")
            } else {
                // not found file\
                // start writing to file
                do {
                    if !FileManager.default.fileExists(atPath: resourceURL.path) {
                        try FileManager.default.createDirectory(at: resourceURL, withIntermediateDirectories: true, attributes: nil)
                    } else {
                        print("directory already created")
                    }
                    
                    try actualPDFData.write(to: newSavingPath, options: .atomic)
                    print("saved pdf successfully")
                    path = newSavingPath.path
                    status = true
                    
                } catch {
                    print("pdf couldnt be saved")
                    print(error.localizedDescription)
                    status = false
                }
            }
            
        } else {
            // when something is specified, saving in sub is assumed
            
            let actualPDFName = pdfName
            print("PDF NAME TO BE SAVED: \(actualPDFName) ---!") // contains .pdf
            
            let actualPDFData = pdfData
            print("PDF does contain data: \(!actualPDFData.isEmpty)")
                        
            guard let ref = directoryRef?.trimBothSides() else { fatalError() }
            
            let relativeFilePath = resourceURL.appendingPathComponent(ref, isDirectory: true)
            print("RELATIVE PATH: \(relativeFilePath)")
            // getting final directory path
            let newSavingPath = relativeFilePath.appendingPathComponent(actualPDFName, isDirectory: false)
            print("FINAL SAVING PATH: \(newSavingPath) --!")
            
            // to check if the file is already saved before
            if self.pdfAlreadySaved(directory: relativeFilePath.path, fileName: actualPDFName, fileurl: newSavingPath.path) {
                // found file
                status = false
                print("❌ PDF ALREADY SAVED BEFORE")
            } else {
                // not found file\
                // start writing to file
                do {
                    if !FileManager.default.fileExists(atPath: relativeFilePath.path) {
                        try FileManager.default.createDirectory(at: relativeFilePath, withIntermediateDirectories: true, attributes: nil)
                    } else {
                        print("directory already created")
                    }
                    
                    try actualPDFData.write(to: newSavingPath, options: .atomic)
                    print("saved pdf successfully")
                    path = newSavingPath.path
                    status = true
                    
                } catch {
                    print("pdf couldnt be saved")
                    print(error.localizedDescription)
                    status = false
                }

            }
            
                        
        }
        
        return (status, path)
    }
    
    func savePdf(urlString: String, direcName: String?, fileName: String) -> Bool {
        var status = false
        
        if direcName != nil {
            DispatchQueue.main.async {
                let url = URL(string: urlString)
                
                // getting direc pathName
                let direcPath = direcName!
                // converting contents of pdf into Data type
                if let pdfdata = try? Data.init(contentsOf: url!) {
                    
                    let resourcePath = self.containerUrl!
                    print("File Manager Path: ------> \(resourcePath)")
                    let pdfName = "\(fileName)"
                    print("Pdf name to save: -------> \(pdfName)")
                    
                    //saving part...
                    let actualSavingDirec = resourcePath.appendingPathComponent("\(direcPath)", isDirectory: true)
                    let actualSavingPath = actualSavingDirec.appendingPathComponent(pdfName, isDirectory: false)
                    
                    // before saving check if file already exists
//                    if self.pdfFileAlreadySaved(direcName: direcName, fileName: fileName) {
//                        // already saved
//                        print("❌ PDF ALREADY SAVED BEFORE")
//                        status = false
//                    } else {
//                        // not saved
//
//                        // lets save now
//                        do {
//                            try pdfdata.write(to: actualSavingPath, options: .atomic)
//                            print("✅ SAVED PDF SUCCESSFULLY")
//                            status = true
//                        } catch {
//                            print("❌ PDF COULD'NT BE SAVED ")
//                            print("////reason: \(error.localizedDescription)")
//                            status = false
//                        }
//                    }
                    
                } else {
                    // if failed alert
                    print("❌ PDF COULD'NT BE SAVED, ERROR CONVERTING INTO DATA TYPE")
                    status = false
                }
            }
            return status
        } else {
            DispatchQueue.main.async {
                let url = URL(string: urlString)

                // converting contents of pdf into Data type
                if let pdfdata = try? Data.init(contentsOf: url!) {
                    
                    let resourcePath = self.containerUrl!
                    print("File Manager Path: ------> \(resourcePath)")
                    let pdfName = "\(fileName)"
                    print("Pdf name to save: -------> \(pdfName)")
                    
                    //saving part...
                    let actualSavingPath = resourcePath.appendingPathComponent("\(pdfName)", isDirectory: false)
                    
                    // before saving check if file already exists
//                    if self.pdfFileAlreadySaved(direcName: direcName, fileName: fileName) {
//                        // already saved
//                        print("❌ PDF ALREADY SAVED BEFORE")
//                    } else {
//                        // not saved
//                        
//                        // lets save now
//                        do {
//                            try pdfdata.write(to: actualSavingPath, options: .atomic)
//                            print("✅ SAVED PDF SUCCESSFULLY")
//                            status = true
//                        } catch {
//                            print("❌ PDF COULD'NT BE SAVED ")
//                            print("////reason: \(error.localizedDescription)")
//                            status = false
//                        }
//                    }
                } else {
                    // if failed alert
                    print("❌ PDF COULD'NT BE SAVED, ERROR CONVERTING INTO DATA TYPE")
                    status = false
                }
            }
            return status
        }
    }
    
    func deleteSavedFolder(folderName: String) -> Bool {
        var status = false
        // any direc
        guard let resourceURL = containerUrl else { fatalError("error getting container URL") }
//        let actualFilePath = resourceURL.appendingPathComponent(folderName, isDirectory: true)
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
            print(contents)
            
            for url in contents {
                
                if url.description.contains(folderName) {
                    try FileManager.default.removeItem(at: url)
                    print("SUCCESSFULLY DELETED FILE ✅")
                    status = true
                }

            }
        } catch {
            print("❌ PDF COULD'NT BE FOUND ")
            print("////reason: \(error.localizedDescription)")
            status = false
        }
        
        return status
    }
    
    func deleteSavedPdf(direcName: String?, fileName: String) -> Bool {
        var status = false
        
        if direcName == nil {
            // PhotoStat
            // getting the main directory file URL
            guard let resourceURL = containerUrl else { fatalError("error getting container URL") }
            let actualFilePath = resourceURL.appendingPathComponent(fileName)
            print("ACTUAL FILE PATH: \(actualFilePath)")
            
            // search and deletion part
            if FileManager.default.fileExists(atPath: actualFilePath.path) {
                print("here")
                
                do {
                    let contents = try FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                    print(contents)
                    
                    for url in contents {
                        
                        if url.description.contains(fileName) {
                            try FileManager.default.removeItem(at: url)
                            print("SUCCESSFULLY DELETED FILE ✅")
                            status = true
                        }

                    }
                } catch {
                    print("❌ PDF COULD'NT BE FOUND ")
                    print("////reason: \(error.localizedDescription)")
                    status = false
                }
                
            } else {
                status = false
                print("❌ PDF COULD'NT BE FOUND ")
            }
            
        } else {
            // any direc
            guard let resourceURL = containerUrl else { fatalError("error getting container URL") }
            let actualDirec = resourceURL.appendingPathComponent(direcName!, isDirectory: true)
            let actualFilePath = actualDirec.appendingPathComponent(fileName)
            print("ACTUAL FILE PATH: \(actualFilePath)")
            
            // search and deletion part
            if FileManager.default.fileExists(atPath: actualFilePath.path) {
                print("here")
                
                do {
                    let contents = try FileManager.default.contentsOfDirectory(at: actualDirec, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                    print(contents)
                    
                    for url in contents {
                        
                        if url.description.contains(fileName) {
                            try FileManager.default.removeItem(at: url)
                            print("SUCCESSFULLY DELETED FILE ✅")
                            status = true
                        }

                    }
                } catch {
                    print("❌ PDF COULD'NT BE FOUND ")
                    print("////reason: \(error.localizedDescription)")
                    status = false
                }
                
            } else {
                status = false
                print("❌ PDF COULD'NT BE FOUND ")
            }
        }
        
        return status
    }
    
    func showSavedPdf(direcName: String?, fileName: String) -> (Bool, String) {
        var status = false
        var path = ""
        
        // getting the main directory file URL
        guard let resourceURL = containerUrl else { fatalError("error getting container URL") }
        print(direcName)
        print("name",fileName)
        
        if direcName == nil {
            
            print(resourceURL.appendingPathComponent(fileName).path)
            
            if FileManager.default.fileExists(atPath: resourceURL.appendingPathComponent(fileName).path) {
                print("here")
            } else {
                print("not here")
            }
            
            // do a file check
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                print(contents)
                
                for url in contents {
                    
                    if url.description.contains(fileName) {
                        status = true
                        path = url.description
                        print("✅ FOUND PDF SUCCESSFULLY, ALREADY SAVED")
                    }

                }
            } catch {
                print("❌ PDF COULD'NT BE FOUND ")
                print("////reason: \(error.localizedDescription)")
                status = false
            }
            
            
        } else {
            let resourcePath = resourceURL.appendingPathComponent(direcName!, isDirectory: true)
            print("File Manager Path OVER HERE: ------> \(resourcePath)")
            print(fileName)
//            print(urlString!)
            
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: resourcePath, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                print(contents)
                
                for url in contents {
                    
                    if url.description.contains(fileName) {
                        status = true
                        path = url.description
                        print("✅ FOUND PDF SUCCESSFULLY, ALREADY SAVED")
                    }
                }
                
            } catch {
                print("❌ PDF COULD'NT BE FOUND ")
                print("////reason: \(error.localizedDescription)")
                status = false
            }
        }
        
        return (status, path)
    }
    
    func pdfAlreadySaved(directory url: String?, fileName: String, fileurl urlString: String?) -> Bool {
            var status = false
            print("urlString: ",urlString)
            print("url: ",url)
            
            if url != nil {
                // directory name specified
                let direcPath = URL(fileURLWithPath: url!)
                
                print("File Manager Path: ------> \(direcPath)") // can force unwrap since we know its not nil
                print("File name: ----> \(fileName)")
                
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: url!)

                    // need to remove symlinks ref while saving every where check stackoverflow
                    print(contents)
                    // /var is the symlink to /private/var
                    for url in contents {
                        
                        if url.description.contains(fileName) {
                            status = true
                            print("✅ FOUND PDF SUCCESSFULLY, ALREADY SAVED")
                        }
                    }
                    
                } catch {
                    print("❌ PDF COULD'NT BE LOCATED ")
                    print("////reason: \(error.localizedDescription)")
                    status = false
                }
                
                return status
                
            } else {
                // directory name not specified, there using main directory as ref i.e., `PhotoStat`
                
                let resourcePath = self.containerUrl!
                print("File Manager Path: ------> \(resourcePath)")
                
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath.path)

                    // need to remove symlinks ref while saving every where check stackoverflow
                    print("inside DOCWIND")
                    print(contents)
                    // /var is the symlink to /private/var
                    for url in contents {
                        
                        if url.description.contains(fileName) {
                            status = true
                            print("✅ FOUND PDF SUCCESSFULLY, ALREADY SAVED")
                        }
                    }
                    
                } catch {
                    print("❌ PDF COULD'NT BE LOCATED , SO SAVE NEW ONE")
                    print("////reason: \(error.localizedDescription)")
                    status = false
                }
                
                return status
            }
        }
    
    /// to create main directory
    /// - Parameter direcName: name for the directory to be created and saved
    /// - Returns: returns status
    func creatingDirectory(direcName: String) -> Bool {
        var status = false
        
        // check for document directory sub dire named `PhotoStat`'s existance
        print("Path: \(self.containerUrl!.path)") // -> use this for at path: key names
        print("Absolute string: \(self.containerUrl!.absoluteString)") // -> use this for folder refrences
        
        if let mainURL = self.containerUrl, !FileManager.default.fileExists(atPath: mainURL.path, isDirectory: nil) {
            // if mainURL is valid and folder doesnt exists, meaning this is first install or first creation of directory
            do {
                try FileManager.default.createDirectory(at: mainURL, withIntermediateDirectories: true, attributes: nil)
                status = true
                print("✅ SUCCESSFULLY CREATED DIRECTORY")
            }
            catch {
                print("❌ FAILED TO CREATED DIRECTORY")
                print(error.localizedDescription)
                status = false
            }
        } else {
            print(" FOLDER ALREADY EXISTS")
            status = true
        }
        
        return status
    }
    
    func createSubDirectory(direcName: String) -> (Bool, String) {
        var status = false
        var path = ""
        
        if let mainURL = self.containerUrl, FileManager.default.fileExists(atPath: mainURL.path) {
            print("yes this exists and we can create")
            let subPath = mainURL.appendingPathComponent(direcName, isDirectory: true)
            

            if !pdfAlreadySaved(directory: nil, fileName: direcName, fileurl: subPath.path) {
                
                // creating
                do {
                    try FileManager.default.createDirectory(at: subPath, withIntermediateDirectories: true, attributes: nil)
                    status = true
                    path = subPath.path
                    print("sucessfully created at \(subPath)")
                } catch {
                    print("failed to created directory")
                    print(error.localizedDescription)
                    status = false
                }
                
            } else {
                status = false
                print("ERROR: file/folder already saved")
            }
            
            status = true
        } else {
            print("ERROR: nope we cant go ahead")
            status = false
        }
        return (status, path)
    }
    
    func createPDF(images:[UIImage], maxSize:Int, quality:Int, pdfPathUrl: URL?) -> NSData? {
        if quality > 0 {
            guard let pdfFilePath = pdfPathUrl else {
                print("Error creating pdf path")
                return nil
            }

            var largestImageSize = CGSize.zero

            for image in images {
                if image.size.width > largestImageSize.width {
                    largestImageSize.width = image.size.width
                }

                if image.size.height > largestImageSize.height {
                    largestImageSize.height = image.size.height
                }
            }

            let pdfData = NSMutableData()
            UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: largestImageSize.width, height: largestImageSize.height), nil)

            let context = UIGraphicsGetCurrentContext()

            for image in images {
                UIGraphicsBeginPDFPage()
                UIGraphicsPushContext(context!)

                if quality != 100 {
                    print(CGFloat(quality)/100.0)
                    guard let imageData = image.jpegData(compressionQuality: CGFloat(quality)/100.0) else {
                        print("Error reducing image size")
                        return nil
                    }
                    guard let newImage = UIImage(data: imageData) else {
                        print("Error creating image from data")
                        return nil
                    }
                    newImage.draw(at: CGPoint.zero)
                } else {
                    image.draw(at: CGPoint.zero)
                }
                UIGraphicsPopContext()
            }

            UIGraphicsEndPDFContext();

            print(pdfData.length)
            print(maxSize)
            
            if (pdfData.length > maxSize) {
                print("reduces quality to \(quality - 10)")
                return self.createPDF(images: images, maxSize: maxSize, quality: quality - 10, pdfPathUrl: pdfFilePath)
            }

            if pdfData.write(to: pdfFilePath, atomically: true) {
                print("success writing to file")
            } else {
                print("write to pdfFilePath failed")
            }
            
//            if pdfData.write(toFile: pdfFilePath.absoluteString, atomically: true)  ==  false{
//                print("write to pdfFilePath failed")
//            } else {
//                print("success writing to file")
//            }

            return NSData(contentsOf: pdfFilePath)
        }

        return nil
    }
    
    /// END OF EXTENSION
}
