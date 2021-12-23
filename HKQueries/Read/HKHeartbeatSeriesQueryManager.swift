//
//  HKHeartbeatSeriesQuery.swift
//  HKQueries
//
//  Created by paige on 2021/12/24.
//

import Foundation
import HealthKit

class HKHeartbeatSeriesQueryManager {
    
    func testHeartbeatSeriesQuery() {
        let healthStore = HKHealthStore()
        
        let allTypes = Set([
            HKSeriesType.heartbeat(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            ])
        
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
                let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
                let query = HKSampleQuery(sampleType: HKSeriesType.heartbeat(),
                                          predicate: nil,
                                          limit: HKObjectQueryNoLimit,
                                          sortDescriptors: [sortDescriptor]) { (_, samples, _) in
                    if let sample = samples?.first as? HKHeartbeatSeriesSample {
                        print("series start:\(sample.startDate)\tend:\(sample.endDate)")
                        let seriesQuery = HKHeartbeatSeriesQuery(heartbeatSeries: sample) {
                            query, timeSinceSeriesStart, precededByGap, done, error in
                            let formatted = String(format: "%.2f", timeSinceSeriesStart)
                            print("timeSinceSeriesStart:\(formatted)\tprecededByGap:\(precededByGap)\t done:\(done)")
//                                    print("sample: \(sample)")
                        }
                        healthStore.execute(seriesQuery)
                    }
                }
                healthStore.execute(query)
            }
        }
    }
    
}
