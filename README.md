# Scheduling-analysis

Scheduling algorithms on cellular networks. This MATLAB project simulates a simplified LTE-like downlink cell and compares four resource-block (RB) schedulers: **Round Robin (RR)**, **Best CQI (BCQI)**, **Blind Equal Throughput (BET)** and **Proportional Fair (PF)**. It reports throughput, fairness, spectral efficiency, delay and outage, and shows how each one changes with the number of users, the channel bandwidth and the packet size.

The script to run is **`Scheduling.m`**.

---

## 1. Project layout

| File | Role |
|---|---|
| `Scheduling.m` | **Main script.** Runs the three parameter sweeps, calls every scheduler and draws all the figures. |
| `RR_function.m` | Round Robin scheduler (used by `Scheduling.m`). |
| `BCQI_function.m` | Best CQI / Max C/I scheduler (used). |
| `BET_FAST_function.m` | Blind Equal Throughput scheduler (used). |
| `PF_FAST_function.m` | Proportional Fair scheduler (used). |
| `CQI.m` | Maps an SNR (dB) to a CQI index and returns the bits carried per resource element. |
| `Modelo_de_canal.m` | Channel model: free-space path loss, returns received power in dBm. |
| `BET_function.m`, `PF_function.m` | Earlier, slower versions of BET and PF. **Not called** by `Scheduling.m`. |
| `Scheduling_2.m`, `Scheduling_3.m`, `Scheduling - Copy.txt` | Earlier versions of the main script. Not needed to reproduce the current results. |
| `Despachadores individuales/` | Standalone script versions of each scheduler, from before they were turned into functions. Kept for reference. |

All four scheduler functions share one signature:

```matlab
[atp, FT, Ef, delay, outt] = <scheduler>(Qty_UE, r, freq, Pout, BW, TTI, buffer, Pkg, fi, frames, rdg)
```

---

## 2. Common simulation model (shared by every scheduler)

Each scheduler function contains its own copy of the same environment. Only the rule that decides **which user gets the next RB** differs between them.

### 2.1 Users and channel
- The gNB sits at the origin. `Qty_UE` users are placed at distances `d` from it, chosen by `rdg`:
  - `0`: `|N(0,1)|·r` (half-normal)
  - `1`: `U(0,1)·r` (uniform random)
  - `2`: `linspace(0,1,Qty_UE)·r`, evenly spaced from 0 to r. **This is the one `Scheduling.m` uses**, so the starting positions are the same in every run.
- **Path loss** (`Modelo_de_canal.m`): free-space loss from MATLAB's `fspl(d, λ)` at `freq = 2.6 GHz`. Received power = `Pout − FSPL` (dBm).
- **SNR per user per RB:**
  `SNR = P_rx − (−174 + mag2db(BW)) − I`
  where `I = |N(0, FN)|` is a random interference/fading term with `FN = Qty_UE · fi`. **Interference grows with the number of users**, so adding users lowers everyone's SNR. A fresh SNR value is drawn for every user on every RB in every frame, so the channel varies quickly and independently over time and frequency.

### 2.2 Link adaptation (`CQI.m`)
The SNR is mapped onto the 4-bit CQI table (3GPP TS 36.213, CQI 1–15: QPSK → 16QAM → 64QAM), which gives `bRE = code rate × bits/symbol`. Below −6.7 dB the CQI is 0 and nothing is sent. The result is then scaled by `mag2db(BW)`, and the data carried by one RB is
`data = bRE · 84` (84 resource elements = 12 subcarriers × 7 OFDM symbols).

### 2.3 Frame structure
- `TTI = 10 ms` is a full LTE **frame**, which is the scheduling round in this model.
- RBs per frame: `RBxFrame = (BW/1 MHz) · 5 · 20`, i.e. 5 RBs per MHz × 20 slots of 0.5 ms. That gives 140, 300 and 500 RBs for 1.4, 3 and 5 MHz.
- Inside a frame, the RBs are handed out **one at a time** (loop over `k = 1:RBxFrame`). Each RB goes to exactly one user.

### 2.4 Traffic / buffer model (`buffer`)
- `1`: finite buffer. Every user has `Pkg` bits, and the run ends when all are delivered.
- `2`: dynamic. When a user finishes, a new user with `Pkg` bits arrives at a random distance.
- `3`: **dynamic with random sizes, used by `Scheduling.m`.** Each user's packet is `N(Pkg, 0.2·Pkg)` bits. When a user finishes, it is removed and a new one arrives (random distance, new random packet size). The number of active users therefore stays at `Qty_UE`, but the total number of users seen during the run grows.
- `0`: infinite (full) buffer.

