//
//  listsController.swift
//  germanHelper
//
//  Created by Aryaa Saravanakumar on 06/12/2021.
//

import UIKit

class listsController: UIViewController {

	@IBOutlet var tableView: UITableView!
	override func viewDidLoad() {
        super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	@IBAction func newList(_ sender: Any) {
		let alertController = UIAlertController(title: "Add New List", message: "Use these lists for different topics you want to study", preferredStyle: .alert)
		alertController.addTextField { textfield in
			textfield.placeholder = "List Name"
		}
		alertController.addAction(UIAlertAction(title: "Create", style: .default, handler: { alert in
			let textfield = alertController.textFields![0] as UITextField
			germanLists.append(germanList(name: textfield.text!, words: []))
			saveToKey(data: JSONEncoder.encode(from: germanLists)!, key: "germanLists")
			self.tableView.reloadData()
			
			currentList = germanLists.count - 1 //new list
			NotificationCenter.default.post(Notification(name: Notification.Name("reloadView")))
			self.dismiss(animated: true, completion: nil)
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		self.present(alertController, animated: true, completion: nil)
	}
	
}

extension listsController: UITableViewDelegate, UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return germanLists.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = germanLists[indexPath.row].name
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		currentList = indexPath.row
		NotificationCenter.default.post(Notification(name: Notification.Name("reloadView")))
		
		self.dismiss(animated: true, completion: nil)
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		if germanLists.count != 1
        {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, sourceView, completitionHandler in
                germanLists.remove(at: indexPath.row) //always remove from array before removing from tableview with animation
                if currentList != 0
                { currentList -= 1 }
                saveToKey(data: JSONEncoder.encode(from: germanLists)!, key: "germanLists")
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
			return swipeConfig
		}
		else
		{
			return nil
		}
	}
}
