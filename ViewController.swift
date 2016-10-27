//
//  ViewController.swift
//  EvilNotes
//
//  Created by Roque Rueda on 09/09/16.
//  Copyright © 2016 RoqueRueda. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController{
    
    @IBOutlet weak var notesTable   : UITableView!
    var cellTitle  : String = ""
    var lat        : String = ""
    var long       : String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        
    }
    
    private func setupTableView() {
        self.notesTable.delegate    = self
        self.notesTable.dataSource  = self
    }
    
    private func setupNavigationBar() {
        let addNewNoteButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        self.navigationItem.rightBarButtonItem = addNewNoteButton
        
        var backBtn = UIImage(named: "home")
        backBtn     = backBtn?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        self.navigationController!.navigationBar.backIndicatorImage = backBtn;
        self.navigationController!.navigationBar.backIndicatorTransitionMaskImage = backBtn;
    }
    
    func addNewNote() {
        cellTitle = ""
        self.performSegue(withIdentifier: "noteDetails", sender: nil)
    }
    
    @IBAction func showNoteLocation(sender: AnyObject){
        
        let button          = sender as! UIButton
        let locationElement = button.tag
        let cellForMap      = notesTable.cellForRow(at: IndexPath.init(row: locationElement, section: 0)) as! EvilNoteTableViewCell
        
        let json    = getContentOfFile(fileTitle: cellForMap.titleLabel.text!)
        
        //if json.keys.contains("latitude") {
        self.lat    = json["latitude"]!
        self.long   = json["longitude"]!
        //}
        
        self.performSegue(withIdentifier: "showMap", sender: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noteDetails" {
            if segue.destination is EvilNoteDetailVC {
                let evilNoteDetail = segue.destination as! EvilNoteDetailVC
                evilNoteDetail.fileTitle = cellTitle
            }
        }
        
        if segue.identifier == "showMap"{
            if segue.destination is MKLocationVC {
                let locationDetail = segue.destination as! MKLocationVC
                locationDetail.noteLatitude     = self.lat
                locationDetail.noteLongitude    = self.long
            }
            
        
        }
    }
    
    func isNoteAdded(noteIsAdded: Bool)  {
        print(noteIsAdded)
        if noteIsAdded {
            // Create the index again
            createIndex()
            
            // Update the datasource
            self.notesTable.reloadData()
        } else {
            // Nothing happend.
        }
    }
    
    func createIndex () {
        let fm = FileManager.default
        // get the documents urls.
        let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
        
        do {
            let directoryContents = try fm.contentsOfDirectory(atPath: documentsUrl[0].path)
            var notesTitles : [String] = []
            for fileName in directoryContents {
                if !(fileName == "EvilNote.json" || fileName == ".EvilNote.json.swp" || fileName.contains(".JPG") || fileName.contains(".PNG")) {
                    let noteTitle = fileName.characters.split(separator: ".").map(String.init)
                    print(noteTitle[0])
                    notesTitles.append(noteTitle[0])
                }
            }
            // write new index
            writeIndexFile(notesTitles: notesTitles);
            print(directoryContents)
        } catch {
            print(error.localizedDescription)
        }
        
        print(documentsUrl)
    }
    
    
    func writeIndexFile(notesTitles: [String])  {
        // file manager.
        // get the documents urls.
        // get the file path as a url.
        let fm              = FileManager.default
        let documentsUrl    = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath        = documentsUrl[0].appendingPathComponent("EvilNote.json")
        
        do {
            let data = try JSONSerialization.data(withJSONObject: notesTitles, options: .prettyPrinted)
            try data.write(to: filePath)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("item selected at section:\(indexPath.section) and row:\(indexPath.row)")
        
        let cell = tableView.cellForRow(at: indexPath) as! EvilNoteTableViewCell
        cellTitle = (cell.titleLabel.text)!
        self.performSegue(withIdentifier: "noteDetails", sender: nil)
    }
    
}

