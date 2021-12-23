# HKQueries

# Instructions

1. I didn't ever use Healthkit before and apple Docs are not kind so I decided to make some organized documents.
2. I highly recommend you to run the code one by one to understand how it works.

# Table of contents 

- HKCharacteristicType
- HKSampleQuery
- HKAnchoredQuery
- HKStatisticsQuery
- HKStatisticsColletionQuery
- HKSourceQuery
- HKActivitySummaryQuery
- HKHeartbeatSeriesQuery
- HKObserverQuery
- HKSampleSeriesQuery
- Read Category Type
- Write Category Data
- Write Sample Data

# Three Types of Apple Health Data Type

1. Quantity type
   - Numerical value
   - Carries a unit
2. Category type
   - List of values
   - No unit
3. workout type
   - Summarizes multiple values
   - Multple units for multiple values

# Brief Summary

### HKCarateristicType: Characteristics of Data

1. You don't need to query data for `CharacteristicTypeIdentifier`
2. You can directly access `CharacteristicType` data

### HKSampleQuery: The Sample query is described as the general purpose query.

```swift
init(sampleType: HKSampleType,
predicate: NSPredicate?,
limit: Int,
sortDescriptors: [NSSortDescriptor]?,
resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void)
```

- line 1 => Line 1 shows that we need a sampleType which is a HKSampleType. This is simply used to set the query to fetch the data you want. Later on, we will use this to specify we want step count data.

- line 2 => On line 2 the `predicate` can be declared, although note that it is optional. You may want to receive all data for step count, or you might want `to limit what you get between two dates`. It is here that you can decide to just pass in nil, or you can form a predicate prior to init and provide some dates such as “a date 7 days ago and today”.

- line 3 => Line 3 has the limit. This is just an integer set to how many results you want returning. Perhaps you `are only interested in seeing 100 results` and `not all of them between two dates`.

- line 4 => Line 4 is the sort descriptor. This is also optional, meaning that nil can be passed in. Note that it is also surrounded in square brackets which indicates that we can use more than 1 type of sort although typically you will use nil and `handle your own sorting`, or use a date type sort. For workouts you can sort by distance, time, and other pre-defined ways.

- line 5 => Line 5 is the results handler. We see that we receive the query, an array of HKSample objects (with the array being marked as optional… meaning we might not get any results), and then an optional error is passed.

### HKAnchoredQuery: What has changed and long running query.. replacement of `HKObserverQuery`

`What has changed and long running query`

The HKAnchoredObjectQuery provides a useful way to keep tabs `on what has changed` for a particular sample type. It provides us with both the ability to receive a snapshot of data, and then on subsequent calls, a snapshot of what has changed. Alternatively you can create the initial snapshot of samples, and then `continuously monitor as a long-running query` which notifies you each time a new sample is added or when a sample is deleted.

### HKStatisticsQuery: Sum & Maximum & Minimum & Average

Sum & Maximum & Minimum & Average
The next query we will look at is the HKStatisticsQuery. This query is particularly interesting to those who want to calculate sum, minimum, maximum, or average values.

### HKStatisticsCollectionQuery: multiple collections

This particular query is useful for creating graphs. Unlike the HKStatisticsQuery which could only run one statistical calculation on one set of matching samples, the HKStatisticsCollectionQuery can perform these calculations over a series of fixed-length time intervals. This allows us to query samples such as step counts and fetch the cumulative sum in 1 hour intervals over a period of time set by the predicate.

This particular query can also be long-lived if needed, meaning that any changes made in Apple Health will be recognised, and you will be notified so that you can act.

### HKSourceQuery: Where the source has been come from

The HKSourceQuery provides a way for you to request what apps and devices are saving a specified sample type to the health store. This tutorial will be one of the shorter ones as there isn’t too much that can be done with this particular query.

### HKActivitySummaryQuery

What user has done each day...
The HKActivitySummaryQuery is useful for apps that are interested in what the user has done each day, in regards to exercise, stand hours, active calories, etc… The query can be used to query a single day, or a range of days.

