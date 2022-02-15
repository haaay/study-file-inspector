//
//  FileChief.swift
//  FileInspector
//
//  Created by hayk on 01.10.2021.
//

import Foundation
import UIKit

protocol FileChiefDelegate: UIViewController {
    func updateFolder(_ name: String, isMain: Bool)
    func presentFolder()
}

class FileChief {
    
    // MARK: - Singleton -
    
    static let instance = FileChief()
    private init() {
        if currentURL == nil { currentURL = mainURL }
    }
    
    var delegate: FileChiefDelegate? {
        didSet {
            displayFolder()
        }
    }
    
    // MARK: - Models -
    
    struct Unit {
        var name: String
        var isDirectory: Bool
    }
    
    // MARK: - Variables -
    
    let manager = FileManager.default
    
    var mainURL: URL? {
        manager.urls(
            for: .documentDirectory,
            in: .userDomainMask).first
    }
    
    var units: [Unit] = []
    var currentURL: URL?
    
    // MARK: - Methods -
    
    // MARK: Displaying
    
    func displayFolder() {
        
        func contents(at url: URL) -> [String] {
            do {
                return try manager.contentsOfDirectory(atPath: url.path)
            } catch {
                print(error)
                return []
            }
        }
        
        guard let url = currentURL else { return }
        
        units = contents(at: url).map {
            
            var isDirectory: ObjCBool = false
            let path = url.appendingPathComponent($0).path
            
            if manager.fileExists(atPath: path, isDirectory: &isDirectory) {
                return Unit(name: $0, isDirectory: isDirectory.boolValue)
            } else {
                return Unit(name: "", isDirectory: false)
            }
        }
        
        units.sort {
            let isSameType = $0.isDirectory && $1.isDirectory || !$0.isDirectory && !$1.isDirectory
            return isSameType ? $0.name < $1.name : $0.isDirectory
        }
        
        delegate?.updateFolder(url.lastPathComponent, isMain: currentURL == mainURL)
    }
    
    // MARK: Creating
    
    func newUnitURL(withKey key: String, extension fileExtension: String) -> URL? {
        
        let set = CharacterSet(charactersIn: " .")
        
        let maxUnitNum = units.filter { $0.name.contains(key) }.map {
            Int($0.name.components(separatedBy: set).dropFirst().first ?? "0") ?? 0
        }.sorted().last ?? 0
        
        guard let url = currentURL else { return nil }
        
        let newUnitName = key + " \(maxUnitNum + 1)" + fileExtension
        return url.appendingPathComponent(newUnitName)
    }
    
    func createFolder() {
        
        let key = "Folder"
        guard let newFolderURL = newUnitURL(withKey: key, extension: "") else { return }
        
        do {
            try manager.createDirectory(
                at: newFolderURL,
                withIntermediateDirectories: true,
                attributes: [:])
        } catch {
            print(error)
        }
        
        displayFolder()
    }
    
    func createFile() {
        
        let key = "File"
        guard let newFileURL = newUnitURL(withKey: key, extension: ".txt") else { return }

        let data = randomText().data(using: .utf8)
        
        manager.createFile(
            atPath: newFileURL.path,
            contents: data,
            attributes: [FileAttributeKey.creationDate : Date()])
        
        displayFolder()
    }
    
    // MARK: Deleting
    
    func commitRemovingForRowAt(_ indexPath: IndexPath) {
        
        guard let url = currentURL else { return }
        
        let unitName = units[indexPath.row].name
        let unitURL = url.appendingPathComponent(unitName)
        
        do {
            try manager.removeItem(atPath: unitURL.path)
            displayFolder()
        } catch {
            print(error)
        }
    }
    
    // MARK: Selecting
    
    func commitSelectingForRowAt(_ indexPath: IndexPath) {
        
        guard let url = currentURL else { return }
        
        let unit = units[indexPath.row]
        let unitURL = url.appendingPathComponent(unit.name)
        
        if unit.isDirectory {
            guard let justDelegate = delegate else { return }
            currentURL = unitURL
            justDelegate.presentFolder()
        } else {
            do {
                let text = try String(contentsOf: unitURL, encoding: .utf8)
                delegate?.presentAlert(withTitle: unit.name, message: text)
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: Pop
    
    func pop() {
        currentURL?.deleteLastPathComponent()
    }
    
    // MARK: Services
    
    func randomText() -> String {
        
        let greetings = ["Hi", "Hello", "Hey"]
        let names = ["Mark", "Sidney", "Liam", "Leo"]
        let phrases = ["How are you?", "What's up?", "What are you doing?"]
        
        return greetings.randomElement()! + " " + names.randomElement()! + "!\n" + phrases.randomElement()!
    }
}
