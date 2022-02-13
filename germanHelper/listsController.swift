//
//  listsController.swift
//  germanHelper
//
//  Created by Aryaa Saravanakumar on 06/12/2021.
//

import UIKit

class listsController: UIViewController {

    @IBOutlet var emptyScreen: EmptyScreen!
    @IBOutlet var languageControl: UISegmentedControl!
    var showingLists: [languageList] = [] //instead of using languageLists, use this instead
    @IBOutlet var tableView: UITableView!
	override func viewDidLoad() {
        super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
        
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set the language
        if currentLanguage == "german"
        { languageControl.selectedSegmentIndex = 0 }
        else if currentLanguage == "french"
        { languageControl.selectedSegmentIndex = 1 }
        else if currentLanguage == "spanish"
        { languageControl.selectedSegmentIndex = 2 }
        getLanguageList()
        tableView.reloadData()
    }
	
    @IBAction func languageChanged(_ sender: Any) {
        switch languageControl.selectedSegmentIndex
        {
        case 0:
            //german
            currentLanguage = "german" //always lowercase
            saveToKey(data: currentLanguage, key: "currentLanguage")
            getLanguageList()
            tableView.reloadData()
        case 1:
            //french
            currentLanguage = "french"
            saveToKey(data: currentLanguage, key: "currentLanguage")
            getLanguageList()
            tableView.reloadData()
        case 2:
            //spanish
            currentLanguage = "spanish"
            saveToKey(data: currentLanguage, key: "currentLanguage")
            getLanguageList()
            tableView.reloadData()
        default:
            break
        }
    }
    
    func getLanguageList() //use this function instead of tableView.reloadData() as it gets the lists which should be displayed
    {
        //get all languageLists with the language set to the currentLanguage, then just return those
        showingLists = []
        for List in languageLists
        {
            if List.language.lowercased() == currentLanguage
            { showingLists.append(List) }
        }
        
        //since this gets called everytime the list changes, we can also use this oppurtunity to show/hide the empty screen
        emptyScreen.viewLabel.text = "You don't have any \(currentLanguage.capitalized) Lists, click the New List button to get started"
        emptyScreen.imageView.image = UIImage(systemName: "book")
        if showingLists.count == 0
        { emptyScreen.isHidden = false }
        else
        { emptyScreen.isHidden = true }
    }
    
    func getListIndex(name: String) -> Int
    {
        var i = 0
        while i != languageLists.count
        {
            if languageLists[i].name == name
            { break }
            i += 1
        }
        return i
    }
    
    @IBAction func newList(_ sender: Any) {
        let alertController = UIAlertController(title: "Add New \(currentLanguage.capitalized) List", message: "Use these lists for different topics you want to study", preferredStyle: .alert)
		alertController.addTextField { textfield in
			textfield.placeholder = "List Name"
		}
		alertController.addAction(UIAlertAction(title: "Create", style: .default, handler: { alert in
            let language = currentLanguage.lowercased()
            print(language)
            let textfield = alertController.textFields![0] as UITextField
            let listText = textfield.text!
            
            //check if this is the same name as any other list
            var nameTaken = false
            for List in languageLists
            {
                if List.name == listText
                { nameTaken = true }
            }
            
            if nameTaken == true
            {
                let errorAlert = UIAlertController(title: "Unable to create list", message: "The list name is already in use by another list", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
            else
            {
                //check if listText is ""
                if listText == ""
                {
                    //show error alert
                    let errorAlert = UIAlertController(title: "Unable to create list", message: "Please enter a valid name", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
                else
                {
                    languageLists.append(languageList(name: textfield.text!, language: language, words: []))
                    saveToKey(data: JSONEncoder.encode(from: languageLists)!, key: "languageLists")
                    self.getLanguageList()
                    self.tableView.reloadData()
                    
                    currentList = languageLists.count - 1 //new list
                    saveToKey(data: String(currentList), key: "currentList")
                    NotificationCenter.default.post(Notification(name: Notification.Name("reloadView")))
                    self.dismiss(animated: true, completion: nil)
                }
            }
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		self.present(alertController, animated: true, completion: nil)
	}
	
}

extension listsController: UITableViewDelegate, UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return showingLists.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = showingLists[indexPath.row].name
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //to find the currentList we need to find the list with the same name (you aren't allowed to have the same list name twice)
        let listName = showingLists[indexPath.row].name
		currentList = getListIndex(name: listName)
        saveToKey(data: String(currentList), key: "currentList")
		NotificationCenter.default.post(Notification(name: Notification.Name("reloadView")))
		
		self.dismiss(animated: true, completion: nil)
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let renameAction = UIContextualAction(style: .normal, title: "Rename") { action, sourceView, completitionHandler in
            //show rename alert
            let renameAlert = UIAlertController(title: "Rename list: " + self.showingLists[indexPath.row].name, message: "", preferredStyle: .alert)
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
                else
                {
                    let listName = self.showingLists[indexPath.row].name
                    let currentIndex = self.getListIndex(name: listName)
                    languageLists[currentIndex].name = listText
                    saveToKey(data: JSONEncoder.encode(from: languageLists)!, key: "languageLists")
                    self.getLanguageList()
                    tableView.reloadData()
                }
            })
            renameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(renameAlert, animated: true, completion: nil)
        }
        renameAction.backgroundColor = .link
        
		if languageLists.count != 1
        {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, sourceView, completitionHandler in
                //cant use indexPath.row anymore, since i need to get the currentList
                
                let listName = self.showingLists[indexPath.row].name
                let currentIndex = self.getListIndex(name: listName)
                languageLists.remove(at: currentIndex) //always remove from array before removing from tableview with animation
                self.getLanguageList()
                
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
