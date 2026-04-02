📊 D2C Ecommerce Funnel Analysis
Data Source: Direct-to-Consumer E-Commerce Funnel Dataset
Link: [(https://www.kaggle.com/datasets/yashch05/direct-to-consumer-e-commerce-funnel-dataset)] 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
📝 Project Overview
This project focuses on analyzing a large-scale dataset of 120,000 user sessions from a Direct-to-Consumer (D2C) e-commerce platform. By leveraging SQL Server for heavy data lifting and Python (Plotly) for advanced visualization, this analysis identifies critical friction points in the customer journey and quantifies revenue leakage to drive data-backed business decisions.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
❓ Business Problem
The platform experiences high traffic volumes but suboptimal conversion rates. The primary goal is to answer:

Where exactly do users drop off in the 5-stage funnel?

Which marketing channels and devices are underperforming?

What is the economic impact of "cart abandonment"?

How does the behavior of New users differ from Returning users?
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
🛠️ Technical Stack & Methodology
To handle the scale of 120,000 user sessions, I implemented a robust data pipeline that bridges the heavy-lifting power of SQL with the advanced visualization capabilities of Python:

Database Management: Microsoft SQL Server (SSMS)
Acting as the backbone of the project, SQL Server was used to manage the large-scale dataset. I designed staging tables to ingest raw data and optimized table schemas to ensure high-performance querying and data integrity.

Data Processing & Logic: T-SQL (Transact-SQL)
I utilized T-SQL for "heavy lifting" tasks, including deep data cleaning, session-level deduplication, and funnel logic auditing. By leveraging advanced techniques such as Common Table Expressions (CTEs) and Window Functions, I ensured that the calculation of core business KPIs (CR, AOV, and Revenue Leakage) remained transparent and mathematically accurate.

Interactive Visualization: Python & Plotly Library
If SQL is the "brain," Python is the "face" of this project. I employed the Plotly library to build high-fidelity, interactive dashboards. The highlight is the Sankey Diagram, which visualizes complex traffic flows, and the Funnel Chart, which instantly identifies friction points and conversion bottlenecks.

Execution Environment: Google Colab
Google Colab was chosen for cloud-based execution, providing a portable and shareable environment. This allows for seamless presentation of interactive charts to stakeholders without the need for complex local installations.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
📂 Project Structure
The repository is organized into a clear data pipeline:

sql_scripts/01_setup_and_staging.sql: Database initialization and raw data ingestion.

sql_scripts/02_cleaning.sql: Deep cleaning, removing duplicates, and fixing funnel logic anomalies (e.g., purchases without product views).

sql_scripts/03_general_funnel_metrics.sql: Calculation of baseline KPIs (CR, AOV) and Revenue Leakage estimation.

sql_scripts/04_advanced_deepDive_views.sql: 7 Specialized views for multi-dimensional analysis (Channel, Device, User Type).

notebooks/06_visual_report.ipynb: Python code for generating the interactive Funnel and Sankey dashboards.

data/: Optimized dataset (~12MB) containing 120k records.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
💡 Key Insights (Data-Driven Findings)
Based on the analysis of 120,000 records:

The Retention Powerhouse: Returning users have a 20.62% conversion rate, nearly 4x higher than new users (5.42%). They also spend significantly more (AOV of $4,494 vs $2,598).

Top-of-Funnel Leakage: We are losing $192M in potential revenue at the very first stage (Visit -> View). The "Upper Funnel" is where the most significant drop-off occurs.

Mobile Ad Friction: Paid Ads on Mobile devices contribute to a 12.56% bounce rate, indicating poor mobile landing page optimization or ad-to-content mismatch.

Discount Sensitivity: Applying a discount boosts the conversion rate to a staggering 87.02%, compared to only 7.87% for non-discounted sessions.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
🚀 Strategic Recommendations
To translate the diagnostic insights into actionable business strategies, I propose the following initiatives:

Fixing the Top-of-Funnel (Curing the $192M Leak): Launch aggressive A/B testing on the Home/Landing pages. Optimize page load speeds, declutter the UI, and implement high-contrast, above-the-fold Call-to-Action (CTA) buttons to immediately drive 'Visitors' into product catalogs.

Mobile-First Ad Overhaul: Audit current Paid Ad campaigns targeting mobile devices. Ensure mobile landing pages are fully responsive and strictly align with the ad's promised product/offer to prevent the current 12.56% immediate bounce rate.

Capitalizing on Returning Users (Loyalty Loop): Shift 30% of the top-of-funnel acquisition budget into retention and retargeting marketing. Implement a VIP Tier or Loyalty Points program to heavily incentivize first-time buyers to return.

Strategic Discount Deployment (Dynamic Pricing): Transition from blanket discounts to an "Exit-Intent" discount strategy. Deploy automated pop-ups offering a 5-10% promo code strictly when a user shows exit-intent behavior during the 'Checkout' phase to recover abandoned carts without cannibalizing baseline profit margins.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
📈 Visualizations
Conversion Funnel (Survival Rate)
The funnel reveals a massive 42% drop-off immediately after landing, pointing to a "Home Page/Landing Page" friction issue.

Behavioral Sankey Diagram (Traffic Flows)
This diagram visualizes how traffic from Paid Ads and Social flows through Mobile/Desktop and where it ultimately terminates, highlighting "Bounced" sessions as the primary leak.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
⚙️ How to Run This Project
Database Setup: Execute 01_setup_and_staging.sql in your SQL Server instance and import the provided dataset.

Data Processing: Run scripts 02 through 04 in sequence to clean the data and generate the analytical views.

Visualization: Open the .ipynb file in Google Colab, input the summary statistics from your SQL results, and run the cells to generate the interactive dashboard.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
🤝 Contact
Author: Trần Cao Quỳnh Như
Email: trancaoquynhnhucmg@gmail.com
