//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

// ToDoItemCell

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

        /* Navigation Bar appearance */
        
        if let colourHex = selectedCategory?.colour {
            if let navBarColour = UIColor(hexString: colourHex) {
                setUpNavBar(with: navBarColour)
            } else {
                setUpNavBar()
            }
        }
        
        searchBar.barTintColor = UIColor(hexString: selectedCategory?.colour ?? "007AFF")
        searchBar.searchTextField.backgroundColor = FlatWhite()
    }
    
    func setUpNavBar(with colour: UIColor = UIColor.white) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.") }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        appearance.backgroundColor = colour
        appearance.titleTextAttributes = [.foregroundColor: ContrastColorOf(colour, returnFlat: true)]
        appearance.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(colour, returnFlat: true)]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.rightBarButtonItem?.tintColor = ContrastColorOf(colour, returnFlat: true)
        navBar.tintColor = ContrastColorOf(colour, returnFlat: true)
    }
    
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            // currently on row #1
            // there's a total of 10 items in todoItems
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
            // Ternary operator ==>
            // value = condition ? valueIfTrue : valueIfFalse
            
            cell.accessoryType = item.done == true ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            // UPDATE operation from CRUD to toggle checkmark
            do {
                try realm.write({
                    item.done = !item.done
                })
            } catch {
                print("Could't realm update item \(error)")
            }
        }
        
        // After reloading the table the cellForRowAt will be executed again and will execute cell accesories modifiers
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { [weak self] _ in
            // what will happen once the user clicks on Add Item button
            
            // unwrap optional values
            guard let safeText = textField.text,
                  let strongSelf = self,
                  let strongCategory = self?.selectedCategory else {
                print("Failed to safely unwrap values")
                return
            }
            
            // Starts of Create operation from CRUD
            do {
                try strongSelf.realm.write({
                    let newItem = Item()
                    newItem.title = safeText
                    newItem.dateCreated = Date()
                    strongCategory.items.append(newItem)
                })
            } catch {
                print("Couldn't realm write new item \(error)")
            }
            // Ends of Create operation from CRUD
            
            strongSelf.tableView.reloadData()
            
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    
    // Read operation from CRUD
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        guard let itemToDelete = todoItems?[indexPath.row] else {
            print("Unable to unwrap itemToDelete")
            return
        }
        
        do {
            try realm.write({
                realm.delete(itemToDelete)
            })
        } catch {
            print("Could not realm delete Item \(error)")
        }
    }
}


//MARK: - UISearchBar Delegate Methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}
