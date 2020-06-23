//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {// Much simpler than UIView + UITableView as used in Flash Chat project
    
    var itemArray = [Item]()
    var selectedCategory : Catagory? {// Xcode had issues with 'Category' as a table name.
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //var itemArray = ["Blue Whale", "Red Heart", "Green Berets"]
    
    //let defaults = UserDefaults.standard // Not DB, but useful e.g. for user preferences, i.e. small data.  NB Singletons!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Store Data in document directory
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        //loadItems() - now in selectedCategory
        
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
            
            // Get the object, not the class
            
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory //Foreign Key
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
        //let encoder = PropertyListEncoder()
        
        do {
            //let data = try encoder.encode(itemArray)
            //try data.write(to: dataFilePath!)
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        
        self.tableView.reloadData() // To display added data
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        // with = external parameter (from searchBarSearchButtonClicked func), request = parameter internal to this function
        // = Item.fetchRequest() = default value, when no request is specified and all data to be diplayed.
        //let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        // select only Items of specified Category
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }
        tableView.reloadData()
    }
    
}

//MARK: - Search Extension Method


extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        print(searchBar.text!)
        // Find the record that partly or wholly contains the text in the searchBar.  MATCHES instead for exact match. [cd] = ignore case and diacratics
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        //request.predicate = predicate
        //Sort
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        //request.sortDescriptors = [sortDescriptor]
        loadItems(with: request, predicate: predicate)
        
        //        do {
        //            itemArray = try context.fetch(request)
        //        } catch {
        //            print("Error fetching data from context, \(error)")
        //        }
        //tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Revert to full display of data if no search data or X is pressed
        if searchBar.text?.count == 0 {
            loadItems()// Step 1
            DispatchQueue.main.async { // Step 2 - Hide K/Board using main thread
                searchBar.resignFirstResponder()
            }
        }
    }
}
