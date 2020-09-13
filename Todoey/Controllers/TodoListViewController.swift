//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController
{
    var itemArray = [Item]()
    var selectedCategory: Category? {
        
        didSet{
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let coreContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.placeholder = "find it..."
        //loadItems()
        // print(FileManager.default.urls(for:.documentDirectory, in: .userDomainMask))
        //loadItems()
        
    }
    
    
    
    
    
    // call try.context.save() for the App Delegate's persistent container
    func saveItems()
    {
        
        
        do {
            try coreContext.save()
            
        } catch {
            print("Error saving context: \(error)")
        }
        
    }
    
    //MARK - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        let item = itemArray[indexPath.row]
        
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done.toggle()
        //coreContext.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        saveItems()
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    

    
    
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title:"Add New Todoey Item",
                                      message: "",
                                      preferredStyle: .alert)
        
        var textField = UITextField()
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create new item"
            
            textField = alertTextField
            
            
            self.tableView.reloadData()
            
            
            
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default){(action) in
            //what will happen once the user clicks the add item button on our UIAlert
            
            
            let newItem = Item(context: self.coreContext)
            
            newItem.title = textField.text ?? "New Item"
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            print("new item: \(newItem)")
            self.saveItems()
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems(_ request: NSFetchRequest<Item> = Item.fetchRequest(),with predicate: NSPredicate? = nil)
    {
       // let predicate = NSPredicate(format:"parentCategory.name MATCHES %@",selectedCategory!.name!)
       
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let safePredicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, safePredicate])
            request.predicate = compoundPredicate
        } else {

            request.predicate = categoryPredicate
        }
        
        
        
        do {
            itemArray = try coreContext.fetch(request)
            tableView.reloadData()
            
        } catch {
            print("Error fetching data from context \(error)")
        }
        
    }
    
    
}

//MARK - UISearchBarDelegate search bar methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text! + " " + selectedCategory!.name!)
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        let sortDescriptor = NSSortDescriptor(key:  "title", ascending: true)
        
        request.sortDescriptors = [sortDescriptor]
        
        loadItems(request, with: titlePredicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count == 0){
            searchBar.placeholder = "find it ... "
            self.loadItems()
            DispatchQueue.main.async{
                searchBar.resignFirstResponder()
                
            }
            
        }
    }
    
}
