//
//  CategoryViewController.swift
//  Todoey
//
//  Created by pancake on 9/11/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData



class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    
    private let coreContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        print("add new category")
        let alert = UIAlertController(title:"Add New Category",
                                      message: "",
                                      preferredStyle: .alert)
        
        var textField = UITextField()
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
            self.tableView.reloadData()
        }
        
        let action = UIAlertAction(title: "Add Category", style: .default){ action in
            
            let newCategory = Category(context: self.coreContext)
            
            newCategory.name = textField.text ?? "New Category"
            
            self.categoryArray.append(newCategory)
            print("new category: \(newCategory)")
            self.saveCategories()
            self.tableView.reloadData()
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    

    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
    
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
        
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
        
    }
    
    //MARK: - Data Manipulation Methods
    private func saveCategories()
    {
        do {
            try coreContext.save()
            
        } catch {
            print("Error saving context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    private  func loadCategories(_ request: NSFetchRequest<Category> = Category.fetchRequest())
    {
        
        do {
            categoryArray = try coreContext.fetch(request)
            tableView.reloadData()
            
        } catch {
            print("Error fetching data from context \(error)")
        }
        
    }
}
