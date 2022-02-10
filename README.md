# German Helper

## An App which lets you add german words and converts them to english, gives you example sentences in both languages and tests you

<ins>API Documentation</ins>

There are 2 APIs, the main one which is called by the app, and then a scrapper API.
The main API uses a 3rd Party Linguee API: https://github.com/imankulov/linguee-api, this is a bit unreliable as if you use it too quickly, it will start returning Error Code 503, which means the server was not able to process the request.

The scrapper API goes to the webpage: https://www.linguee.de/deutsch-englisch/uebersetzung/[GermanWord].html, and gets the data directly from the website. This is only to be used as a last resort as if you use it too much Linguee will block the Azure Function's IP Address and you have to manually restart the function app.

After either of the 2 APIs has got the data, it uploads the data to a Firebase Realtime Database, in this format: [LowercaseGermanWord] : [GermanWordDataJSON], to the path data/GermanEnglish. This is useful as it allows the API to build up its own dictionary, so in the case of both APIs failing you can use the database.

When you call a word, the API first checks if the word already exists in firebase, if not then it calls the Linguee API, and if that doesn't work then it will use the scrapping API

<ins>App Documentation</ins>

Here is a preview of the App:

![Preview Image](https://github.com/AryaaSk/germanHelper/blob/main/5.5%20Photos/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202022-02-02%20at%2017.31.35.png)
