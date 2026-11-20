Create Database Loan_Defaulters_Analysis
select * from Fact_loan

select sum(count_id)as Total_Records from (
                     select count(loan_id)count_id from fact_loan
                     )fact

select distinct(count(loan_id))as Total_Records from fact_loan
select top 10 * from Fact_loan

--1	How many total loans are recorded, and how many unique loans exist?	
select count(distinct loan_id) as Unique_Loan_Records,
       count(loan_id) as Total_Records
from fact_loan


--2	How many loans are approved, rejected, and Under Review?	
select distinct application_status from Fact_Loan

select Application_Status,
       count(Loan_id)as Loan_Status_count
from fact_loan
group by Application_Status


--3	What is the total requested amount versus the total funded amount?
select sum(cast(Requested_Amount as Bigint))as Total_Requested_Amount,
       sum(cast(funded_Amount as Bigint)) as Total_Funded_Amount,
       sum(cast(Requested_Amount as bigint)) - sum(cast(Funded_amount as bigint)) as Funding_Gap
from fact_loan

--4	How many loans are classified as defaults versus non-defaults?	
select default_flag,
       count(*)as Default_count
from fact_loan
group by default_flag

--5	What is the overall default rate among funded loans?
select count(case
             when default_flag = 1 and funded_Amount > 0 then loan_id
             end)* 100.0 /
       nullif(
       count(case
             when funded_Amount > 0 then loan_id 
            end),
            0
            )as defaulter_Rate_Percentage
from fact_loan
            
--6	What is the distribution of loans by loan_status and Risk_rating?
select loan_status,
       risk_rating,
       count(loan_id)as Loan_count
from fact_loan 
group by Loan_Status,
         Risk_Rating
order by count(loan_id) desc

--7	Which loan_type has the highest default rate?
select loan_type,
       round(count(case
             when default_flag = 1 then loan_id 
             end)*100.0/
             count(loan_id),2) as Default_Rate
from Fact_Loan
group by loan_type
order by Default_Rate desc

--8 How does default rate vary across Risk_rating categories?
select Risk_Rating,
       round(count(case
              when default_flag = 1 then loan_id 
              end)*100.0/
        count(loan_id),2) as Default_rate
from fact_loan
group by Risk_Rating
order by Default_rate desc


--9	Do loans with higher interest_rate have higher default rates?
select interest_Rate,
       round(count(case
             when default_flag = 1 then loan_id 
             end)*100.0/
        nullif(count(loan_id),0),2) as Default_Rate
from Fact_loan
group by Interest_Rate
order by Interest_Rate desc,
         Default_Rate desc

--10 How does tenure_months relate to default rates?
select Tenure_months,
       count(case
             when default_flag = 1 then loan_id
             end) as Default_loan,
       count(loan_id) as  Total_loans,
       count(case
                   when default_flag = 1 then loan_id
                   end)*100/
              nullif(count(loan_id),0) as Default_rate
from Fact_Loan
group by Tenure_Months
order by Tenure_Months desc

--11 Are higher EMI amounts associated with higher default rates?	
select EMI,
       count(case
             when default_flag = 1 then loan_id
             end)*100.0/
        nullif(count(loan_id),0) as Default_Rate
from Fact_Loan
group by EMI
order by EMI Desc,
         Default_rate Desc

--12 Do loans with higher DTI_ratio have higher default rates?	
select 
       case 
           when DTI_Ratio < 30.0 then 'Low DTI'
           when DTI_Ratio <= 50.0 then 'Medium DTI'
           Else 'High DTI'
       end as DTI_Category,
       count(case
             when default_flag = 1 then loan_id end)as Defautl_loans,
       count(loan_id) as Total_loans,
       count(case
              when default_flag = 1 then loan_id
              end)*100.0/
        nullif(count(loan_id),0) as Default_rate
from fact_loan
Group by case 
           when DTI_Ratio < 30.0 then 'Low DTI'
           when DTI_Ratio <= 50.0 then 'Medium DTI'
           Else 'High DTI'
       end

