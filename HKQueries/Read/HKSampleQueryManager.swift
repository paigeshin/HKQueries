//
//  HKSampleQury.swift
//  HKQueries
//
//  Created by paige on 2021/12/23.
//

// https://www.devfright.com/hksamplequery-tutorial-and-examples/
// The Sample query is described as the general purpose query.

/*
 
 init(sampleType: HKSampleType,
 predicate: NSPredicate?,
 limit: Int,
 sortDescriptors: [NSSortDescriptor]?,
 resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void)
 
 line 1 => Line 1 shows that we need a sampleType which is a HKSampleType. This is simply used to set the query to fetch the data you want. Later on, we will use this to specify we want step count data.
 line 2 => On line 2 the `predicate` can be declared, although note that it is optional. You may want to receive all data for step count, or you might want `to limit what you get between two dates`. It is here that you can decide to just pass in nil, or you can form a predicate prior to init and provide some dates such as “a date 7 days ago and today”.
 line 3 => Line 3 has the limit. This is just an integer set to how many results you want returning. Perhaps you `are only interested in seeing 100 results` and `not all of them between two dates`.
 line 4 => Line 4 is the sort descriptor. This is also optional, meaning that nil can be passed in. Note that it is also surrounded in square brackets which indicates that we can use more than 1 type of sort although typically you will use nil and `handle your own sorting`, or use a date type sort. For workouts you can sort by distance, time, and other pre-defined ways.
 line 5 => Line 5 is the results handler. We see that we receive the query, an array of HKSample objects (with the array being marked as optional… meaning we might not get any results), and then an optional error is passed.
 */

import HealthKit

class HKSampleQueryManager {
    
    let healthStore = HKHealthStore()
    
    func requestPermission() {
        if HKHealthStore.isHealthDataAvailable() {
            let readDataTypes : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
                                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
            
            let writeDataTypes : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
            
            healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                } else {
//                    self.testSampleQuery()
//                    self.testSampleQueryWithPredicate()
//                    self.testSampleQueryWithSortDescriptor()
                }
            }
        }
    }
    
    func testSampleQuery() {
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let query = HKSampleQuery.init(sampleType: sampleType!,
                                       predicate: nil,
                                       limit: HKObjectQueryNoLimit,
                                       sortDescriptors: nil) { (query, results, error) in
//            print(results)
        }
        
        healthStore.execute(query)
    }
    
    // HKSampleQuery with a predicate
    func testSampleQueryWithPredicate() {
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        
        let today = Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -3, to: today)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: today, options: HKQueryOptions.strictEndDate)
    

        let query = HKSampleQuery(sampleType: sampleType!,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { (query, results, error) in
                
            
            print("testSampleQueryWithPredicate")
            
            // returns 1185 on current device
            print("query length: \(results?.count ?? 0)")
            
            // Data type returned...
            print(results?[0])
            /*
             60 count/min 6A44E2C4-36A2-4A26-B171-14F558F5E7F9 "신승현’s Apple Watch" (8.1), "Watch5,2" (8.1) "Apple Watch" metadata: {
                 HKMetadataKeyHeartRateMotionContext = 0;
             } (2021-12-08 19:49:02 +0900 - 2021-12-08 19:49:02 +0900)
             */
            
   
        }
        
        healthStore.execute(query)
    }
    
    // Sample query with a sort descriptor
    func testSampleQueryWithSortDescriptor() {
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        
        let today = Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -3, to: today)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: today, options: HKQueryOptions.strictEndDate)
        
        let query = HKSampleQuery.init(sampleType: sampleType!,
                                       predicate: predicate,
                                       limit: HKObjectQueryNoLimit,
                                       sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { (query, results, error) in
//            print(results)
        }
        
        healthStore.execute(query)
    }
    
}
