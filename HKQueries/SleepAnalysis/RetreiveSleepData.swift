//
//  RetreiveSleepData.swift
//  HKQueries
//
//  Created by paige on 2021/12/24.
//

import Foundation
import HealthKit

class RetrieveSleepData {
    
    let healthStore = HKHealthStore()
    
    func requestPermission() {
        if HKHealthStore.isHealthDataAvailable() {
            let readDataTypes : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
                                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
                                       HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
            ]
            
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
    
    func retrieveSleepData() {
        let categoryType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)
        if let sleepType = categoryType {

//            let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                if let result = tmpResult {
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            print("sleep: \(sample.startDate) \(sample.endDate) - source: \(sample.source.name) - value: \(value)")
                            let seconds = sample.endDate.timeIntervalSince(sample.startDate)
                            let minutes = seconds/60
                            let hours = minutes/60
                        }
                    }
                }
            }

            healthStore.execute(query)
            
            /*
             Return
             sleep: 2021-12-23 06:03:47 +0000 2021-12-23 14:03:47 +0000 - source: HealthKit Queries - value: InBed
             sleep: 2021-12-23 06:13:47 +0000 2021-12-23 13:58:47 +0000 - source: HealthKit Queries - value: Asleep
             sleep: 2021-12-22 06:09:56 +0000 2021-12-22 14:09:56 +0000 - source: HealthKit Queries - value: InBed
             sleep: 2021-12-22 06:19:56 +0000 2021-12-22 14:04:56 +0000 - source: HealthKit Queries - value: Asleep
             sleep: 2021-12-22 00:09:07 +0000 2021-12-22 08:09:07 +0000 - source: HealthKit Queries - value: InBed
             sleep: 2021-12-22 00:19:07 +0000 2021-12-22 08:04:07 +0000 - source: HealthKit Queries - value: Asleep
             */
        }
    }
    
}
