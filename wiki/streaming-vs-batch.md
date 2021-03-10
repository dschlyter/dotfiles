## Why streaming is harder

Data processing is generally element wise operations (map in map-reduce), and aggregate operations (reduce in map-reduce). In theory element wise should be just as easy to stream as to batch (ignoring efficency), however with aggregations you ideally need all the data.

Batch is just a pragmatic shortcut where you simply wait for a while until you have all data, or at least close enough so you can pretend that you do. Batch is computing on a complete view of the world that will never change (even if this is a small lie), while streaming will have you guessing as data comes in.

## Advantages of streaming

* Timliness
    * Streaming can give you results earlier
    * Even cooler, streaming can give you results *later*, since the streaming context can extend for longer than a batch (at an efficiency cost)
    * Streaming can also give you multiple emissions using early, on-time and late firings (at an complexity cost)
    * Modern stream processing (Beam) will often allow you to more explicitly reason about event time when in batch there is often the case that late events are just put in the wrong batch
    * With session windows you can decide when to emit results based on the data itself, keeping data along for as long as it is relevant, while batch has more fixed input and output.
    * (All of the above can be solved with multple batch jobs for early/on-time/late, and logic in the code for event time, even if this quickly becomes cumbersome.)
* No arbitrary cutoff
    * Session windows can be arbitrarily cut off at the batch boundary
    * Data will be more complete at the begining of the batch vs at the end, if there are straggler events
    * (Both of these can be somewhat fixed with sliding windows over multiple batches)

## Cost of streaming

* Operationally
    * Generally streaming systems are less mature - even if this is getting better
    * Streaming input is mutable, losing the enormous operational benefit of immutable datasets
        * Changes to batch jobs are easy to test, just re-run them on the same input, which is hard with the mutable stream input
        * How do you even backfill a stream on error? 
    * Streaming input is often ephemeral - unless you are using Kafka, but even then you usually need a "live" and a "long term" store
    * How does one streaming job consume the output of another, if the first job emits early/on-time/late results.
    * Deployment is harder, since the job is always running and intermediary state must be migrated.
    * Batch is more resillient to intermittent errors since there is less expectation of constant availability of fresh data
    * If streaming gives the expectations of reliable real time data you will need to have engineers on-call and this costs a lot
* Code complexity
    * The Beam model has you reasoning about the "What, Where, When and How" of events, while Batch is basically just "What".
    * The power of multiple emissions comes at a cost, your code needs to be able to assemble data from any order of the input. Split and merge groupings based on new data points.
    * Harder to ensure your pipeline is deterministic when input order and data completeness is different per execution.
    * Your code needs to think about intermediary state.
* Efficiency
    * Streaming requires holding intermediary state for longer periods of time
    * With multiple emissions, you may need to re-run computations
    * Streaming joins require a lookup-table for both sides, while batch only needs for one side (the smaller one)
    * Streaming data is sorted by time, while batch data can be sorted to be processed more efficiently (e.g. SMB).
    * Streaming is harder to scale. Underprovisioning will violate latency SLOs and overprovisioning is idling and wasteful, batch will just be a bit slower or faster.
    * Streaming will need to respond to spikes, resulting in more rescaling and overhead with shard balancing.
    * Streaming requires more checkpointing since batch can lean more heavily on recomputing stuff based on stable inputs.