--13 How does LTV_ratio relate to default rates?
select case
       when LTV_ratio < 30.0 then 'Low LTV'
       when LTV_ratio <= 50.0 then 'Medium LTV'
       else 'High LTV'
       end as LTV_Category,
       count(case
             when default_flag = 1 then loan_id
             end)*100.0/
        count(loan_id) as Default_rate
from Fact_loan
group by case
       when LTV_ratio < 30.0 then 'Low LTV'
       when LTV_ratio <= 50.0 then 'Medium LTV'
       else 'High LTV'
       end

--14 Do larger funded loans have higher default rates or defaulted exposure?	
select top 10 * from Fact_Loan
select case 
       when Funded_Amount >= 500000 then 'High'
       when Funded_Amount < 500000 then 'Medium'
       when Funded_Amount < 200000 then 'Low'
       end as Fund_Category,
       count(case
                  when default_flag = 1 then loan_id
                  end)*100.0/
           count(loan_id) as Default_Rate
from Fact_Loan
group by case 
       when Funded_Amount >= 500000 then 'High'
       when Funded_Amount < 500000 then 'Medium'
       when Funded_Amount < 200000 then 'Low'
       end

--15 Are partially funded loans associated with different default outcomes?
Select
    Case
        When Funded_Amount < Requested_Amount Then 'Partially Funded'
        When Funded_Amount = Requested_Amount Then 'Fully Funded'
        Else 'Check Funding Data'
    end as Funding_Category,

    Count(loan_id) AS Total_Loans,

    Count(Case
        When default_flag = 1 Then loan_id
    end) as Defaulted_Loans,

    Round(
        Count(Case
            When default_flag = 1 Then loan_id
        End) * 100.0
        / Count(loan_id),
        2
    ) AS Default_Rate

From Fact_Loan
Where Funded_Amount > 0
Group by
    Case
        When Funded_Amount < Requested_Amount Then 'Partially Funded'
        When Funded_Amount = Requested_Amount Then 'Fully Funded'
        Else 'Check Funding Data'
    end
Order by Default_Rate Desc;


--16 Do customers with lower income have higher loan default rates?
select top 10 * from Dim_Customer

select  case 
       when c.Annual_Income <= 250000 then 'Low Income'
       when c.Annual_income <= 500000 then 'Medium Income'
       else 'High Income'
       end as Income_category,
      count(case
            when l.default_flag = 1 then l.loan_id
            end)*100.0/
            count(loan_id) as  Default_Rate
from Dim_Customer c left join 
     Fact_Loan l on c.Customer_ID = l.Customer_ID
group by case 
       when c.Annual_Income <= 250000 then 'Low Income'
       when c.Annual_income <= 500000 then 'Medium Income'
       else 'High Income'
       end

--17 How does default rate vary by credit score or credit rating?
select case 
       when c.Credit_Score >= 700 then 'High'
       when c.Credit_Score >= 601 then 'Medium'
       else 'Low'
       end as Credit_Score_Category,
       count(case
             when l.Default_Flag = 1 then l.Loan_ID
             end)*100.0/
       count(l.loan_id) as Default_rate            
from Dim_Customer c left join
Fact_Loan l on c.Customer_ID = l.Customer_ID
group by case 
       when c.Credit_Score >= 700 then 'High'
       when c.Credit_Score >= 601 then 'Medium'
       else 'Low'
       end

--18 Are default rates different across customer age groups?
select case 
    when c.Age is null then 'Unknown'
    when c.Age <= 30 then 'Young'
    when c.Age <= 45 then 'Adult'
    when c.Age <=60 then 'Middle Age'
    Else 'Senior'
end as Age_Category,
count(case
          when l.Default_Flag = 1 then l.Loan_ID
          end)*100.0/
     count(l.Loan_ID) as Default_Rate
from Dim_Customer c left join 
Fact_Loan l on c.Customer_ID = l.Customer_ID
group by case 
     when c.Age is null then 'Unknown'
    when c.Age <= 30 then 'Young'
    when c.Age <= 45 then 'Adult'
    when c.Age <=60 then 'Middle Age'
    Else 'Senior'
    end
