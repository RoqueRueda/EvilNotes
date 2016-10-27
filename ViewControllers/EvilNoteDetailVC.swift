//
//  EvilNoteDetailViewController.swift
//  EvilNotes
//
//  Created by Roque Rueda on 09/09/16.
//  Copyright © 2016 RoqueRueda. All rights reserved.
//

import UIKit
import CoreLocation

class EvilNoteDetailVC : UIViewController {
    
    @IBOutlet weak var titleTextField   : UITextField!
    @IBOutlet weak var contentTextView  : UITextView!
    @IBOutlet weak var saveButton       : UIButton!
    @IBOutlet weak var scroll           : UIScrollView!
    @IBOutlet weak var collectionView   : UICollectionView!
    
    var myLocationManager       : CLLocationManager = CLLocationManager()
    var photoPath               : String?           = ""
    var latitude                : String!           = ""
    var longitude               : String!           = ""
    var photoPicker                                 = UIImagePickerController()
    
    
    //self.present(photoPicker, animated: true, completion: nil)
    //This is going to be in the "add photo" button
   
    
    @IBAction func saveNote(){
        
        // Hide keyboard
        dismissKeyboard()
        
        if editMode {
            //We are editing
            if fileTitle != titleTextField.text! {
                // Delete old file
                deleteNotesFile(fileName: fileTitle)
                
            }
        }
        
        //We are adding
        let evilNote : [String:String] = ["title"     : titleTextField.text!,
                                          "content"   : contentTextView.text!,
                                          "image"     : photoPath!,
                                          "latitude"  : latitude!,
                                          "longitude" : longitude!]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: evilNote, options: .prettyPrinted)
            writeFile(contentOfFile: data)
            let vc = self.navigationController?.viewControllers[0] as! ViewController
            vc.isNoteAdded(noteIsAdded: true)
            //callBack?.isNoteAdded(noteIsAdded: true)
            self.navigationController!.popViewController(animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
    
    var fileTitle : String = ""
    var editMode  : Bool = false
    var url : URL!
    //var galleryItems: [GalleryItem] = []
    var picketImages: [UIImage] = []
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.initLocationManager()
        
        // Do any additional setup after loading the view.
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        if fileTitle.isEmpty {
            // New note
            editMode = false
        } else {
            // Edit note
            editMode = true
            titleTextField.text = fileTitle
            self.title = fileTitle
            let json = getContentOfFile();
            contentTextView.text = json["content"]
        }
        
        photoPicker.delegate = self
        photoPicker.sourceType = .photoLibrary
        photoPicker.allowsEditing = false
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        initGalleryItems()
    }
    
    private func initGalleryItems() {
        
        let defaultImage : UIImage = UIImage(named: "camera-polaroid")!
        picketImages.append(defaultImage)
        
        let contentOfJson : [String:String] = getContentOfFile()
        if let imageName = contentOfJson["image"] {
            print(imageName)
            
            // File Manager
            let fm = FileManager.default
            // get the documents urls.
            let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
            
            // get the file path as a url.
            let imagePath = documentsUrl[0].appendingPathComponent("\(imageName)")
            
            if let savedImage = UIImage(contentsOfFile: imagePath.path) {
                picketImages.append(savedImage)
            }
        }
    }

    
    func dismissKeyboard() {
        self.titleTextField.resignFirstResponder()
        self.contentTextView.resignFirstResponder()
    }
    
