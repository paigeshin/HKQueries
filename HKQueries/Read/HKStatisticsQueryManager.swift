//
//  HKStatisticsQueryManager.swift
//  HKQueries
//
//  Created by paige on 2021/12/24.
//

import HealthKit

/// Sum & Maximum & Minimum & Average
/// The next query we will look at is the HKStatisticsQuery. This query is particularly interesting to those who want to calculate sum, minimum, maximum, or average values.
class HKStatisticsQueryManager {
    
    let healthStore = HKHealthStore()
    
    func requestPermission() {
        // Do any additional setup after loading the view, typically from a nib.
        
        if HKHealthStore.isHealthDataAvailable() {
            let readDataTypes : Set = [
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]
            
            let writeDataTypes : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,]
            
            healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                } else {
//                    self.testStatisticsQueryCumulitive()
//                    self.testStatisticsQueryDiscrete()
                }
            }
        }
        
    }
    
    func testStatisticsQueryCumulitive() {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** Unable to get the step count type ***")
        }
        
        // we initialise the HKStatisticsQuery and pass in the quantity type. On the next line we specify that we are using no predicate. This will request all data.
        /// For stepCount we have just 2 options. One is the cumulativeSum of samples between the dates provided in the predicate (or all samples if the predicate is nil). The other is an option to separate by source. The source refers to which app or device was used to create the samples. In the example above we do not separate by source. In a few moments we will look at that option.
        let query = HKStatisticsQuery.init(quantityType: stepCountType,
                                           quantitySamplePredicate: nil,
                                           options: [HKStatisticsOptions.cumulativeSum, HKStatisticsOptions.separateBySource]) { (query, results, error) in
            print("Total: \(results?.sumQuantity()?.doubleValue(for: HKUnit.count()))")
            // return 89855.16314160473)
            for source in (results?.sources)! {
                print("Seperate Source: \(results?.sumQuantity(for: source)?.doubleValue(for: HKUnit.count()))")
                // return 28479, 88432
            }
        }
        
        healthStore.execute(query)
    }
    
    func testStatisticsQueryDiscrete() {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            fatalError("*** Unable to get the body mass type ***")
        }
        
        let query = HKStatisticsQuery.init(quantityType: bodyMassType,
                                           quantitySamplePredicate: nil,
                                           options: [HKStatisticsOptions.discreteMax, HKStatisticsOptions.separateBySource]) { (query, results, error) in
            print("Total: \(results?.maximumQuantity()?.doubleValue(for: HKUnit.pound()))")
            for source in (results?.sources)! {
                print("Seperate Source: \(results?.maximumQuantity(for: source)?.doubleValue(for: HKUnit.pound()))")
            }
        }
        
        healthStore.execute(query)
    }
    
    
}
