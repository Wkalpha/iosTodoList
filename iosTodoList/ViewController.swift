//
//  ViewController.swift
//  iosTodoList
//
//  Created by Wkalpha on 2019/4/16.
//  Copyright © 2019 wkalpha. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func addBtn(_ sender: UIButton) {
        // Check text if empty pop up alert window and return 0 do nothing
        if(textField.text == ""){
            checkData()
            return
        }
        // Add user input text
        myTask.append(textField.text!)
        
        // Reload when press add button
        tableView.reloadData()
        // Clean text
        textField.text = ""
    }
    
    func checkData() {
        let alertController = UIAlertController(title: "Text can't be empty", message: "", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    var myTask:[String] = []
    
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
    }


}

