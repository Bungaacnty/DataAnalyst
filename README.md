# A/B Testing – Mobile Experience Conversion Optimization

## 1. Business Problem

The Product team wants to evaluate whether a new mobile experience can improve user conversion.
The experiment focuses on **mobile users** and compares a **Treatment group** that receives the new experience against a **Control group** that continues to use the existing experience.
The main business question is:
> **Does the new mobile experience generate a statistically significant improvement in conversion while maintaining or improving revenue performance?**
---

## 2. Dataset
The analysis uses an e-commerce event-level dataset covering the **2020–2025** analysis period.

### Key Event Types
* `page_view` – User views a page
* `add_to_cart` – User adds a product to cart
* `checkout` – User proceeds to checkout
* `purchase` – User completes a purchase

### Relevant Attributes
* `customer_id`
* `session_id`
* `event_type`
* `device`
* `payment/revenue information`
* `marketing_opt_in`
* `experiment/group assignment`
* Transaction-related attributes

The analysis focuses specifically on users who meet the experiment eligibility criteria.

---

## 3. Experiment Design
The experiment uses an **A/B testing framework**.

### Eligibility Criteria
Users included in the experiment must:

1. Be **mobile users**
2. Have at least **2 sessions**
3. Be within the analysis period **2020–2025**
4. Have `marketing_opt_in = TRUE`
5. Have total mobile transactions greater than **$10**

### Experimental Groups

| Group     | Description                                     |
| --------- | ----------------------------------------------- |
| Treatment | Users exposed to the new mobile experience      |
| Control   | Users exposed to the existing mobile experience |

The treatment and control groups are evaluated using the same observation period and eligibility criteria.

---

## 4. Data Preparation

The following data preparation steps were performed before statistical analysis:

1. Filtered the dataset to eligible mobile users.
2. Restricted observations to the defined analysis period.
3. Removed invalid or incomplete records where necessary.
4. Identified unique users and sessions using `customer_id` and `session_id`.
5. Classified users into Treatment and Control groups.
6. Aggregated event-level data into session- and user-level metrics.
7. Identified sessions containing a purchase event.
8. Aggregated transaction values for revenue-related metrics.
9. Calculated conversion and revenue KPIs for each experiment group.
10. Validated the resulting datasets before hypothesis testing.

---

## 5. KPI Definition

### Primary KPI: Conversion Rate (CVR)

Conversion Rate measures the proportion of page-view sessions that resulted in a purchase.

$$
CVR = \frac{Purchase\ Sessions}{Page\ View\ Sessions}
$$

The primary KPI is used to determine whether the new mobile experience improves conversion.

### Supporting KPIs

#### Add-to-Cart Rate

$$
Add\text{-}to\text{-}Cart\ Rate =
\frac{Add\text{-}to\text{-}Cart\ Sessions}
{Page\ View\ Sessions}
$$

Measures the proportion of sessions that resulted in users adding products to their cart.

#### Checkout Rate

$$
Checkout\ Rate =
\frac{Checkout\ Sessions}
{Page\ View\ Sessions}
$$

Measures the proportion of sessions reaching checkout.

#### Average Order Value (AOV)

$$
AOV = \frac{Total\ Revenue}{Total\ Orders}
$$

Measures the average monetary value of each completed order.

#### Revenue per User

$$
Revenue\ per\ User =
\frac{Total\ Revenue}{Unique\ Users}
$$

Measures the average revenue generated per user.

---

## 6. Statistical Methodology

### Conversion Rate – One-Tailed Two-Proportion Z-Test

A **two-proportion z-test** was used to compare conversion rates between Treatment and Control.

The test uses a **10% significance level ($\alpha = 0.10$)**.

### Hypotheses

**Null hypothesis ($H_0$):**

$$
p_{Treatment} \leq p_{Control}
$$

**Alternative hypothesis ($H_1$):**

$$
p_{Treatment} > p_{Control}
$$

The test is **one-tailed** because the business objective is specifically to determine whether the new experience improves conversion.

The Treatment is considered statistically significant if:

$$
p\text{-value} < 0.10
$$

### Revenue Metrics – Welch's T-Test

For revenue-related metrics such as AOV, **Welch's independent two-sample t-test** is used because transaction values may have different variances between groups.

This evaluates whether the difference in average revenue metrics is statistically significant without assuming equal variances.

