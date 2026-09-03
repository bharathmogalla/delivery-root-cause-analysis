Case Study Write-Up

Create this as a Word doc, PDF, or even a simple text file in your project folder. Use this exact structure with your real numbers:

Title: Delivery Root-Cause Analysis: Olist Brazilian E-Commerce

Problem: Olist needed to understand where and why delivery failures occur, to prioritize operational fixes.

Method: Analyzed 96,478 delivered orders using SQL Server (root-cause segmentation) and Power BI (visualization + AI-driven pattern detection via Key Influencers, Decomposition Tree, and Anomaly Detection).

Key Findings (write these as bullet points):

Only 6.8% of orders (6,534) arrived late overall, but the average delay was -11 days, revealing that delivery estimates are heavily padded — the true on-time performance is likely overstated.
Late orders split into two distinct problems: mild delays (56% under 7 days) vs. a smaller but severe group — 345 orders (5.3%) delayed 30+ days.
Raw volume initially suggested SP had the most delays (1,820), but this was a population-size effect, not a severity signal.
Testing severity specifically revealed extreme (30+ day) failures concentrate in RJ (135) and SP (65) — Brazil's highest-volume commercial hubs, not remote/distant regions as initially hypothesized.
Extreme delays cluster sharply in a Nov 2017–Feb 2018 window (peaking Feb 2018), aligning with Black Friday/Christmas peak demand — confirmed independently by Power BI's Anomaly Detection, which flagged Feb 28, 2018 as a statistical anomaly.
Power BI's Key Influencers AI feature found customers in CE state face a 5.36x higher likelihood of extreme delay, and orders placed in November face a 1.63x higher likelihood — both independent of the raw volume findings.

Recommendation: Prioritize temporary carrier/fulfillment capacity increases in RJ and SP specifically during Nov–Feb, rather than broad year-round logistics investment. Separately investigate CE-specific delivery infrastructure given its disproportionate risk.

Tools used: SQL Server, Power BI (DAX, Key Influencers, Decomposition Tree, Anomaly Detection)

