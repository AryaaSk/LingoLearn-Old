//
//  globalData.swift
//  germanHelper
//
//  Created by Aryaa Saravanakumar on 06/12/2021.
//

import Foundation

enum language
{
    case german
}

struct languageObject: Codable
{
	var original: String
	let translation: String
	let sentence: String
	let sentence_translation: String
    let word_type: String
    let gender: String
    
    private enum CodingKeys : String, CodingKey {
        case original, translation, sentence = "german_sentence", sentence_translation = "english_translation", word_type, gender
    }
}
struct languageList: Codable {
	var name: String
	var words: [languageObject]
}

func addArticle(object: languageObject) -> String
{
    var original = object.original
    //return the original but with an article if its a noun, I can just display this instead of the raw original
    if object.word_type == "Noun"
    {
        //we know its a noun so we can just add the article
        //add der, die or das
        if object.gender == "Masculine"
        { original = "der " + original }
        if object.gender == "Feminine"
        { original = "die " + original }
        if object.gender == "Neuter"
        { original = "das " + original }
    }
    
    return original
}
func checkWords()
{
    //checks all lists for ... as those are just loading indicators
    var a = 0
    while a != germanLists.count
    {
        //loop through and remove items with original == ...
        var i = 0
        while i != germanLists[a].words.count
        {
            if germanLists[a].words[i].original == "..."
            { germanLists[a].words.remove(at: i) }
            else
            { i += 1 }
        }
        a += 1
    }
}

extension JSONEncoder {
	static func encode<T: Encodable>(from data: T) -> String? {
		do {
			let jsonEncoder = JSONEncoder()
			jsonEncoder.outputFormatting = .prettyPrinted
			let json = try jsonEncoder.encode(data)
			let jsonString = String(data: json, encoding: .utf8)
			
			return jsonString
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}
}


func saveToKey(data: String, key: String)
{
	UserDefaults.standard.set(data, forKey: key) //setObject
}

func decodeToGermanLists(jsonString: String) -> [languageList]
{
	let decoder = JSONDecoder()
	do
	{
		let returnData = try decoder.decode([languageList].self, from: jsonString.data(using: .utf8)!)
		return returnData
	}
	catch
	{
		return [languageList(name: "New List", words: [])] //so there is always at least one list so the app doesn't crash
	}
}
func decodeToGermanWords(jsonString: String) -> [languageObject]
{
	let decoder = JSONDecoder()
	do
	{
		let returnData = try decoder.decode([languageObject].self, from: jsonString.data(using: .utf8)!)
		return returnData
	}
	catch
	{
		return []
	}
	
}

var germanWords: [languageObject] = decodeToGermanWords(jsonString: UserDefaults.standard.string(forKey: "germanWords") ?? "")
var germanLists: [languageList] = decodeToGermanLists(jsonString: UserDefaults.standard.string(forKey: "germanLists") ?? "")
var currentList: Int = Int(UserDefaults.standard.string(forKey: "currentList") ?? "0")!

extension StringProtocol {
    subscript(_ offset: Int)                     -> Element     { self[index(startIndex, offsetBy: offset)] }
    subscript(_ range: Range<Int>)               -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    subscript(_ range: ClosedRange<Int>)         -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
    subscript(_ range: PartialRangeUpTo<Int>)    -> SubSequence { prefix(range.upperBound) }
    subscript(_ range: PartialRangeFrom<Int>)    -> SubSequence { suffix(Swift.max(0, count-range.lowerBound)) }
}
extension LosslessStringConvertible {
    var string: String { .init(self) }
}
extension BidirectionalCollection {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
        return self[i]
    }
}


