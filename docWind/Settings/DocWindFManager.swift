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
    func pdfFileAlreadySaved(urlString:String, direcName: String?, fileName:String) -> Bool
    func creatingDirectory(direcName: String) -> Bool
    func createSubDirectory(direcName: String) -> Bool
}

//MARK: - Extension
extension DocWindFManager {
    /// START OF EXTENSION
    
    func fileURL() -> URL {
        let direcURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return direcURL.appendingPathComponent("DocWind", isDirectory: true)
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
                    let pdfName = "\(fileName).pdf"
                    print("Pdf name to save: -------> \(pdfName)")
                    
                    //saving part...
                    let actualSavingDirec = resourcePath.appendingPathComponent("\(direcPath)", isDirectory: true)
                    let actualSavingPath = actualSavingDirec.appendingPathComponent(pdfName, isDirectory: false)
                    
                    // before saving check if file already exists
                    if self.pdfFileAlreadySaved(urlString: urlString, direcName: direcName, fileName: fileName) {
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
        } else {
            DispatchQueue.main.async {
                let url = URL(string: urlString)

                // converting contents of pdf into Data type
                if let pdfdata = try? Data.init(contentsOf: url!) {
                    
                    let resourcePath = self.fileURL()
                    print("File Manager Path: ------> \(resourcePath)")
                    let pdfName = "\(fileName).pdf"
                    print("Pdf name to save: -------> \(pdfName)")
                    
                    //saving part...
                    let actualSavingPath = resourcePath.appendingPathComponent("\(pdfName)", isDirectory: false)
                    
                    // before saving check if file already exists
                    if self.pdfFileAlreadySaved(urlString: urlString, direcName: direcName, fileName: fileName) {
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
                        if url.description.contains("\(fileName).pdf") {
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
                        if url.description.contains("\(fileName).pdf") {
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
    
    func pdfFileAlreadySaved(urlString:String, direcName: String?, fileName:String) -> Bool {
        var status = false
        
        // check for direc name
        if direcName != nil {
            
            let direcPath = direcName!
            let _ = URL(string: urlString)
            let resourcePath = self.fileURL().appendingPathComponent(direcPath, isDirectory: true)
            print("File Manager Path: ------> \(resourcePath)")
            
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: resourcePath, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("\(fileName).pdf") {
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
            let _ = URL(string: urlString)
            let resourcePath = self.fileURL()
            print("File Manager Path: ------> \(resourcePath)")
            
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: resourcePath, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("\(fileName).pdf") {
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
    
    /// END OF EXTENSION
}
