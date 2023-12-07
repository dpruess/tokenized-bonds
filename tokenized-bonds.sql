--- Tokenized Treasuries Dashboard Oct. 2023 ---
-- by Dennis Pruess 

-- create Real World Assets database 
CREATE DATABASE rwa;

-- create treasuries table 
CREATE TABLE treasuries (
	Protocol text,
	Network text,
	Manager_Name text,
	Ticker text,
	Name text,
	Market_Cap numeric(16,2),
	Yield_to_Maturity numeric(6,2),
	Weighted_Average_Maturity numeric(6,2),
	Total_Management_Fee numeric(6,2),
	Min_Initial_Deposit numeric(11,2),
	Min_Subsequent_Deposit numeric(11,2),
	Primary_Currency char(5),
	Contract_Address text,
	Redemption_Description text,
	Contract_Type text,
	Decimals numeric(6,2),
	Subscription_Fee numeric(6,2),
	Redemption_Fee numeric(6,2),
	Subscription_Description text,
	Token_Supply numeric(16,2),
	Product_Description text,
	Custodian_Name text,
	Jurisdiction text,
	Investor_Protections_Description text, 
	KYC_Required boolean,
	Investors_Allowed_Description text,
	Transferability_Description text,
	Fee_Description text,
	Other_Fees_Description text
); 

-- load CSV into Postgre 
COPY treasuries
FROM '/Users/my_personal_path/treasuries.csv'
WITH (FORMAT CSV, HEADER);

-- show table 
TABLE treasuries;

-- Treasuries analysis --

-- total marketcap by networks 
SELECT network, SUM(market_cap) as total_market_cap
FROM treasuries
GROUP BY network
ORDER BY network ASC;

-- protocols by AUM  
SELECT protocol, SUM(market_cap) AS market_cap_sum
FROM treasuries
WHERE market_cap > 0 
GROUP BY protocol
ORDER BY market_cap_sum DESC; 

-- top 5 managers with highest yield 
SELECT network, manager_name, yield_to_maturity AS yield
FROM treasuries 
WHERE yield_to_maturity > 0 
ORDER BY yield_to_maturity DESC
LIMIT 5;

-- average yield 
SELECT ROUND(AVG(yield_to_maturity),2) AS average_yield
FROM treasuries;

-- total market cap 
SELECT SUM(market_cap) AS total_market_cap
FROM treasuries;

-- top protocols without KYC
SELECT protocol, network, market_cap, yield_to_maturity
FROM treasuries
WHERE kyc_required = 'false'
ORDER BY market_cap DESC;

-- deposit overview 
SELECT protocol, manager_name, min_initial_deposit, min_subsequent_deposit, redemption_description, kyc_required
FROM treasuries 
ORDER BY min_initial_deposit ASC;

-- fee overview 
SELECT protocol, manager_name, subscription_description, subscription_fee, redemption_fee, total_management_fee
FROM treasuries 
ORDER BY total_management_fee ASC; 

-- time series analysis -- 

-- create table for time series 
CREATE TABLE treasuries_ts (
    timestamp bigint,
    protocol TEXT NOT NULL,
    market_cap numeric(20, 8),
    date TEXT
);

-- load CSV into Postgre 
COPY treasuries_ts
FROM '/Users/my_personal_path/treasury-timeseries.csv'
WITH (FORMAT CSV, HEADER); 

-- check table
TABLE treasuries_ts;

-- add date column 
ALTER TABLE treasuries_ts ADD COLUMN date_as_timestamp TIMESTAMP;

-- convert 'date' string to timestamp format and store in 'date_as_timestamp'
UPDATE treasuries_ts 
SET date_as_timestamp = to_timestamp(
    substring(date from 5 for 20), 
    'Mon DD YYYY HH24:MI:SS'
);

-- drop column 'date'
ALTER TABLE treasuries_ts DROP COLUMN date;

-- rename column 
ALTER TABLE treasuries_ts RENAME COLUMN date_as_timestamp TO date;

-- check table again 
TABLE treasuries_ts;

-- time series group by protocol 
SELECT protocol, market_cap, date
FROM treasuries_ts
GROUP BY protocol, market_cap, date
ORDER BY protocol ASC, date ASC;
