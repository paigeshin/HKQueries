//
//  HKObserverQuery.swift
//  HKQueries
//
//  Created by paige on 2021/12/24.
//

import Foundation
import HealthKit

class HKObserverQueryManager {
    
    let bodyMassType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    let hkStore = HKHealthStore()
    var bodyMassObserverQuery: HKObserverQuery? = nil

    func startObserving() {
        /*
            `bodyMassObserverQuery` should be a property not a local variable,
            so you'll be able to stop the query when necessary
        */
        bodyMassObserverQuery = HKObserverQuery(
            sampleType: bodyMassType,
            predicate: nil) { [weak self] (query, completion, error) in
                self?.bodyMassObserverQueryTriggered()
        }

        hkStore.execute(bodyMassObserverQuery!)
    }

    func bodyMassObserverQueryTriggered() {
        let bodyMassSampleQuery = HKSampleQuery(
                sampleType: bodyMassType,
                predicate: nil,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil,
                resultsHandler: { [weak self] (query, samples, error) in
//                    self?.bodyMassSampleQueryFinished(samples: samples)
            })
        hkStore.execute(bodyMassSampleQuery!)
    }

    
}

