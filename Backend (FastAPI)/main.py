from typing import List
from fastapi import FastAPI
from VisionAPI_Demo import *
from CloudFireStoreApi import *
from pydantic import BaseModel
import base64, binascii
import requests

app = FastAPI()

temp = ['1.jpeg', 'tylenol', ['เช้า', 'เย็น'], ['หลังอาหาร']]

class Img(BaseModel):
   uid: str    #นำ class BaseModel มาใส่ไว้ในวงเล็บ
   image : str
   createDate: str

class DrugResquest(BaseModel):
    typeOfAlarm: str
    uid: str
    drugName: str
    times: List[str]
    acts: List[str]
    createDate: str
    manualTimes: List[str]

class UserId(BaseModel):
    uid: str

class DrugId(BaseModel):
    drugId: str

class DrugName(BaseModel):
    drugName: str

class DrugIdAndLastDate(BaseModel):
    drugId: str
    lastDate: str

class UserSetting(BaseModel):
    uid: str
    morning: str
    noon: str
    evening: str
    sleep: str

class DrugIdAndManualTimes(BaseModel):
    drugId: str
    manualTimes: List[str]

class DrugIdAndTimes(BaseModel):
    drugId: str
    times: List[str]

class History(BaseModel):
    uid: str

@app.post("/addDrugByScan")
async def addDrugByScan(picture: Img):
    # print(picture.image)

    base64_string = picture.image

    try:
        image = base64.b64decode(base64_string, validate=True)
        file_to_save = "./images/my_image.png"
        dummyTest = "./images/7.jpeg"
        with open(file_to_save, "wb") as f:
            f.write(image)
        
        drug = detectText(file_to_save)
        # drug = detectText(dummyTest)
        print(drug)
        # print(text.to_markdown())
        if(len(drug)>0):
            addNewDrug(picture.uid, drug[0], drug[1], drug[2])
    except binascii.Error as e:
        print(e)
        return {"message": "Error!", "error": e}
    return {"message": "Success!"}

@app.post("/getTextToPreview")
async def getTextToPreview(picture: Img):
    base64_string = picture.image

    try:
        image = base64.b64decode(base64_string, validate=True)
        file_to_save = "./images/my_image.png"
        dummyTest = "./images/7.jpeg"
        with open(file_to_save, "wb") as f:
            f.write(image)
        
        drug = detectText(file_to_save)
        # drug = detectText(dummyTest)
        for i in drug[2]:
            if i == 'beforeSleep':
                if i not in drug[1]:
                    drug[1].append('sleep')
        print(drug)
        # print(text.to_markdown())
        if(len(drug)>0):
            # addNewDrug(picture.uid, drug[0], drug[1], drug[2])
            response = {
                'typeOfAlarm': 'routine',
                'drugId': '',
                'uid': picture.uid,
                'drugName': drug[0],
                'times': drug[1],
                'acts': drug[2],
                'createDate': picture.createDate,
                'manualTimes': []
            }
        else:
            response = {
                'typeOfAlarm': 'routine',
                'drugId': '',
                'uid': "",
                'drugName': "",
                'times': [],
                'acts': [],
                'createDate': "",
                'manualTimes': []
            }
    except binascii.Error as e:
        print(e)
        return {"message": "Error!", "error": e}
    print(response)
    return response

@app.post("/addDrugByManual")
async def addDrugByManual(request: DrugResquest):
    addNewDrug(request.typeOfAlarm, request.uid, request.drugName, request.times, request.acts, request.createDate, request.manualTimes)

@app.post("/getDrugById")
async def findDrugById(userId: UserId):
    return getDrugById(userId.uid)

@app.post("/addNewUser")
async def addNewUserById(userId: UserId):
    addNewUser(userId.uid)

@app.post("/updateUserSettingById")
async def updateUserSettingById(user: UserSetting):
    updateUserSetting(user.uid, user.morning, user.noon, user.evening, user.sleep)

@app.post("/getUserSetting")
async def findUserSetting(userId: UserId):
    return getUserSettingById(userId.uid)

@app.post("/deleteDrugById")
async def deleteDrug(drugId: DrugIdAndLastDate):
    return deleteDrugById(drugId.drugId, drugId.lastDate)

@app.post("/updateManualTimes")
async def updatemanualTime(drug: DrugIdAndManualTimes):
    return updateManualTimes(drug.drugId, drug.manualTimes)

@app.post("/updateTimes")
async def updateTime(drug: DrugIdAndTimes):
    return updateTimes(drug.drugId, drug.times)

@app.post("/getHistory")
async def getHistory(hist: History):
    return getHistoryById(hist.uid)

@app.post("/searchDrugFda")
async def searchDrug(drug: DrugName):
    url = "https://api.fda.gov/drug/label.json?search=openfda.brand_name:\""+ drug.drugName +"\"&limit=5"

    # A GET request to the API
    response = requests.get(url)
    result = []

    # Print the response
    if response.status_code == 200:
        response_json = response.json()
        temp = response_json['results']
        for r in temp:
            data = {
                'status': 'found',
                'brand_name': r['openfda']['brand_name'][0],
                'generic_name': r['openfda']['generic_name'][0],
                'indications_and_usage': r['indications_and_usage'][0]
            }
            print(data)
            result.append(data)
        return result
    else:
        return [{
            'status': 'notFound',
            'brand_name': "",
            'generic_name': "",
            'indications_and_usage': ""
        }]

