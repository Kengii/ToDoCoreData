//
//  TaskTVC.swift
//  ToDoCoreData
//
//  Created by Владимир Данилович on 8.03.22.
//

import UIKit
import CoreData

class TaskTVC: UITableViewController {

    var chosenMainToDo: MainToDo? {
        didSet {
            self.title = chosenMainToDo?.name
            loadTask()
        }
    }
    var tasks = [Task]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addBtn(_ sender: UIBarButtonItem) {
        let alertC = UIAlertController(title: "add Task", message: nil, preferredStyle: .alert)

        alertC.addTextField { textFieald in
            textFieald.placeholder = "AddTask"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] textField in
            if let textField = alertC.textFields?.first,
                let text = textField.text, text != "",
                let self = self {
                let task = Task(context: self.context)
                task.title = text
                task.done = false
                task.mainToDo = self.chosenMainToDo
                self.tasks.append(task)
                self.saveTask()
                self.tableView.insertRows(at: [IndexPath(row: self.tasks.count - 1, section: 0)], with: .fade)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertC.addAction(addAction)
        alertC.addAction(cancelAction)
        present(alertC, animated: true)
    }


    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

        cell.textLabel?.text = tasks[indexPath.row].title
        cell.accessoryType = tasks[indexPath.row].done ? .checkmark : .none

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let title = tasks[indexPath.row].title {
                let request: NSFetchRequest<Task> = Task.fetchRequest()
                request.predicate = NSPredicate(format: "title==\(title)")

                if let tasks = try? context.fetch(request) {
                    for task in tasks {
                        context.delete(task)
                    }

                    self.tasks.remove(at: indexPath.row)
                    saveTask()
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let elementToMove = tasks[fromIndexPath.row]
        tasks.remove(at: fromIndexPath.row)
        tasks.insert(elementToMove, at: to.row)
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - Table view delegate
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let done = tasks[indexPath.row]
        done.done.toggle()
            tableView.reloadData()
    }

    // MARK: - Core Data
    
    private func saveTask() {
        do {
            try context.save()
        } catch {
            print("Error Save")
        }
    }

    private func loadTask(with request: NSFetchRequest<Task> = Task.fetchRequest(), predicate: NSPredicate? = nil) {

        guard let name = chosenMainToDo?.name else { return }
        let mainToDoPredicate = NSPredicate(format: "mainToDo.name MATCHES %@", name)
        
        if let predicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, mainToDoPredicate])
        } else {
        request.predicate = mainToDoPredicate
        }
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Error Load")
        }
        tableView.reloadData()
    }
}

extension TaskTVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadTask()
            searchBar.resignFirstResponder()
        } else {
            let reauest: NSFetchRequest<Task> = Task.fetchRequest()
            let searchPredicate = NSPredicate(format: "title CONTAINS %@", searchText)
            reauest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            loadTask(with: reauest, predicate: searchPredicate)
        }
    }
}
