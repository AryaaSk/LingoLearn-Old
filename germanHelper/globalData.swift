//
//  globalData.swift
//  germanHelper
//
//  Created by Aryaa Saravanakumar on 06/12/2021.
//

import Foundation

struct germanObject: Codable
{
	let original: String
	let translation: String
	let german_sentence: String
	let english_translation: String
}
struct germanList: Codable {
	let name: String
	var words: [germanObject]
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

func decodeToGermanLists(jsonString: String) -> [germanList]
{
	let decoder = JSONDecoder()
	do
	{
		let returnData = try decoder.decode([germanList].self, from: jsonString.data(using: .utf8)!)
		return returnData
	}
	catch
	{
		return [germanList(name: "List 1", words: [])] //so there is always at least one list so the app doesn't crash
	}
}
func decodeToGermanWords(jsonString: String) -> [germanObject]
{
	let decoder = JSONDecoder()
	do
	{
		let returnData = try decoder.decode([germanObject].self, from: jsonString.data(using: .utf8)!)
		return returnData
	}
	catch
	{
		return []
	}
	
}

var germanWords: [germanObject] = decodeToGermanWords(jsonString: UserDefaults.standard.string(forKey: "germanWords") ?? "")
var germanLists: [germanList] = decodeToGermanLists(jsonString: UserDefaults.standard.string(forKey: "germanLists") ?? "")
var currentList: Int = 0