order by Default_Rate desc

--19 Does employment type relate to default rates?
Select c.Employment_Type,
       count(case
             when l.Default_Flag = 1 then l.Loan_ID
             end)as Default_Loans,
        count(l.Loan_ID) as Total_Loans,
        count(case 
              when l.Default_Flag = 1 then l.Loan_ID
              end)*100.0/
        count(l.Loan_ID) as Default_Rate
from Dim_Customer c Left Join 
Fact_Loan l on c.Customer_ID = l.Customer_ID 
group by c.Employment_Type
order by Default_Rate desc

--20 How do default rates vary by customer location?
select c.State,
       c.City,
       count(case
             when l.Default_Flag = 1 then l.Loan_ID
             end)as Default_Loans,
        count(l.Loan_ID) as Total_Loans,
        count(case 
              when l.Default_Flag = 1 then l.Loan_ID
              end)*100.0/
        count(l.Loan_ID) as Default_Rate
from Dim_Customer c Left Join
Fact_Loan l on c.Customer_ID = l.Customer_ID 
group by c.State,
         c.City
order by Default_Rate desc

--21 Do customers with multiple loans have higher default rates?
select c.Customer_ID,
       count(l.loan_id) as Total_Laons,
       count(case
             when l.default_flag = 1 then l.loan_id
             end)*100.0/
        count(l.loan_id) as Default_Rate
from Dim_Customer c Left join
Fact_Loan l on c.Customer_ID = l.Customer_ID
group by c.Customer_id
having count(l.loan_id) > 1
order by Total_Laons desc

--22 Are customers with a high DTI ratio and low income more likely to default?
Select case 
           when l.DTI_Ratio < 30.0 then 'Low DTI'
           when l.DTI_Ratio <= 50.0 then 'Medium DTI'
           Else 'High DTI'
       end as DTI_Category,
       case 
       when c.Annual_Income <= 250000 then 'Low Income'
       when c.Annual_income <= 500000 then 'Medium Income'
       else 'High Income'
       end as Income_category,
       count(case
             when l.Default_Flag = 1 then l.Loan_ID
             end)*100.0/
        count(l.Loan_ID) as Default_Rate       
from Dim_Customer c Left join
Fact_Loan l on c.Customer_ID = l.Customer_ID 
group by case 
           when l.DTI_Ratio < 30.0 then 'Low DTI'
           when l.DTI_Ratio <= 50.0 then 'Medium DTI'
           Else 'High DTI'
       end,
       case 
       when c.Annual_Income <= 250000 then 'Low Income'
       when c.Annual_income <= 500000 then 'Medium Income'
       else 'High Income'
       end
Order by Default_Rate Desc

--23 Which customer segments account for the largest share of defaulted funded amounts?
select case 
       when c.Annual_Income <= 250000 then 'Low Income'
       when c.Annual_income <= 500000 then 'Medium Income'
       else 'High Income'
       end as Income_category,
       case 
       when c.Credit_Score > 600 then 'High'
       when c.Credit_Score <= 700 then 'Medium'
       else 'Low'
       end as Credit_Score_Category,
       sum(case
        when l.Default_Flag = 1
        then l.Funded_Amount
        else 0
    end) AS Defaulted_Funded_Amount,
       count(case
             when l.Default_Flag = 1 then l.Loan_ID
             end)*100.0/
        count(l.Loan_ID) as Default_Rate
from Dim_Customer c left join
Fact_Loan l on c.Customer_ID = l.Customer_ID
group by case
       when c.Annual_Income <= 250000 then 'Low Income'
       when c.Annual_income <= 500000 then 'Medium Income'
       else 'High Income'
       end ,
       case 
       when c.Credit_Score > 600 then 'High'
       when c.Credit_Score <= 700 then 'Medium'
       else 'Low'
       end 
order by Default_Rate desc

