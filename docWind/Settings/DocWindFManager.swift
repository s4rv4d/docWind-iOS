//
//  DocWindFManager.swift
//  docWind
//
//  Created by Sarvad shetty on 7/2/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: - Main protocol
protocol DocWindFManager {
    func fileURL() -> URL
    func reset()
    func savePdf(urlString: String, direcName: String?, fileName: String) -> Bool
    func showSavedPdf(direcName: String?, fileName: String) -> (Bool, String)
    func pdfAlreadySaved(directory url: String?, fileName: String, fileurl urlString: String?) -> Bool
    func creatingDirectory(direcName: String) -> Bool
    func createSubDirectory(direcName: String) -> (Bool, String)
    func renameFile(direcName: String?, oldFileName: String, newFileName: String) -> (Bool, String)
    func saveFileWithPDFContent(pdfData: Data, pdfName: String, directoryRef: String?) -> (Bool, String)
    func savePdfWithSubFolder(pdfData: Data, pdfName: String, subDir: String) -> (Bool, String)
    func deleteSavedPdf(direcName: String?, fileName: String) -> Bool
    func deleteSavedFolder(folderName: String) -> Bool
    func createPDF(images:[UIImage], maxSize:Int, quality:Int, pdfPathUrl: URL?) -> NSData?
    func updateFileWithPDFContent(pdfData: Data, pdfName: String, directoryRef: String?) -> (Bool, String)
    func syncUpLocalFilesWithApp(direcName: String?, directory: DirecModel, context: NSManagedObjectContext) -> Bool
}

//MARK: - Extension
extension DocWindFManager {
    /// START OF EXTENSION
    
    var containerUrl: URL? {
        let container =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return container.appendingPathComponent("DocWind", isDirectory: true)
    }
    