extension ViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let cell : EvilNoteTableViewCell = tableView.cellForRow(at: indexPath) as! EvilNoteTableViewCell
            
            deleteNote(fileName: cell.titleLabel.text!)
            var titles = getTitles();
            titles.remove(at: indexPath.row)
            writeIndexFile(notesTitles: titles)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func deleteNote(fileName: String) {
        // get file manager
        // get the documents urls.
        // get the file path as a url.
        let fm              = FileManager.default
        let documentsUrl    = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath        = documentsUrl[0].appendingPathComponent("\(fileName).json")
        
        do {
            try fm.removeItem(atPath: filePath.path)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numberOfRows = getNumberOfItems()
        
        if numberOfRows > 0 {
            // Return number of rows.
            notesTable.separatorStyle   = .singleLine
            tableView.backgroundView    = nil
        } else {
            // We dont have rows.
            let noDataLabel: UILabel     =
                UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width,
                                      height: tableView.bounds.size.height))
            noDataLabel.text             = "You don't have notes, add one :D!"
            noDataLabel.textColor        = UIColor.black
            noDataLabel.textAlignment    = .center
            tableView.backgroundView     = noDataLabel
            tableView.separatorStyle     = .none
            
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell") as! EvilNoteTableViewCell
        
        let titles = getTitles()
        let json = getContentOfFile(fileTitle: titles[indexPath.row])
        
        if let imageName = json["image"] {
            // File Manager
            let fm = FileManager.default
            // get the documents urls.
            let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
            // get the file path as a url.
            let imagePath = documentsUrl[0].appendingPathComponent("\(imageName)")
            
            if let savedImage = UIImage(contentsOfFile: imagePath.path) {
                cell.cellImage.contentMode = .scaleAspectFit
                cell.cellImage.image = savedImage
            }
        } else {
            cell.cellImage.frame = CGRect.init(x: 0, y: 0, width: 0, height: 0)
        }
        
        let preview = (NSString.init(string: json["content"]!)).replacingOccurrences(of: "\n", with: ". ") as NSString
        if preview.length > 0
        {
            cell.previewLabel.text = preview.substring(with: NSRange(location: 0, length: preview.length > 200 ? 200 : preview.length))
        }
        cell.titleLabel.text = titles[indexPath.row]
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        cell.mapButton.tag = indexPath.row

        return cell
    }
    
    private func getTitles() -> [String] {
        // get file manager
        let fm = FileManager.default
        // get the documents urls.
        let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
        // get the file path as a url.
        let filePath = documentsUrl[0].appendingPathComponent("EvilNote.json")
        
        // Get the contents of the file as a String.
        let contentOfFile = openFile(fm, path: filePath)
        
        do {
            if let data = contentOfFile.data(using: .utf8) {
                if let json = try JSONSerialization.jsonObject(with: data,
                                                               options: .mutableContainers) as?                                                                [String] {
                    return json
                }
            }
        } catch {
            // In any error we assume there is no items.
            print(error.localizedDescription)
        }
        return [String]()
    }
    
    func getContentOfFile(fileTitle : String) -> [String: String] {
        // file manager.
        let fm = FileManager.default
        // get the documents urls.
        let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
        // get the file path as a url.
        let filePath = documentsUrl[0].appendingPathComponent("\(fileTitle).json")
        
        // Get the contents of the file as a String.
        let contentOfFile = openFile(fm, path: filePath)
        
        do {
            if let data = contentOfFile.data(using: .utf8) {
                if let json = try JSONSerialization.jsonObject(with: data,
                                                               options: .mutableContainers) as?
                                                                [String: String] {
                    return json
                }
            }
        } catch {
            // In any error we assume there is no items.
            print(error.localizedDescription)
        }
        
        return [String: String]()
    }
    
    private func getNumberOfItems() -> Int {
        let fm = FileManager.default
        // get the documents urls.
        let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
        // get the file path as a url.
        let filePath = documentsUrl[0].appendingPathComponent("EvilNote.json")
        
        // check if the file exist.
        if !fm.fileExists(atPath: filePath.path) {
            // there is no file... lest create a new one.
            createFile(fm, path: filePath)
        }
        
        // Get the contents of the file as a String.
        let contentOfFile = openFile(fm, path: filePath)
        
        do {
            if let data = contentOfFile.data(using: .utf8) {
                if let json = try JSONSerialization.jsonObject(with: data,
                                                               options: .mutableContainers) as?
                                                                [String] {
                    return json.count
                }
            }
        } catch {
            // In any error we assume there is no items.
            return 0
        }
        
        // If we reach here something went wrong
        return 0
    }
    
    private func openFile(_ fileManager: FileManager, path: URL) -> String {
        do {
            let contentOfFile : String = try String.init(contentsOf: path, encoding: .utf8)
            return contentOfFile
        } catch {
            print(error.localizedDescription)
        }
        return "File was not found"
    }
    
    private func createFile(_ fileManager: FileManager, path: URL) {
        do {
            try "[{}]".write(to: path, atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}





