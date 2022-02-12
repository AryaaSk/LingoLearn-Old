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
        alertController.addTextField { languageTextfield in
            languageTextfield.placeholder = "German, French, or Spanish"
        }
		alertController.addAction(UIAlertAction(title: "Create", style: .default, handler: { alert in
            let languageTextfield = alertController.textFields![1] as UITextField
            let language = languageTextfield.text!.lowercased()
            print(language)
            if language == "german" || language == "french" || language == "spanish"
            {
                let textfield = alertController.textFields![0] as UITextField
                languageLists.append(languageList(name: textfield.text!, language: language, words: []))
                saveToKey(data: JSONEncoder.encode(from: languageLists)!, key: "languageLists")
                self.tableView.reloadData()
                
                currentList = languageLists.count - 1 //new list
                saveToKey(data: String(currentList), key: "currentList")
                NotificationCenter.default.post(Notification(name: Notification.Name("reloadView")))
                self.dismiss(animated: true, completion: nil)
            }
            else
            {
                //create a new alert
                let warningAlert = UIAlertController(title: "Invalid Language", message: "Please type one of the 3 languages in the language textfield\n(German, French or Spanish)", preferredStyle: .alert)
                warningAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(warningAlert, animated: true, completion: nil)
            }
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		self.present(alertController, animated: true, completion: nil)
	}
	
}

extension listsController: UITableViewDelegate, UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return languageLists.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = languageLists[indexPath.row].name
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		currentList = indexPath.row
        saveToKey(data: String(currentList), key: "currentList")
		NotificationCenter.default.post(Notification(name: Notification.Name("reloadView")))
		
		self.dismiss(animated: true, completion: nil)
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let renameAction = UIContextualAction(style: .normal, title: "Rename") { action, sourceView, completitionHandler in
            //show rename alert
            let renameAlert = UIAlertController(title: "Rename list: " + languageLists[indexPath.row].name, message: "", preferredStyle: .alert)
            renameAlert.addTextField { textfield in
                textfield.placeholder = "New List Name"
            }
            
            renameAlert.addAction(UIAlertAction(title: "Rename", style: .default) { alert in
                let textfield = renameAlert.textFields![0] as UITextField
                let listText = textfield.text!
                
                //check if listText is ""
                if listText == ""
                {
                    //show error alert
                    let errorAlert = UIAlertController(title: "Unable to rename list", message: "Please enter a valid name", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
                
                languageLists[indexPath.row].name = listText
                saveToKey(data: JSONEncoder.encode(from: languageLists)!, key: "languageLists")
                tableView.reloadData()
            })
            renameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(renameAlert, animated: true, completion: nil)
        }
        renameAction.backgroundColor = .link
        
		if languageLists.count != 1
        {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, sourceView, completitionHandler in
                languageLists.remove(at: indexPath.row) //always remove from array before removing from tableview with animation
                if currentList != 0
                { currentList -= 1; saveToKey(data: String(currentList), key: "currentList") }
                saveToKey(data: JSONEncoder.encode(from: languageLists)!, key: "languageLists")
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, renameAction])
			return swipeConfig
		}
		else
		{
            let swipeConfig = UISwipeActionsConfiguration(actions: [renameAction])
            return swipeConfig
		}
	}
}
