//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Juan Felipe Zorrilla Ocampo on 4/07/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadCategories()

        /* Navigation Bar appearance */
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
    

    //MARK: - TableView Datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let safeColour = categoryArray?[indexPath.row].colour else { fatalError("Colour cannot be unwrapped from Category array colour property") }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories Added yet"
        cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: safeColour)!, returnFlat: true)
        cell.backgroundColor = UIColor(hexString: categoryArray?[indexPath.row].colour ?? "3478F6")
        
        return cell
    }
    

    //MARK: - TableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
            destinationVC.title = categoryArray?[indexPath.row].name ?? "No Categories Added yet"
        }
    }
    
    
    
    //MARK: - Data Manipulation methods
    
    func save(category: Category) {
        
        do {
            // CREATE from CRUD
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    // Read operation from CRUD
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Data from Swipe
    
    // Delete from CRUD operation
    override func updateModel(at indexPath: IndexPath) {
        guard let categoryForDeletion = categoryArray?[indexPath.row] else {
            print("Unable to safely unwrap categoryForDeletion")
            return
        }
        do {
            try realm.write {
                realm.delete(categoryForDeletion)
            }
        } catch {
            print("Could not realm delete Category \(error)")
        }
    }
    
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { [weak self] _ in
            // what will happen once the user clicks on Add Category Button
            guard let safeText = textField.text,
                  let strongSelf = self else {
                      print("Failed to safely unwrapp values")
                      return
                  }
            
            // Starts of Create operation from CRUD
            let newCategory = Category()
            newCategory.name = safeText
            newCategory.colour = UIColor.randomFlat().hexValue()
            strongSelf.save(category: newCategory)
            // Ends of Create operation from CRUD
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }

}

