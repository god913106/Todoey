//
//  ViewController.swift
//  Todoey
//
//  Created by 洋蔥胖 on 2018/4/9.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController{
    
    var itemArray = [Item]()
    //https://medium.com/@z1235678/將圖片儲存在app裡-b7690fb2074
    var selectedCategory : Category? {
        didSet{
            loadItems() //選取category的indexpath.row 會去讀取請求那row名稱的coredata
        }
    }
    //let defaults = UserDefaults.standard //android SharedPreferences
    
    //在TodoListViewController中，要用Application不能直接用AppDelegate.persistentContainer.viewContext因為AppDelegate是class要跨檔案使用要讓AppDelegate變成delegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
 
    }
    
    //MARK - TableView Datasource Methods
    //http://eddychang.me/blog/swift/64-uitableviewcell-reuse.html
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        //Ternary operator ==>
        // value = condition ? valueIfTrue : valueIfFalse
        
        cell.accessoryType = item.done ? .checkmark : .none //跟下面的if/else 一樣的功能 卻只要寫一行就好
        
        //但還有個bug你勾選後卻不會更新
        /*
         if item.done == true {
         cell.accessoryType = .checkmark
         } else {
         cell.accessoryType = .none
         }*/
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print(itemArray[indexPath.row])
        // itemArray[indexPath.row].setValue("Complted", forKey: "title")
        
        //context.delete一定要在remove前面 才會刪除同一個indexPath.row
        //        context.delete(itemArray[indexPath.row])
        //        itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done //同下註解掉的
        
        saveItems()
        
        
        //因為點選row時 會一直是灰體 直到點選另一個row 才會變回白體
        //所以用deselectRow 這個method 可以點選某row 灰體馬上回白體 為了更良好的用戶體驗
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add Itme button on our UIAlert
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory//新增item時 會存到該category的coredata
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK - Model Manupulation Methods
    func saveItems(){
        
        do{
            try context.save()
        }catch{
            print("Error saving context, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(),predicate: NSPredicate? = nil){
       let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let addtionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,addtionalPredicate])
        }else {
            request.predicate = categoryPredicate
        }

        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Error fetching data from context\(error)")
        }
        tableView.reloadData()
    }
    
}
//MARK: - Search bar methods
//擴充功能 GetONE
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        //過濾
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
     
        //把搜尋到的排序一下
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() //輸入完成 關閉鍵盤
            }
        }
    }
}
