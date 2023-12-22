USE HTAUTO
GO
DROP TABLE IF EXISTS Marketing_CRM
GO
DECLARE @PREVIOUS_YEAR int = YEAR(DATEADD(year, -1, DATEADD(DAY, -1, GETDATE())))
DECLARE @YESTERDAY date = DATEADD(day, -1, GETDATE());
WITH CTE AS (
SELECT
Customer_list.[Mã khách hàng],
Customer_list.[Tên khách hàng], 
b.Address,
Customer_list.Tỉnh,
b.PhoneVT, 
b.PhoneVT2,
b.PhoneVT3,
b.PhoneSep ĐT_Sếp,
b.VTName,
Customer_list.[NV phụ tùng],
b.SepBirthday,
[Ngày tạo]
FROM
Customer_list
LEFT JOIN B8_HTAuto_VN.dbo.B20Customer b ON b.Code = Customer_list.[Mã khách hàng]
WHERE Customer_list.Bravo = 'HT'),

CTE1 AS (
SELECT                                        
    [Mã KH],
	SUM([Thành tiền bán]) Doanh_số_năm_trước,
	SUM([Số lượng]) Sản_lượng_năm_trước
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
        AND YEAR(Ngày) = @PREVIOUS_YEAR
    GROUP BY
        [Mã KH]
),

CTE2 AS (
SELECT                                        
    [Mã KH],
	SUM([Thành tiền bán]) Doanh_số_năm_nay,
	SUM([Số lượng]) Sản_lượng_năm_nay
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
        AND YEAR(Ngày) = YEAR(DATEADD(DAY, -1, GETDATE()))
    GROUP BY
        [Mã KH]
),
CTE3 AS (
    SELECT                                 
    [Mã KH],
	SUM([Thành tiền bán]) Doanh_số,
	CONCAT('{ ',b.[Nhà cung cấp], '-', b.[Mã nhóm 2], ': ', SUM ( [Thành tiền bán] ), ' }') [Doanh số 3 tháng gần nhất]
    FROM
        [dbo].[Transaction_Detail] a
        LEFT JOIN Product_list b ON a.[Mã hàng] = b.[Mã vật tư] AND b.Bravo = 'HT'
    WHERE
        a.Bravo = 'HT' 
        AND ( a.[TK dư nợ DT] = 1311 OR [TK dư nợ DT] = 1312 OR [TK dư nợ DT] = 5212 ) 
        AND a.[Mã nhóm 1] != 'DICHVU' 
        AND a.[Mã nhóm 1] != 'CHATLONG' 
        AND a.[Mã nhóm 1] != 'HT-CHATLONG' 
        AND [Mã KH] != 'ASP' 
        AND UPPER ( a.[NV phụ tùng] ) NOT IN ( 'THANGPHAM', 'HUONGHOANG', 'HUYENTRAN', 'QUYNHBUI', 'PHUONGLE' ) 
        AND Ngày BETWEEN DATEADD(MONTH, -3, GETDATE()) AND GETDATE()
    GROUP BY
        [Mã KH], b.[Nhà cung cấp], b.[Mã nhóm 2]
	HAVING
	SUM ( [Thành tiền bán] )  > 0
),
CTE4 AS (
SELECT
[Mã KH],
STRING_AGG([Doanh số 3 tháng gần nhất], ' , ') [Doanh số 3 tháng gần nhất]
FROM (
SELECT 
[Mã KH], 
[Doanh số 3 tháng gần nhất],
DENSE_RANK() OVER(PARTITION BY [Mã KH] ORDER BY Doanh_số DESC) rank_DS
FROM CTE3 ) a 
WHERE a.rank_DS < 6
GROUP BY [Mã KH]
),
CTE5 AS (
    SELECT                                 
    [Mã KH],
	SUM([Số lượng]) Sản_lượng,
	CONCAT('{ ',b.[Nhà cung cấp], '-', b.[Mã nhóm 2], ': ', SUM ( [Số lượng]), ' }') [Sản lượng 3 tháng gần nhất]
    FROM
        [dbo].[Transaction_Detail] a
        LEFT JOIN Product_list b ON a.[Mã hàng] = b.[Mã vật tư] AND b.Bravo = 'HT'
    WHERE
        a.Bravo = 'HT' 
        AND ( [TK dư nợ DT] = 1311 OR [TK dư nợ DT] = 1312 OR [TK dư nợ DT] = 5212 ) 
        AND a.[Mã nhóm 1] != 'DICHVU' 
        AND a.[Mã nhóm 1] != 'CHATLONG' 
        AND a.[Mã nhóm 1] != 'HT-CHATLONG' 
        AND [Mã KH] != 'ASP' 
        AND UPPER ( a.[NV phụ tùng] ) NOT IN ( 'THANGPHAM', 'HUONGHOANG', 'HUYENTRAN', 'QUYNHBUI', 'PHUONGLE' ) 
        AND Ngày BETWEEN DATEADD(MONTH, -3, GETDATE()) AND GETDATE()
    GROUP BY
        [Mã KH], b.[Nhà cung cấp], b.[Mã nhóm 2]
	HAVING 
		SUM ( [Thành tiền bán] )  > 0
),
CTE6 AS (
SELECT
[Mã KH],
STRING_AGG([Sản lượng 3 tháng gần nhất], ' , ') [Sản lượng 3 tháng gần nhất]
FROM (
SELECT 
[Mã KH], 
[Sản lượng 3 tháng gần nhất],
DENSE_RANK() OVER(PARTITION BY [Mã KH] ORDER BY Sản_lượng DESC) rank_SL
FROM CTE5 ) a 
WHERE a.rank_SL < 6
GROUP BY [Mã KH]
),