For every `buffer ≠ 1` the run stops after `frames` frames (`frames = 5`, i.e. **50 ms of simulated time**).

---

## 3. The schedulers

### 3.1 Round Robin: `RR_function.m`
Users take turns in a fixed cyclic order: RB *k* goes to the next active user after the one served last, and finished users are skipped. The channel is ignored completely.
- **Expected behaviour:** very fair in RB count, but it gives RBs to users in deep fades (CQI 0) and wastes them, so throughput is moderate. When `Qty_UE` exceeds the RBs per frame, some users get nothing in a frame.

### 3.2 Best CQI (Max C/I): `BCQI_function.m`
For each RB, the scheduler picks the user with the **highest SNR on that RB**: `active_UE = argmax SNR(:,k)`. Finished users are excluded.
- **Expected behaviour:** maximum cell throughput and spectral efficiency, because every RB uses the best available modulation. Fairness is very poor: users near the gNB get almost everything and users at the cell edge are starved (high outage).

### 3.3 Blind Equal Throughput: `BET_FAST_function.m`
Picks the user with the **lowest average throughput so far**, regardless of the channel:
- `R_i(t) = a·R_i(t−1) + (1−a)·r_i`, where `r_i` is the user's accumulated bits and `a = 0.99999`.
- Metric `m_i = 1 / R_i`, and the RB goes to `argmax m_i`. Ties (for example several users who have not been served yet, `R_i = 0 → m_i = ∞`) are broken at random.
- **Expected behaviour:** the highest fairness, because it tries to equalise throughput across users. Throughput is the lowest, because users with a bad channel get as many bits as users with a good one and therefore need many more RBs.

### 3.4 Proportional Fair: `PF_FAST_function.m`
Balances channel quality against past service:
- Instantaneous achievable rate per RB: `Cap_i = BW · log2(1 + SNR_i)` (Shannon).
- Average rate: `R_i(t) = β·R_i(t−1) + (1−β)·dataRate_i` with `β = 0.5`, where `dataRate_i = bits_i / (time since user i arrived)`.
- Metric `m_i = Cap_i / R_i`, and the RB goes to `argmax m_i` (random tie-break).
- **Expected behaviour:** the middle ground. It serves users when their channel is good *relative to what they have already received*, so throughput is close to BCQI and fairness is close to BET/RR.

---

## 4. Metrics (returned by every scheduler)

| Output | Name | How it is computed | Unit |
|---|---|---|---|
| `atp` | Average cell throughput | Total bits delivered to all users / simulated time (`numTTI · TTI`) | bps |
| `FT` | Fairness | **Jain's index** over the total bits each user received: `(Σx_i)² / (N · Σx_i²)`. 1 = perfectly equal; 1/N = one user gets everything. N includes users that arrived during the run. | 0–1 |
| `Ef` | Spectral efficiency | `atp / BW` | bps/Hz |
| `delay` | Average delay | Mean of `(finish time − arrival time)` over the users that **completed** their packet. Resolution is one frame (10 ms). `Inf` if no user finished. | s |
| `outt` | Outage | For each frame, the % of users that received **0 bits** in that frame (not scheduled, or scheduled at CQI 0), averaged over frames. | % |

Note that `Ef` is just `atp` divided by a constant whenever BW is fixed, so in the user-count and packet-size sweeps the efficiency curve has exactly the same shape as the throughput curve.

---

## 5. What `Scheduling.m` does (main script)

`Scheduling.m` is the experiment driver. It does no scheduling itself: it sets up the parameters, runs three **one-at-a-time sweeps** over all four schedulers, stores the results and plots them.

### Step 1: Fixed simulation parameters
| Variable | Value | Meaning |
|---|---|---|
| `r` | 1 | Cell radius (users at 0–1 m) |
| `freq` | 2.6 GHz | Carrier frequency (LTE band 7) |
| `Pout` | 10 dBm | Transmit power |
| `TTI` | 10 ms | Scheduling round (one LTE frame) |
| `fi` | 0.1 | Interference factor, `FN = 0.1 · Qty_UE` (dB) |
| `frames` | 5 | Frames simulated per run (50 ms) |
| `buffer` | 3 | Dynamic traffic with random packet sizes |
| `rdg` | 2 | Evenly spaced initial user distances |

