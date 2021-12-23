//
//  SaveHealthKitData.swift
//  HKQueries
//
//  Created by paige on 2021/12/24.
//

import Foundation
import HealthKit

class HKSampleDataSaver {
    
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
            
            let writeDataTypes : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]
            
            healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                } else {
                    self.saveBodyMass(date: Date(), bodyMass: 189.4)
                }
            }
        }
    }
    
    func saveBodyMass(date: Date, bodyMass: Double) {
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        let bodyMass = HKQuantitySample.init(type: quantityType!,
                                             quantity: HKQuantity.init(unit: HKUnit.pound(), doubleValue: bodyMass),
                                             start: date,
                                             end: date)
        healthStore.save(bodyMass) { success, error in
            if (error != nil) {
                print("Error: \(String(describing: error))")
            }
            if success {
                print("Saved: \(success)")
            }
        }
    }
    
}
