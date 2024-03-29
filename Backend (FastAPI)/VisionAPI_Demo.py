import os, io
from google.cloud import vision_v1
# from google.cloud.vision_v1 import types
import pandas as pd
from IPython.display import display
from fastapi import FastAPI
from googletrans import Translator
import requests
import json

api_url = "https://opend.data.go.th/get-ckan/datastore_search"

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = r'vision-ai-api-407210-672d4f1d6de2.json'

client = vision_v1.ImageAnnotatorClient()

detector = Translator()
listOfAction = ["อาหาร", "นอน"]
listOfTimes = ["เช้า", "กลางวัน", "เย็น", "ก่อนนอน"]
listOfWhenToAct = ["ก่อน", "หลัง"]
dictOf = {"เช้า": "morning", "กลางวัน": "noon", "เย็น": "evening", "ก่อนนอน": "beforeSleep", "ก่อนอาหาร": "beforeMeal", "หลังอาหาร": "afterMeal"}
eatTimes = []
drugName = ""

def detectText(imgPath):
    with io.open(imgPath, 'rb') as image_file:
        content = image_file.read()

    image = vision_v1.Image(content=content)
    response = client.text_detection(image=image)
    texts = response.text_annotations
    if(len(texts) > 0):
        listOfText = texts[0].description.split("\n")
        eatTimes = []
        acts = []
        temp = ""
        drugName = ""
        for text in texts:
            word = text.description
            # print(word)
            if word in listOfWhenToAct:
                temp = word
            if word in listOfAction:
                if temp in listOfWhenToAct:
                    temp = temp + word;
                    if dictOf[temp] == 'beforesleep' and dictOf[temp] not in eatTimes:
                        eatTimes.append(dictOf[temp])
                    if dictOf[temp] not in acts:
                        acts.append(dictOf[temp])
                    temp = ""
            if word in listOfTimes:
                if dictOf[word] not in eatTimes:
                    eatTimes.append(dictOf[word])
            if word.isalpha() & (word.lower() != 'mg'):
                todo = {}
                headers =  {"api-key":"7cLVFLBMsauxWGFn9jJ7cGsSIKjAIW4w"}
                query = "?q=" + word + "&resource_id=caa41e90-aa41-41c0-9316-2b73a1f45cec"
                response = requests.post(api_url + query, data=json.dumps(todo), headers=headers)
                # print(word, "response: ", response.json())
                for drug in response.json()["result"]["records"]:
                    # print(word, "TradeName: ", drug["TradeName"], " ", drug["ActiveIngredient"])
                    tradeName = drug["TradeName"].lower()
                    activeIngredient = drug["ActiveIngredient"].lower()
                    if " " in tradeName:
                        tradeName = tradeName.split(" ")[0]
                    if " " in activeIngredient:
                        activeIngredient = activeIngredient.split(" ")[0]
                    if (word.lower() == tradeName) or (word.lower() == activeIngredient):
                        if drugName == "":
                            drugName = word.upper()

        # print(eatTimes, drugName)
        result = [drugName, eatTimes, acts]
        return result
    else:
        return []
    # df = pd.DataFrame(columns=['locale', 'description'])
    # # df = pd.DataFrame(columns=['description'])
    # count = 0
    # for text in texts:
    #     # print("text ", count, " = ", text.description)
    #     count += 1
    #     df = pd.concat([df, pd.DataFrame.from_records([{'locale': text.locale, 'description': text.description }])])
    #     # df_new_row = pd.DataFrame({ 'locale': text.locale, 'description': text.description })
    #     # df = pd.concat([df, df_new_row])
    #     # df = df.append(
    #     #     dict(
    #     #     locale=text.locale,
    #     #     description=text.description
    #     #     ),
    #     #     ignore_index=True
    #     # )
    # return df

# FILE_NAME = '6.jpeg'
# listOfImages = ['1.jpeg', '2.jpeg', '3.jpeg', '4.jpeg', '5.jpeg', '6.jpeg', '7.jpeg', '8.jpeg', '9.jpeg', '10.jpeg', '11.jpeg', '12.jpeg']
# FOLDER_PATH = r'/Users/v1em/Desktop/TermProject/VisionAPIDemo/images'
# list_of_dict = detectText(os.path.join(FOLDER_PATH,FILE_NAME))
# print(list_of_dict)
# response = []
# for image in listOfImages:
#     print(image)
#     response.append(detectText(os.path.join(FOLDER_PATH,image)))
# for r in response:
#     print(r[0],r[1], ": ", r[2], " ", r[3])
# drug = detectText(os.path.join(FOLDER_PATH,"7.jpeg"))
# print(drug)

