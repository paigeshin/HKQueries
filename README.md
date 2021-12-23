# HKQueries

- HKCarateristicType: Characteristics of Data

  1. You don't need to query data for `CharacteristicTypeIdentifier`
  2. You can directly access `CharacteristicType` data

- HKSampleQuery: The Sample query is described as the general purpose query.

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

- HKAnchoredQuery: What has changed and long running query.. replacement of `HKObserverQuery`

  `What has changed and long running query`

  The HKAnchoredObjectQuery provides a useful way to keep tabs `on what has changed` for a particular sample type. It provides us with both the ability to receive a snapshot of data, and then on subsequent calls, a snapshot of what has changed. Alternatively you can create the initial snapshot of samples, and then `continuously monitor as a long-running query` which notifies you each time a new sample is added or when a sample is deleted.

- HKSta

# References

[https://dmtopolog.com/healthkit-changes-observing/](https://dmtopolog.com/healthkit-changes-observing/)

[HealthKit Tutorial Ray](https://www.raywenderlich.com/459-healthkit-tutorial-with-swift-getting-started)

[https://www.devfright.com/healthkit/](https://www.devfright.com/healthkit/)
