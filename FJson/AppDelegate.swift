//
//  AppDelegate.swift
//  FJson
//
//  Created by Andras Helyes on 3/12/16.
//  Copyright © 2016 11toes. All rights reserved.
//

import Cocoa
import Foundation
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    let contextMenu = NSMenu()
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //Init
        if let button = statusItem.button {
            button.image = NSImage(named: "AppIcon")
            
            button.target = self
            button.action = #selector(self.statusBarButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            
        }
        
        
        //        let menu = NSMenu()
        //
        //        menu.addItem(NSMenuItem(title: "Format", action: #selector(prettifyClipboardJSON(sender:)), keyEquivalent: "F"))
        //        menu.addItem(NSMenuItem.separator())
        //        menu.addItem(NSMenuItem(title: "Quit", action: #selector(ExitNow(sender:)), keyEquivalent: "q"))
        //
        //        statusItem.menu = menu
        
        //        contextMenu.addItem(NSMenuItem(title: "Jira", action: #selector(copyJiraTemplateToClipboard(sender:)), keyEquivalent: "J"))
        //        contextMenu.addItem(NSMenuItem(title: "Format", action: #selector(prettifyClipboardJSON(sender:)), keyEquivalent: "F"))
        //        contextMenu.addItem(NSMenuItem.separator())
        //        contextMenu.addItem(NSMenuItem(title: "Quit", action: #selector(ExitNow(sender:)), keyEquivalent: "q"))
        
        // let folderPath = NSBundle.mainBundle().pathForResource("Files", ofType: nil)
        let folderPath = "~/";
        let templateFilePaths = getFJsonTemplateFilePaths(atPath: folderPath, withExtension: "txt")
        print("Template files: \(templateFilePaths)")
        
        //var jiraTemplateFileContents: [String] = []
        
        var theFileName = "";
        var counter = 0;
        for path in templateFilePaths {
            theFileName = (path as NSString).lastPathComponent
            print("Filename: \(theFileName)");
            //  theFileName = (path as NSString).absoluteString
            print("Path: \(theFileName)");
            
            let label = getTemplateLabel(file: theFileName)
            print ("Label: \(label)")
            
            let thisTemplate = readContent(file: path)
            print("Tempalte: \(thisTemplate)");
            // let obj = AAA();
            
            counter = counter + 1
            let menuitem = NSMenuItem(title: label, action: #selector(copyTemplateToClipboard(sender:)), keyEquivalent: String(counter))
            menuitem.representedObject = path;
            contextMenu.addItem(menuitem)
        }
        
        if contextMenu.items.count > 0 {
            contextMenu.addItem(NSMenuItem.separator())
        }
        contextMenu.addItem(NSMenuItem(title: "Format", action: #selector(prettifyClipboardJSON(sender:)), keyEquivalent: "F"))
        contextMenu.addItem(NSMenuItem.separator())
        contextMenu.addItem(NSMenuItem(title: "Quit", action: #selector(ExitNow(sender:)), keyEquivalent: "q"))
        
        
    }
    
    // --------------------
    func copyTemplateToClipboard(sender: NSMenuItem) {
        let target = sender.representedObject as! String
        let content = readContent(file: target)
        //print("The content: \(content)")
        copyToPasteboard(text: content)
        
    }
    
    func getTemplateLabel (file: String) -> String {
        var ret = "Could not parse filename: \(file)";
        
        var tokens = file.components(separatedBy: ".");
        
        tokens.remove(at: 0)
        tokens.remove(at: tokens.count-1)
        tokens.remove(at: tokens.count-1)
        tokens.remove(at: tokens.count-1)
        
        
        
        ret = tokens.joined()
        return ret;
    }
    
    
    class AAA: NSObject {
        var path = "1.2.txt"
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Tear down
    }
    
    
    func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == NSEventType.rightMouseUp {
            print("Right click")
            statusItem.menu = contextMenu
            statusItem.popUpMenu(contextMenu)
            
            // This is critical, otherwise clicks won't be processed again
            statusItem.menu = nil
        } else {
            print("Left click")
            
            // prettifyClipboardJSON(sender:)
            
            //uber dry - content of prettifyClipboardJSON - call above doesnt work
            let pasteboard = NSPasteboard.general()
            
            let pasteboardString = pasteboard.string(forType: NSPasteboardTypeString)
            
            let pasteboardStringTrimmed = pasteboardString?.trimmingCharacters(in: .whitespacesAndNewlines);
            
            
            //print("Original pasteboard: \(pasteboardString)")
            //print("Trimmed  pasteboard: \(pasteboardStringTrimmed)")
            
            let jsonObj = JSONParseDictionary(string: pasteboardStringTrimmed!)
            //print("JSON: \(jsonObj)")
            
            let jsonString = JSONStringify(value: jsonObj as AnyObject, prettyPrinted:true)
            print(jsonString)
            
            copyToPasteboard(text: jsonString)
            
        }
    }
    
    
    
    
    func readContent (file: String) -> String {
        
        var template = "Could not read file \(file)";
        
        let location = NSString(string:file).expandingTildeInPath
        
        do {
            print("Reading file: \(file)")
            template = try NSString(contentsOfFile: location, encoding: String.Encoding.utf8.rawValue) as String
        } catch {
            print("Error: \(error)")
            print(Thread.callStackSymbols)
        }
        return template
    }
    
    
    func getFJsonTemplateFilePaths(atPath path: String, withExtension fileExtension:String) -> [String] {
        //let pathURL = NSURL(fileURLWithPath: path, isDirectory: true)
        var ret: [String] = []
        let fileManager = FileManager.default
        let location = NSString(string:path).expandingTildeInPath
        
        
        do {
            //if let enumerator = fileManager.enumerator(atPath: location) {
            let enumerator = try fileManager.contentsOfDirectory(atPath: location)
            //print(enumerator)
            
            let fjsonTemplates = enumerator.filter{ $0.hasPrefix("fjson") && $0.hasSuffix("txt") }
            print("fjson file names:",fjsonTemplates)
            
            for file in fjsonTemplates {
                //       print("Enum \(file)" )
                //if let path = NSURL(fileURLWithPath: file , relativeTo: pathURL as URL).absoluteString
                
                
                // ,path.hasPrefix("jsonf")
                // {
                //       ret.append(path)
                
                // ret.append(location + path)
                let locpath = location + "/" + file
                //print("locapath: \(locpath)")
                ret.append(locpath)
                //}
            }
            
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return ret
    }
    
    
    // --------------------
    func prettifyClipboardJSON(sender: AnyObject) {
        
        let pasteboard = NSPasteboard.general()
        
        let pasteboardString = pasteboard.string(forType: NSPasteboardTypeString)
        
        let pasteboardStringTrimmed = pasteboardString?.trimmingCharacters(in: .whitespacesAndNewlines);
        
        //print("Original pasteboard: \(pasteboardString)")
        //print("Trimmed  pasteboard: \(pasteboardStringTrimmed)")
        
        let jsonObj = JSONParseDictionary(string: pasteboardStringTrimmed!)
        //print("JSON: \(jsonObj)")
        
        let jsonString = JSONStringify(value: jsonObj as AnyObject, prettyPrinted:true)
        print(jsonString)
        
        
        copyToPasteboard(text: jsonString)
        
    }
    
    
    
    func copyToPasteboard(text: String) {
        let pasteboard = NSPasteboard.general()
        pasteboard.clearContents()
        pasteboard.setString(text, forType: NSPasteboardTypeString)
        
        
    }
    
    
    func JSONStringify(value: AnyObject,prettyPrinted:Bool = false) -> String{
        
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        
        if JSONSerialization.isValidJSONObject(value) {
            
            do{
                let data = try JSONSerialization.data(withJSONObject: value, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    print("Formatted: \(string)")
                    
                    return string as String
                }
                
            } catch let error as NSError {
                print("Error: \(error)")
                print(Thread.callStackSymbols)
            }
        }
        return ""
        
    }
    
    func JSONParseDictionary(string: String) -> [String: AnyObject]{
        
        
        if let data = string.data(using: String.Encoding.utf8){
            
            do{
                if let dictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]{
                    
                    return dictionary
                    
                }
            }catch {
                
                print("error")
            }
        }
        return [String: AnyObject]()
    }
    
    
    func ExitNow(sender: AnyObject) {
        NSApplication.shared().terminate(self)
    }
    
}