### HKHeartBeatSeriesQuery

Fetch heartbeat series.. (almost real time)

### HKObserverQuery

Observe when HKDataType has changed
Don't need to use, since HKAnchoredQuery is upgraded version of HKObserverQuery

### HKSampleSeriesQuery

https://developer.apple.com/documentation/healthkit/samples/reading_and_writing_healthkit_series_data

- Measurements at a particular time
- Occur a timeinterval
- Walking Distance & Body Mass & Heart Rate
- Distance & Calories, Steops => sum
- Heart Rate & Boyd Mass & Height => Average, Minimum, Maximum, Most Recent

### Read Category Type Query

Link provided below...

### Write Category Data

Code provided below...

### Write Sample Data

Code provided below...

# Code

### Read CharacteristicsType

```swift

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

```

### HKSampleQuery

```swift
    let healthStore = HKHealthStore()

    func requestPermission() {
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
//                    self.testSampleQuery()
//                    self.testSampleQueryWithPredicate()
//                    self.testSampleQueryWithSortDescriptor()
                }
            }
        }
    }

    func testSampleQuery() {
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let query = HKSampleQuery.init(sampleType: sampleType!,
                                       predicate: nil,
                                       limit: HKObjectQueryNoLimit,
                                       sortDescriptors: nil) { (query, results, error) in
//            print(results)
        }

        healthStore.execute(query)
    }

    // HKSampleQuery with a predicate
    func testSampleQueryWithPredicate() {
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)

        let today = Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -3, to: today)

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: today, options: HKQueryOptions.strictEndDate)


        let query = HKSampleQuery(sampleType: sampleType!,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { (query, results, error) in


            print("testSampleQueryWithPredicate")

            // returns 1185 on current device
            print("query length: \(results?.count ?? 0)")

            // Data type returned...
            print(results?[0])
            /*
             60 count/min 6A44E2C4-36A2-4A26-B171-14F558F5E7F9 "신승현’s Apple Watch" (8.1), "Watch5,2" (8.1) "Apple Watch" metadata: {
                 HKMetadataKeyHeartRateMotionContext = 0;
             } (2021-12-08 19:49:02 +0900 - 2021-12-08 19:49:02 +0900)
             */


        }

        healthStore.execute(query)
    }

    // Sample query with a sort descriptor
    func testSampleQueryWithSortDescriptor() {
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)

        let today = Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -3, to: today)

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: today, options: HKQueryOptions.strictEndDate)

        let query = HKSampleQuery.init(sampleType: sampleType!,
                                       predicate: predicate,
                                       limit: HKObjectQueryNoLimit,
                                       sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { (query, results, error) in
//            print(results)
        }

        healthStore.execute(query)
    }
```

### HKStatisticsQuery

```swift
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
```

### HKStatisticsCollectionQuery

```swift
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
```

### HKAnchoredQuery

