//
//  HKCategoryDataSaver.swift
//  HKQueries
//
//  Created by paige on 2021/12/24.
//

import Foundation
import HealthKit

class HKCategoryDataSaver {
    
    let healthStore = HKHealthStore()
    
    func requestPermission() {
  
        // Do any additional setup after loading the view, typically from a nib.
        
        if HKHealthStore.isHealthDataAvailable() {
            var readDataTypes : Set<HKObjectType> = []
            if #available(iOS 9.3, *) {
                readDataTypes = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                                 HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                                 HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                                 HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
                                 HKObjectType.activitySummaryType()]
            } else {
                // Fallback on earlier versions
                readDataTypes = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                                 HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                                 HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                                 HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]
            }
            
            let writeDataTypes : Set = [HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!]

            healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                } else {
                    self.recordSleep()
                }
            }
        }
    }
    
    func recordSleep() {
        let now = Date()
        let startBed = Calendar.current.date(byAdding: .hour, value: -8, to: now)
        let startSleep = Calendar.current.date(byAdding: .minute, value: -470, to: now)
        let endSleep = Calendar.current.date(byAdding: .minute, value: -5, to: now)
        
        let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)
        let inBed = HKCategorySample.init(type: sleepType!, value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: startBed!, end: now)
        let asleep = HKCategorySample.init(type: sleepType!, value: HKCategoryValueSleepAnalysis.asleep.rawValue, start: startSleep!, end: endSleep!)
        healthStore.save([inBed, asleep]) { (success, error) in
            if !success {
                // Handle the error here.
            } else {
                print("Saved")
            }
        }
    }

}