    func getContentOfFile() -> [String : String] {
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
        
        return [String : String]()
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
    
    private func deleteNotesFile(fileName: String) {
        // file manager.
        let fm = FileManager.default
        // get the documents urls
        let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
        
        // get the file path as a url.
        let filePath = documentsUrl[0].appendingPathComponent("\(fileName).json")
        
        do {
            try fm.removeItem(atPath: filePath.path)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func writeFile(contentOfFile: Data) {
        // file manager.
        let fm = FileManager.default
        // get the documents urls.
        let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
        // get the file path as a url.
        let filePath = documentsUrl[0].appendingPathComponent("\(self.titleTextField.text!).json")
        
        print(filePath)
        
        do {
            try contentOfFile.write(to: filePath)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension EvilNoteDetailVC : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // This is the point to scroll
        let scrollPoint = CGPoint(x: 0, y: textField.frame.origin.y)
        self.scroll.setContentOffset(scrollPoint, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Scroll back
        self.scroll.setContentOffset(CGPoint(x:0 , y:-69), animated: true)
        //self.scroll.contentInset = UIEdgeInsets.zero
    }
}

extension EvilNoteDetailVC : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let scrollPoint = CGPoint(x: 0, y: textView.frame.origin.y - 54)
        self.scroll.setContentOffset(scrollPoint, animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.scroll.setContentOffset(CGPoint(x:0, y:-69), animated: true)
        //self.scroll.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.url = URL
        self.performSegue(withIdentifier: "webViewSegue", sender: self)
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webViewSegue" {
            if segue.destination is WebViewController {
                let webviewController = segue.destination as! WebViewController
                webviewController.webUrl = self.url
            }
        }
    }

    
}
extension EvilNoteDetailVC : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "didSelectItemAtIndexPath:", message: "Indexpath = \(indexPath)", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
        alert.addAction(alertAction)
        
        //self.present(alert, animated: true, completion: nil)
        
    }
}

extension EvilNoteDetailVC : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let picDimension = self.view.frame.size.width / 4.0
        return CGSize(width: picDimension, height: picDimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftRightInset = self.view.frame.size.width / 14.0
        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
    }
    
    @objc(collectionView:shouldSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc(collectionView:didHighlightItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("Nada de Nada")
        
        if indexPath.item == 0 {
            self.present(photoPicker, animated: true, completion: nil)
        }
    }
    
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get the image
        print("AQUI")
        
    }
    
}

extension EvilNoteDetailVC : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        // TODO: Here we need to do something
        cell.setGalleryPickerImage(image: picketImages[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return picketImages.count
    }
    
    
}

extension EvilNoteDetailVC : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // File Manager
        let fm = FileManager.default
        // get the documents urls.
        let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
        
        let url = info[UIImagePickerControllerReferenceURL] as! URL
        let imageName = (url.path as NSString).lastPathComponent
        
        // get the file path as a url.
        let fileName = "\(UUID().uuidString)\(imageName)"
        let filePath = documentsUrl[0].appendingPathComponent("\(fileName)")
        
        // Add the image to the Collection View
        if let picked = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // Add to the list of images
            picketImages.append(picked)
            
            let data = UIImagePNGRepresentation(picked)
            do {
                try data!.write(to: filePath, options: .atomic)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        photoPath = fileName
        
        collectionView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension EvilNoteDetailVC : UINavigationControllerDelegate{
    
}

extension EvilNoteDetailVC : CLLocationManagerDelegate {
    
    func initLocationManager() {
        self.myLocationManager.delegate = self
        self.verifyLocationPermission(status: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.verifyLocationPermission(status: status)
    }
    
    func verifyLocationPermission(status: CLAuthorizationStatus?) {
        var currentStatus : CLAuthorizationStatus
        if status != nil {
            currentStatus = status!
        } else {
            currentStatus = CLLocationManager.authorizationStatus()
        }
        
        switch currentStatus {
        case .notDetermined:
            print("Not determine")
            self.myLocationManager.requestWhenInUseAuthorization()
        case .denied:
            print("Denegate")
        case .authorizedAlways:
            print("Always authorize")
        case .authorizedWhenInUse:
            print("When in use")
            self.myLocationManager.startUpdatingLocation()
        case .restricted:
            print("Restricted")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation : CLLocation = locations[0]
        manager.stopUpdatingLocation()
        
        longitude    = userLocation.coordinate.longitude.description
        latitude     = userLocation.coordinate.latitude.description
        //let coordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        
    }
    
}
