//
//  ViewController.swift
//  Todoey
//
//  Created by 洋蔥胖 on 2018/4/9.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    //https://medium.com/@z1235678/將圖片儲存在app裡-b7690fb2074
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist") //預先指定的路徑
    //let defaults = UserDefaults.standard //android SharedPreferences
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath!)
        
        loadItems()
        
//        let newItem1 = Item()
//        newItem1.title = "Find Mike"
//        //newItem1.done = true
//        itemArray.append(newItem1)
//        
//        let newItem2 = Item()
//        newItem2.title = "Buy Eggos"
//        itemArray.append(newItem2)
//        
//        let newItem3 = Item()
//        newItem3.title = "Destory Demogorgon"
//        itemArray.append(newItem3)
        //有個bug就是你對某row打勾了 滑到下面明明有個沒打勾的卻打勾 有重覆利用這個物件
        
        //and we're going to cast this as an array of strings [String] ->[Item]
        //        if let items = defaults.array(forKey: "ToDoListArray") as? [Item] {
        //             itemArray = items
        //        }
        
    }
    
    //MARK - TableView Datasource Methods
    //http://eddychang.me/blog/swift/64-uitableviewcell-reuse.html
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("cellForRowAtIndex")
        
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
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done //同下註解掉的
        
        //        if  itemArray[indexPath.row].done == true {
        //            itemArray[indexPath.row].done = false
        //        }else{
        //            itemArray[indexPath.row].done = true
        //        }
        
        //        if(tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark){
        //           tableView.cellForRow(at: indexPath)?.accessoryType = .none
        //        }else{
        //            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        //        }
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
            print("Success!")
            print(textField.text!)
            let newItem = Item()
            newItem.title = textField.text!
            self.itemArray.append(newItem)
            // self.itemArray.append(textField.text!) //新增了沒錯 但沒有重載 他是不會出現的
            
            //            self.defaults.set(self.itemArray, forKey: "ToDoListArray")
            /*
             [User Defaults] Attempt to set a non-property-list object (
             "Todoey.Item",
             "Todoey.Item",
             "Todoey.Item",
             "Todoey.Item"
             ) as an NSUserDefaults/CFPreferences value for key ToDoListArray
             */
            self.saveItems()
            self.tableView.reloadData()
            
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            //            print(alertTextField.text)
            //            print("now!")
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK - Model Manupulation Methods
    func saveItems(){
        let encoder = PropertyListEncoder() //編碼進item.list 存在APP裡
        do{
            let data  = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        }catch{
            print("Error encodeing item array, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(){
        if let data = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder() //解碼APP裡item.list的東西
            do{
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decodeing item array, \(error)")
            }
        }
        
    }
}