```swift
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
                    //                    self.testAnchoredQuery()
                }
            }
        }
    }

    // You can also check deleted objects
    // We passed in nil for the anchor. This resulted in all bodyMass records being returned.
    func testAnchoredQuery() {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            fatalError("*** Unable to get the body mass type ***")
        }

        // Create the query.
        let query = HKAnchoredObjectQuery(type: bodyMassType,
                                          predicate: nil,
                                          anchor: nil,
                                          limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
                fatalError("*** An error occurred during the initial query: \(errorOrNil!.localizedDescription) ***")
            }

            for bodyMassSample in samples {
                print("Samples: \(bodyMassSample)")
                // One element from samples
                /*
                 60 count/min 6A44E2C4-36A2-4A26-B171-14F558F5E7F9 "신승현’s Apple Watch" (8.1), "Watch5,2" (8.1) "Apple Watch" metadata: {
                 HKMetadataKeyHeartRateMotionContext = 0;
                 } (2021-12-08 19:49:02 +0900 - 2021-12-08 19:49:02 +0900)
                 */
            }

            // returns 1185
            print("total sample: \(samples.count)")

            for deletedBodyMassSample in deletedObjects {
                print("deleted: \(deletedBodyMassSample)")
            }

            // returns 0
            print("total deleted sample: \(deletedObjects.count)")

        }
        healthStore.execute(query)
    }


    // We will first look at how to keep a copy of HKQueryAnchor,
    // and then look at how we can make edits and then reinitialise HKAnchoredObjectQuery to get just a list of changes.
    /*
     If you run the app now you will see a log of every single bodyMass that has been recorded on your device. When completed you can stop the app and visit the health app. Add in a few new weight entries. Run the app again, and in the logs you will see just the changes that you made. If you stop the app, and go and delete some or all of those entries that you just created, then when starting the app again, you will be notified of the specific objects that were deleted.
     */
    /*
     When you persist the anchor you can then rerun the query with that anchor and receive just the information that has been added or deleted. When that happens, the new anchor will be updated again, and each time you load the app you will only be presented with changes that have been made between the last anchor and now.
     */
    func mostRecentAnchoredQueryQuery() {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            fatalError("*** Unable to get the body mass type ***")
        }

        var anchor = HKQueryAnchor.init(fromValue: 0)

        // The anchor does not naturally persist, so unless you persist it between app loads, you will need to start the query from the beginning each time the app loads.
        ///where we check if we already have an anchor saved. If we do, we need first extract the data and store it as Data. We then unarchive that data with NSKeyedUnarchiver. We need to go this route because we cannot store a HKQueryAnchor in UserDefaults as it is. Instead, we need to convert to data and archive that data, and then unarchive it when needed.
        if UserDefaults.standard.object(forKey: "Anchor") != nil {
            let data = UserDefaults.standard.object(forKey: "Anchor") as! Data
            anchor = NSKeyedUnarchiver.unarchiveObject(with: data) as! HKQueryAnchor
        }

        ///We next create the HKAnchoredObjectQuery, but instead of setting the anchor to nil, we pass in our newly created anchor which will either be initialised with a 0, or be initialised later on in the code.
        let query = HKAnchoredObjectQuery(type: bodyMassType,
                                          predicate: nil,
                                          anchor: anchor,
                                          limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
                fatalError("*** An error occurred during the initial query: \(errorOrNil!.localizedDescription) ***")
            }

            ///This is where we work more with the anchor. Here we assign the new anchor to anchor. This means that the next time the query runs it ignores everything except changes that have happened since the anchor was created.
            ///These are where we archive the newAnchor to Data, and then save that in UserDefaults. This is where the anchor is persisted.
            anchor = newAnchor!
            let data : Data = NSKeyedArchiver.archivedData(withRootObject: newAnchor as Any)
            UserDefaults.standard.set(data, forKey: "Anchor")

            for bodyMassSample in samples {
                print("Samples: \(bodyMassSample)")
            }

            for deletedBodyMassSample in deletedObjects {
                print("deleted: \(deletedBodyMassSample)")
            }

            print("Anchor: \(anchor)")
        }
        healthStore.execute(query)
    }

    /*
     I mentioned earlier that HKAnchoredObjectQuery also has the ability to be long-running. What this means is that you can make a query just once, and then each time a change is made in Health to body Mass (or whatever type of sample you are running the query on), you will be immediately notified without having to run the query manually.
     You don't need to change anything manually..
     */
    func testLongRunningQuery() {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            fatalError("*** Unable to get the body mass type ***")
        }

        var anchor = HKQueryAnchor.init(fromValue: 0)

        if UserDefaults.standard.object(forKey: "Anchor") != nil {
            let data = UserDefaults.standard.object(forKey: "Anchor") as! Data
            anchor = NSKeyedUnarchiver.unarchiveObject(with: data) as! HKQueryAnchor
        }

        let query = HKAnchoredObjectQuery(type: bodyMassType,
                                          predicate: nil,
                                          anchor: anchor,
                                          limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
                fatalError("*** An error occurred during the initial query: \(errorOrNil!.localizedDescription) ***")
            }

            anchor = newAnchor!
            let data : Data = NSKeyedArchiver.archivedData(withRootObject: newAnchor as Any)
            UserDefaults.standard.set(data, forKey: "Anchor")

            for bodyMassSample in samples {
                print("Samples: \(bodyMassSample)")
            }

            for deletedBodyMassSample in deletedObjects {
                print("deleted: \(deletedBodyMassSample)")
            }

            print("Anchor: \(anchor)")
        }

        /// Update Handler
        query.updateHandler = { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in

            guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
                // Handle the error here.
                fatalError("*** An error occurred during an update: \(errorOrNil!.localizedDescription) ***")
            }

            anchor = newAnchor!
            let data : Data = NSKeyedArchiver.archivedData(withRootObject: newAnchor as Any)
            UserDefaults.standard.set(data, forKey: "Anchor")

            for bodyMassSample in samples {
                print("samples: \(bodyMassSample)")
            }

            for deletedBodyMassSample in deletedObjects {
                print("deleted: \(deletedBodyMassSample)")
            }
        }

        healthStore.execute(query)
    }
```

