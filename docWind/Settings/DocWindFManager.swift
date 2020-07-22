//
//  DocWindFManager.swift
//  docWind
//
//  Created by Sarvad shetty on 7/2/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation

// MARK: - Main protocol
protocol DocWindFManager {
    func fileURL() -> URL
    func reset()
    func savePdf(urlString: String, direcName: String?, fileName: String) -> Bool
    func showSavedPdf(direcName: String?, fileName: String) -> (Bool, String)
    func pdfFileAlreadySaved(direcName: String?, fileName:String) -> Bool
    func creatingDirectory(direcName: String) -> Bool
    func createSubDirectory(direcName: String) -> (Bool, String)
    func createSubSubDirectory(headName: URL, newDirecName: String) -> (Bool, String)
    func savePdfWithDataContent(pdfData: Data, pdfName: String, direcName: String?) -> (Bool, String)
    func savePdfWithSubFolder(pdfData: Data, pdfName: String, subDir: String) -> (Bool, String)
    func deleteSavedPdf(direcName: String?, fileName: String) -> Bool
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
//            try FileManager.default.evictUbiquitousItem(at: containerUrl!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fileURL() -> URL {
//        let direcURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        print("MAIN ---->",FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//        return direcURL.appendingPathComponent("DocWind", isDirectory: true)
        
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
        
        let actualSavingFilePath = direcPath.appendingPathComponent(pdfName, isDirectory: false)
        print("Actiual saved path --------> \(actualSavingFilePath)")
        // before saving check if filename already exists
        if self.pdfFileAlreadySaved(direcName: "\(direcPath)", fileName: pdfName) {
            // already saved
            status = false
            print("❌ PDF ALREADY SAVED BEFORE")
        } else {
            // not saved
            // start writing
            do {
                try pdfData.write(to: actualSavingFilePath, options: .atomic)
                print("✅ SAVED PDF SUCCESSFULLY")
                path = "\(actualSavingFilePath)"
                status = true
            } catch {
                print("❌ PDF COULD'NT BE SAVED ")
                print("////reason: \(error.localizedDescription)")
                status = false
            }
        }
        