--24	How many payments were made late, and how many were on time?
select top 100 * from Fact_Loan_Payment
select case 
       when Late_Days = 0 then 'On Time'
       when Late_Days > 0 then 'Late'
       when Late_Days < 0 then 'Early'
       else 'Unknown'
       end as Payment_Category,
       count(Loan_ID) as Total_Payments
from Fact_Loan_Payment 
group by case 
       when Late_Days = 0 then 'On Time'
       when Late_Days > 0 then 'Late'
       when Late_Days < 0 then 'Early'
       else 'Unknown'
       end
order by Total_Payments desc

--25	Which loans have the highest number of late payments?
with LatePayments as
(
    select
        Loan_ID,
        count(*) AS Total_Late_Payments,
        max(Late_Days) AS Maximum_Late_Days
    from Fact_Loan_Payment
    where Late_Days > 0
    group by Loan_ID
)
select * from LatePayments
order by Total_Late_Payments desc

--26	Do loans with more late payments have higher default rates?	
with Loan_Late_Payments as
(
    select
        Loan_ID,
        count(case
            when Late_Days > 0 then 1
        end) AS Total_Late_Payments
    from Fact_Loan_Payment
    group by Loan_ID
),

Loan_Categories as
(
    select
        l.Loan_ID,
        l.Default_Flag,
        case
            when isnull(p.Total_Late_Payments, 0) = 0
                then 'No Late Payments'
            when p.Total_Late_Payments <= 2
                then '1-2 Late Payments'
            when p.Total_Late_Payments <= 5
                then '3-5 Late Payments'
            else 'More Than 5 Late Payments'
        end as Late_Payment_Category
    from Fact_Loan l
    left join Loan_Late_Payments p
        on l.Loan_ID = p.Loan_ID
)
select
    Late_Payment_Category,
    count(Loan_ID) as Total_Loans,

    count(case
        when Default_Flag = 1 then Loan_ID
    end) as Defaulted_Loans,
    count(case
          when Default_Flag = 1 then Loan_ID
        end) * 100.0 /
    count(Loan_ID)
     as Default_Rate

from Loan_Categories
group by Late_Payment_Category
order by Default_Rate desc

--27	What is the average delay in days for payments associated with defaulted versus non-defaulted loans?
select case
       when l.Default_Flag = 1 then 'Defaulted'
       else 'Non-Defaulted'
       end as Loan_Category,
       count(p.Loan_ID) AS Total_Payments,
       avg(cast(p.Late_Days as decimal(10,2)))
       as Average_Delay_Days
from Fact_Loan_Payment p
inner join Fact_Loan l
on p.Loan_ID = l.Loan_ID
where p.Late_Days is not null
group by
    case
    when l.Default_Flag = 1 then 'Defaulted'
    else 'Non-Defaulted'
    end
order by Average_Delay_Days desc

--28	How much principal and interest have been paid by defaulted versus non-defaulted loans?
select Case
       when l.default_flag = 1 then 'Defaulted'
       else 'Non-Defaulted'
       end as Loan_Category,
       Count(Distinct l.loan_id) as Total_Loans,
       Round(Sum(p.Principal_Paid),2) as Total_Principle_Paid,
       Round(Sum(p.Interest_Paid),2) as Total_Interest_Paid
from Fact_Loan_Payment p Inner Join 
Fact_Loan l on p.Loan_ID = l.Loan_ID
Group by Case
       when l.default_flag = 1 then 'Defaulted'
       else 'Non-Defaulted'
       end

--29	Which defaulted loans have the largest outstanding or unpaid amounts, if these can be derived reliably?
select l.Loan_ID,
       sum(case
           when p.Payment_Status = 'Late' then p.Payment_Amount
           end) as Total_Late_Payment
from Fact_Loan_Payment p Inner Join 
Fact_Loan l on p.Loan_ID = l.Loan_ID
where l.Default_Flag = 1
group by l.Loan_ID
order by Total_Late_Payment desc


