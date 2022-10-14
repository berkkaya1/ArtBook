//
//  ViewController.swift
//  9-ArtBookCoreDataProject
//
//  Created by Berk Kaya on 7.10.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    //Dbden gelecek degerler
    var nameArray = [String]()
    var idArray = [UUID]()
    
    //Veri aktarımı icin secilen degiskenleri tanimladik.
    var selectedPainting = ""
    var selectedPaintingId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        //navigation bar'a (üstte duran) + isareti ekledik.
        navigationController?.navigationBar.topItem?.rightBarButtonItem =
        UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        
        getData()
    }
    
    //her bu viewcontroller acildiginde kontrol edecek, viewdidload bir kez calisiyor.
    override func viewWillAppear(_ animated: Bool) {
        //obur taraftan bir adet observer geldigi zaman yolladıgı string mesaj ayni ise devreye giriyor.
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    //DBden verileri getirmek.
   @objc func getData(){
       //dublicate olmasın diye temizliyoruz.
       nameArray.removeAll(keepingCapacity: false)
       idArray.removeAll(keepingCapacity: false)
       
       //hazir kaliplar.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //Fetch request olusturmamız gerekiyor (fetch = getir demek)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        //Cache'den okuma islemleri ile ilgili ayar, daha hızlı gerceklestiriyor islemi.
        fetchRequest.returnsObjectsAsFaults = false
        //bir dizi geri döndürecek
        do{
           let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        self.nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    //Reflesh etmek icin.
                    self.tableView.reloadData()
                }
            }
            //ismini idsini vs cekebilmek icin any formundan nsmanagedobject formatına donustuyoruz
           
        } catch {
            print("Error")
        }
      
    }
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    @objc func addButtonClicked(){
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingId = idArray[indexPath.row]
        self.performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDetailsVC"){
            let destination = segue.destination as! DetailsVC
            destination.chosenPainting = selectedPainting
            destination.chosenPaintingId = selectedPaintingId
        }
    }
    
    
    //Coredatadan silme islemi.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do{
                                    try  context.save()
                                } catch {
                                    print("ERROR")
                                }
                               break
                            }
                        }
                    }
                }
            } catch {
                
            }
            
        }
    }


}