        return (status, path)
    }
    
    func savePdfWithDataContent(pdfData: Data, pdfName: String, direcName: String?) -> (Bool, String) {
        var status = false
        var path = ""
        
        if direcName != nil {
            let resourcePath = self.containerUrl!
            print("File Manager Path: ------> \(resourcePath)")
            let pdfName = "\(pdfName)"
            print("Pdf name to save: -------> \(pdfName)")
            let pdfData = pdfData
            
            // saving part
            let actualSavingDirectory = resourcePath.appendingPathComponent("\(direcName!)", isDirectory: true)
            let actualSavingFilePath = actualSavingDirectory.appendingPathComponent(pdfName, isDirectory: false)
            
            print("SAVING DIREC PATH ", actualSavingDirectory)
            print("SAVING FILE PATH ", actualSavingFilePath)
            
            // before saving check if filename already exists
            if self.pdfFileAlreadySaved(direcName: direcName, fileName: pdfName) {
                // already saved
                status = false
                print("❌ PDF ALREADY SAVED BEFORE")
            } else {
                // not saved
                // start writing
                do {
                    try pdfData.write(to: actualSavingFilePath, options: .atomic)
                    print("✅ SAVED PDF SUCCESSFULLY")
                    path = "\(actualSavingFilePath)"
                    status = true
                } catch {
                    print("❌ PDF COULD'NT BE SAVED ")
                    print("////reason: \(error.localizedDescription)")
                    status = false
                }
            }
        } else {
            let resourcePath = self.containerUrl!
            print("File Manager Path: ------> \(resourcePath)")
            let pdfName = "\(pdfName)"
            print("Pdf name to save: -------> \(pdfName)")
            let pdfData = pdfData
            
            // saving part
            let actualSavingFilePath = resourcePath.appendingPathComponent(pdfName, isDirectory: false)
            print("SAVING FILE PATH ", actualSavingFilePath)
            // before saving check if filename already exists
            if self.pdfFileAlreadySaved(direcName: "\(resourcePath)", fileName: pdfName) {
                // already saved
                status = false
                print("❌ PDF ALREADY SAVED BEFORE")
            } else {
                // not saved
                // start writing
                do {
                    try pdfData.write(to: actualSavingFilePath, options: .atomic)
                    print("✅ SAVED PDF SUCCESSFULLY")
                    path = "\(actualSavingFilePath)"
                    status = true
                } catch {
                    print("❌ PDF COULD'NT BE SAVED ")
                    print("////reason: \(error.localizedDescription)")
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
                    if self.pdfFileAlreadySaved(direcName: direcName, fileName: fileName) {
                        // already saved
                        print("❌ PDF ALREADY SAVED BEFORE")
                        status = false
                    } else {
                        // not saved
                        
                        // lets save now
                        do {
                            try pdfdata.write(to: actualSavingPath, options: .atomic)
                            print("✅ SAVED PDF SUCCESSFULLY")
                            status = true
                        } catch {
                            print("❌ PDF COULD'NT BE SAVED ")
                            print("////reason: \(error.localizedDescription)")
                            status = false
                        }
                    }
                    
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
                    if self.pdfFileAlreadySaved(direcName: direcName, fileName: fileName) {
                        // already saved
                        print("❌ PDF ALREADY SAVED BEFORE")
                    } else {
                        // not saved
                        
                        // lets save now
                        do {
                            try pdfdata.write(to: actualSavingPath, options: .atomic)
                            print("✅ SAVED PDF SUCCESSFULLY")
                            status = true
                        } catch {
                            print("❌ PDF COULD'NT BE SAVED ")
                            print("////reason: \(error.localizedDescription)")
                            status = false
                        }
                    }
                } else {
                    // if failed alert
                    print("❌ PDF COULD'NT BE SAVED, ERROR CONVERTING INTO DATA TYPE")
                    status = false
                }
            }
            return status
        }
    }
    
    func deleteSavedFolder(dirname: String?, fileName: String) -> Bool {
        var status = false
        
        if dirname != nil {
            let resourcePath = URL(string: dirname!)!
            print("File Manager Path OVER HERE: ------> \(resourcePath)")
            
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: resourcePath, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                print(contents)
                print(fileName)
                for url in contents {
                    print(url)
                    
                    if url.description.contains("/\(fileName)/") {
                        try FileManager.default.removeItem(at: url)
                        print("SUCCESSFULLY DELETED folder ✅")
                        status = true
                    } else {
                        print("Couldnt find the folder 😞")
                    }
                }
                
            } catch {
                status = false
                print("error while deleting file \(error.localizedDescription)")
            }
        } else {
            let resourcePath = self.containerUrl!
            print("File Manager Path OVER HERE: ------> \(resourcePath)")
            
            do {
                 let contents = try FileManager.default.contentsOfDirectory(at: resourcePath, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                    for url in contents {
                        if url.description.contains("\(fileName)") {
                            try FileManager.default.removeItem(atPath: resourcePath.path + fileName)
                            print("SUCCESSFULLY DELETED FILE ✅")
                            status = true
                        } else {
                            print("Couldnt find the file 😞")
                            status = false
                        }
                    }
            } catch {
                status = false
                print("error while deleting file \(error.localizedDescription)")
            }

        }
        
        return status
    }
    
    func deleteSavedPdf(direcName: String?, fileName: String) -> Bool {
        var status = false
        
        if direcName != nil {
            let resourcePath = URL(string: direcName!)!
            print("File Manager Path OVER HERE: ------> \(resourcePath)")
            
            // search and deletion part
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: resourcePath, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                
                for url in contents {
                    if url.description.contains("\(fileName)") {
                        try FileManager.default.removeItem(at: url)
                        print("SUCCESSFULLY DELETED FILE ✅")
                        status = true
                    } else {
                        print("Couldnt find the file 😞")
                    }
                }
            } catch {
                status = false
                print("error while deleting file \(error.localizedDescription)")
            }
        } else {
            let resourcePath = self.containerUrl!
            print("File Manager Path OVER HERE: ------> \(resourcePath)")
            
            do {
                 let contents = try FileManager.default.contentsOfDirectory(at: resourcePath, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                    for url in contents {
                        if url.description.contains("\(fileName)") {
                            try FileManager.default.removeItem(atPath: resourcePath.path + fileName)
                            print("SUCCESSFULLY DELETED FILE ✅")
                            status = true
                        } else {
                            print("Couldnt find the file 😞")
                            status = false
                        }
                    }
            } catch {
                status = false
                print("error while deleting file \(error.localizedDescription)")
            }
        }
        
        return status
    }
    
    func showSavedPdf(direcName: String?, fileName: String) -> (Bool, String) {
        var status = false
        var path = ""
        
        if direcName != nil {
            let resourcePath = URL(string: direcName!)!
            print("File Manager Path OVER HERE: ------> \(resourcePath)")
            
            do {
                 let contents = try FileManager.default.contentsOfDirectory(at: resourcePath, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                    for url in contents {
                        if url.description.contains("\(fileName)") {
                            status = true
                            path = "\(url.description)"
                            print("✅ FOUND PDF SUCCESSFULLY \(url.description)")
                            // do something with file
                        }
                    }
            } catch {
                print("❌ PDF COULD'NT BE FOUND ")
                print("////reason: \(error.localizedDescription)")
                status = false
            }
        } else {
            let resourcePath = self.containerUrl!
            print("File Manager Path OVER HERE: ------> \(resourcePath)")
            
            do {
                 let contents = try FileManager.default.contentsOfDirectory(at: resourcePath, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                    for url in contents {
                        if url.description.contains("\(fileName)") {
                            status = true
                            path = "\(url.description)"
                            print("✅ FOUND PDF SUCCESSFULLY \(url.description)")
                            // do something with file
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
    
    func pdfFileAlreadySaved(direcName: String?, fileName:String) -> Bool {
        var status = false
        
        // check for direc name
        if direcName != nil {
            
            let direcPath = URL(string: direcName!)!
//            let resourcePath = self.containerUrl!
            print("File Manager Path: ------> \(direcPath)")
            
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: direcPath, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("\(fileName)") {
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
            let resourcePath = self.containerUrl!
            print("File Manager Path: ------> \(resourcePath)")
            
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: resourcePath, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("\(fileName)") {
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
    
    func creatingDirectory(direcName: String) -> Bool {
        var status = false
        
        // check for container existence
        if let url = self.containerUrl, !FileManager.default.fileExists(atPath: url.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
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
        
        let documentsPath = self.containerUrl!
        print("File Manager Path: ------> \(documentsPath)")
        let logsPath = documentsPath.appendingPathComponent("\(direcName)", isDirectory: true)
        print("Updated Manager Path: ------> \(String(describing: logsPath))")
                
        do {
            try FileManager.default.createDirectory(atPath: logsPath.path, withIntermediateDirectories: true, attributes: nil)
            status = true
            path = "\(logsPath)"
            print("✅ SUCCESSFULLY CREATED  \(direcName) DIRECTORY")
        } catch {
            print("❌ FAILED TO CREATED DIRECTORY")
            print("////reason: \(error.localizedDescription)")
            status = false
        }
        
        return (status, path)
    }
    
    func createSubSubDirectory(headName: URL, newDirecName: String) -> (Bool, String) {
        var status = false
        var path = ""
        
        let documentsPath = headName
        print("File Manager Path: ------> \(documentsPath)")
        let logsPath = documentsPath.appendingPathComponent("\(newDirecName)", isDirectory: true)
        print("Updated Manager Path: ------> \(String(describing: logsPath))")
                
        do {
            try FileManager.default.createDirectory(atPath: logsPath.path, withIntermediateDirectories: true, attributes: nil)
            status = true
            path = "\(logsPath)"
            print("✅ SUCCESSFULLY CREATED  \(headName)\(newDirecName) DIRECTORY")
        } catch {
            print("❌ FAILED TO CREATED DIRECTORY")
            print("////reason: \(error.localizedDescription)")
            status = false
        }
        
        return (status, path)
    }
    
    /// END OF EXTENSION
}
