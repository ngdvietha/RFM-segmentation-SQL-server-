USE HTAUTO 
DROP TABLE IF EXISTS Frequency_result
GO
DECLARE @HIGHEST_FREQUENCY float
SET @HIGHEST_FREQUENCY = 
(SELECT MAX(Tần_suất) + 10
FROM(
SELECT [Mã KH], 
CAST(COUNT(DISTINCT Ngày) as float) / cast((DATEDIFF(MONTH, MIN(Ngày), MAX(Ngày)) + 1) as float) Tần_suất
FROM [dbo].[Transaction_Detail] a
WHERE Bravo = 'HT' 
AND ( [TK dư nợ DT] = 1311 OR [TK dư nợ DT] =  1312) 
AND [Mã nhóm 1] != 'DICHVU' 
AND [Mã nhóm 1] != 'CHATLONG' 
AND [Mã nhóm 1] != 'HT-CHATLONG'
AND [Mã KH] != 'ASP' 
AND UPPER(a.[NV phụ tùng]) NOT IN ( 'THANGPHAM','HUONGHOANG','HUYENTRAN','QUYNHBUI')
AND YEAR(Ngày) >= 2020
GROUP BY [Mã KH]) a)

UPDATE 
  Frequency 
SET 
  [Cận trên] = @HIGHEST_FREQUENCY 
WHERE 
  Frequency.Stt = 1


DROP TABLE IF EXISTS #Frequency_result
SELECT [Mã KH], 
DATEDIFF(MONTH, MIN(Ngày), MAX(Ngày)) + 1 Số_tháng, 
COUNT(DISTINCT Ngày) Số_Ngày_PSGD,
CAST(COUNT(DISTINCT Ngày) as float) / cast((DATEDIFF(MONTH, MIN(Ngày), MAX(Ngày)) + 1) as float) Tần_suất into #Frequency_result
FROM [dbo].[Transaction_Detail] a 
WHERE Bravo = 'HT' 
AND ( [TK dư nợ DT] = 1311 OR [TK dư nợ DT] =  1312) 
AND [Mã nhóm 1] != 'DICHVU' 
AND [Mã nhóm 1] != 'CHATLONG' 
AND [Mã nhóm 1] != 'HT-CHATLONG'
AND [Mã KH] != 'ASP' 
AND UPPER(a.[NV phụ tùng]) NOT IN ( 'THANGPHAM','HUONGHOANG','HUYENTRAN','QUYNHBUI')
AND YEAR(Ngày) >= 2020
GROUP BY [Mã KH]

DROP TABLE IF EXISTS #Frequency_result_2
SELECT a.*, 
CASE
	WHEN b.[Tên phân loại] IS NULL OR b.[Tên phân loại]= '' THEN N'KHÁCH LẺ'
	ELSE UPPER(b.[Tên phân loại])
END Loại_KH_chuỗi into #Frequency_result_2
FROM #Frequency_result a
LEFT JOIN Customer_list b ON a.[Mã KH] = b.[Mã khách hàng] AND b.Bravo = 'HT'

SELECT a.[Mã KH], a.Loại_KH_chuỗi, ROUND(a.Tần_suất,2) Tần_suất, Score, [Tên phân loại] into Frequency_result FROM #Frequency_result_2 a
LEFT JOIN Frequency b ON a.Loại_KH_chuỗi = b.[Loại Kh] AND a.Tần_suất < b.[Cận trên] AND a.Tần_suất >= b.[Cận dưới]