    func reset() {
        do {
            try FileManager.default.removeItem(atPath: containerUrl!.path)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fileURL() -> URL {
        let container =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return container.appendingPathComponent("DocWind", isDirectory: true)
    }
    
    func savePdfWithSubFolder(pdfData: Data, pdfName: String, subDir: String) -> (Bool, String) {
        let status = false
        let path = ""
        
        let direcPath = URL(string: subDir)!
        print("File Manager Path: ------> \(direcPath)")
        let pdfName = "\(pdfName)"
        print("Pdf name to save: -------> \(pdfName)")
        _ = pdfData
        
        
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
    
    /// renaming a file/folder
    /// - Parameters:
    ///   - direcName: directory where the file is present
    ///   - oldFileName: old file name
    ///   - newFileName: new file name
    /// - Returns: status of completion of execution of this function
    func renameFile(direcName: String?, oldFileName: String, newFileName: String) -> (Bool, String) {
        var status = false
        var path = ""
        
        if direcName == nil {
            
            print(oldFileName)
            print(newFileName)
            
            let con = try! FileManager.default.contentsOfDirectory(atPath: containerUrl!.path)
            print(con)
            
            
            // getting the main directory file URL
            guard let resourceURL = containerUrl else { fatalError("error getting container URL") }
            let oldPath = resourceURL.appendingPathComponent(oldFileName)
            let newPath = resourceURL.appendingPathComponent(newFileName)
            
            print("OLD PATH:")
            print(oldPath)
            print("NEW PATH:")
            print(newPath)
            
            do {
                try FileManager.default.moveItem(at: oldPath, to: newPath)
                status = true
                path = newPath.path
            } catch {
                status = false
                print("❌ ERROR RENAMING FILE: \(error.localizedDescription)")
            }
            
            
        } else {
            guard let resourceURL = containerUrl else { fatalError("error getting container URL") }
            let resourcePath = resourceURL.appendingPathComponent(direcName!, isDirectory: true)
            print("File Manager Path OVER HERE: ------> \(resourcePath)")
            
            let oldPath = resourcePath.appendingPathComponent(oldFileName)
            let newPath = resourcePath.appendingPathComponent(newFileName)
            
            do {
                try FileManager.default.moveItem(at: oldPath, to: newPath)
                status = true
                path = newPath.path
            } catch {
                status = false
                print("❌ ERROR RENAMING FILE: \(error.localizedDescription)")
            }
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
                if let _ = try? Data.init(contentsOf: url!) {
                    
                    let resourcePath = self.containerUrl!
                    print("File Manager Path: ------> \(resourcePath)")
                    let pdfName = "\(fileName)"
                    print("Pdf name to save: -------> \(pdfName)")
                    
                    //saving part...
                    let actualSavingDirec = resourcePath.appendingPathComponent("\(direcPath)", isDirectory: true)
                    _ = actualSavingDirec.appendingPathComponent(pdfName, isDirectory: false)
                    
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
                if let _ = try? Data.init(contentsOf: url!) {
                    
                    let resourcePath = self.containerUrl!
                    print("File Manager Path: ------> \(resourcePath)")
                    let pdfName = "\(fileName)"
                    print("Pdf name to save: -------> \(pdfName)")
                    
                    //saving part...
                    _ = resourcePath.appendingPathComponent("\(pdfName)", isDirectory: false)
                    
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
            // DocWind
            
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
        print((direcName ?? "failing so default value") as String)
        print("name",fileName)
        
        if direcName == nil {
            
            print(resourceURL.appendingPathComponent(fileName).path)
            let contents = try! FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
            print(contents)
            
            if FileManager.default.fileExists(atPath: resourceURL.appendingPathComponent(fileName).path) {
                print("here")
            } else {
                print("not here")
                status = false
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
            print("urlString: ",urlString ?? "")
            print("url: ",url ?? "")
            
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
                // directory name not specified, there using main directory as ref i.e., `DocWind`
                
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
        
        // check for document directory sub dire named `DocWind`'s existance
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
//            status = true
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
    
    /// update pdf file to documents directory
    /// - Parameters:
    ///   - pdfData: data of pdf to store
    ///   - pdfName: pdf name
    ///   - directoryRef: folder reference to store file in
    /// - Returns: state of the completion of executing
    func updateFileWithPDFContent(pdfData: Data, pdfName: String, directoryRef: String?) -> (Bool, String) {
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
            
            // to check if the file is already saved before
            if self.pdfAlreadySaved(directory: resourceURL.path, fileName: actualPDFName, fileurl: newSavingPath.path) {
                // found file
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

            } else {
                // not found file\
                status = false
                print("❌ PDF NOT FOUND")
            }
            
        } else {
            // when something is specified, saving in sub is assumed
            
            let actualPDFName = pdfName
            print("PDF NAME TO BE SAVED: \(actualPDFName) ---!") // contains .pdf
            
            let actualPDFData = pdfData
            print("PDF does contain data: \(!actualPDFData.isEmpty)")
                        
            guard let ref = directoryRef else { fatalError() }
            
            let relativeFilePath = resourceURL.appendingPathComponent(ref, isDirectory: true)
            print("RELATIVE PATH: \(relativeFilePath)")
            // getting final directory path
            let newSavingPath = relativeFilePath.appendingPathComponent(actualPDFName, isDirectory: false)
            print("FINAL SAVING PATH: \(newSavingPath) --!")
            
            // to check if the file is already saved before
            if self.pdfAlreadySaved(directory: relativeFilePath.path, fileName: actualPDFName, fileurl: newSavingPath.path) {
                
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
                
            } else {
                // not found file\
                
                // found file
                status = false
                print("❌ PDF NOT FOUND")
            }
            
                        
        }
        
        return (status, path)
    }
    
    func syncUpLocalFilesWithApp(direcName: String?, directory: DirecModel, context: NSManagedObjectContext) -> Bool {
        
        var status = false
        
        // getting the main directory file URL
        guard let resourceURL = containerUrl else { fatalError("error getting container URL") }
        
        if FileManager.default.fileExists(atPath: resourceURL.path) {
            print("Exists")
        } else {
            print("Doesnt exist")
        }
        
        if direcName == nil {
            // not under a direc

            /// only for deleting  the AppSettings file
            let container =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            /// go through all the contents first for CONTAINER not under docWind
            let contents = try! FileManager.default.contentsOfDirectory(at: container, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
            print("contents: ", contents)
            
            // delete AppSettings
            do {
                for url in contents {
                    let lastParts = url.path.split(separator: "/")
                    let lastName = String(lastParts.last!)
                                        
                    if lastName.contains(".plist") {
                        // delete
                        try FileManager.default.removeItem(at: url)
                        print("SUCCESSFULLY DELETED APP-SETTINGS FILE ✅")
                    }
                }
            } catch {
                print("❌ APP-SETTINGS COULD'NT BE FOUND ")
                print("////reason: \(error.localizedDescription)")
            }
            
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                print(contents)
                
                /// going through all the files one by one
                for url in contents {
                    
                    print(directory.filesName)
                    print(url.path.replacingOccurrences(of: "_", with: " "))
                    
                    let lastParts = url.path.split(separator: "/")
                    let lastName = String(lastParts.last!)
                    print(String(lastParts.last!))
                    
                    if lastName.contains(".pdf") {
                        
                        let lastNameNew = lastName.replacingOccurrences(of: " ", with: "_")
                        print(lastName.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".pdf", with: ""))
                        print(lastNameNew)
                        
                        if !directory.filesName.contains(lastName.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".pdf", with: "")) {
                            print("doesnt exist")
                            
                            let stat = renameFile(direcName: direcName, oldFileName: lastName, newFileName: lastNameNew)
                            if stat.0 {
                                // add it too items
                                let item = ItemModel(context: context)
                                item.itemName = lastNameNew.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".pdf", with: "")
                                item.itemType = DWPDFFILE
                                item.itemURL = stat.1
                                item.iconName = "blue"
                                item.locked = NSNumber(booleanLiteral: false)
                                item.itemCreated = Date()
                                item.origin = directory

                                do {
                                   try context.save()
                                   print("✅ created and saved \(lastNameNew.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".pdf", with: " ")) to coredata")
                                    status = true
                               } catch {
                                   print("❌ FAILED TO UPDATE COREDATA")
                               }
                            }
                            
                        } else {
                            print("already exists")
                            
                            /// no new files to add
                            status = false
                        }
                    } else {
                        // its a directory
                        print("directory")
                        let lastNameNew = lastName.replacingOccurrences(of: " ", with: "_")
                        print(lastName.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".pdf", with: ""))
                        print(lastNameNew)
                        
                        if !directory.filesName.contains(lastName.replacingOccurrences(of: "_", with: " ")) {
                            /// renaming folder
                            let stat = renameFile(direcName: direcName, oldFileName: lastName, newFileName: lastNameNew)
                            if stat.0 {
                                
                                /// add to items
                                let item = ItemModel(context: context)
                                item.itemName = lastNameNew.replacingOccurrences(of: "_", with: " ")
                                item.itemType = DWDIRECTORY
                                item.itemURL = stat.1
                                item.iconName = "blue"
                                item.locked = NSNumber(booleanLiteral: false)
                                item.itemCreated = Date()
                                item.origin = directory
                                        
                                let newDirec = DirecModel(context: context)
                                newDirec.name = lastNameNew.replacingOccurrences(of: "_", with: " ")
                                newDirec.created = Date()
                                
                                do {
                                   try context.save()
                                   print("✅ created and saved \(lastNameNew.replacingOccurrences(of: "_", with: " ")) to coredata")
                                    status = true
                               } catch {
                                   print("❌ FAILED TO UPDATE COREDATA")
                               }
                            }
                        } else {
                            print("already exists")
                            status = false
                        }
                    }
                }
            } catch {
                print("❌ Directory COULD'NT BE FOUND ")
                print("////reason: \(error.localizedDescription)")
            }
            
            
        } else {
            // under a direc            
            /// get directory name
            let ref = direcName!.replacingOccurrences(of: " ", with: "_").trimBothSides()
            let relativeFilePath = resourceURL.appendingPathComponent(ref, isDirectory: true)
            print("RELATIVE PATH: \(relativeFilePath)")
            
            /// go through all the contents first
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: relativeFilePath, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                print(contents)
                
                /// going through all the files one by one
                for url in contents {
                    
                    print(directory.filesName)
                    print(url.path.replacingOccurrences(of: "_", with: " "))
                    
                    let lastParts = url.path.split(separator: "/")
                    let lastName = String(lastParts.last!)
                    print(String(lastParts.last!))
                    
                    if lastName.contains(".pdf") {
                        
                        let lastNameNew = lastName.replacingOccurrences(of: " ", with: "_")
                        print(lastName.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".pdf", with: ""))
                        print(lastNameNew)
                        
                        if !directory.filesName.contains(lastName.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".pdf", with: "")) {
                            print("doesnt exist")
                            
                            let stat = renameFile(direcName: ref, oldFileName: lastName, newFileName: lastNameNew)
                            if stat.0 {
                                // add it too items
                                let item = ItemModel(context: context)
                                item.itemName = lastNameNew.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".pdf", with: "")
                                item.itemType = DWPDFFILE
                                item.itemURL = stat.1
                                item.iconName = "blue"
                                item.locked = NSNumber(booleanLiteral: false)
                                item.itemCreated = Date()
                                item.origin = directory

                                do {
                                   try context.save()
                                   print("✅ created and saved \(lastNameNew.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".pdf", with: " ")) to coredata")
                               } catch {
                                   print("❌ FAILED TO UPDATE COREDATA")
                               }
                            }
                            
                        } else {
                            print("already exists")
                        }
                    }
                    // no sub directory creation allowed
                }
            } catch {
                print("❌ Directory COULD'NT BE FOUND ")
                print("////reason: \(error.localizedDescription)")
            }
        }
        
        return status
        
    }
    
    /// END OF EXTENSION
}
