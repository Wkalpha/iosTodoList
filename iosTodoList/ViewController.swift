//
//  ViewController.swift
//  iosTodoList
//
//  Created by Wkalpha on 2019/4/16.
//  Copyright © 2019 wkalpha. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var editBtnOutlet: UIButton!
    
    
    var flag = 0
    @IBAction func editBtn(_ sender: Any, forEvent event: UIEvent) {
        if flag != 1{
            editBtnOutlet.setTitle("Done", for: .normal)
            flag = 1
        }else{
            editBtnOutlet.setTitle("Edit", for: .normal)
            flag = 0
        }
        tableView.isEditing = !tableView.isEditing
    }
    
    
    @IBAction func deleteBtn(_ sender: Any) {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            // The selected rows are added to a temporary array
            var items = [String]()
            for indexPath in selectedRows  {
                items.append(myTask[indexPath.row])
            }
            // The index of the items of the temporary array will be used to remove the items of the numbers array
            // And delete from SQLite where text same as select
            for item in items {
                if let index = myTask.index(of: item) {
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let db = try? Connection("\(path)/todo.sqlite")
                    let main = Table("main")
                    let text = Expression<String>("text")
                    let m = main.filter(text == myTask[index])
                    myTask.remove(at: index)
                    try? db?.run(m.delete())
                }
            }
            // The selected rows will be deleted from the table view
            tableView.beginUpdates()
            tableView.deleteRows(at: selectedRows, with: .automatic)
            tableView.endUpdates()
        }
    }
    
    // slide and delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle{
        case UITableViewCell.EditingStyle.delete :
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let db = try? Connection("\(path)/todo.sqlite")
            let main = Table("main")
            let text = Expression<String>("text")
            let m = main.filter(text == myTask[indexPath.row])
            myTask.remove(at: indexPath.row)
            try? db?.run(m.delete())
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        default :
            break
        }
    }
    
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
            if checkData(textField.text!) == textField.text!{
                doubleData()
                return
            }else{
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
            }
//            print(checkData(textField.text!))
            
            
        }catch{
            print(error)
        }
        
        tableView.beginUpdates()
        tableView.insertRows(at: [[0,myTask.count - 1]], with: UITableView.RowAnimation.fade) // insert animation
        tableView.endUpdates()
        
        // Scroll to newest data
        tableView.scrollToRow(at: [0,myTask.count - 1], at: UITableView.ScrollPosition.bottom, animated: true)
        
        // Clean text
        textField.text = ""
    }
    // check text exist or not
    func checkData(_ text :String) -> String{
        var checkText = ""
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let db = try? Connection("\(path)/todo.sqlite")
        
        let main = Table("main")
        let text = Expression<String>("text")
        
        let filter1 = main.filter(text == textField.text!)
        for result in (try? db?.prepare(filter1))!!{
            checkText = result[text]
        }
        return checkText
    }
    
    // alert when data already exist
    func doubleData() {
        let alertController = UIAlertController(title: "Data already exist!", message: "", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // alert when text is empty
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
        tableView.allowsMultipleSelectionDuringEditing = true
        
        // keyboard need
        self.textField.delegate = self
    }
    
    // when press return keyboard will hide
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // when touch anywhere keyboard will hide
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

