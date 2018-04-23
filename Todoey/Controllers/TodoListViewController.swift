//
//  ViewController.swift
//  Todoey
//
//  Created by 洋蔥胖 on 2018/4/9.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController{
    
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems: Results<Item>?
    //https://medium.com/@z1235678/將圖片儲存在app裡-b7690fb2074
    var selectedCategory : Category? {
        didSet{
            loadItems() //選取category的indexpath.row 會去讀取請求那row名稱的coredata
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        guard let colorHex = selectedCategory?.color else {fatalError()}
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "28AAC0")
    }
    
    //MARK: - Nav Bar Setup Methods
    func updateNavBar(withHexCode colorHexCode: String){
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")//fatalError("Navigation controller does not exist.") nav的error用法
        }
        guard let navColor = UIColor(hexString: colorHexCode) else { fatalError()}
        //let navColor = FlatWhite()
        
        //navigationController?.navigationBar.barTintColor = UIColor(hexString: colorHex)
        navBar.barTintColor = navColor //barTintColor 導覽列修改背景色
        searchBar.barTintColor = navColor
        navBar.tintColor = ContrastColorOf(navColor, returnFlat: true) //除了背景色以外的 文字 圖標
        
        if #available(iOS 11.0, *) {
            navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navColor, returnFlat: true)]
        } else {
            // Fallback on earlier versions
        }
    }
    
    //MARK - TableView Datasource Methods
    //http://eddychang.me/blog/swift/64-uitableviewcell-reuse.html
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) // cell is already a SwipeCell
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            
            
            if let color = UIColor(hexString: (selectedCategory!.color))?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)){
                cell.backgroundColor = color
                /*
                 ContrastColorOf(color, returnFlat: true)=> 背景顏色太暗 字體顏色會反白，反之，背景色是亮的，字體色就會黑
                 */
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            //            print("version 1:\(CGFloat(indexPath.row/todoItems!.count))")
            //            print("version 2:\(CGFloat(indexPath.row)/CGFloat(todoItems!.count))")
            
            cell.accessoryType = (item.done) ? .checkmark : .none //跟下面的if/else 一樣的功能 卻只要寫一行就好
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        
        return cell
    }
    //    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let cell = super.tableView(tableView, cellForRowAt: indexPath) // cell is already a SwipeCell
    //
    //        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
    //        cell.accessoryType = .disclosureIndicator
    //
    //        return cell
    //    }
    
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
                if (textField.text!) != "" {
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
                }else{
                    print("456")
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
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        
        if let todoItemsForDeletion = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    realm.delete(todoItemsForDeletion)
                }
            }catch{
                print("Error deleting todoItems, \(error)")
            }
        }
    }
    
}
//MARK: - Search bar methods
//擴充功能 GetONE
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
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
