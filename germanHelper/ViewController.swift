//
//  ViewController.swift
//  germanHelper
//
//  Created by Aryaa Saravanakumar on 05/12/2021.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet var tableView: UITableView!
	
    var multipleWords = 0
    var wordStorage: [germanObject] = []
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.delegate = self
		tableView.dataSource = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: Notification.Name("reloadView"), object: nil)
		self.title = germanLists[currentList].name
	}
	
	@objc func reloadView()
	{
		tableView.reloadData()
		self.title = germanLists[currentList].name
	}
	
	@IBAction func goToLists(_ sender: Any) {
		self.performSegue(withIdentifier: "lists", sender: self)
	}
	@IBAction func goToTest(_ sender: Any) {
		//list must have 4 or more items
		if germanLists[currentList].words.count >= 4
		{
			self.performSegue(withIdentifier: "startTest", sender: self)
		}
		else
		{
			let alert = UIAlertController(title: "List must have 4 or more items", message: "Please add at least 4 items to your study list", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	func search(text: String)
	{
		//when search button is clicked, add word to german words list and then add it to the current list separately
		let germanWord = text
		
		germanLists[currentList].words.append(germanObject(original: "...", translation: "", german_sentence: "", english_translation: ""))
		self.tableView.reloadData()
		
		//check if word is already in germanWords
		var wordDownloaded = false
		for word in germanWords
		{
			if word.original.lowercased() == germanWord.lowercased()
			{ wordDownloaded = true }
		}
		
		if wordDownloaded == false
		{
			let urlString = "https://europe-west2-functions-hello-world-334109.cloudfunctions.net/functions-hello-world?word=" + germanWord
            
            if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
                let url = URL(string: encoded)
            {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let jsonString = String(data: data!, encoding: .utf8)
                    {
                        DispatchQueue.main.async {
                            let decoder = JSONDecoder()
                            do
                                {
                                    var jsonData = try decoder.decode(germanObject.self, from: jsonString.data(using: .utf8)!)
                                    //capitalise the first letter of the original
                                    var original = jsonData.original.lowercased()
                                    original = original.capitalized
                                    jsonData.original = original
                                    
                                    self.wordStorage.append(jsonData)
                                    
                                    if self.multipleWords > 0
                                    {
                                        //self.wordStorage.append(jsonData)
                                        self.multipleWords -= 1
                                    }
                                    if self.multipleWords == 0
                                    {
                                        //first remove all the ... indicators
                                        var i = 0
                                        while i != self.wordStorage.count
                                        {
                                            germanLists[currentList].words.removeLast() //remove the loading indicator
                                            i += 1
                                        }
                                        for item in self.wordStorage
                                        {
                                            print(item)
                                            germanWords.append(item)
                                            germanLists[currentList].words.append(item)
                                            
                                            saveToKey(data: JSONEncoder.encode(from: germanWords)!, key: "germanWords")
                                            saveToKey(data: JSONEncoder.encode(from: germanLists)!, key: "germanLists")
                                        }
                                    }
                                    
                                    self.tableView.reloadData()
                                }
                            catch
                            {
                                print(error)
                                germanLists[currentList].words.removeLast() //remove the loading indicator
                                self.tableView.reloadData()
                                
                                let alert = UIAlertController(title: "Invalid Word", message: "Please enter a valid word", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }.resume()
            }
		}
		else
		{
			for word in germanWords
			{
				if word.original.lowercased() == germanWord.lowercased()
				{
					germanLists[currentList].words.removeLast()
					germanLists[currentList].words.append(word)
					saveToKey(data: JSONEncoder.encode(from: germanLists)!, key: "germanLists")
					tableView.reloadData()
				}
			}
		}
	}
	
}

extension ViewController: UITableViewDelegate, UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return germanLists[currentList].words.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0
		{
			//add item cell
			let cell = tableView.dequeueReusableCell(withIdentifier: "addNewWord", for: indexPath) as! addNewWordCell
			cell.centerLabel.text = "Add Word"
			cell.centerLabel.textColor = .link
			return cell
		}
		else
		{
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
			
			cell.textLabel?.text = germanLists[currentList].words[indexPath.row - 1].original
			if germanLists[currentList].words[indexPath.row - 1].original == "..."
			{ cell.isUserInteractionEnabled = false }
			else
			{ cell.isUserInteractionEnabled = true }
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.row != 0
		{
			let selectedIndex = indexPath.row - 1
			
            var germanSentence = germanLists[currentList].words[selectedIndex].german_sentence
            var englishSentence = germanLists[currentList].words[selectedIndex].english_translation
            
            if germanSentence == ""
            { germanSentence = "Unavailable" }
            if englishSentence == ""
            { englishSentence = "Unavailable" }
            
			let alert = UIAlertController(title: "Word: \(germanLists[currentList].words[selectedIndex].original)", message: "Translation : " + germanLists[currentList].words[selectedIndex].translation + "\n\nGerman Sentence : " + germanSentence + "\n\nEnglish Translation : " + englishSentence, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
		else
		{
			let alertController = UIAlertController(title: "Add New Word", message: "Enter a german word to help you study", preferredStyle: .alert)
			alertController.addTextField { textfield in
				textfield.placeholder = "Word"
			}
            alertController.addAction(UIAlertAction(title: "Add Multiple Words", style: .default, handler: { alert in
                self.wordStorage = []
                
                let textfield = alertController.textFields![0] as UITextField
                let text = textfield.text!
                
                var textList = Array(text) //filter out all the puncuation
                var i = 0
                while i != textList.count
                {
                    if textList[i] == "," || textList[i] == "."
                    { textList.remove(at: i) }
                    else
                    { i += 1 }
                }
                
                var wordList = String(textList).components(separatedBy: [" "]).filter({!$0.isEmpty})
                //filter out the words like ein, eine, einen, der, die, das
                i = 0
                while i != wordList.count
                {
                    if wordList[i].lowercased() == "ein" || wordList[i].lowercased() == "eine" || wordList[i].lowercased() == "einen" || wordList[i].lowercased() == "der" || wordList[i].lowercased() == "die" || wordList[i].lowercased() == "das"
                    { wordList.remove(at: i) }
                    else
                    { i += 1 }
                }
                
                //now we go through the list and search each word 1 by 1
                self.multipleWords = wordList.count
                for word in wordList
                {
                    self.search(text: word)
                }
                
            }))
            alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { alert in
                let textfield = alertController.textFields![0] as UITextField
				self.search(text: textfield.text!)
			}))
			alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			self.present(alertController, animated: true, completion: nil)
		}
		
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		if indexPath.row != 0
		{
			let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, sourceView, completitionHandler in
				germanLists[currentList].words.remove(at: indexPath.row - 1) //always remove from array before removing from tableview with animation
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
