//
//  HKAnchoredQueryManager.swift
//  HKQueries
//
//  Created by paige on 2021/12/24.
//

/**
 `What has changed and long running query`
 The HKAnchoredObjectQuery provides a useful way to keep tabs `on what has changed` for a particular sample type. It provides us with both the ability to receive a snapshot of data, and then on subsequent calls, a snapshot of what has changed. Alternatively you can create the initial snapshot of samples, and then `continuously monitor as a long-running query` which notifies you each time a new sample is added or when a sample is deleted.
 **/

/**
 `Difference with HKSampleQuery`
 Much of what we have seen is very similar to the HKSampleQuery. There are just a few differences. One difference is that `you cannot sort`. The other difference is that you are notified of additions or deletions to the sample type.
 **/

/**
 `Pass a nil to anchor and new anchor will be provided`
 The HKAnchoredObjectQuery initialiser allows you to optionally pass in a HKQueryAnchor. If this is the first query your app is making, then you can just pass in nil here. This will request all data. When all data is retrieved, a new anchor is provided which is used automatically when the app is running, or alternatively, you can persist the anchor and use it for the next time you open the app.
 **/

// Return Type, Same as SampleType but you can provide anchor to know about `changes` made to your app.

import HealthKit

class HKAnchoredQueryManager {
    
    let healthStore = HKHealthStore()
    
