---
name: defer
description: Complete a task later
---

The user wants you to do something, but later once a condition is met.

First check the condition once right away - it might already be met.

Ideally you should write some deterministic code that checks for the condition, and once the check completes execute the task.
Use good judgement for how often to actually check. A good default is every minute, but do it more seldom if the check is expensive, or more frequently if it is cheap.

Also good to set a timeout, e.g. 1 hour, after that some re-assessment of the situation could be good. Is it expected to take this long, anything wrong with the check or are fixes needed.

If tool `Monitor` is available it should be suitable for this.

Otherwise run the check loop in the background (`run_in_background`), so you are woken up when it exits:
```
for i in $(seq 60); do <check logic> && exit 0; sleep 60; done; exit 1
```

If condition cannot be checked with a command, instead schedule a regular wakeup with `CronCreate`.
Here a lower cadence is appropriate, perhaps every 5 or 10 minutes.

Before starting, tell the user in one line what the check is, how often it runs, and when it times out.

## Repeat actions

Once the condition is met and the task is executed, a follow up question is: is it done now? or should we do it again?

If the same condition could arise again, and it makes sense to repeat the action, then keep checking.
Users explicit instructions takes priority, but otherwise use your judgement on this.

## Backoff

The more time passes, the less frequent the check should be, and the less likely we should be to decide to repeat the action.

## Final timeout

All tasks time out after 24 hours, unless the user explicitly instructed otherwise.

Stop any scheduled wakeups (`CronDelete`) and do not run more commands to check for things.