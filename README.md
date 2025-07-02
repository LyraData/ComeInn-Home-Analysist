# 🏠 Comeinn Home Analyst

---

## 📌 1. Introduction and Project Context

Comeinn is a small-scale hostel system serving long-term and short-term tenants, primarily students. The Comeinn Home Analyst project was undertaken to address manual management issues, lack of systemization, and to optimize business operations.

### 🔍 Problems to Address

- Inefficient data management: Customer, service, and invoice data scattered across multiple Excel files, leading to errors and time loss.  
- Lack of analytics tools: No system to filter or analyze customer, service, or revenue data over time.  
- Difficulty predicting customer behavior: Unclear which customers will renew contracts after expiration.  

### 🎯 Analysis Objectives

- Clean and standardize data: Create a unified data system from disparate Excel files.  
- Design customer ID coding: Facilitate easy lookup and filtering.  
- Build Excel/Power BI dashboard: Support customer and service queries and provide operational insights.  
- SQL queries: Generate statistics on total customers, revenue, renewal rates, vacant rooms, etc.  
- Predict customer behavior: Use Machine Learning (Random Forest, Logistic Regression) to forecast contract renewals or churn.  

![Flowchart](https://github.com/LyraData/ComeInn-Home-Analysist/blob/main/FLOWCHART.png)

---

## 📂 2. Data Description

- **BRANCHES**: Includes BranchID, Name, Address; used to manage branch information.  
- **ROOMS**: Includes RoomID, BranchID, RoomNumber, BedCount, Area, RoomType, RoomGender, Amenities; used to manage rooms and amenities.  
- **BEDS**: Includes BedID, RoomID, Position, BedNo; used to manage beds within rooms.  
- **CUSTOMERS**: Includes CustomerID, FullName, DateOfBirth, Gender, IdentityNumber, PhoneNumber, Address, Email, VehiclePlateType, VehicleType, AppRegistered, TemporaryResidenceRegistered, TempResidenceExpiryDate, Age, AgeGroup; used to store customer information.  
- **CONTRACTS**: Includes ID, CustomerID, BedID, StartDate, EndDate, CheckoutDate, Status, IsRenewal, ContractLength; used to manage rental contracts.  
- **PRICE**: Includes PriceID, BedID, Price, ElectricityPrice_per_kWh, WaterPrice_per_person, ParkingFee_per_vehicle; used to manage room pricing and service fees.  

---

## ⚙️ 3. Project Implementation Steps

### 🔹 Step 1: Data Cleaning and Standardization (Python)
- **Objective**: Standardize data from `combined_customers.csv` (238 records).  
- **Tools**: Python (Pandas, NumPy, Seaborn, Matplotlib), Jupyter Notebook.  
- **Results**: Cleaned data, age analysis (56% aged 18–24), app registration status (58% unregistered), age group distribution visualized via bar charts.

### 🔹 Step 2: SQL Queries for Data Analysis (T-SQL)
- **Objective**: Extract detailed insights for management decision-making.  
- **Tools**: SQL (JOIN, CTE, Window Functions).  
- **Results**: 50+ queries for revenue analysis, loyal customer identification, vacancy rates, and anomaly detection.

### 🔹 Step 3: Power BI Dashboard
- **Objective**: Visualize revenue, customer, and operational performance.  
- **Results**: 4B VND revenue, 78% occupancy rate, dormitories (KTX) contribute 66.2% of revenue, identified high/low demand seasons and high-churn branch.

### 🔹 Step 4: Machine Learning Analysis
- **Objective**: Predict churn, segment customers, analyze time-to-churn and pricing.  
- **Results**:  
  - **Churn Prediction**: ROC AUC 0.78, key factor (ActualStayDays).  
  - **Segmentation**: 3 clusters (loyal females, new customers, high-income males).  
  - **Time-to-Churn**: Long contracts and renewals reduce churn risk.  
  - **Time Series**: Prices fluctuate by day/week.  
  - **Amenity Recommendation**: Personalized amenity suggestions.  
  - **A/B Testing**: 5–10% price increase does not affect renewal rates.

### 🔹 Step 5: Flask API Deployment
- **Objective**: Predict churn and recommend suitable rooms.  
- **Results**: API with 70–80% accuracy, automates churn prediction and room allocation.

---

## 🧭 4. Strategic Actions

1. **Stabilize Seasonal Revenue**: Offer summer discounts, boost marketing in peak months, and forecast Q3 revenue.  
2. **Reduce Churn**: Send payment reminders, offer installments to young tenants, and collect exit feedback.  
3. **Optimize Rooms & Amenities**: Expand KTX rooms and upgrade Wi-Fi and water quality.  
4. **Increase Contract Value**: Provide 6-month contracts with free amenities and launch a loyalty program.  
5. **Data Management**: Update dashboards monthly and forecast churn 30 days ahead.  

---

## 📊 5. Results and Conclusion

The **Comeinn Home Analyst** project achieved significant outcomes:

- ✅ **Management Efficiency**: Consolidated data across systems and reduced manual errors.  
- 📈 **Decision Support**: Built dashboards and SQL queries to generate actionable insights.  
- 🧠 **Behavior Prediction**: Applied machine learning to identify at-risk customers proactively.  
- 💰 **Revenue Growth**: Increased contract value and occupancy; KTX contributed 66.2% of revenue.  
- 🤖 **Automation**: Deployed a Flask API to automate personalized recommendations.

> Overall, the project resolved manual management issues, delivered a unified data system, and leveraged modern technologies (SQL, Python, Power BI, Machine Learning, Flask API) to optimize operations.  
> Proposed strategies reduced churn, boosted revenue, and improved customer experience, especially for 18–24-year-old students.  
> The solution is **scalable**, with potential to integrate customer feedback and expand long-term forecasting capabilities.

---

