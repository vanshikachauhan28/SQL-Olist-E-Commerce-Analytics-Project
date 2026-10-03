# Key Findings

Analysis window: **Jan 2017 – Aug 2018** (earlier and later months in the dataset are incomplete and distort trends).

## 1. Delivery performance
- **8.11%** of orders were delivered late.
- Late orders had an average review score of **2**, versus **4** for on-time orders.
- Takeaway: delivery delays are directly linked to customer dissatisfaction.

## 2. Customer retention
- Only **2,997 customers (~3%)** placed more than one order.
- `customer_id` is unique per order, so `customer_unique_id` was used to identify repeat customers.
- Takeaway: Olist has a very low repeat-purchase rate. Most customers buy once.

## 3. Regional order value
- Northern and remote states have the **highest** average order value.
- São Paulo (SP) has the **lowest**.
- Takeaway: customers in distant regions tend to spend more per order.

## 4. Sales trends
- Month-over-month growth was calculated with `LAG()`.
- Sep–Dec 2016 and Sep–Oct 2018 showed extreme, misleading growth rates because those months are incomplete.
- Takeaway: trend analysis should be limited to Jan 2017 – Aug 2018.

## 5. Payments
- Payment type distribution and installment behavior (min, max, average, single vs multi-installment) were analyzed.
- 2 rows with zero installments were found and documented as anomalies.

## 6. Data quality issues found and fixed
| Issue | Count | Fix |
|---|---|---|
| Orders with impossible date sequences | 166 | Flagged with CASE WHEN |
| "Delivered" orders with no delivery timestamp | 8 | Identified and documented |
| Products with empty category names | 610 | Set to `missing_category` |
| Missing category translations | 2 | Inserted manually |
| Encoding corruption in geolocation | n/a | Re-imported with Code Page 65001 |

## 7. Indexing and performance
Measured with `SET STATISTICS IO`:

| Query type | Logical reads before | After index |
|---|---|---|
| Point lookup by `customer_id` | 2,391 | 6 (~400x faster) |
| Full-table aggregate (late-delivery %) | 2,391 | 2,391 (no change) |

Takeaway: indexes speed up selective lookups but not full-table scans, since every row must be read anyway.
