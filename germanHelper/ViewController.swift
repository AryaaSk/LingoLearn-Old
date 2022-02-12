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
    
    var isLoading = false
    
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
        
        isLoading = false
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
	
    func searchWords(words: [String])
    {
        isLoading = true
        collectionView.reloadData()
        emptyScreen.isHidden = true //just hide the empty screen as there is guarnteed to be a loading cell
        
        //check which words are already in germanWords
        var alreadyHave: [languageObject] = []
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
        saveToKey(data: JSONEncoder.encode(from: germanLists)!, key: "germanLists")
        
        if needToGet.count > 0 //check if there are even any words to get
        {
            /*
            var wordList = ""
            for word in needToGet
            { wordList = wordList + word + "_" }
            wordList.removeLast()
            */
            
            var wordCount = needToGet.count //when this reaches 0 we set loading to 0
            
            for word in needToGet
            {
                //now just call the api (uses linguee external API but if that fails it uses the old scrapper API)
                let urlString = "https://aryaagermantranslatorapi.azurewebsites.net/api/germantranslation?wordList=" + word
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
                                    var words: [languageObject]
                                }
                                let jsonData = try decoder.decode(returnObject.self, from: jsonString.data(using: .utf8)!)
                                print(jsonData)
                                
                                //and now just add the data to german words and then the current list
                                germanWords.append(contentsOf: jsonData.words)
                                germanLists[currentList].words.append(contentsOf: jsonData.words)
                                
                                //save data
                                saveToKey(data: JSONEncoder.encode(from: germanLists)!, key: "germanLists")
                                saveToKey(data: JSONEncoder.encode(from: germanWords)!, key: "germanWords")
                                
                                //reload views
                                self.collectionView.reloadData()
                                self.checkEmptyScreen()
                                wordCount -= 1
                                if wordCount == 0 //checking if all words have been loaded, if so then we end the loading
                                {
                                    self.isLoading = false
                                }
                            }
                            catch
                            {
                                print(jsonString)
                                print(error)
                                
                                self.collectionView.reloadData()
                                self.checkEmptyScreen()
                                wordCount -= 1
                                if wordCount == 0
                                {
                                    self.isLoading = false
                                }
                            }
                        }
                    }
                }.resume()
            }
        }
        else
        {
            //if there arent any words to get from api then we can just stop loading and reload the table view here
            isLoading = false
            collectionView.reloadData()
            checkEmptyScreen()
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
            let removeWords = ["ein", "eine", "einen", "der", "die", "das", "dem", "zu", "zur", "zum", "und", "am", "im", "um"]
            
            i = 0
            while i != wordList.count
            {
                //if wordList[i].lowercased() == "ein" || wordList[i].lowercased() == "eine" || wordList[i].lowercased() == "einen" || wordList[i].lowercased() == "der" || wordList[i].lowercased() == "die" || wordList[i].lowercased() == "das"
                if removeWords.contains(wordList[i].lowercased())
                { wordList.remove(at: i) }
                else
                { i += 1 }
            }
            
            wordList = Array(Set(wordList)) //removes duplicates
            
            //AZURE FUNCTION GETS BLOCKED AFTER 22 WORDS (FIRST TEST), TO STAY SAFE I WILL SET THE LIMIT AS 15 WORDS
            //IF THE SERVER UNEXPECTANTLY CRASHES/BREAKS, JUST GO TO THE AZURE PORTAL AND RESTART THE FUNCTION APP
            
            //now checks if the wordList.count > 15, if it is then give an alert since it could get the azure function blocked
            
            if wordList.count > 15
            {
                let alert = UIAlertController(title: "Too many words", message: "You can only add upto 15 words at one time", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else
            { self.searchWords(words: wordList) }
            
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
        if isLoading == false
        { return germanLists[currentList].words.count }
        else
        { return germanLists[currentList].words.count + 1 }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! wordCell
        
        if indexPath.row == germanLists[currentList].words.count
        {
            //this is the loading cell since it's indexpath is at the end of the list
            cell.wordButton.setTitle("Loading...", for: .normal)
            cell.isUserInteractionEnabled = false
        }
        else
        {
            cell.wordButton.setTitle(addArticle(object: germanLists[currentList].words[indexPath.row]), for: .normal)
            cell.tag = indexPath.row
            cell.isUserInteractionEnabled = true
        }
        
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