--30	What percentage of payments are late for each loan type?
select l.Loan_Type,
       count(case
       when p.Payment_Status = 'Late' then p.Loan_ID
       end)*100.0/
       count(p.Loan_ID) as Late_Payment_Percent
from Fact_Loan_Payment p inner join 
Fact_Loan l on p.Loan_ID = l.Loan_ID
group by l.Loan_Type
order by Late_Payment_Percent desc


--31	Do repayment delays increase before a loan is classified as defaulted?
select case
       when l.Default_Flag = 1 then 'Defaulted'
       else 'Non-Defaulted'
       end as Loan_Category,
       count(*) AS Total_Payments,
       Round(avg(cast(p.Late_Days as Decimal(10,2))), 2) as Average_Delay_Days,
       max(p.Late_Days) as Maximum_Delay_Days
from Fact_Loan_Payment p Inner Join 
Fact_Loan l on p.Loan_ID = l.Loan_ID
where p.Late_Days > 0
group by
    case
       when l.Default_Flag = 1 then 'Defaulted'
       else 'Non-Defaulted'
       end


--32	Which customers have multiple loans with repayment delays or defaults?
With Customer_Loan_Analysis as
(
select l.Customer_ID,
       count(l.Loan_ID)as Total_loans,
       count(case
             when l.Default_Flag = 1 then l.Loan_ID
             end) as Defaulted_loans,
        count(case
              when p.Payment_Status = 'Late' then l.Loan_ID
              end) as Delayed_Loans
from Fact_Loan_Payment p
inner join Fact_Loan l
on p.Loan_ID = l.Loan_ID
Group by l.Customer_ID
)
select * From Customer_Loan_Analysis
Where Total_loans > 1
And (Defaulted_Loans > 0 or Delayed_Loans > 0)
Order by  Defaulted_Loans Desc, Delayed_Loans Desc

--33	What are the differences in average income, DTI, LTV, interest rate, EMI, and tenure between defaulters and non-defaulters?
Select Case
       when l.Default_Flag = 1 then 'Defaulted'
       else 'Non-Defaulted'
       end as Loan_Category,
       avg(cast(c.Annual_Income as Decimal(18,2))) as Avg_Income,
       avg(cast(l.DTI_Ratio as Decimal(18,2))) as Avg_DTI,
       avg(cast(l.LTV_Ratio as decimal(18,2))) as Avg_LTV,
       avg(cast(l.Interest_Rate as Decimal(18,2))) as Avg_Interest_Rate,
       avg(cast(l.EMI as decimal(18,2))) as Avg_EMI,
       avg(cast(l.Tenure_Months as decimal(18,2))) as Avg_Tenure
from Fact_Loan l Left Join
Dim_Customer c on l.Customer_ID = c.Customer_ID
Group by Case
       when l.Default_Flag = 1 then 'Defaulted'
       else 'Non-Defaulted'
       end

--34	Do defaulters have a higher average number of late payments than non-defaulters?
With loan_Late_Payment as
(select l.loan_id,
       l.default_flag,
       count(case
       when p.Payment_status = 'Late' then 1
       end) as Total_Late_Payment
from Fact_Loan l Left Join
Fact_Loan_Payment p on l.Loan_ID = p.Loan_ID
Group by l.Loan_ID,
         l.Default_Flag
)
Select case
       when default_flag = 1 then 'Defaulted loans'
       else 'Non-Defaulted loans'
       end as Loan_Category,
       Count(loan_id) as Total_Loans,
       avg(cast(Total_Late_Payment as Decimal(18,2))) as Avg_Late_Payment
from loan_late_Payment
group by case
         when default_flag = 1 then 'Defaulted loans'
         else 'Non-Defaulted loans'
         end
order by Avg_Late_Payment desc