CTE7 AS (
SELECT                                        
    [Mã KH],
	SUM([Thành tiền bán]) Doanh_số_tháng_này
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
        AND YEAR(Ngày) = YEAR(@YESTERDAY) AND MONTH(Ngày) = MONTH(@YESTERDAY)
    GROUP BY
        [Mã KH]
),

CTE8 AS (
SELECT                                        
    [Mã KH],
	SUM([Thành tiền bán]) Doanh_số_tháng_trước
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
        AND YEAR(Ngày) = YEAR(DATEADD(month, -1,@YESTERDAY)) AND MONTH(Ngày) = MONTH(DATEADD(month, -1,@YESTERDAY))
    GROUP BY
        [Mã KH]
),
CTE9 AS (
SELECT                                        
    [Mã KH],
	SUM([Thành tiền bán]) Doanh_số_2_tháng_trước
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
        AND YEAR(Ngày) = YEAR(DATEADD(month, -2,@YESTERDAY)) AND MONTH(Ngày) = MONTH(DATEADD(month, -2,@YESTERDAY))
    GROUP BY
        [Mã KH]
),
CTE10 AS (
    SELECT                                 
    [Mã KH],
	SUM([Thành tiền bán]) Doanh_số,
	CONCAT('{ ',b.[Nhà cung cấp], '-', b.[Mã nhóm 2], ': ', SUM ( [Thành tiền bán] ), ' }') [Doanh số 12 tháng gần nhất]
    FROM
        [dbo].[Transaction_Detail] a
        LEFT JOIN Product_list b ON a.[Mã hàng] = b.[Mã vật tư] AND b.Bravo = 'HT'
    WHERE
        a.Bravo = 'HT' 
        AND ( a.[TK dư nợ DT] = 1311 OR [TK dư nợ DT] = 1312 OR [TK dư nợ DT] = 5212 ) 
        AND a.[Mã nhóm 1] != 'DICHVU' 
        AND a.[Mã nhóm 1] != 'CHATLONG' 
        AND a.[Mã nhóm 1] != 'HT-CHATLONG' 
        AND [Mã KH] != 'ASP' 
        AND UPPER ( a.[NV phụ tùng] ) NOT IN ( 'THANGPHAM', 'HUONGHOANG', 'HUYENTRAN', 'QUYNHBUI', 'PHUONGLE' ) 
        AND Ngày BETWEEN DATEADD(MONTH, -12, GETDATE()) AND GETDATE()
    GROUP BY
        [Mã KH], b.[Nhà cung cấp], b.[Mã nhóm 2]
	HAVING
	SUM ( [Thành tiền bán] )  > 0
),
CTE11 AS (
SELECT
[Mã KH],
STRING_AGG([Doanh số 12 tháng gần nhất], ' , ') [Doanh số 12 tháng gần nhất]
FROM (
SELECT 
[Mã KH], 
[Doanh số 12 tháng gần nhất],
DENSE_RANK() OVER(PARTITION BY [Mã KH] ORDER BY Doanh_số DESC) rank_DS
FROM CTE10 ) a 
WHERE a.rank_DS < 6
GROUP BY [Mã KH]
),
CTE12 AS (
SELECT 
  * 
FROM 
  (
    SELECT 
      [Mã KH], 
      Ngày, 
      ROW_NUMBER() OVER(
        PARTITION BY [Mã KH] 
        ORDER BY 
          Ngày DESC
      ) stt 
    FROM 
      Transaction_Detail 
    GROUP BY 
      [Mã KH], 
      Ngày
  ) a 
WHERE 
  stt = 2
),
CTE13 AS (
SELECT                                        
    [Mã KH],
	COUNT(DISTINCT Số) SL_đơn_tháng_này
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
        AND YEAR(Ngày) = YEAR(@YESTERDAY) AND MONTH(Ngày) = MONTH(@YESTERDAY)
		AND LEFT(Số, 2) <> 'TL'
    GROUP BY
        [Mã KH]
),

