//
//  HKActivitySummaryQuery.swift
//  HKQueries
//
//  Created by paige on 2021/12/24.
//

/// What use has done each day...
/// The HKActivitySummaryQuery is useful for apps that are interested in what the user has done each day, in regards to exercise, stand hours, active calories, etc… The query can be used to query a single day, or a range of days.

import Foundation
import HealthKit

class HKActivitySummaryQueryManager {

    let healthStore = HKHealthStore()
    
    func testActivitySummaryQuery() {
        if #available(iOS 9.3, *) {

            let query = HKActivitySummaryQuery.init(predicate: nil) { (query, summaries, error) in
                let calendar = Calendar.current
                for summary in summaries! {
                    let dateComponants = summary.dateComponents(for: calendar)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let date = dateComponants.date
                    
                    print("Date: \(dateFormatter.string(from: date!)), Active Energy Burned: \(summary.activeEnergyBurned), Active Energy Burned Goal: \(summary.activeEnergyBurnedGoal)")
                    print("Date: \(dateFormatter.string(from: date!)), Exercise Time: \(summary.appleExerciseTime), Exercise Goal: \(summary.appleExerciseTimeGoal)")
                    print("Date: \(dateFormatter.string(from: date!)), Stand Hours: \(summary.appleStandHours), Stand Hours Goal: \(summary.appleStandHoursGoal)")
                    print("----------------")
                }
            }
            healthStore.execute(query)
        } else {
            // Fallback on earlier versions
        }
    }
    
}
