import logging
import pyrebase
import requests
import json

import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    #header should be in format word1_word2_word3 (couldnt parse json)
    #here is github page for API: https://github.com/imankulov/linguee-api
    #here is the documentation for the API: https://linguee-api-v2.herokuapp.com/docs#/default/translations_api_v2_translations_get

    language = req.params.get('language')
    if language == None:
        language = "German" #always keep it capital
    language = language.capitalize()

    wordListString = req.params.get('wordList')
    wordList = wordListString.split("_")

    words = "{ \"words\" : [" #format of return

    for item in wordList:
        translation = ""

        translation = getFromFirebase(item, language) #first it checks firebase, then the API and finally it scraps it from the website if nothing else works

        if translation == "":
            translation = getWord(item, language)

        if translation == "":
            translation = callScrapperAPI(item, language)

        words = words + translation

    if words[len(words) - 1] != "[": #just closing the bracket in the return json
        words = words[:-1]
    words = words + "]}"

    return words

def getFromFirebase(word, language):
    app_name = "germanhelper-1804c"
    config = {
        "apiKey": "apiKey",
        "authDomain": app_name + ".firebaseapp.com",
        "databaseURL": "https://" + app_name + "-default-rtdb.europe-west1.firebasedatabase.app/",
        "storageBucket": app_name + ".appspot.com"
    }
    firebase = pyrebase.initialize_app(config)
    db = firebase.database()

    word = word.lower() #the api always saves the keys (originals) as lowercase
    
    data = db.child("data/" + language + "English/" + word).get() #this is how you get the data, it works with special characters as well
    if data.pyres == None:
        return ""
    return str(data.pyres) + "," #directly adding back the comma so i dont have to add it later on



def getWord(word, language):
    #using this api: https://linguee-api-v2.herokuapp.com/docs
    #https://linguee-api-v2.herokuapp.com/api/v2/translations?query=[GERMAN_WORD]&src=de&dst=en&guess_direction=true
    #need to convert the language to the language query
    languageQuery = ""
    if language == "German":
        languageQuery = "de"
    elif language == "French":
        languageQuery = "fr"
    elif language == "Spanish":
        languageQuery = "es"

    url = "https://linguee-api-v2.herokuapp.com/api/v2/translations?query=" + word + "&src=" + languageQuery+ "&dst=en&guess_direction=true"
    r = requests.get(url)
    text = r.text
    if text == "Internal Server Error":
        return "" #this means the user entered a word which doesnt exist in the APIs dictionary

    response = json.loads(text)
    #decode this text to get the original, translation, german example sentence, english translation. word type and gender
    try:
        original = str(response[0]['text'])
    except:
        #we test the response call, if it doesnt even contain the original then we know its an invalid response
        #we can try and call the scrapping api (germanTranslatorAPIScrapper), since that gets the data directly from the website
        return ""
    
    translation = str(response[0]['translations'][0]['text'])

    #the sentences could not exist, so we make them blank if the api is unable to get them
    germanSentence = ""
    englishSentence = ""
    try:
        germanSentence = str(response[0]['translations'][0]['examples'][0]['src'])
        englishSentence = str(response[0]['translations'][0]['examples'][0]['dst'])
    except:
        germanSentence = ""
        englishSentence = ""

    #and finally we need the word type and gender
    wordInfo = str(response[0]['pos']).split()
    wordType = wordInfo[0]
    gender = "None" #gender is only available in nouns
    try:
        gender = wordInfo[1]
        #if there is a gender that means there will be a comma after the "noun" in wordType, so we need to remove that
        wordType = wordType[:-1]
    except:
        gender = "None"
    
    #sometimes the API returns 2 wordTypes such as adjective / past participle, this causes the gender to become "/", so lets fix that
    if gender == "/":
        gender = "None"

    #finally we capitalise everything
    original = original.capitalize()
    translation = translation.capitalize()
    germanSentence = germanSentence.capitalize()
    englishSentence = englishSentence.capitalize()
    wordType = wordType.capitalize()
    gender = gender.capitalize()
    
    data = "{\"original\" : \"" + original + "\", \"translation\" : \"" + translation +"\", \"german_sentence\" : \"" +  germanSentence + "\", \"english_translation\": \"" + englishSentence + "\", \"word_type\": \"" + wordType + "\", \"gender\": \"" + gender + "\"},"
    saveToFirebase(data[:-1], language, original.lower())
    return data


def callScrapperAPI(word, language):
    scrappingURL = "https://aryaagermantranslatorapiscrapper.azurewebsites.net/api/germantranslation?wordList=" + word + "&language=" + language
    r = requests.get(scrappingURL)
    response = json.loads(r.text) #parse this data

    #now check if the words directory contains anything
    if len(response['words']) != 0:
        #we know that there is something, so just parse the data and return that
        words = response['words']

        original = words[0]['original']
        translation = words[0]['translation']
        germanSentence = words[0]['german_sentence']
        englishSentence = words[0]['english_translation']
        wordType = words[0]['word_type']
        gender = words[0]['gender']

        data = "{\"original\" : \"" + original + "\", \"translation\" : \"" + translation +"\", \"german_sentence\" : \"" +  germanSentence + "\", \"english_translation\": \"" + englishSentence + "\", \"word_type\": \"" + wordType + "\", \"gender\": \"" + gender + "\"},"
        saveToFirebase(data[:-1], language, original.lower())
        return data
        
    else:
        return "" # and just return blank so it doesnt affect the returnJSON

def saveToFirebase(data, language, word):
    app_name = "germanhelper-1804c"
    config = {
        "apiKey": "apiKey",
        "authDomain": app_name + ".firebaseapp.com",
        "databaseURL": "https://" + app_name + "-default-rtdb.europe-west1.firebasedatabase.app/",
        "storageBucket": app_name + ".appspot.com"
    }

    firebase = pyrebase.initialize_app(config)
    db = firebase.database()
    db.child("data/" + language + "English/" + word).set(data)

#testing github from vscode