//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {// Much simpler than UIView + UITableView as used in Flash Chat project
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    var selectedCategory : Catagory? {// Xcode had issues with 'Category' as a table name.
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    // MARK: -  TableView Datasource Methods
    
    //Determine how many rows:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    // Display the data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {// To shorten repetitive use of index.Path.row
            cell.textLabel?.text = item.title
            //Instead use the ternery operator - Handy
            //value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items added."
        }
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Replaced by - if true, make false; if false, make true - Handy!:
        //todoItems[indexPath.row].done = !todoItems[indexPath.row].done
        
        //saveItems()
        
        // Remove grey background to flash briefly
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // Pop up to add new item
        
        var textField = UITextField() // Global variable to function
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
        
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)// .done defaults to Class declaration in Item.swift
                    }
                } catch {
                    print("Error saving new Item, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item" // Local variable
            textField = alertTextField // Extend local variable to entire function
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Model Manipulation Methods
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
}

//MARK: - Search Extension Method


//extension TodoListViewController: UISearchBarDelegate {
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//        print(searchBar.text!)
//        // Find the record that partly or wholly contains the text in the searchBar.  MATCHES instead for exact match. [cd] = ignore case and diacratics
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        //request.predicate = predicate
//        //Sort
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        //request.sortDescriptors = [sortDescriptor]
//        loadItems(with: request, predicate: predicate)
//
//        //        do {
//        //            itemArray = try context.fetch(request)
//        //        } catch {
//        //            print("Error fetching data from context, \(error)")
//        //        }
//        //tableView.reloadData()
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        // Revert to full display of data if no search data or X is pressed
//        if searchBar.text?.count == 0 {
//            loadItems()// Step 1
//            DispatchQueue.main.async { // Step 2 - Hide K/Board using main thread
//                searchBar.resignFirstResponder()
//            }
//        }
//    }
//}
