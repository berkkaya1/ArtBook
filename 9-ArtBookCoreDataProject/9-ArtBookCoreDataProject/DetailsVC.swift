//
//  DetailsVC.swift
//  9-ArtBookCoreDataProject
//
//  Created by Berk Kaya on 7.10.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if chosenPainting != "" {
            
            saveButton.isHidden = true
            
            //coredatadan data cekicez
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameTextField.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistTextField.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearTextField.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            imageView.image = UIImage(data: imageData)
                        }
                    }
                }
            } catch {
                print("Error")
            }
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameTextField.text = ""
            artistTextField.text = ""
            yearTextField.text = ""
        }
        
        //Recognizers
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
        
        
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true , completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        //app delegate tan??mlam??s olduk
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //context icine ne koyacagizi yaz??yoruz
        //forentityName = coredata icine yazd??g??m??z entity ismi.
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //attributes yaziyoruz
        //keyimiz entity icinde yazd??g??m??z ozellikler
        newPainting.setValue(nameTextField.text!, forKey: "name")
        newPainting.setValue(artistTextField.text!, forKey: "artist")
        if let year = Int(yearTextField.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(),forKey: "id")
        
        //ui image'i dataya ceviriyoruz
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("Saved")
        }  catch{
            print("Error")
        }
        
        //Geri Gitmek icin.
        self.navigationController?.popViewController(animated: true)
        
        //Observer kullanimi, burdan mesaj yolluyoruz oteki taraf mesaj?? al??rsa istenen fonksiyonu yap??yor.
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        
    }
    
}
