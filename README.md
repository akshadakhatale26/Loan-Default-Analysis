# Loan Default Analysis | SQL Server & Power BI

## 📌 Project Overview

The Loan Default Analysis project focuses on analyzing banking and loan repayment data to identify default patterns, evaluate borrower risk, and assess loan portfolio performance. Using SQL Server and Power BI, the project transforms loan, customer, and repayment data into meaningful insights to support credit risk monitoring and better lending decisions.

## 🎯 Project Objectives

- Analyze loan applications, approvals, and funded amounts.
- Identify loan default patterns and default rates.
- Evaluate borrower risk based on income, credit score, DTI, and LTV ratios.
- Analyze repayment behaviour and payment delays.
- Identify high-risk loan categories and customer segments.
- Understand monthly and yearly default trends.

## 🛠️ Tools & Technologies

- **SQL Server:** Data extraction, joins, aggregations, CTEs, subqueries, and 40 analytical business questions.
- **Power BI:** Data modeling, DAX measures, KPI cards, and interactive dashboards.

## 📂 Dataset

The project uses a synthetic Banking Analytics & Loan Risk dataset.

Main tables:

- `Dim_Customer` – Customer demographics, income, and credit information.
- `Fact_Loan` – Loan applications, approvals, funding, and default information.
- `Fact_Loan_Payment` – Loan repayment and payment transaction details.

Additional dimension tables support data modeling and analysis.

## 🔍 Project Workflow

1. **Data Understanding:** Explored the dataset, tables, columns, and relationships.
2. **Data Extraction:** Retrieved relevant information using SQL queries and joins.
3. **SQL Analysis:** Analyzed loan portfolio performance, default patterns, customer risk, and repayment trends through 41 analytical questions.
4. **Data Modeling:** Implemented dimensional modeling using a Star Schema approach in Power BI.
5. **DAX Calculations:** Developed measures for loan KPIs, default rates, funded exposure, and repayment analysis.
6. **Dashboard Development:** Created an interactive four-page Power BI dashboard with KPI cards, charts, filters, and trend analysis.

## 📊 Power BI Dashboard

The dashboard consists of four pages:

- **Front Page:** Project introduction and dashboard navigation.
- **Loan Portfolio Overview:** Total loans, approved loans, approval rate, average loan amount, and active loans.
- **Loan Default & Risk Analysis:** Funded loans, defaulted loans, default rate, defaulted funded amount, and high-risk loans.
- **Loan Repayment & Delinquency Analysis:** Total payments, on-time payments, late payments, and average late days.

## 📈 Key Business Insights

- High-risk customers recorded the highest default rate of **11.46%**.
- Customers with high DTI ratios recorded an **8.44%** default rate.
- Gold loans recorded the highest default rate among loan types at **3.68%**.
- Defaulters had an average repayment delay of **18 days**.
- 2025 recorded the highest annual default rate of **3.26%**.
- January 2024 recorded the highest monthly default rate of **5.72%**.

## 💡 Business Value

The analysis helps identify potential risk indicators, monitor loan portfolio performance, understand customer repayment behaviour, and recommend improvements in credit assessment and early warning systems.

## ⚠️ Disclaimer

This project uses synthetic educational data and does not contain actual customer or banking records. The findings represent descriptive analysis and are intended for learning and portfolio demonstration purposes only.
