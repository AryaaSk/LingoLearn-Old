import logging
from bs4 import BeautifulSoup
import requests

import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    #THIS API IS SPECIFICALLY FOR WHEN THE MAIN API FAILS AND THIS NEEDS TO GET THE WORDS DIRECTLY FROM THE WEBSITE
    #IF YOU USE THIS TOO MUCH IT CAN CAUSE THE AZURE FUNCTION'S IP ADDRESS TO BE BLOCKED AND BREAK THIS

    #testing git

    #header should be in format "word1"_"word2"_"word3" (couldnt parse json)

    language = req.params.get('language')
    if language == None:
        language = "German" #always capitalised

    wordListString = req.params.get('wordList')
    wordList = wordListString.split("_")

    words = "{ \"words\" : [" #format of return
    #Changed the translation website to https://www.linguee.de/deutsch-englisch/uebersetzung/Brot.html, has better example sentences

    for item in wordList:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0', 'Content-type': 'text/plain; charset=utf-8'}
        url = "https://www.linguee.com/" + language.lower() + "-english/translation/"
        url = url+item+".html"
        #can also use https://www.linguee.de (but then will have to translate)

        r = requests.get(url, headers=headers)
        soup = BeautifulSoup(r.content, "html.parser")

        item = item.capitalize()

        #GETTING THE TRANSLATION
        text = str(soup.find(class_="dictLink featured"))

        #check if text is none, if it is then it means a wrongly spelt word was given
        if text != "None":
            mainWord = getMainContent(text)
            #Now capitalise the first letter
            mainWord = mainWord.capitalize()

            #GETTING THE WORD TYPE
            text = str(soup.find(class_="tag_wordtype"))
            wordTypeList = getMainContent(text).split(",")
            
            if wordTypeList != ['']:
                wordType = wordTypeList[0].lower()
                wordType = wordType.capitalize()

                gender = "None"
                if len(wordTypeList) > 1:
                    gender = wordTypeList[1][1:].lower()
                    gender = gender[0].upper() + gender[1: len(gender)] #capitalisation

                #GETTING EXAMPLE SENTENCE
                exampleLine = str(soup.find(class_="example line"))
                exampleLineSoup = BeautifulSoup(exampleLine, "html.parser")

                germanSentence = getMainContent(str(exampleLineSoup.find(class_="tag_s")))
                englishSentence = getMainContent(str(exampleLineSoup.find(class_="tag_t")))
                words = words + "{\"original\" : \"" + item + "\", \"translation\" : \"" + mainWord +"\", \"german_sentence\" : \"" +  germanSentence + "\", \"english_translation\": \"" + englishSentence + "\", \"word_type\": \"" + wordType + "\", \"gender\": \"" + gender + "\"},"

    if words[len(words) - 1] != "[":
        words = words[:-1]
    words = words + "]}"

    return words


def getMainContent(text):
    firstIndex = 0
    secondIndex = 0
    i = 0
    while i != len(text):
        if text[i] == ">":
            firstIndex = i
        if firstIndex != 0 and text[i] == "<":
            secondIndex = i
            break
        i += 1
    return text[firstIndex + 1: secondIndex]