### Step 2: Sweep definitions and baseline
| Sweep | Values | Held fixed at |
|---|---|---|
| Number of users `Qty_UE_vec` | 50, 100, 150, 200, 250 | BW = 1.4 MHz, Pkg = 5 Mbit |
| Bandwidth `BW_values` | 1.4, 3, 5 MHz | Qty_UE = 100, Pkg = 5 Mbit |
| Packet size `Pkg_values` | 1, 5, 10 Mbit | Qty_UE = 100, BW = 1.4 MHz |

The schedulers are stored as function handles:
```matlab
algoCalls = {@RR_function, @BCQI_function, @BET_FAST_function, @PF_FAST_function};
```
so the same loop can call each one in turn.

### Step 3: Result storage
For each sweep there is one `nAlg × nPoints` matrix per metric (`ATP_*`, `FT_*`, `Ef_*`, `delay_*`, `outt_*`, with suffix `_qty`, `_bw` or `_pkg`). Row = scheduler, column = sweep value.

### Step 4: Run the three sweeps
Three nested loops (sweep value × scheduler) call `algoCalls{a}(...)` and fill the matrices. In total that is (5 + 3 + 3) × 4 = **44 independent simulations**. Each is a **single random realisation**: there is no averaging over seeds and no fixed `rng`, so the numbers change slightly from run to run.

### Step 5: Figures
`Scheduling.m` opens **seven figures**:

1. **Throughput vs Fairness, Qty_UE sweep.** One curve per scheduler, each point labelled with its user count. This is the key trade-off plot: the top-right corner is ideal, BCQI sits bottom-right (high throughput, low fairness), BET/RR sit top-left, and PF is closest to the top-right.
2. **Throughput vs Fairness, BW sweep.** Same plot, points labelled with BW in MHz.
3. **Throughput vs Fairness, Pkg sweep.** Same plot, points labelled with packet size in Mbit.
4. **Metrics vs Qty_UE** (2×2): throughput, fairness, spectral efficiency and delay against the number of users.
5. **Outage vs Qty_UE.**
6. **Metrics vs BW** (2×2, Qty_UE = 100): throughput, fairness, spectral efficiency and outage.
7. **Metrics vs packet size** (2×2, Qty_UE = 100): throughput, fairness, delay and outage.

Each scheduler function also prints its run time (`tic/toc`) and `Frames simulados` to the command window. `Frames simulados` is only printed by RR, and it actually counts **completed users**, not frames.

---

## 6. Example results and how to read them

Values from one run (`rng(1); Scheduling`) for the **user-count sweep** (BW = 1.4 MHz, Pkg = 5 Mbit):

| Qty_UE | | 50 | 100 | 150 | 200 | 250 |
|---|---|---|---|---|---|---|
| Throughput (Mbps) | RR | 702 | 598 | 524 | 436 | 384 |
| | BCQI | 803 | 803 | 803 | 803 | 803 |
| | BET | 688 | 574 | 468 | 374 | 326 |
| | PF | 771 | 749 | 714 | 658 | 577 |
| Jain fairness | RR | 0.98 | 0.94 | 0.86 | 0.77 | 0.71 |
| | BCQI | 0.16 | 0.08 | 0.06 | 0.04 | 0.04 |
| | BET | 1.00 | 0.98 | 0.96 | 0.87 | 0.85 |
| | PF | 0.92 | 0.93 | 0.93 | 0.94 | 0.93 |
| Outage (%) | RR | 0 | 0.4 | 9.3 | 36.9 | 53.6 |
| | BCQI | 83.6 | 90.9 | 92.2 | 93.3 | 94.3 |
| | BET | 10 | 32 | 48.8 | 62.7 | 68.9 |
| | PF | 0 | 0.2 | 13.7 | 34.7 | 49.3 |

How to read them:
- **BCQI** has the highest throughput, and it stays flat because every RB is used at the top CQI (there is always some user close enough to the gNB). Its fairness (~0.04–0.16) and outage (>80 %) are the worst. It is the classic throughput-maximising, unfair scheduler.
- **BET** has the best fairness and the lowest throughput, which is the expected price of equalising throughput regardless of the channel.
- **RR** sits between the two. It is fair while there are more RBs than users (140 RBs per frame at 1.4 MHz). Above roughly 140 users, some users cannot be served in a frame, so fairness falls and outage climbs (≈ 1 − 140/Qty_UE).
- **PF** gives the best balance: about 90 % of BCQI's throughput at 50 users, with fairness around 0.93 that stays flat as the load grows, and the lowest outage at low and medium load.
- **More users** → more interference (`FN ∝ Qty_UE`) → lower SNR, so throughput drops for every scheduler except BCQI.
- **More bandwidth** → more RBs per frame → throughput rises roughly in proportion and outage falls. BCQI gains the most.
- **Larger packets** barely change throughput, because in 50 ms almost no user finishes anyway. Mainly they lower BCQI's fairness, since fewer completions mean fewer new users arriving.

