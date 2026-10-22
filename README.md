<<<<<<< HEAD
# Scheduling-analysis
Scheduling algorithms on cellular networks. This is using RR, BCQI, BET and PF scheduling algorithms for analysis and metrics comparison under 

## Wireless Scheduling Comparison

This MATLAB project compares four wireless downlink schedulers:
- Round Robin
- Best CQI
- Blind Equal Throughput
- Proportional Fair

The main script `Scheduling.m` runs each algorithm across multiple user counts and generates plots for throughput, fairness, spectral efficiency, delay, outage probability, and throughput-vs-fairness behavior.

Each scheduler returns:
- average throughput
- fairness index
- spectral efficiency
- average delay
- outage probability

The Round Robin scheduler in `RR_function.m` allocates resource blocks sequentially to active users, skipping completed users. The other schedulers use channel-aware or fairness-aware selection strategies.

This project is intended to evaluate and compare scheduler performance in a simplified LTE-like simulation environment, showing the tradeoffs between throughput, fairness, and user service quality.
=======
# Scheduling-Algorithms-Analysis
Scheduling algorithms on cellular networks. This is using RR, BCQI, BET and PF scheduling algorithms for analysis and metrics comparison under 
>>>>>>> 16ed9bb0dda179a5f4f6899b427e4259d5d10d2c
