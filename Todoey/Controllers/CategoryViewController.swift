//
//  CategoryViewController.swift
//  Todoey
//
//  Created by 洋蔥胖 on 2018/4/16.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController, UITextFieldDelegate {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        tableView.separatorStyle = .none
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
//    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.navigationBar.barTintColor = UIColor(hexString: "28AAC0")
//    }
    
    //MARK - Add New Items
    //Shopping List , Home , Work , Misc. , To Eat
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //what will happen once the user clicks the Add Itme button on our UIAlert
            
            let newCategory = Category()
            if (textField.text!) != ""{
                newCategory.name = textField.text!
                newCategory.color = UIColor.randomFlat.hexValue()
                self.save(category: newCategory)
            }else{
                print("123")
            }
            
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 //Nil Coalescing Operator
        //categories?.count 可能是新new出來的 那就會回傳1row 但不是nil就會回傳該有的row
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) // cell is already a SwipeCell
        
        if let category = categories?[indexPath.row]{
            cell.textLabel?.text = category.name
            cell.accessoryType = .disclosureIndicator
            
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
            cell.backgroundColor = categoryColor
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        
        
        
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = tableView.indexPathForSelectedRow{
            let destinationVC = segue.destination as! TodoListViewController
            
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    //MARK: - Data Manipulation Methods
    func save(category: Category){
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Error saving category, \(error)")
        }
        tableView.reloadData() //新增完都要reload
        
    }
    func loadCategory(){
        categories = realm.objects(Category.self)
        tableView.reloadData() //叫檔案都要reload
    }
    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        
        if let categoryForDeletion = categories?[indexPath.row]{
            do{
                try realm.write {
                    realm.delete(categoryForDeletion)
                }
            }catch{
                print("Error deleting ctegory, \(error)")
            }
        }
    }
}
