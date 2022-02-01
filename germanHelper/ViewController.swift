//
//  ViewController.swift
//  germanHelper
//
//  Created by Aryaa Saravanakumar on 05/12/2021.
//

import UIKit

class ViewController: UIViewController {
	
    var multipleWords = 0
    var wordStorage: [germanObject] = []
    var clickedMultiWord = false
    
    @IBOutlet var collectionView: UICollectionView!
    override func viewDidLoad() {
		super.viewDidLoad()
		
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
		NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: Notification.Name("reloadView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clickedOnWord(notification:)), name: Notification.Name("clickedWord"), object: nil)
		self.title = germanLists[currentList].name
	}
	
	@objc func reloadView()
	{
        collectionView.reloadData()
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
		
        germanLists[currentList].words.append(germanObject(original: "...", translation: "", german_sentence: "", english_translation: "", word_type: "", gender: ""))
		self.collectionView.reloadData()
		
		//check if word is already in germanWords
		var wordDownloaded = false
		for word in germanWords
		{
			if word.original.lowercased() == germanWord.lowercased()
			{ wordDownloaded = true }
		}
        //check if word is in list already
        for word in germanLists[currentList].words
        {
            if germanWord.lowercased() == word.original.lowercased()
            {
                //the word is already in the list
                if clickedMultiWord == false
                {
                    let alert = UIAlertController(title: "Word already in list", message: "Cannot have duplicate words", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                germanLists[currentList].words.removeLast() //remove the loading indicator
                return
            }
        }
		
		if wordDownloaded == false
		{
			let urlString = "https://aryaagermantranslatorapi.azurewebsites.net/api/germantranslation?word=" + germanWord
            
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
                                    let jsonData = try decoder.decode(germanObject.self, from: jsonString.data(using: .utf8)!)
                                    self.completion(jsonData: jsonData, alreadyContained: false)
                                }
                            catch
                            {
                                print(error)
                                germanLists[currentList].words.removeLast() //remove the loading indicator
                                self.multipleWords -= 1
                                self.collectionView.reloadData()
                                
                                if self.clickedMultiWord == false
                                {
                                    let alert = UIAlertController(title: "Invalid Word", message: "Please enter a valid word", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
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
                    completion(jsonData: word, alreadyContained: true)
				}
			}
		}
	}
    func completion(jsonData: germanObject, alreadyContained: Bool)
    {
        var jsonData = jsonData
        //capitalise the first letter of the original
        var original = jsonData.original.lowercased()
        original = original.capitalized
        
        //add der, die or das
        if jsonData.gender == "Masculine"
        { original = "der " + original }
        if jsonData.gender == "Feminine"
        { original = "die " + original }
        if jsonData.gender == "Neuter"
        { original = "das " + original }
        
        jsonData.original = original
        
        if alreadyContained == false
        {
            germanWords.append(jsonData)
        }
        
        //find a ...
        var i = 0
        while i != germanLists[currentList].words.count
        {
            if germanLists[currentList].words[i].original == "..."
            {
                germanLists[currentList].words.remove(at: i)
                //replace word
                if i == germanLists[currentList].words.count
                {
                    germanLists[currentList].words.append(jsonData)
                }
                else
                {
                    germanLists[currentList].words.insert(jsonData, at: i)
                }
                break
            }
            else
            { i += 1 }
        }
        
        saveToKey(data: JSONEncoder.encode(from: germanLists)!, key: "germanLists")
        saveToKey(data: JSONEncoder.encode(from: germanWords)!, key: "germanWords")
        
        collectionView.reloadData()
    }
    
    @IBAction func addWords(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Words", message: "Type 1 or more words separated by a space or a comma", preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "Word"
        }
        
        alertController.addAction(UIAlertAction(title: "Add Word(s)", style: .default, handler: { alert in
            self.clickedMultiWord = true
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
            self.wordStorage = []
            self.multipleWords = wordList.count
            for word in wordList
            {
                self.search(text: word)
            }
            //need to filter out the ... in the main list since this feature is quite buggy now
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func clickedOnWord(notification: NSNotification)
    {
        let tag = notification.userInfo!["tag"] as! Int
        let selectedIndex = tag
        
        var germanSentence = germanLists[currentList].words[selectedIndex].german_sentence
        var englishSentence = germanLists[currentList].words[selectedIndex].english_translation
        
        if germanSentence == ""
        { germanSentence = "Unavailable" }
        if englishSentence == ""
        { englishSentence = "Unavailable" }
        
        var alertMessage = "Translation : " + germanLists[currentList].words[selectedIndex].translation + "\n\nGerman Sentence : " + germanSentence + "\n\nEnglish Translation : " + englishSentence + "\n\nWord Type : " + germanLists[currentList].words[selectedIndex].word_type
        if germanLists[currentList].words[selectedIndex].gender != "None"
        { alertMessage = alertMessage + "\n\nGender : " + germanLists[currentList].words[selectedIndex].gender }
        
        let alert = UIAlertController(title: "Word: \(germanLists[currentList].words[selectedIndex].original)", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { alert in
            germanLists[currentList].words.remove(at: selectedIndex) //always remove from array before removing from tableview with animation
            saveToKey(data: JSONEncoder.encode(from: germanLists)!, key: "germanLists")
            self.collectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
	
}


extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return germanLists[currentList].words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! wordCell
        cell.wordButton.setTitle(germanLists[currentList].words[indexPath.row].original, for: .normal)
        cell.tag = indexPath.row
        return cell
    }
}

/*

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
			
		}
		else
		{
            let alertController = UIAlertController(title: "Add Words", message: "Type 1 or more words separated by a space or a comma", preferredStyle: .alert)
            alertController.addTextField { textfield in
                textfield.placeholder = "Word"
            }
            
            alertController.addAction(UIAlertAction(title: "Add Word(s)", style: .default, handler: { alert in
                self.clickedMultiWord = true
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
                self.wordStorage = []
                self.multipleWords = wordList.count
                for word in wordList
                {
                    self.search(text: word)
                }
                
                //need to filter out the ... in the main list since this feature is quite buggy now
                
            }))
            
            /*
             alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { alert in
             self.clickedMultiWord = false
             let textfield = alertController.textFields![0] as UITextField
             self.wordStorage = []
             self.search(text: textfield.text!)
             }))*/
            
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
*/
