//
//  testController.swift
//  germanHelper
//
//  Created by Aryaa Saravanakumar on 07/12/2021.
//

import UIKit

class testController: UIViewController {

	@IBOutlet var question: UILabel!
	@IBOutlet var button1Outlet: answerButton!
	@IBOutlet var button2Outlet: answerButton!
	@IBOutlet var button3Outlet: answerButton!
	@IBOutlet var button4Outlet: answerButton!
	
	var answerIndexList = [0, 1, 2, 3]
	var questions: [questionObject] = []
	var currentQuestion = 0
	var score = 0
    
    var alreadyAnswered = false
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Test for \(languageLists[currentList].name)"
		self.navigationItem.setHidesBackButton(true, animated: true)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		prepareTest()
	}
	
	func prepareTest()
	{
		score = 0
        alreadyAnswered = false
        
		currentQuestion = 0
		questions = []
		//put words into a random order
		let testList: [languageObject] = languageLists[currentList].words.shuffled()
		
		for word in testList
		{
            //Now we decide the question type, IF USING SENTENCES MUST CHECK IF THERE IS A SENTENCE AVAILABLE FOR THE WORD, SOME DON'T HAVE THEM
            var randomNum = 0
            if word.sentence != "" && word.sentence_translation != ""
            { randomNum = Int.random(in: 0...3) }
            else //only 1 word questions
            { randomNum = Int.random(in: 0...1) }
            //German to English, 1 word
            
            var excludingWords: [languageObject] = []
            if randomNum == 2 || randomNum == 3 //need to exclude the sentences if there isnt any available
            {
                for item in testList
                {
                    if item.sentence == "" || item.sentence_translation == ""
                    {
                        excludingWords.append(item)
                    }
                }
            }
            
			//for answers get some other random items from the testList
            let answer1 = getRandomElement(list: testList, excluding: [word]+excludingWords)
			let answer2 = getRandomElement(list: testList, excluding: [word, answer1]+excludingWords)
			let answer3 = getRandomElement(list: testList, excluding: [word, answer1, answer2]+excludingWords)//there is some problem with this line (could be because the excluding words is the same length as the list)
            let correctAnswer = word
            
            let language = languageLists[currentList].language
            
            if randomNum == 0
            {
                questions.append(questionObject(questionText: "What is the English translation of \(addArticle(object: word, language: language))", answers: [answer1, answer2, answer3, correctAnswer], correctAnswer: correctAnswer, questionType: "GermanToEnglish"))
            }
            //English to German, 1 word
            else if randomNum == 1
            {
                questions.append(questionObject(questionText: "What is the \(language.capitalized) translation of \(word.translation)", answers: [answer1, answer2, answer3, correctAnswer], correctAnswer: correctAnswer, questionType: "EnglishToGerman"))
            }
            //German to English, Sentence
            else if randomNum == 2
            {
                questions.append(questionObject(questionText: "Translate: \(word.sentence)", answers: [answer1, answer2, answer3, correctAnswer], correctAnswer: correctAnswer, questionType: "GermanToEnglishSentence"))
            }
            //English to German, Sentence
            else if randomNum == 3
            {
                questions.append(questionObject(questionText: "Translate: \(word.sentence_translation)", answers: [answer1, answer2, answer3, correctAnswer], correctAnswer: correctAnswer, questionType: "EnglishToGermanSentence"))
            }
		}
        prepareQuestion()
	}
    func prepareQuestion()
	{
        alreadyAnswered = false
		answerIndexList.shuffle()
        
        if currentQuestion >= questions.count //if the user spams a button it could lead to an out of range error
        {
            let alert = UIAlertController(title: "Test Finished", message: "You got \(score) / \(questions.count)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { alert in
                _ = self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            question.text = questions[currentQuestion].questionText
            
            if questions[currentQuestion].questionType == "GermanToEnglish" //answers should be in English
            {
                /*
                button1Outlet.titleLabel?.font = .systemFont(ofSize: 25)
                button2Outlet.titleLabel?.font = .systemFont(ofSize: 25)
                button3Outlet.titleLabel?.font = .systemFont(ofSize: 25)
                button4Outlet.titleLabel?.font = .systemFont(ofSize: 25)
                */ //caused werid animations
                
                button1Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[0]].translation, for: .normal)
                button2Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[1]].translation, for: .normal)
                button3Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[2]].translation, for: .normal)
                button4Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[3]].translation, for: .normal)
            }
            else if questions[currentQuestion].questionType == "EnglishToGerman" //answers in german
            {
                let language = languageLists[currentList].language
                button1Outlet.setTitle(addArticle(object: questions[currentQuestion].answers[answerIndexList[0]], language: language), for: .normal)
                button2Outlet.setTitle(addArticle(object: questions[currentQuestion].answers[answerIndexList[1]], language: language), for: .normal)
                button3Outlet.setTitle(addArticle(object: questions[currentQuestion].answers[answerIndexList[2]], language: language), for: .normal)
                button4Outlet.setTitle(addArticle(object: questions[currentQuestion].answers[answerIndexList[3]], language: language), for: .normal)
            }
            else if questions[currentQuestion].questionType == "GermanToEnglishSentence"
            {
                button1Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[0]].sentence_translation, for: .normal)
                button2Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[1]].sentence_translation, for: .normal)
                button3Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[2]].sentence_translation, for: .normal)
                button4Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[3]].sentence_translation, for: .normal)
            }
            else if questions[currentQuestion].questionType == "EnglishToGermanSentence"
            {
                button1Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[0]].sentence, for: .normal)
                button2Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[1]].sentence, for: .normal)
                button3Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[2]].sentence, for: .normal)
                button4Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[3]].sentence, for: .normal)
            }
        }
        
    }
    func answerClicked(button: Int)
    {
        buttonClickedTag = button
		if questions[currentQuestion].answers[answerIndexList[button]].original == questions[currentQuestion].correctAnswer.original
		{
            if button == 0
            { button1Outlet.setTitleColor(.systemGreen, for: .normal) }
            else if button == 1
            { button2Outlet.setTitleColor(.systemGreen, for: .normal) }
            else if button == 2
            { button3Outlet.setTitleColor(.systemGreen, for: .normal) }
            else if button == 3
            { button4Outlet.setTitleColor(.systemGreen, for: .normal) }
            
			score += 1
		}
        else
        {
            if button == 0
            { button1Outlet.setTitleColor(.red, for: .normal) }
            else if button == 1
            { button2Outlet.setTitleColor(.red, for: .normal) }
            else if button == 2
            { button3Outlet.setTitleColor(.red, for: .normal) }
            else if button == 3
            { button4Outlet.setTitleColor(.red, for: .normal) }
        }
        
		if currentQuestion != questions.count - 1 && alreadyAnswered == false
		{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.button1Outlet.reset()
                self.button2Outlet.reset()
                self.button3Outlet.reset()
                self.button4Outlet.reset()
                
                self.currentQuestion += 1
                self.prepareQuestion()
            }
		}
		else
		{
			let alert = UIAlertController(title: "Test Finished", message: "You got \(score) / \(questions.count)", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { alert in
				_ = self.navigationController?.popViewController(animated: true)
			}))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	struct questionObject
	{
		let questionText: String
		let answers: [languageObject]
		let correctAnswer: languageObject
        let questionType: String
	}
	
	@IBAction func button1(_ sender: Any) {
        if alreadyAnswered == false
        { answerClicked(button: 0); alreadyAnswered = true }
	}
	@IBAction func button2(_ sender: Any) {
        if alreadyAnswered == false
        { answerClicked(button: 1); alreadyAnswered = true }
	}
	@IBAction func button3(_ sender: Any) {
        if alreadyAnswered == false
        { answerClicked(button: 2); alreadyAnswered = true }
	}
	@IBAction func button4(_ sender: Any) {
        if alreadyAnswered == false
        { answerClicked(button: 3); alreadyAnswered = true }
	}
		
	@IBAction func nextButton(_ sender: Any) {
	}
	
	func getRandomElement(list: [languageObject], excluding: [languageObject]) -> languageObject
	{
        if list.count <= excluding.count //check if the excluding is the same length or smaller, this should not be happening but I can't fix it right now so this is the temporary fix
        {
            //im not sure what happened but this seems to solve the issue, THIS IS PROBABLY ONLY A TEMPORARY FIX THOUGH
            return list[0]
        }
        
        //THIS ERROR IS CAUSED BY THE LIST BEING THE SAME AS THE EXCLUDING LIST SO THE checkElementContained function never returns false
		var randomIndex = Int.random(in: 0...list.count-1)
		while checkElementContained(list: excluding, element: list[randomIndex]) == true //the problem is in this loop
        { randomIndex = Int.random(in: 0...list.count-1)} //this causes an infinite loop sometimes
		return list[randomIndex]
	}
	func checkElementContained(list: [languageObject], element: languageObject) -> Bool
	{
		for item in list
		{
			if item.original == element.original
			{ return true }
		}
		return false
	}
}

extension UIButton
{
    func changeColour(colour: UIColor)
    {
        self.backgroundColor = colour
    }
}
