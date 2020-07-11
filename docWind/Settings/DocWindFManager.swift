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
    func savePdf(urlString: String, direcName: String?, fileName: String) -> Bool
    func showSavedPdf(urlString: String, direcName: String?, fileName: String) -> Bool
    func pdfFileAlreadySaved(direcName: String?, fileName:String) -> Bool
    func creatingDirectory(direcName: String) -> Bool
    func createSubDirectory(direcName: String) -> Bool
    func createSubSubDirectory(headName: String, newDirecName: String) -> Bool
    func savePdfWithDataContent(pdfData: Data, pdfName: String, direcName: String?) -> (Bool, String)
}

//MARK: - Extension
extension DocWindFManager {
    /// START OF EXTENSION
    
    func fileURL() -> URL {
        let direcURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return direcURL.appendingPathComponent("DocWind", isDirectory: true)
    }
    
    func savePdfWithDataContent(pdfData: Data, pdfName: String, direcName: String?) -> (Bool, String) {
        var status = false
        var path = ""
        
        if direcName != nil {
            let resourcePath = self.fileURL()
            print("File Manager Path: ------> \(resourcePath)")
            let pdfName = "\(pdfName)"
            print("Pdf name to save: -------> \(pdfName)")
            let pdfData = pdfData
            
            // saving part
            let actualSavingDirectory = resourcePath.appendingPathComponent("\(direcName!)", isDirectory: true)
            let actualSavingFilePath = actualSavingDirectory.appendingPathComponent(pdfName, isDirectory: false)
            
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
            let resourcePath = self.fileURL()
            print("File Manager Path: ------> \(resourcePath)")
            let pdfName = "\(pdfName)"
            print("Pdf name to save: -------> \(pdfName)")
            let pdfData = pdfData
            
            // saving part
            let actualSavingFilePath = resourcePath.appendingPathComponent(pdfName, isDirectory: false)
            
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
                    
                    let resourcePath = self.fileURL()
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
                    
                    let resourcePath = self.fileURL()
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
    
    func showSavedPdf(urlString: String, direcName: String?, fileName: String) -> Bool {
        var status = false
        
        // check for direcName
        if direcName != nil {
            
            let direcPath = direcName!
            let _ = URL(string: urlString)
            let resourcePath = self.fileURL().appendingPathComponent(direcPath, isDirectory: true)
            print("File Manager Path: ------> \(resourcePath)")
            
            do {
                 let contents = try FileManager.default.contentsOfDirectory(at: resourcePath, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                    for url in contents {
                        if url.description.contains("\(fileName)") {
                            status = true
                            print("✅ FOUND PDF SUCCESSFULLY")
                            // do something with file
                        }
                    }
            } catch {
                print("❌ PDF COULD'NT BE SAVED ")
                print("////reason: \(error.localizedDescription)")
                status = false
            }
            
            return status
        } else {
            let _ = URL(string: urlString)
            let resourcePath = self.fileURL()
            print("File Manager Path: ------> \(resourcePath)")
            
            do {
                 let contents = try FileManager.default.contentsOfDirectory(at: resourcePath, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                    for url in contents {
                        if url.description.contains("\(fileName)") {
                            status = true
                            print("✅ FOUND PDF SUCCESSFULLY")
                            // do something with file
                        }
                    }
            } catch {
                print("❌ PDF COULD'NT BE SAVED ")
                print("////reason: \(error.localizedDescription)")
                status = false
            }
            
            return status
        }
    }
    
    func pdfFileAlreadySaved(direcName: String?, fileName:String) -> Bool {
        var status = false
        
        // check for direc name
        if direcName != nil {
            
            let direcPath = direcName!
            let resourcePath = self.fileURL().appendingPathComponent(direcPath, isDirectory: true)
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
                print("❌ PDF COULD'NT BE LOCATED ")
                print("////reason: \(error.localizedDescription)")
                status = false
            }
            
            return status
        } else {
            let resourcePath = self.fileURL()
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
        
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        print("File Manager Path: ------> \(documentsPath)")
        let logsPath = documentsPath.appendingPathComponent("\(direcName)")
        print("Updated Manager Path: ------> \(String(describing: logsPath))")
                
        do {
            try FileManager.default.createDirectory(atPath: logsPath!.path, withIntermediateDirectories: true, attributes: nil)
            status = true
            print("✅ SUCCESSFULLY CREATED DIRECTORY")
        } catch {
            print("❌ FAILED TO CREATED DIRECTORY")
            print("////reason: \(error.localizedDescription)")
            status = false
        }
        
        return status
    }
    
    func createSubDirectory(direcName: String) -> Bool {
        var status = false
        
        let documentsPath = fileURL()
        print("File Manager Path: ------> \(documentsPath)")
        let logsPath = documentsPath.appendingPathComponent("\(direcName)")
        print("Updated Manager Path: ------> \(String(describing: logsPath))")
                
        do {
            try FileManager.default.createDirectory(atPath: logsPath.path, withIntermediateDirectories: true, attributes: nil)
            status = true
            print("✅ SUCCESSFULLY CREATED  \(direcName) DIRECTORY")
        } catch {
            print("❌ FAILED TO CREATED DIRECTORY")
            print("////reason: \(error.localizedDescription)")
            status = false
        }
        
        return status
    }
    
    func createSubSubDirectory(headName: String, newDirecName: String) -> Bool {
        var status = false
        
        let documentsPath = fileURL().appendingPathComponent("\(headName)")
        print("File Manager Path: ------> \(documentsPath)")
        let logsPath = documentsPath.appendingPathComponent("\(newDirecName)")
        print("Updated Manager Path: ------> \(String(describing: logsPath))")
                
        do {
            try FileManager.default.createDirectory(atPath: logsPath.path, withIntermediateDirectories: true, attributes: nil)
            status = true
            print("✅ SUCCESSFULLY CREATED  \(headName)/\(newDirecName) DIRECTORY")
        } catch {
            print("❌ FAILED TO CREATED DIRECTORY")
            print("////reason: \(error.localizedDescription)")
            status = false
        }
        
        return status
    }
    
    /// END OF EXTENSION
}
