//
//  MainToDoTVC.swift
//  ToDoCoreData
//
//  Created by Владимир Данилович on 8.03.22.
//

import UIKit
import CoreData

class MainToDoTVC: UITableViewController {

    var mainToDo = [MainToDo]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadMainToDo()
    }

    @IBAction func editMoveCell(_ sender: UIBarButtonItem) {
        isEditing.toggle()
        saveMainToDo()
    }

    @IBAction func addBtn(_ sender: UIBarButtonItem) {

        let alertC = UIAlertController(title: "MainToDo", message: nil, preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] textField in
            if let textField = alertC.textFields?.first,
                let text = textField.text, text != "",
                let self = self {
                let mainToDo = MainToDo(context: self.context)
                mainToDo.name = text
                self.mainToDo.append(mainToDo)
                self.saveMainToDo()
                self.tableView.insertRows(at: [IndexPath(row: self.mainToDo.count - 1, section: 0)], with: .fade)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertC.addTextField { textFieald in
            textFieald.placeholder = "AddToDo"
        }
        alertC.addAction(addAction)
        alertC.addAction(cancelAction)
        present(alertC, animated: true)
    }


    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mainToDo.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath)

        cell.textLabel?.text = mainToDo[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            if let name = mainToDo[indexPath.row].name {
                let request: NSFetchRequest<MainToDo> = MainToDo.fetchRequest()
                request.predicate = NSPredicate(format: "name==\(name)")
                
                if let mainToDo = try? context.fetch(request) {
                    for toDo in mainToDo {
                        context.delete(toDo)
                    }
                    
                    self.mainToDo.remove(at: indexPath.row)
                    saveMainToDo()
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let elementToMove = mainToDo[fromIndexPath.row]
        mainToDo.remove(at: fromIndexPath.row)
        mainToDo.insert(elementToMove, at: to.row)
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    //  MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goTasks", sender: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let taskTVC = segue.destination as? TaskTVC,
           let indexPath = tableView.indexPathForSelectedRow {
            taskTVC.chosenMainToDo = mainToDo[indexPath.row]
        }
    }

    // MARK: - Core Data

    private func saveMainToDo() {
        do {
            try context.save()
        } catch {
            print("Error Save")
        }
    }

    private func loadMainToDo(with request: NSFetchRequest<MainToDo> = MainToDo.fetchRequest()) {
        do {
            mainToDo = try context.fetch(request)
        } catch {
            print("Error Load")
        }
        tableView.reloadData()
    }
}