--35	Which combination of risk rating, income band, and loan type has the highest default rate?
Select l.Risk_Rating,
       case
       when c.Annual_Income <= 250000 then 'Low Income'
       when c.Annual_Income <= 500000 then 'Medium Income'
       else 'High Income'
       end as Income_Band,
       l.Loan_Type,
       count(l.loan_id) as Total_Loans,
       count(case
             when l.default_flag = 1 then l.loan_id
             end) as Defaulted_loans,
       count(case
             when l.Default_Flag = 1 then l.Loan_ID
             end)*100.0/
       count(l.Loan_ID) as Default_Rate
from Fact_Loan l Inner join
Dim_Customer c on l.Customer_ID = c.Customer_ID
Group by l.Risk_Rating,
       case
       when c.Annual_Income <= 250000 then 'Low Income'
       when c.Annual_Income <= 500000 then 'Medium Income'
       else 'High Income'
       end,
       l.Loan_Type
order by  Defaulted_loans desc,
         Default_Rate desc
  
--36	How has the number of defaults changed by month and year?
select year(Application_Date) as Loan_Year,
       month(Application_Date) as Loan_Month_Number,
       datename(month, Application_Date) as Loan_Month,
       count(case
             when Default_Flag = 1 then Loan_ID
       end) as Total_Defaults
from Fact_Loan
group by year(Application_Date),
         month(Application_Date),
         datename(month, Application_Date)
order by Loan_Year,
         Loan_Month_Number

--37	How has the funded-loan default rate changed over time?
select case 
       when Funded_Amount >= 500000 then 'High'
       when Funded_Amount < 500000 then 'Medium'
       when Funded_Amount < 200000 then 'Low'
       end as Fund_Category,
       year(Application_Date) as Loan_Year,
       month(Application_Date) as Loan_Month_Number,
       datename(month, Application_Date) as Loan_Month,
       count(case
       when Default_Flag = 1 then Loan_ID
       end)*100.0/
       count(Loan_ID) as Default_Rate       
from Fact_Loan
where Funded_Amount > 0
group by case 
       when Funded_Amount >= 500000 then 'High'
       when Funded_Amount < 500000 then 'Medium'
       when Funded_Amount < 200000 then 'Low'
       end,
       year(Application_Date),
       month(Application_Date),
       datename(month,Application_Date)
order by Default_Rate desc

--38	Which application periods have the highest observed default rates?
select Year(Application_Date) as Loan_Year,
       Month(Application_Date) as Loan_Month,
       Datename(Month,Application_Date) as Loan_Month,
       count(case
             when default_flag = 1 then 1
             end) as Defaulted_Loans,
       count(case
             when default_flag = 1 then loan_id
             end)*100.0/
       count(loan_id) as Default_Rate
from Fact_Loan 
group by Year(Application_Date),
       Month(Application_Date),
       Datename(Month,Application_Date)
order by Default_Rate desc

--39	Does default rate vary by loan type across different periods?
select loan_type,
       Year(Application_Date) as Loan_Year,
       Month(Application_Date) as Loan_Month,
       Datename(Month,Application_Date) as Loan_Month,
       count(case
             when default_flag = 1 then 1
             end) as Defaulted_Loans,
       count(case
             when default_flag = 1 then loan_id
             end)*100.0/
       count(loan_id) as Default_Rate
from Fact_Loan 
group by loan_type,
       Year(Application_Date),
       Month(Application_Date),
       Datename(Month,Application_Date)
order by Default_Rate desc

--40	How does repayment delay change over time for loans that eventually default?
select Year(P.payment_date) as Payment_Year,
       Month(P.payment_date) as Payment_Month,
       Datename(Month, P.payment_date) as Month_Name,
       Count(*) as Total_Payments,
       avg(Cast(P.late_days as Decimal(10,2)))
       as Avg_Repayment_Delay,
       Max(P.late_days) as Max_Repayment_Delay,
       sum(Case
           when P.late_days > 0 then 1
           else 0
           end) as Late_Payments
From Fact_Loan_Payment P Inner join
Fact_Loan L on P.loan_id = L.loan_id
Where L.default_flag = 1
Group by Year(P.payment_date),
       Month(P.payment_date),
       Datename(Month, P.payment_date)
Order by Payment_Year,
         Payment_Month