### HKActivitySummaryQuery

```swift
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
```

### HKHeartbeatSeriesQuery

```swift
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
```

### HKSourceQuery

```swift
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
```

### HKObserverQuery

```swift
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

```

### HKSampleSeriesQuery

https://developer.apple.com/videos/play/wwdc2019/218/

### Read CategoryType

```swift
    let healthStore = HKHealthStore()

    func requestPermission() {
        if HKHealthStore.isHealthDataAvailable() {
            let readDataTypes : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
                                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
                                       HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
            ]

            let writeDataTypes : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]

            healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                } else {
//                    self.testSampleQuery()
//                    self.testSampleQueryWithPredicate()
//                    self.testSampleQueryWithSortDescriptor()
                }
            }
        }
    }

    func retrieveSleepData() {
        let categoryType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)
        if let sleepType = categoryType {

//            let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                if let result = tmpResult {
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            print("sleep: \(sample.startDate) \(sample.endDate) - source: \(sample.source.name) - value: \(value)")
                            let seconds = sample.endDate.timeIntervalSince(sample.startDate)
                            let minutes = seconds/60
                            let hours = minutes/60
                        }
                    }
                }
            }

            healthStore.execute(query)

            /*
             Return
             sleep: 2021-12-23 06:03:47 +0000 2021-12-23 14:03:47 +0000 - source: HealthKit Queries - value: InBed
             sleep: 2021-12-23 06:13:47 +0000 2021-12-23 13:58:47 +0000 - source: HealthKit Queries - value: Asleep
             sleep: 2021-12-22 06:09:56 +0000 2021-12-22 14:09:56 +0000 - source: HealthKit Queries - value: InBed
             sleep: 2021-12-22 06:19:56 +0000 2021-12-22 14:04:56 +0000 - source: HealthKit Queries - value: Asleep
             sleep: 2021-12-22 00:09:07 +0000 2021-12-22 08:09:07 +0000 - source: HealthKit Queries - value: InBed
             sleep: 2021-12-22 00:19:07 +0000 2021-12-22 08:04:07 +0000 - source: HealthKit Queries - value: Asleep
             */
        }
    }
```

### Write Sample Data

```swift
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

```

### Write Category Data

```swift
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
```


# References

[https://dmtopolog.com/healthkit-changes-observing/](https://dmtopolog.com/healthkit-changes-observing/)

[HealthKit Tutorial Ray](https://www.raywenderlich.com/459-healthkit-tutorial-with-swift-getting-started)

[https://www.devfright.com/healthkit/](https://www.devfright.com/healthkit/)

https://developer.apple.com/videos/play/wwdc2019/218/
