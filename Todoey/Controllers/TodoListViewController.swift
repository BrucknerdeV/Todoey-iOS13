//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {// Much simpler than UIView + UITableView as used in Flash Chat project
    
    var itemArray = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    //var itemArray = ["Blue Whale", "Red Heart", "Green Berets"]
    
    //let defaults = UserDefaults.standard // Not DB, but useful e.g. for user preferences, i.e. small data.  NB Singletons!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Store Data in document directory
        
        print(dataFilePath!)
        
        loadItems()
        
        //if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
        //itemArray = items
        //}
        
    }
    
    // MARK: -  TableView Datasource Methods
    
    //Determine how many rows:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // Display the data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("Cell for row @ indexPath called")
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row] // To shorten repetitive use of index.Path.row
        
        cell.textLabel?.text = item.title
        
        // Fix checkmark not cancelling when another row is selected
        //if item.done == true {
        //  cell.accessoryType = .checkmark
        //} else {
        //  cell.accessoryType = .none
        //}
        
        //Instead use the ternery operator - Handy
        //value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item.done ? .checkmark : .none
        
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(indexPath.row)
        //print(itemArray[indexPath.row])
        
        // Add tick when row selected
        //if itemArray[indexPath.row].done == false {
        //  itemArray[indexPath.row].done = true
        //} else {
        //  itemArray[indexPath.row].done = false
        //}
        //Replaced by - if true, make false; if false, make true - Handy!:
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
        //  tableView.cellForRow(at: indexPath)?.accessoryType = .none
        //} else {
        //  tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        //}
        saveItems()
        
        // Remove grey background to flash briefly
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // Pop up to add new item
        
        var textField = UITextField() // Global variable to function
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // Event when Add Item button is pressed
            
            let newItem = Item()
            newItem.title = textField.text ?? "Lost"
            self.itemArray.append(newItem)
            
            self.saveItems()
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item" // Local variable
            textField = alertTextField // Extend local variable to entire function
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Model Manipulation Methods
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding itemArray, \(error)")
        }
        
        self.tableView.reloadData() // To display added data
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding itemArray, \(error)")
            }
            
        }
    }
}
