//
//  TableViewController.swift
//  ToDoList
//
//  Created by Alexey Manokhin on 10.07.2023.
//

import UIKit
import CoreData

final class TableViewController: UITableViewController {
    
    
    var tasks: [Task] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let context = getContext()
        
        let fetchRequest = Task.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch {
            print (error.localizedDescription)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        tasks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        
        return cell
    }
    
    
    @IBAction func createTaskButtonTapped(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Новая задача", message: "Добавьте новую задачу", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] action in
            let textFiled = alertController.textFields?.first
            if let newTaskTitle = textFiled?.text, textFiled?.text != "" {
                self?.saveTask(withTitle: newTaskTitle)
                self?.tableView.reloadData()
            }
        }
        alertController.addTextField()
        let cancelAction = UIAlertAction(title: "Отмена", style: .default)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    @IBAction func removeAllTasks(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Удалить все задачи?", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Удалить", style: .default) { [weak self] action in
            let context = self?.getContext()
            let fetchRequest = Task.fetchRequest()
            if let objects = try? context?.fetch(fetchRequest) {
                for object in objects {
                    context?.delete(object)
                }
            }
            do {
                try context?.save()
                self?.tableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .default)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func saveTask(withTitle: String) {
        
        let context = getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        
        let taskObject = Task(entity: entity, insertInto: context)
        taskObject.title = withTitle
        
        do {
            try context.save()
            tasks.insert(taskObject, at: 0)
        } catch {
            print (error.localizedDescription)
        }
    }
    
    private func getContext() -> NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType) }
        let context = appDelegate.persistentContainer.viewContext
        return context
    }
}
