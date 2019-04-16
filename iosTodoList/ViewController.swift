//
//  ViewController.swift
//  iosTodoList
//
//  Created by Wkalpha on 2019/4/16.
//  Copyright © 2019 wkalpha. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var myTask:[String] = []
    @IBAction func addBtn(_ sender: UIButton) {
        // Check text if empty pop up alert window and return 0 do nothing
        if(textField.text == ""){
            // show alert window
            // see line 32
            showAlert()
            return
        }
        
        do{
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let db = try? Connection("\(path)/todo.sqlite")
            
            let main = Table("main")
            let id = Expression<Int64>("id")
            let text = Expression<String>("text")
            
            try! db?.run(main.create(ifNotExists: true,block:{(table) in
                table.column(id, primaryKey: true)
                table.column(text)}))
            
            do {
                let rowid = try db?.run(main.insert(text <- textField.text!))
                myTask = []
                for toDoList  in (try? db?.prepare(main))!! {
                    myTask.append("\(toDoList[text])")
                }
                print("inserted id: \(rowid!)")
            } catch {
                print("insertion failed: \(error)")
            }
            
        }catch{
            print(error)
        }
        
        tableView.reloadData()
        
        // Clean text
        textField.text = ""
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Text can't be empty", message: "", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // 底線_ 代表可以省略參數名稱直接使用
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myTask.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)// index begin from 0
        // Configure the cell...
        cell.textLabel?.text = myTask[indexPath.row]
        return cell
    }
    

    // The app startup view
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        do{
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let db = try? Connection("\(path)/todo.sqlite")
            
            let main = Table("main")
            let id = Expression<Int64>("id")
            let text = Expression<String>("text")
            
            try! db?.run(main.create(ifNotExists: true,block:{(table) in
                table.column(id, primaryKey: true)
                table.column(text)}))
            
            do {
                myTask = []
                for toDoList  in (try? db?.prepare(main))!! {
                    myTask.append("\(toDoList[text])")
                }
            } catch {
                print(error)
            }
            
        }catch{
            print(error)
        }
    }


}

