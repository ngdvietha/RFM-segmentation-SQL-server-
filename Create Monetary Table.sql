--Khai báo bảng Monetary Result
USE HTAUTO
DROP TABLE IF EXISTS #Monetary_result
    SELECT TOP 0                                           
    [Mã KH],
    SUM ( [Thành tiền bán] ) [Doanh số YTD],
    SUM ( [Thành tiền bán] ) / 12 [Doanh số TB theo tháng],
	2023 calculate_year into #Monetary_result
    FROM
        [dbo].[Transaction_Detail] a
        LEFT JOIN Customer_list b ON a.[Mã KH] = b.[Mã khách hàng] AND b.Bravo = 'HT'
    WHERE
        a.Bravo = 'HT' 
        AND ( [TK dư nợ DT] = 1311 OR [TK dư nợ DT] = 1312 OR [TK dư nợ DT] = 5212 ) 
        AND [Mã nhóm 1] != 'DICHVU' 
        AND [Mã nhóm 1] != 'CHATLONG' 
        AND [Mã nhóm 1] != 'HT-CHATLONG' 
        AND [Mã KH] != 'ASP' 
        AND UPPER ( a.[NV phụ tùng] ) NOT IN ( 'THANGPHAM', 'HUONGHOANG', 'HUYENTRAN', 'QUYNHBUI', 'PHUONGLE' ) 
        AND YEAR(Ngày) = 2022
    GROUP BY
        [Mã KH]

--Insert dữ liệu tính toán doanh số các năm 
DECLARE @calculate_year AS int = 2021
DECLARE @month_number_thisyear AS int = IIF(DATEDIFF(month, DATEFROMPARTS(YEAR(GETDATE()),1 ,1), GETDATE()) = 0, 12, DATEDIFF(month, DATEFROMPARTS(YEAR(GETDATE()),1 ,1), GETDATE()))
WHILE @calculate_year <> YEAR(GETDATE()) + 1
BEGIN -- added BEGIN statement
	USE HTAUTO
	INSERT INTO #Monetary_result
    SELECT                                            
    [Mã KH],
    SUM ( [Thành tiền bán] ) [Doanh số YTD],
    SUM ( [Thành tiền bán] ) / IIF( @calculate_year = YEAR(GETDATE()), @month_number_thisyear, 12 ) [Doanh số TB theo tháng],
	@calculate_year calculate_year
    FROM
        [dbo].[Transaction_Detail] a
        LEFT JOIN Customer_list b ON a.[Mã KH] = b.[Mã khách hàng]  AND b.Bravo= 'HT'
    WHERE
        a.Bravo = 'HT' 
        AND ( [TK dư nợ DT] = 1311 OR [TK dư nợ DT] = 1312 OR [TK dư nợ DT] = 5212 ) 
        AND [Mã nhóm 1] != 'DICHVU' 
        AND [Mã nhóm 1] != 'CHATLONG' 
        AND [Mã nhóm 1] != 'HT-CHATLONG' 
        AND [Mã KH] != 'ASP' 
        AND UPPER ( a.[NV phụ tùng] ) NOT IN ( 'THANGPHAM', 'HUONGHOANG', 'HUYENTRAN', 'QUYNHBUI', 'PHUONGLE' ) 
        AND YEAR(Ngày) = @calculate_year
    GROUP BY
        [Mã KH]
    SET @calculate_year = @calculate_year + 1
END; -- added END statement



DROP TABLE IF EXISTS #Monetary_result_final
SELECT
	a.[Mã KH],
	a.[Doanh số TB theo tháng],
	a.Calculate_year,
	a.[Doanh số YTD],
	CASE
		WHEN b.[Tên phân loại] IS NULL OR b.[Tên phân loại]  = '' THEN N'KHÁCH LẺ'
		ELSE UPPER(b.[Tên phân loại])
	END Loại_KH_chuỗi into #Monetary_result_final
	
FROM
	( SELECT *, ROW_NUMBER ( ) OVER ( PARTITION BY [Mã KH] ORDER BY Calculate_year DESC ) "year_rank" FROM #Monetary_result ) a 
LEFT JOIN Customer_list b ON a.[Mã KH] = b.[Mã khách hàng] AND b.Bravo = 'HT'
WHERE
	a.year_rank = 1


--Update doanh số TB tháng cao nhất vào bảng định nghĩa Monetary
DECLARE @MOST_MONTHLY_BUYING_AMOUNT float
SET @MOST_MONTHLY_BUYING_AMOUNT = (SELECT MAX([Doanh số TB theo tháng]) + 1 FROM #Monetary_result_final)

UPDATE Monetary
SET
	[Cận trên] = @MOST_MONTHLY_BUYING_AMOUNT
WHERE Monetary.Stt = 1


--Join bất đối xứng
DROP TABLE IF EXISTS Monetary_result
SELECT a.[Mã KH], a.Loại_KH_chuỗi,a.[Doanh số TB theo tháng], b.Score, b.[Tên phân loại], a.[Doanh số YTD] into Monetary_result FROM #Monetary_result_final a
LEFT JOIN Monetary b ON a.Loại_KH_chuỗi = b.[Phân loại KH] AND a.[Doanh số TB theo tháng] <= b.[Cận trên] AND a.[Doanh số TB theo tháng] > b.[Cận dưới]
WHERE [Doanh số YTD] > 0