---

## 7. Results

### Conversion Rate

The experiment produced the following results:

| Group         | Page View Sessions | Purchase Sessions |    CVR |
| ------------- | -----------------: | ----------------: | -----: |
| Treatment (B) |             21,289 |             7,374 | 34.64% |
| Control (A)   |             21,237 |             7,190 | 33.86% |

The Treatment group achieved a higher conversion rate than the Control group.

The difference is approximately:

* **Absolute uplift:** +0.78 percentage points
* **Relative uplift:** +2.31%

The one-tailed two-proportion z-test produced a statistically significant result at the **10% significance level**.

Therefore, the experiment provides evidence that the new mobile experience improves conversion.

### AOV

The observed AOV was approximately:

| Group     |    AOV |
| --------- | -----: |
| Treatment | 135.55 |
| Control   | 135.25 |

Although Treatment generated a slightly higher AOV, the difference should be evaluated using the Welch's t-test before concluding that the increase is statistically meaningful.

Overall, the experiment's strongest evidence is the improvement in **conversion rate**.

---

## 8. Segment Analysis

Segment analysis is performed to determine whether the treatment effect is consistent across different user groups.

Potential segmentation dimensions include:

* User engagement
* Number of sessions
* Customer characteristics
* Traffic or acquisition source
* Purchase behavior
* User activity level

For each segment, the analysis compares:

1. Treatment CVR
2. Control CVR
3. Absolute uplift
4. Relative uplift
5. Statistical significance

This helps identify whether the new mobile experience is particularly effective for specific customer segments.

Segment analysis should be interpreted carefully because smaller segments have lower statistical power and may produce unstable estimates.

---

## 9. Business Impact

The new mobile experience demonstrates a positive impact on the primary business objective: **conversion**.

The observed CVR increased from approximately **33.86% to 34.64%**, representing a **0.78 percentage-point absolute improvement** or approximately **2.31% relative uplift**.

From a business perspective, even a relatively small conversion-rate improvement can generate meaningful additional purchases when applied to a large volume of mobile traffic.

The impact can be translated into incremental purchases using:

$$
Incremental\ Purchases =
Eligible\ Traffic \times CVR_{Treatment}
-
Eligible\ Traffic \times CVR_{Control}
$$

Potential incremental revenue can then be estimated as:

$$
Incremental\ Revenue =
Incremental\ Purchases \times AOV
$$

This provides a framework for translating the statistical experiment result into an estimated financial impact.

---

## 10. Recommendation

Based on the experiment results, the new mobile experience is recommended for **further rollout** because:

* Treatment achieved a higher conversion rate than Control.
* The observed improvement was approximately **2.31% relative uplift**.
* The conversion improvement was statistically significant at the **10% significance level**.
* AOV remained broadly comparable between the two groups.
* The treatment therefore appears to improve conversion without a clear negative impact on order value.

### Recommended Next Steps

1. Gradually roll out the new mobile experience.
2. Monitor CVR and revenue metrics after deployment.
3. Continue monitoring AOV and Revenue per User to ensure conversion gains translate into business value.
4. Monitor segment-level performance to identify users who benefit most from the new experience.
5. Conduct a longer-term experiment if additional data becomes available.

---

## 11. Tech Stack

### Data Analysis

* **SQL** – Data extraction, filtering, transformation, and aggregation
* **Python** – Statistical analysis and data processing
* **Pandas** – Data manipulation
* **NumPy** – Numerical computation
* **SciPy** – Statistical testing

### Database / Query Engine

* **DuckDB / SQL environment** – Analytical querying and data preparation

---

## Project Structure

```text
.
├── data/
│   └── dataset.csv
├── sql/
│   └── analysis.sql
├── notebooks/
│   └── ab_testing_analysis.ipynb
├── presentation/
│   └── experiment_results.pptx
├── README.md
└── requirements.txt
```

---

## Conclusion

The A/B test indicates that the **new mobile experience can improve conversion**.

Treatment achieved a CVR of approximately **34.64%**, compared with **33.86%** for Control, resulting in a **+0.78 percentage-point absolute uplift** and **+2.31% relative uplift**.

The statistically significant improvement supports moving forward with a controlled rollout while continuing to monitor **AOV, Revenue per User, and segment-level performance** to ensure that the conversion improvement translates into sustainable business value.
