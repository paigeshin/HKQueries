//
//  HKSourceQueryManager.swift
//  HKQueries
//
//  Created by paige on 2021/12/24.
//

/// The HKSourceQuery provides a way for you to request what apps and devices are saving a specified sample type to the health store. This tutorial will be one of the shorter ones as there isn’t too much that can be done with this particular query.

import Foundation
import HealthKit

class HKSourceQueryManager {
    
    
    let healthStore = HKHealthStore()
    
    func requestPermission() {
        // Do any additional setup after loading the view, typically from a nib.
        
        if HKHealthStore.isHealthDataAvailable() {
            let readDataTypes : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]
            
            let writeDataTypes : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!]
            
            healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                } else {
                    //self.testCharachteristic()
                    //self.testSampleQuery()
                    //self.testSampleQueryWithPredicate()
                    //self.testSampleQueryWithSortDescriptor()
                    //self.testAnchoredQuery()
                    //self.testStatisticsQueryCumulitive()
                    //self.testStatisticsQueryDiscrete()
                    //self.testStatisticsCollectionQueryCumulitive()
                    //self.testStatisticsCollectionQueryDiscrete()
                    //                     self.testSourceQuery()
                }
            }
        }
        
    }
    
    
    func testSourceQuery() {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            fatalError("*** Unable to get the body mass type ***")
        }
        
        let query = HKSourceQuery.init(sampleType: bodyMassType,
                                       samplePredicate: nil) { (query, sources, error) in
            for source in sources! {
                print(source.name)
            }
        }
        
        healthStore.execute(query)
    }
    
    
    
}


