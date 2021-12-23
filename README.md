# HKQueries

# Instructions.

1. I didn't ever use Healthkit before and apple Docs are not kind so I decided to make some organized documents.
2. I highly recommend you to run the code one by one to understand how it works.

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

### HKCarateristicType: Characteristics of Data

[Code Example](https://github.com/paigeshin/HKQueries/blob/master/Read/HKCharacteristicTypeQueryManager.swift)

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

- Measurements at a particular time
- Occur a timeinterval
- Walking Distance & Body Mass & Heart Rate
- Distance & Calories, Steops => sum
- Heart Rate & Boyd Mass & Height => Average, Minimum, Maximum, Most Recent

### Read Category Type Query

# References

[https://dmtopolog.com/healthkit-changes-observing/](https://dmtopolog.com/healthkit-changes-observing/)

[HealthKit Tutorial Ray](https://www.raywenderlich.com/459-healthkit-tutorial-with-swift-getting-started)

[https://www.devfright.com/healthkit/](https://www.devfright.com/healthkit/)
