import logging
from bs4 import BeautifulSoup
import requests

import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    #THIS API IS SPECIFICALLY FOR TRANSLATING WORDS WITH SYMBOLS IN THEM, SUCH AS Äpfel (umlout)

    #header should be in format "word1"_"word2"_"word3" (couldnt parse json)

    wordListString = req.params.get('wordList')
    wordList = wordListString.split("_")

    words = "{ \"words\" : [" #format of return
    #Changed the translation website to https://www.linguee.de/deutsch-englisch/uebersetzung/Brot.html, has better example sentences

    for item in wordList:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0', 'Content-type': 'text/plain; charset=utf-8'}
        url = "https://www.linguee.de/deutsch-englisch/uebersetzung/"
        #can also use https://www.linguee.com

        r = requests.get(url+item+".html", headers=headers)
        soup = BeautifulSoup(r.content, "html.parser")

        item = item[0].upper() + item[1: len(item)]

        #GETTING THE TRANSLATION
        text = str(soup.find(class_="dictLink featured"))
        
        #check if text is none, if it is then it means a wrongly spelt word was given
        if text != "None":
            mainWord = getMainContent(text)
            #Now capitalise the first letter
            mainWord = mainWord[0].upper() + mainWord[1: len(mainWord)]

            #GETTING THE WORD TYPE
            text = str(soup.find(class_="tag_wordtype"))
            wordTypeList = getMainContent(text).split(",")
            
            if wordTypeList != ['']:
                wordType = wordTypeList[0].lower()
                if wordType == "substantiv": #adding the word types
                    wordType = "noun"
                elif wordType == "pronomen":
                    wordType = "pronoun"
                elif wordType == "verb":
                    wordType = "verb"

                wordType = wordType[0].upper() + wordType[1: len(wordType)] #capitalisation

                gender = "None"
                if len(wordTypeList) > 1:
                    gender = wordTypeList[1][1:].lower()
                    if gender == "maskulin":
                        gender = "masculine"
                    elif gender == "feminin":
                        gender = "feminine"
                    elif gender == "neutrum":
                        gender = "neuter"
                    elif gender == "plural":
                        gender = "plural"
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
    
    """
    #OLD CODE:

    word = req.params.get('word')
    #Changed the translation website to https://www.linguee.de/deutsch-englisch/uebersetzung/Brot.html, has better example sentences

    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0', 'Content-type': 'text/plain; charset=utf-8'}
    url = "https://www.linguee.de/deutsch-englisch/uebersetzung/"
    r = requests.get(url+word+".html", headers=headers)
    soup = BeautifulSoup(r.content, "html.parser")

    #GETTING THE TRANSLATION
    text = str(soup.find(class_="dictLink featured"))

    mainWord = getMainContent(text)
    #Now capitalise the first letter
    mainWord = mainWord[0].upper() + mainWord[1: len(mainWord)]

    #GETTING THE WORD TYPE
    text = str(soup.find(class_="tag_wordtype"))
    wordTypeList = getMainContent(text).split(",")
    
    wordType = wordTypeList[0].lower()
    if wordType == "substantiv": #adding the word types
        wordType = "noun"
    elif wordType == "pronomen":
        wordType = "pronoun"
    elif wordType == "verb":
        wordType = "verb"
    wordType = wordType[0].upper() + wordType[1: len(wordType)] #capitalisation

    gender = "None"
    if len(wordTypeList) > 1:
        gender = wordTypeList[1][1:].lower()
        if gender == "maskulin":
            gender = "masculine"
        elif gender == "feminin":
            gender = "feminine"
        elif gender == "neutrum":
            gender = "neuter"
        elif gender == "plural":
            gender = "plural"
        gender = gender[0].upper() + gender[1: len(gender)] #capitalisation

    #GETTING EXAMPLE SENTENCE
    exampleLine = str(soup.find(class_="example line"))
    exampleLineSoup = BeautifulSoup(exampleLine, "html.parser")

    germanSentence = getMainContent(str(exampleLineSoup.find(class_="tag_s")))
    englishSentence = getMainContent(str(exampleLineSoup.find(class_="tag_t")))

    return str({"original" : word, "translation" : mainWord, "german_sentence" : germanSentence, "english_translation": englishSentence, "word_type": wordType, "gender": gender})
    """


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
