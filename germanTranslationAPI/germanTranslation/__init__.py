import logging
from sre_parse import CATEGORIES
import requests
import json

import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    #header should be in format word1_word2_word3 (couldnt parse json)

    wordListString = req.params.get('wordList')
    wordList = wordListString.split("_")

    words = "{ \"words\" : [" #format of return
    #Changed the translation website to https://www.linguee.de/deutsch-englisch/uebersetzung/Brot.html, has better example sentences

    for item in wordList:
        translation = getWord(item) #just add the word with the function
        words = words + translation

    if words[len(words) - 1] != "[": #just closing the bracket in the return json
        words = words[:-1]
    words = words + "]}"

    return words


def getWord(word):
    #using this api: https://linguee-api-v2.herokuapp.com/docs
    #https://linguee-api-v2.herokuapp.com/api/v2/translations?query=[GERMAN_WORD]&src=de&dst=en&guess_direction=true
    url = "https://linguee-api-v2.herokuapp.com/api/v2/translations?query=" + word + "&src=de&dst=en&guess_direction=true"
    r = requests.get(url)
    text = r.text
    response = json.loads(text)

    #decode this text to get the original, translation, german example sentence, english translation. word type and gender
    try:
        logging.info("valid response")
        original = str(response[0]['text'])
    except:
        logging.info("invalid response")
        return "" #we test the response call, if it doesnt even contain the original then we know its an invalid response and just return blank so it doesnt affect the returnJSON

    
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
    gender = "" #gender is only available in nouns
    try:
        gender = wordInfo[1]
    except:
        gender = ""

    #finally we capitalise everything
    original = original.capitalize()
    translation = translation.capitalize()
    germanSentence = germanSentence.capitalize()
    englishSentence = englishSentence.capitalize()
    wordType = wordType.capitalize()
    gender = gender.capitalize()
    
    return "{\"original\" : \"" + original + "\", \"translation\" : \"" + translation +"\", \"german_sentence\" : \"" +  germanSentence + "\", \"english_translation\": \"" + englishSentence + "\", \"word_type\": \"" + wordType + "\", \"gender\": \"" + gender + "\"},"