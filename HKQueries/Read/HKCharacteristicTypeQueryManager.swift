//
//  HKCharacteristicTypeVC.swift
//  HKQueries
//
//  Created by paige on 2021/12/23.
//

//https://www.devfright.com/reading-characteristic-data-from-healthkit/

// 1. You don't need to query data for `CharacteristicTypeIdentifier`
// 2. You can directly access `CharacteristicType` data

import HealthKit

class HKCharacteristicTypeQueryManager {
    
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
                    self.testCharachteristic()
                }
            }
        }
    }

    // Fetches biologicalSex of the user, and date of birth.
    func testCharachteristic() {
        // Biological Sex
        if try! healthStore.biologicalSex().biologicalSex == HKBiologicalSex.female {
            print("You are female")
        } else if try! healthStore.biologicalSex().biologicalSex == HKBiologicalSex.male {
            print("You are male")
        } else if try! healthStore.biologicalSex().biologicalSex == HKBiologicalSex.other {
            print("You are not categorised as male or female")
        }
        
        // Date of Birth
        if #available(iOS 10.0, *) {
            try? print(healthStore.dateOfBirthComponents())
        } else {
            // Fallback on earlier versions
            do {
                let dateOfBirth = try healthStore.dateOfBirth()
                print(dateOfBirth)
            } catch let error {
                print("There was a problem fetching your data: \(error)")
            }
        }
    }

}
