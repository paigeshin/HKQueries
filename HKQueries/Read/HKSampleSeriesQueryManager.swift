//
//  HKSampleSeriesQueryManager.swift
//  HKQueries
//
//  Created by paige on 2021/12/24.
//

import Foundation
import HealthKit

class HKSampleSeriesQueryManager {

    let healthStore = HKHealthStore()
    let dataTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
    
    func requestPermission() {
        healthStore.requestAuthorization(toShare: dataTypes, read: dataTypes) { success, error in
            
        }
        
        
    }
    
    func createSampleBuilder(heartRate: HKQuantity) {
        // Create a HKQuantitySeriesSampleBuilder
        let builder = HKQuantitySeriesSampleBuilder(healthStore: healthStore, quantityType: HKObjectType.quantityType(forIdentifier: .heartRate)!, startDate: Date().addingTimeInterval(60 * 60 * 24), device: .local())
        
        // add qauntities to builder
        do {
            try builder.insert(heartRate, at: Date())
        } catch {
            
        }
        
        // finish
        builder.finishSeries(metadata: [:]) { samples, error in
            
        }
        
    }
    
    func read() {
        let query = HKQuantitySeriesSampleQuery(quantityType: HKObjectType.quantityType(forIdentifier: .heartRate), predicate: nil) { query, quantity, dateInterval, sample, done, error in
            
        }
    }
    
}
