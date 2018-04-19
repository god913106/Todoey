//
//  ViewController.swift
//  Todoey
//
//  Created by 洋蔥胖 on 2018/4/9.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController{
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    //https://medium.com/@z1235678/將圖片儲存在app裡-b7690fb2074
    var selectedCategory : Category? {
        didSet{
            loadItems() //選取category的indexpath.row 會去讀取請求那row名稱的coredata
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    //MARK - TableView Datasource Methods
    //http://eddychang.me/blog/swift/64-uitableviewcell-reuse.html
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            //Ternary operator ==>
            // value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none //跟下面的if/else 一樣的功能 卻只要寫一行就好
        }else{
            cell.textLabel?.text = "No Items Added"
        }
        
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
        /*
         bug：目前在tableview做done的check會跟realm同步互動，但在realm改動done的check 還無法跟tableview同步互動
         but when i check them over realm they will not get reflected in our tablview
         because as you remember we cannot call reload tableview from a different application into our app.
         So it has to happen over here.
         */
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                    //realm.delete(item)
                }
            }catch{
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        //因為點選row時 會一直是灰體 直到點選另一個row 才會變回白體
        //所以用deselectRow 這個method 可以點選某row 灰體馬上回白體 為了更良好的用戶體驗
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //     what will happen once the user clicks the Add Itme button on our UIAlert
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK - Model Manupulation Methods
    func save(items: Item){
        
        do{
            try realm.write {
                realm.add(items)
            }
        }catch{
            print("Error saving context, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    //新增delete
    override func tableView(_ tableView: UITableView, editActionsForRowAt
        indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //delete
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default
            , title:"Delete", handler:{(action, indexPath) -> Void in
                
                //從view上刪除此物件 也在core data內刪除
                if let item = self.todoItems?[indexPath.row]{
                    do{
                        try self.realm.write {
                            //item.done = !item.done
                            self.realm.delete(item)
                        }
                    }catch{
                        print("Error saving done status, \(error)")
                    }
                }
                self.tableView.reloadData()
        })
        
        return [deleteAction]
    }
    
}
//MARK: - Search bar methods
//擴充功能 GetONE
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
    }
    //        let request : NSFetchRequest<Item> = Item.fetchRequest()
    //        //過濾
    //        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
    //
    //        //把搜尋到的排序一下
    //        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
    //
    //        loadItems(with: request, predicate: predicate)
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() //輸入完成 關閉鍵盤
            }
        }
    }
}