CTE14 AS (
SELECT                                        
    [Mã KH],
	COUNT(DISTINCT Số) SL_đơn_tháng_trước
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
        AND YEAR(Ngày) = YEAR(DATEADD(month, -1,@YESTERDAY)) AND MONTH(Ngày) = MONTH(DATEADD(month, -1,@YESTERDAY))
		AND LEFT(Số, 2) <> 'TL'
    GROUP BY
        [Mã KH]
),
CTE15 AS (
SELECT                                        
    [Mã KH],
	COUNT(DISTINCT Số) SL_đơn_năm_nay
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
        AND YEAR(Ngày) = YEAR(@YESTERDAY)
		AND LEFT(Số, 2) <> 'TL'
    GROUP BY
        [Mã KH]
),
CTE16 AS (
SELECT                                        
    [Mã KH],
	COUNT(DISTINCT Số) SL_đơn_năm_trước
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
        AND YEAR(Ngày) = YEAR(DATEADD(year, -1,@YESTERDAY))
		AND LEFT(Số, 2) <> 'TL'
    GROUP BY
        [Mã KH]
),
CTE17 AS (
SELECT                                        
    [Mã KH],
	SUM([Thành tiền bán]) Doanh_số_cùng_kì_năm_trước
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
        AND Ngày BETWEEN DATEFROMPARTS(@PREVIOUS_YEAR,1,1) AND DATEADD(year, -1, DATEADD(DAY, -1, GETDATE()))  
    GROUP BY
        [Mã KH]
)

SELECT 
b.*
	  ,Loại_KH_chuỗi
      ,[Doanh số TB theo tháng]
      ,[Monetary_score]
      ,[Phân loại Monetary]
      ,[Ngày_mua_gần_nhất]
	  ,y.Ngày Ngày_mua_gần_nhất_2
      ,[Buying_gap]
      ,[Recency_score]
      ,[Phân loại Recency]
      ,[Tần_suất]
      ,[Frequency_Score]
      ,a.[RFM]
      ,[Code]
      ,[Phân loại Frequency]
      ,h.[Customer category]
	  ,c.Doanh_số_năm_trước
	  ,c.Sản_lượng_năm_trước
	  ,d.Doanh_số_năm_nay
	  ,d.Sản_lượng_năm_nay
	  ,d.Doanh_số_năm_nay / CTE15.SL_đơn_năm_nay TB_đơn_năm_nay
	  ,CTE15.SL_đơn_năm_nay
	  ,c.Doanh_số_năm_trước / CTE16.SL_đơn_năm_trước TB_đơn_năm_trước
	  ,CTE16.SL_đơn_năm_trước
	  ,e.[Doanh số 3 tháng gần nhất]
	  ,g.[Sản lượng 3 tháng gần nhất]
	  ,k.Doanh_số_tháng_này
	  ,j.Doanh_số_tháng_trước
	  , CTE13.SL_đơn_tháng_này
	  , CTE14.SL_đơn_tháng_trước
	  , m.Doanh_số_2_tháng_trước
	  , l.[Doanh số 12 tháng gần nhất]
	  , CTE17.Doanh_số_cùng_kì_năm_trước
	  , IIF(a.[Mã khách hàng] = 'VAPC-HCM', N'Vùng 0', z.Vùng) Vùng into Marketing_CRM
FROM RFM_result a
LEFT JOIN CTE b ON a.[Mã khách hàng] = b.[Mã khách hàng]
LEFT JOIN CTE1 c ON a.[Mã khách hàng] = c.[Mã KH]
LEFT JOIN CTE2 d ON a.[Mã khách hàng] = d.[Mã KH]
LEFT JOIN CTE4 e ON a.[Mã khách hàng] = e.[Mã KH]
LEFT JOIN CTE6 g ON a.[Mã khách hàng] = g.[Mã KH]
LEFT JOIN CTE7 k ON a.[Mã khách hàng] = k.[Mã KH]
LEFT JOIN CTE8 j ON a.[Mã khách hàng] = j.[Mã KH]
LEFT JOIN CTE9 m ON a.[Mã khách hàng] = m.[Mã KH]
LEFT JOIN CTE11 l ON a.[Mã khách hàng] = l.[Mã KH]
LEFT JOIN CTE12 y ON y.[Mã KH] = a.[Mã khách hàng]
LEFT JOIN CTE13 ON CTE13.[Mã KH] = a.[Mã khách hàng]
LEFT JOIN CTE14 ON CTE14.[Mã KH] = a.[Mã khách hàng]
LEFT JOIN CTE15 ON CTE15.[Mã KH] = a.[Mã khách hàng]
LEFT JOIN CTE16 ON CTE16.[Mã KH] = a.[Mã khách hàng]
LEFT JOIN CTE17 ON CTE17.[Mã KH] = a.[Mã khách hàng]
LEFT JOIN RFM_category h ON h.RFM = a.RFM



