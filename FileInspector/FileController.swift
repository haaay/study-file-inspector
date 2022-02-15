//
//  FileController.swift
//  FileInspector
//
//  Created by hayk on 16.09.2021.
//

import UIKit

class FileController: UITableViewController, FileChiefDelegate {
    
    let chief = FileChief.instance
    
    // MARK: Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func setBarButtons() {
            
            let fileButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createFile))
            let folderButton = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(createFolder))
            
            navigationItem.setRightBarButtonItems([fileButton,folderButton], animated: true)
        }
        
        setBarButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chief.delegate = self
    }
    
    // MARK: Creating
    
    @objc func createFolder() {
        chief.createFolder()
    }
    
    @objc func createFile() {
        chief.createFile()
    }
    
    // MARK: File Chief Delegate
    
    func updateFolder(_ name: String, isMain: Bool) {
        
        func setBackItem() {
            let backButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(back))
            navigationItem.setLeftBarButton(backButton, animated: true)
        }
        
        func deleteBackItem() {
            navigationItem.leftBarButtonItem = nil
        }
        
        tableView.reloadData()
        isMain ? deleteBackItem() : setBackItem()
        title = name
    }
    
    func presentFolder() {
        
        let fileController = storyboard?.instantiateViewController(withIdentifier: fileControllerIdentifier) as! FileController
        
        navigationController?.pushViewController(fileController, animated: true)
    }
    
    // MARK: Data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chief.units.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let unit = chief.units[indexPath.row]
        
        cell.textLabel?.text = unit.name
        cell.imageView?.image = UIImage(named: unit.isDirectory ? "folder.png" : "file.png")

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        chief.commitRemovingForRowAt(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chief.commitSelectingForRowAt(indexPath)
    }
    
    // MARK: Navigating
    
    @objc func back() {
        chief.pop()
        navigationController?.popViewController(animated: true)
    }
}