    func requestPermission() {
        if HKHealthStore.isHealthDataAvailable() {
            let readDataTypes : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
            
            let writeDataTypes : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
            
            healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                    print("Error", error?.localizedDescription ?? "no error")
                } else {
                    //                    self.testAnchoredQuery()
                }
            }
        }
    }
    
    // You can also check deleted objects
    // We passed in nil for the anchor. This resulted in all bodyMass records being returned.
    func testAnchoredQuery() {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            fatalError("*** Unable to get the body mass type ***")
        }
        
        // Create the query.
        let query = HKAnchoredObjectQuery(type: bodyMassType,
                                          predicate: nil,
                                          anchor: nil,
                                          limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
                fatalError("*** An error occurred during the initial query: \(errorOrNil!.localizedDescription) ***")
            }
            
            for bodyMassSample in samples {
                print("Samples: \(bodyMassSample)")
                // One element from samples
                /*
                 60 count/min 6A44E2C4-36A2-4A26-B171-14F558F5E7F9 "신승현’s Apple Watch" (8.1), "Watch5,2" (8.1) "Apple Watch" metadata: {
                 HKMetadataKeyHeartRateMotionContext = 0;
                 } (2021-12-08 19:49:02 +0900 - 2021-12-08 19:49:02 +0900)
                 */
            }
            
            // returns 1185
            print("total sample: \(samples.count)")
            
            for deletedBodyMassSample in deletedObjects {
                print("deleted: \(deletedBodyMassSample)")
            }
            
            // returns 0
            print("total deleted sample: \(deletedObjects.count)")
            
        }
        healthStore.execute(query)
    }
    
    
    // We will first look at how to keep a copy of HKQueryAnchor,
    // and then look at how we can make edits and then reinitialise HKAnchoredObjectQuery to get just a list of changes.
    /*
     If you run the app now you will see a log of every single bodyMass that has been recorded on your device. When completed you can stop the app and visit the health app. Add in a few new weight entries. Run the app again, and in the logs you will see just the changes that you made. If you stop the app, and go and delete some or all of those entries that you just created, then when starting the app again, you will be notified of the specific objects that were deleted.
     */
    /*
     When you persist the anchor you can then rerun the query with that anchor and receive just the information that has been added or deleted. When that happens, the new anchor will be updated again, and each time you load the app you will only be presented with changes that have been made between the last anchor and now.
     */
    func mostRecentAnchoredQueryQuery() {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            fatalError("*** Unable to get the body mass type ***")
        }
        
        var anchor = HKQueryAnchor.init(fromValue: 0)
        
        // The anchor does not naturally persist, so unless you persist it between app loads, you will need to start the query from the beginning each time the app loads.
        ///where we check if we already have an anchor saved. If we do, we need first extract the data and store it as Data. We then unarchive that data with NSKeyedUnarchiver. We need to go this route because we cannot store a HKQueryAnchor in UserDefaults as it is. Instead, we need to convert to data and archive that data, and then unarchive it when needed.
        if UserDefaults.standard.object(forKey: "Anchor") != nil {
            let data = UserDefaults.standard.object(forKey: "Anchor") as! Data
            anchor = NSKeyedUnarchiver.unarchiveObject(with: data) as! HKQueryAnchor
        }
        
        ///We next create the HKAnchoredObjectQuery, but instead of setting the anchor to nil, we pass in our newly created anchor which will either be initialised with a 0, or be initialised later on in the code.
        let query = HKAnchoredObjectQuery(type: bodyMassType,
                                          predicate: nil,
                                          anchor: anchor,
                                          limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
                fatalError("*** An error occurred during the initial query: \(errorOrNil!.localizedDescription) ***")
            }
            
            ///This is where we work more with the anchor. Here we assign the new anchor to anchor. This means that the next time the query runs it ignores everything except changes that have happened since the anchor was created.
            ///These are where we archive the newAnchor to Data, and then save that in UserDefaults. This is where the anchor is persisted.
            anchor = newAnchor!
            let data : Data = NSKeyedArchiver.archivedData(withRootObject: newAnchor as Any)
            UserDefaults.standard.set(data, forKey: "Anchor")
            
            for bodyMassSample in samples {
                print("Samples: \(bodyMassSample)")
            }
            
            for deletedBodyMassSample in deletedObjects {
                print("deleted: \(deletedBodyMassSample)")
            }
            
            print("Anchor: \(anchor)")
        }
        healthStore.execute(query)
    }
    
    /*
     I mentioned earlier that HKAnchoredObjectQuery also has the ability to be long-running. What this means is that you can make a query just once, and then each time a change is made in Health to body Mass (or whatever type of sample you are running the query on), you will be immediately notified without having to run the query manually.
     You don't need to change anything manually..
     */
    func testLongRunningQuery() {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            fatalError("*** Unable to get the body mass type ***")
        }
        
        var anchor = HKQueryAnchor.init(fromValue: 0)
        
        if UserDefaults.standard.object(forKey: "Anchor") != nil {
            let data = UserDefaults.standard.object(forKey: "Anchor") as! Data
            anchor = NSKeyedUnarchiver.unarchiveObject(with: data) as! HKQueryAnchor
        }
        
        let query = HKAnchoredObjectQuery(type: bodyMassType,
                                          predicate: nil,
                                          anchor: anchor,
                                          limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
                fatalError("*** An error occurred during the initial query: \(errorOrNil!.localizedDescription) ***")
            }
            
            anchor = newAnchor!
            let data : Data = NSKeyedArchiver.archivedData(withRootObject: newAnchor as Any)
            UserDefaults.standard.set(data, forKey: "Anchor")
            
            for bodyMassSample in samples {
                print("Samples: \(bodyMassSample)")
            }
            
            for deletedBodyMassSample in deletedObjects {
                print("deleted: \(deletedBodyMassSample)")
            }
            
            print("Anchor: \(anchor)")
        }
        
        /// Update Handler
        query.updateHandler = { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            
            guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
                // Handle the error here.
                fatalError("*** An error occurred during an update: \(errorOrNil!.localizedDescription) ***")
            }
            
            anchor = newAnchor!
            let data : Data = NSKeyedArchiver.archivedData(withRootObject: newAnchor as Any)
            UserDefaults.standard.set(data, forKey: "Anchor")
            
            for bodyMassSample in samples {
                print("samples: \(bodyMassSample)")
            }
            
            for deletedBodyMassSample in deletedObjects {
                print("deleted: \(deletedBodyMassSample)")
            }
        }
        
        healthStore.execute(query)
    }
    
}
