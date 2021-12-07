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
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Test for \(germanLists[currentList].name)"
		self.navigationItem.setHidesBackButton(true, animated: true)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		prepareTest()
	}
	
	func prepareTest()
	{
		score = 0
		currentQuestion = 0
		questions = []
		//put words into a random order
		let testList: [germanObject] = germanLists[currentList].words.shuffled()
		
		for word in testList
		{
			//IF USING SENTENCES MUST CHECK IF THERE IS A SENTENCE AVAILABLE FOR THE WORD, SOME DON'T HAVE THEM
			
			//for answers get some other random items from the testList
			let answer1 = getRandomElement(list: testList, excluding: [word])
			let answer2 = getRandomElement(list: testList, excluding: [word, answer1])
			let answer3 = getRandomElement(list: testList, excluding: [word, answer1, answer2])
			let correctAnswer = word
			
			questions.append(questionObject(questionText: "What is the English translation of \(word.original)", answers: [answer1, answer2, answer3, correctAnswer], correctAnswer: correctAnswer))
		}
		
		prepareQuestion()
	}
	func prepareQuestion()
	{
		answerIndexList.shuffle()
		
		question.text = questions[currentQuestion].questionText
		
		button1Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[0]].translation, for: .normal)
		button2Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[1]].translation, for: .normal)
		button3Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[2]].translation, for: .normal)
		button4Outlet.setTitle(questions[currentQuestion].answers[answerIndexList[3]].translation, for: .normal)
	}
	func answerClicked(button: Int)
	{
		if questions[currentQuestion].answers[answerIndexList[button]].original == questions[currentQuestion].correctAnswer.original
		{
			score += 1
		}
		if currentQuestion != questions.count - 1
		{
			currentQuestion += 1
			prepareQuestion()
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
		let answers: [germanObject]
		let correctAnswer: germanObject
	}
	
	@IBAction func button1(_ sender: Any) {
		answerClicked(button: 0)
	}
	@IBAction func button2(_ sender: Any) {
		answerClicked(button: 1)
	}
	@IBAction func button3(_ sender: Any) {
		answerClicked(button: 2)
	}
	@IBAction func button4(_ sender: Any) {
		answerClicked(button: 3)
	}
		
	@IBAction func nextButton(_ sender: Any) {
	}
	
	func getRandomElement(list: [germanObject], excluding: [germanObject]) -> germanObject
	{
		var randomIndex = Int.random(in: 0...list.count-1)
		while checkElementContained(list: excluding, element: list[randomIndex]) == true
		{ randomIndex = Int.random(in: 0...list.count-1) }
		return list[randomIndex]
	}
	func checkElementContained(list: [germanObject], element: germanObject) -> Bool
	{
		for item in list
		{
			if item.original == element.original
			{ return true }
		}
		return false
	}
}
