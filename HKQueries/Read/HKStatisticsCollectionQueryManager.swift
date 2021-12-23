//
//  HKStatisticsCollectionQueryManager.swift
//  HKQueries
//
//  Created by paige on 2021/12/24.
//

///This particular query is useful for creating graphs. Unlike the HKStatisticsQuery which could only run one statistical calculation on one set of matching samples, the HKStatisticsCollectionQuery can perform these calculations over a series of fixed-length time intervals. This allows us to query samples such as step counts and fetch the cumulative sum in 1 hour intervals over a period of time set by the predicate.
///This particular query can also be long-lived if needed, meaning that any changes made in Apple Health will be recognised, and you will be notified so that you can act.

import Foundation
import HealthKit

class HKStatisticsCollectionQueryManager {
    
    let healthStore = HKHealthStore()
    
    func requestPermission(){
        // Do any additional setup after loading the view, typically from a nib.
        
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
                    //self.testCharachteristic()
                    //self.testSampleQuery()
                    //self.testSampleQueryWithPredicate()
                    //self.testSampleQueryWithSortDescriptor()
                    //self.testAnchoredQuery()
                    //self.testStatisticsQueryCumulitive()
                    //self.testStatisticsQueryDiscrete()
                    //                    self.testStatisticsCollectionQueryCumulitive()
                    //                    self.testStatisticsCollectionQueryDiscrete()
                }
            }
        }
        
    }

    /// The anchor is an important part of the HKStatisticsCollectionQuery. When we initialise the query we need to specify an anchor. The anchor defines a moment in time where we are to calculate our samples from. Likewise, the interval is also important. We need to setup the query to work on specific time intervals in order for it to calculate based on that interval.
    func testStatisticsCollectionQueryCumulitive() {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** Unable to get the step count type ***")
        }
        
        var interval = DateComponents()
        interval.hour = 1
        
        let calendar = Calendar.current
        let anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())
        
        let query = HKStatisticsCollectionQuery.init(quantityType: stepCountType,
                                                     quantitySamplePredicate: nil, // if you want to have more control over each sample predicate.
                                                     options: [.cumulativeSum, .separateBySource],
                                                     anchorDate: anchorDate!,
                                                     intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            
            let startDate = calendar.startOfDay(for: Date())
            
            print("Cumulative Sum")
            results?.enumerateStatistics(from: startDate,
                                         to: Date(), with: { (result, stop) in
                print("Time: \(result.startDate), \(result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)")
            })
            
            print("By Source")
            for source in (results?.sources())! {
                print("Next Device: \(source.name)")
                results?.enumerateStatistics(from: startDate,
                                             to: Date(), with: { (result, stop) in
                    print("\(result.startDate): \(result.sumQuantity(for: source)?.doubleValue(for: HKUnit.count()) ?? 0)")
                })
            }
        }
        
        query.statisticsUpdateHandler = {
            query, statistics, statisticsCollection, error in
            print(query)
            print(statistics)
            print(statisticsCollection)
            print(error)
        }
        
        healthStore.execute(query)
    }
    
    func testStatisticsCollectionQueryDiscrete() {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            fatalError("*** Unable to get the body mass type ***")
        }
        
        var interval = DateComponents()
        interval.month = 1
        
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month], from: Date())
        let startOfMonth = calendar.date(from: components)
        let anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: startOfMonth!)
        
        let query = HKStatisticsCollectionQuery.init(quantityType: bodyMassType,
                                                     quantitySamplePredicate: nil, // if you want to have more control over each sample predicate.
                                                     options: [.discreteAverage, .separateBySource],
                                                     anchorDate: anchorDate!,
                                                     intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            
            let date = calendar.startOfDay(for: Date())
            
            let startDate = Calendar.current.date(byAdding: .year, value: -5, to: date)
            
            print("Cumulative Sum")
            results?.enumerateStatistics(from: startDate!,
                                         to: Date(), with: { (result, stop) in
                print("Month: \(result.startDate), \(result.averageQuantity()?.doubleValue(for: HKUnit.pound()) ?? 0)lbs")
            })
            
            print("By Source")
            for source in (results?.sources())! {
                print("Next Device: \(source.name)")
                results?.enumerateStatistics(from: startDate!,
                                             to: Date(), with: { (result, stop) in
                    print("\(result.startDate): \(result.averageQuantity(for: source)?.doubleValue(for: HKUnit.pound()) ?? 0)lbs")
                })
            }
        }
        healthStore.execute(query)
    }
    
    
}