Treat the **absolute** values as relative scores, not real LTE figures (see §7.1). The ranking and trends between schedulers are the meaningful part.

---

## 7. Review: known issues and limitations

### 7.1 Model and scaling
1. **Data per RB is scaled by `mag2db(BW)` in `CQI.m`** (≈ 123 for 1.4 MHz). This multiplies bits per RE by about 120×, which is why the results show ~800 Mbps and ~570 bps/Hz in 1.4 MHz. Real LTE peaks at ~4–5 bps/Hz per layer. Without the factor, one RB at CQI 15 carries ≈ 466 bits.
2. **Noise power uses `mag2db(BW)` = 20·log10(BW) instead of 10·log10(BW).** The noise floor ends up ~61 dB too high. Together with the 1 m cell radius this happens to give SNRs in the CQI range, but neither value is physical on its own.
3. **RBs per frame at 1.4 MHz** are 140, but LTE has 6 RBs × 20 slots = 120. The 3 MHz and 5 MHz values (300 and 500) are correct.
4. **Simulation length is 5 frames (50 ms) with a single realisation.** With 5 Mbit packets and 1.4 MHz, almost no user can finish, so delay and completion-based effects rest on very few samples. Results also vary between runs because there is no `rng` seed and no Monte Carlo averaging.
5. In `CQI.m`, an SNR of exactly 22.7 dB returns CQI 0 because the last test uses `>` instead of `>=`. The CQI 15 comment also says "16QAM", but the code (correctly) uses 64QAM.

### 7.2 Bugs that affect the plotted metrics
1. **BET and PF delay is always 0.** In `BET_FAST_function.m` (line 107) and `PF_FAST_function.m` (line 100), `UE_tend` starts at `zeros`, whereas RR/BCQI use `Inf`. Initial users who never finish therefore get `UE_time = 0` and are averaged into the delay as 0 s. Fix: `UE_tend = Inf*ones(1, Qty_UE);`.
2. **RR delay is `Inf`** in every sweep because no RR user finishes in 50 ms. The RR curve is missing from the delay plots.
3. **BET and PF overstate outage.** RR/BCQI set `aux_data(st) = 1` for users that have already finished, so they are not counted as "received 0 bits". BET_FAST and PF_FAST leave that line out, so finished users count as outage.
4. **BET and PF reset every user's history whenever someone finishes.** On each arrival, `Ri = ones(Qty_UE,1)*mean(Ri)` (and, for BET, `BET_metric = ones*mean(...)`) overwrite all users' averages with the mean. Every completion erases the fairness memory, and the next decisions become random tie-breaks.
5. **The "Round Robin warm-up" in PF_FAST is dead code.** It checks `numTTI == 0`, but `numTTI` has already been incremented to 1 before the RB loop. (It also checks for `-999`, while PF marks finished users with `999`.)

### 7.3 Minor / code quality
- `length(active_UE>1)` in BET/PF should be `length(active_UE) > 1`. It works by accident, because `randi(1)` returns 1.
- `UE_tp(active_UE) = UE_tp(Active_QtyUE) + ...` uses the wrong index. It is harmless because `UE_tp` is recomputed later and is not an output.
- The functions inside `RR_function.m`, `BCQI_function.m`, `BET_FAST_function.m` and `PF_FAST_function.m` are named `RR`, `BCQI`, `BET_FAST` and `PF`. MATLAB uses the file name, so they work, but the mismatch triggers a Code Analyzer warning.
- `Scheduling.m` starts with `clear all`, which also clears breakpoints and cached functions. `clear` or `clearvars` is enough.
- `TTI` actually holds the frame duration (10 ms). An LTE TTI is 1 ms.
- The Jain fairness index includes users that arrived late and had little time to be served, which lowers fairness for schedulers that complete users quickly (mainly BCQI).

---

## 8. How to run

1. Open MATLAB in this folder.
2. Run `Scheduling` (it needs a toolbox that provides `fspl` and `physconst`, such as the Phased Array System Toolbox).
3. Seven figures open. To make results reproducible, add `rng(<seed>)` at the top of `Scheduling.m`.
