import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from google.cloud.firestore_v1.base_query import FieldFilter
from operator import itemgetter

cred = credentials.Certificate(r'/Users/v1em/Desktop/TermProject/VisionAPIDemo/drug-application-390fe-firebase-adminsdk-bggzt-d88f7b7596.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

# data = {
#     'drugName': 'Covid19',
#     'times': '9:00'
# }

# doc_ref = db.collection('Drug').document("test")
# doc_ref.set(data)

# print('Document ID: ', doc_ref.id)

# docs = (
#     db.collection("Drug")
#     .where(filter=FieldFilter("drugName", "==", "Covid"))
#     .stream()
# )

# for doc in docs:
#     print(f"{doc.id} => {doc.to_dict()}")
#     db.collection("Drug").document(doc.id).delete()
def getUserById(uid):
    # print(uid)
    docs = (
        db.collection("Users")
        .where(filter=FieldFilter("uid", "==", uid))
        .stream()
    )
    response = []
    for doc in docs:
        user = doc.to_dict()
        data={
            'uid': uid,
            'morning': user['morning'],
            'noon': user['noon'],
            'evening': user['evening'],
            'sleep': user['sleep']
        }
        response.append(data)
    # print(response)
    return response

def addNewUser(uid):
    data = {
        'uid': uid,
        'morning': '07:00:00',
        'noon': '12:00:00',
        'evening': '17:00:00',
        'sleep': '21:00:00'
    }
    doc_ref = db.collection('Users').document()
    doc_ref.set(data)

def updateUserSetting(uid, morning, noon, evening, sleep):
    # print(uid)
    updateField = {
        'morning': morning,
        'noon': noon,
        'evening': evening,
        'sleep': sleep
    }
    collection_ref = db.collection('Users') # col_ref is CollectionReference
    docs = collection_ref.where('uid', '==', uid).get()
    for doc in docs:
        # print(doc.id)
        user = collection_ref.document(doc.id)
        user.update(updateField)

def addNewDrug(typeOfAlarm, uid, drugName, times, acts, createDate, manualTimes):
    if(typeOfAlarm == 'manual'):
        if(len(uid) > 0 and len(drugName) > 0 and len(createDate) > 0 and len(manualTimes) > 0):
            data = {
                'typeOfAlarm': typeOfAlarm,
                'uid': uid,
                'drugName': drugName,
                'times': times,
                'acts': acts,
                'createDate': createDate,
                'manualTimes': manualTimes
            }
            doc_ref = db.collection('Drug').document()
            doc_ref.set(data)
    else:
        if(len(uid) > 0 and len(drugName) > 0 and len(times) > 0 and len(createDate) > 0):
            data = {
                'typeOfAlarm': typeOfAlarm,
                'uid': uid,
                'drugName': drugName,
                'times': times,
                'acts': acts,
                'createDate': createDate,
                'manualTimes': [""]
            }
            doc_ref = db.collection('Drug').document()
            doc_ref.set(data)

        
        

def getDrugById(uid):
    # print(uid)
    docs = (
        db.collection("Drug")
        .where(filter=FieldFilter("uid", "==", uid))
        .stream()
    )
    response = []
    for doc in docs:
        drug = doc.to_dict()
        # print(drug)
        data={
            'typeOfAlarm': drug["typeOfAlarm"],
            'drugId': doc.id,
            'uid': drug["uid"],
            'drugName': drug["drugName"],
            'times': drug["times"],
            'acts': drug["acts"],
            'createDate': drug["createDate"],
            'manualTimes': drug["manualTimes"]
        }
        response.append(data)
    
    sortResponseByCreateDate = sorted(response, key=itemgetter('createDate'), reverse=True) 
    # print(response)
    # print(sortResponseByCreateDate)
    return sortResponseByCreateDate

def getUserSettingById(uid):
    collection_ref = db.collection('Users') # col_ref is CollectionReference
    docs = collection_ref.where('uid', '==', uid).get()
    response = []
    for doc in docs:
        # print(doc)
        doc = doc.to_dict()
        user = {
            'uid': doc['uid'],
            'morning': doc['morning'],
            'noon': doc['noon'],
            'evening': doc['evening'],
            'sleep': doc['sleep']
        }
        response.append(user)
    # print(response)
    return response[0]

def deleteDrugById(drugId, lastDate):
    print("DrugID for delete: ", drugId)
    collection_ref = db.collection('Drug')
    drug = collection_ref.document(drugId).get()
    doc_dict = drug.to_dict()
    data = {
        # 'typeOfAlarm': doc_dict["typeOfAlarm"],
        # 'drugId': doc_dict.id,
        'uid': doc_dict["uid"],
        'drugName': doc_dict["drugName"],
        'lastDate': lastDate
        # 'times': doc_dict["times"],
        # 'acts': doc_dict["acts"],
        # 'createDate': doc_dict["createDate"],
        # 'manualTimes': doc_dict["manualTimes"]
    }
    history_ref = db.collection('History').document()
    history_ref.set(data)
    db.collection("Drug").document(drugId).delete()

def updateManualTimes(drugId, manualTimes):
    print(drugId, manualTimes)
    updateField = {
        'manualTimes': manualTimes
    }
    collection_ref = db.collection('Drug') # col_ref is CollectionReference
    drug = collection_ref.document(drugId)
    drug.update(updateField)
    # docs = collection_ref.where('drugId', '==', drugId).get()
    # for doc in docs:
    #     print(doc.id)
    #     drug = collection_ref.document(doc.id)
    #     drug.update(updateField)

def updateTimes(drugId, times):
    print("-------------------UpdateTimes: ", drugId, times)
    if(len(times) > 0):
        updateField = {
            'times': times
        }
        collection_ref = db.collection('Drug') # col_ref is CollectionReference
        drug = collection_ref.document(drugId)
        drug.update(updateField)
    # docs = collection_ref.where('drugId', '==', drugId).get()
    # for doc in docs:
    #     print(doc.id)
    #     drug = collection_ref.document(doc.id)
    #     drug.update(updateField)

def getHistoryById(uid):
    # print(uid)
    docs = (
        db.collection("History")
        .where(filter=FieldFilter("uid", "==", uid))
        .stream()
    )
    response = []
    for doc in docs:
        hist = doc.to_dict()
        data={
            'uid': uid,
            'drugName': hist['drugName'],
            'lastDate': hist['lastDate']
        }
        response.append(data)
    print(response)
    return response

