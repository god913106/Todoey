//
//  ViewController.swift
//  Todoey
//
//  Created by 洋蔥胖 on 2018/4/9.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    let itemArray = ["Find Mike","Buy Eggos","Destory Demogorgon"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK - TableView Datasource Methods
    //http://eddychang.me/blog/swift/64-uitableviewcell-reuse.html
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print(itemArray[indexPath.row])
        
        if(tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark){
           tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        
        //因為點選row時 會一直是灰體 直到點選另一個row 才會變回白體
        //所以用deselectRow 這個method 可以點選某row 灰體馬上回白體 為了更良好的用戶體驗
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

