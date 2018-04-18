//
//  CategoryViewController.swift
//  Todoey
//
//  Created by 洋蔥胖 on 2018/4/16.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    //MARK - Add New Items
    //Shopping List , Home , Work , Misc. , To Eat
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //what will happen once the user clicks the Add Itme button on our UIAlert
            
            let newCategory = Category()
            newCategory.name = textField.text!
            //self.categories.append(newCategory) 用了realm就會自動監控變化 故不用append
            self.save(category: newCategory)
            
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToItems", sender: self)
        
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

}
