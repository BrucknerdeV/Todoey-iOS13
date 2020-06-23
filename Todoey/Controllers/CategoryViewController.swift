//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Bruckner de Villiers on 2020/06/22.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categories = [Catagory]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadCategories()
    }
    
    // MARK: - Table view data source
    
    //Determine how many rows:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    // Display the data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("Cell for row @ indexPath called")
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        //let category = categories[indexPath.row] // To shorten repetitive use of index.Path.row
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
    }
    
    //MARK: - Table view Delegate Methods
    
    // Invoke segue to Items
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    //MARK: - Add new Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // Pop up to add new item
        
        var textField = UITextField() // Global variable to function
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            // Event when Add Item button is pressed
            
            // Get the object, not the class
            
            let newCategory = Catagory(context: self.context)
            newCategory.name = textField.text!
            self.categories.append(newCategory)
            
            self.saveCategories()
            
        }
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field // Extend local variable to entire function
            textField.placeholder = "Add new Category" // Local variable
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Data manipulation Methods
    
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving category, \(error)")
        }
        
        tableView.reloadData() // To display added data
    }
    
    // Search
    func loadCategories(with request: NSFetchRequest<Catagory> = Catagory.fetchRequest()) {
        // with = external parameter (from searchBarSearchButtonClicked func), request = parameter internal to this function
        // = Item.fetchRequest() = default value, when no request is specified and all data to be diplayed.
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories, \(error)")
        }
        tableView.reloadData()
    }
}
