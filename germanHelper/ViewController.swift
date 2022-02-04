//
//  ViewController.swift
//  germanHelper
//
//  Created by Aryaa Saravanakumar on 05/12/2021.
//

import UIKit

class ViewController: UIViewController {
	
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var addWordButton: UIButton!
    @IBOutlet var emptyScreen: EmptyScreen!
    override func viewDidLoad() {
		super.viewDidLoad()
		
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
		NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: Notification.Name("reloadView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clickedOnWord(notification:)), name: Notification.Name("clickedWord"), object: nil)
		self.title = germanLists[currentList].name
        
        checkWords()
        
        emptyScreen.imageView.image = UIImage(systemName: "text.bubble")
        emptyScreen.viewLabel.text = "You have not added any words, to get started click the Add Words button"
        emptyScreen.isHidden = true
        checkEmptyScreen()
	}
    
    func checkEmptyScreen()
    {
        if germanLists[currentList].words.count == 0
        { emptyScreen.isHidden = false }
        else
        { emptyScreen.isHidden = true }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 115, height: 115) //can also make this screenwidth/height / 3
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        collectionView!.collectionViewLayout = layout
        
        //need to add  a bottom border to the addNewWords button
        setColours()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setColours()
        }
    }
    
    func setColours()
    {
        if traitCollection.userInterfaceStyle == .dark {
            //Dark
            addWordButton.addBottomBorderWithColor(color: UIColor.init(red: 30/255, green: 30/255, blue: 30/255, alpha: 1), width: 0.5)
        }
        else {
            //Light
            addWordButton.addBottomBorderWithColor(color: UIColor.init(red: 215/255, green: 215/255, blue: 215/255, alpha: 1), width: 0.5)
        }
    }
	
	@objc func reloadView()
	{
        collectionView.reloadData()
        checkEmptyScreen()
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
	/*
    func search(text: String)
    {
        //when search button is clicked, add word to german words list and then add it to the current list separately
        let germanWord = text
        
        germanLists[currentList].words.append(germanObject(original: "...", translation: "", german_sentence: "", english_translation: "", word_type: "", gender: ""))
        self.collectionView.reloadData()
        checkEmptyScreen()
        
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
            //let urlString = "https://europe-west2-functions-hello-world-334109.cloudfunctions.net/functions-hello-world?word=" + germanWord (OLD API)
            let urlString = "https://aryaagermantranslatorapi.azurewebsites.net/api/germantranslation?word=" + germanWord //in the future I will need to change this to just submit one list and then get 1 list returned
            
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
                                print(jsonString)
                                print(error)
                                
                                germanLists[currentList].words.removeLast() //remove the loading indicator
                                self.collectionView.reloadData()
                                self.checkEmptyScreen()
                                
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
        checkEmptyScreen()
    }
     */
    
    func searchWords(words: [String])
    {
        //check which words are already in germanWords
        var alreadyHave: [germanObject] = []
        var needToGet: [String] = []
        
        for word in words
        {
            var i = 0
            var didAdd = false
            while i != germanWords.count
            {
                if germanWords[i].original.lowercased() == word.lowercased()
                {
                    //since it already exists we add it to alreadyHave
                    alreadyHave.append(germanWords[i])
                    didAdd = true
                }
                i += 1
            }
            if didAdd == false
            {
                //didnt add so we just add it to need to get
                needToGet.append(word)
            }
        }
        
        //once we have these we can just add the alreadyHave and get the other words in one api call
        germanLists[currentList].words.append(contentsOf: alreadyHave)
        collectionView.reloadData()
        checkEmptyScreen()
        
        saveToKey(data: JSONEncoder.encode(from: germanLists)!, key: "germanLists")
        
        if needToGet.count > 0 //check if there are even any words to get
        {
            var wordList = ""
            for word in needToGet
            { wordList = wordList + word + "_" }
            wordList.removeLast()
            
            //now just call the api
            let urlString = "https://aryaagermantranslatorapi.azurewebsites.net/api/germantranslation?wordList=" + wordList
            let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            let url = URL(string: encoded!)
            
            URLSession.shared.dataTask(with: url!) { data, response, error in
                if let jsonString = String(data: data!, encoding: .utf8)
                {
                    DispatchQueue.main.async {
                        let decoder = JSONDecoder()
                        do
                        {
                            struct returnObject: Decodable
                            {
                                var words: [germanObject]
                            }
                            let jsonData = try decoder.decode(returnObject.self, from: jsonString.data(using: .utf8)!)
                            
                            //and now just add the data to german words and then the current list
                            germanWords.append(contentsOf: jsonData.words)
                            germanLists[currentList].words.append(contentsOf: jsonData.words)
                            
                            //save data
                            saveToKey(data: JSONEncoder.encode(from: germanLists)!, key: "germanLists")
                            saveToKey(data: JSONEncoder.encode(from: germanWords)!, key: "germanWords")
                            
                            //reload views
                            self.collectionView.reloadData()
                            self.checkEmptyScreen()
                        }
                        catch
                        {
                            print(jsonString)
                            print(error)
                            
                            self.collectionView.reloadData()
                            self.checkEmptyScreen()
                        }
                    }
                }
            }.resume()
        }
    }
    
    @IBAction func addWords(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Words", message: "Type 1 or more words separated by a space or a comma.\n\nYou can also scan words in by clicking on the textfield and selecting scan text.", preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "German Words"
        }
        
        alertController.addAction(UIAlertAction(title: "Add Word(s)", style: .default, handler: { alert in
            let textfield = alertController.textFields![0] as UITextField
            let text = textfield.text!
            
            let removeItems = [",", ".", "/", "?", "!", "(", ")", "=", "[", "]", "&", ":", "`", "-", "_"]
            
            var textList = Array(text) //filter out all the puncuation
            var i = 0
            while i != textList.count
            {
                if removeItems.contains(String(textList[i]))
                { textList[i] = " " }
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
            self.searchWords(words: wordList)
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
        
        let alert = UIAlertController(title: "Word: \(addArticle(object: germanLists[currentList].words[selectedIndex]))", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { alert in
            germanLists[currentList].words.remove(at: selectedIndex) //always remove from array before removing from tableview with animation
            saveToKey(data: JSONEncoder.encode(from: germanLists)!, key: "germanLists")
            self.collectionView.reloadData()
            self.checkEmptyScreen()
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
        cell.wordButton.setTitle(addArticle(object: germanLists[currentList].words[indexPath.row]), for: .normal)
        cell.tag = indexPath.row
        return cell
    }
}


extension UIView {
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
}
