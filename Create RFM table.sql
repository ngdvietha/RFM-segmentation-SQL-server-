USE HTAUTO
GO
DROP TABLE IF EXISTS RFM_result
SELECT 
a.[Mã khách hàng],
b.Loại_KH_chuỗi,
b.[Doanh số TB theo tháng], 
b.Score Monetary_score, 
b.[Tên phân loại] 'Phân loại Monetary',
c.Ngày_mua_gần_nhất,
c.Buying_gap, 
c.Score Recency_score,
c.[Tên phân loại] 'Phân loại Recency',
d.Tần_suất,
d.Score Frequency_Score,
d.[Tên phân loại] 'Phân loại Frequency' ,
CONCAT(c.Score, d.Score, b.Score) RFM,
CONCAT_WS(' - ',b.[Tên phân loại],c.[Tên phân loại], d.[Tên phân loại]) Code into RFM_result
FROM Customer_list a
LEFT JOIN Monetary_result b ON a.[Mã khách hàng] = b.[Mã KH]
LEFT JOIN Recency_result c ON a.[Mã khách hàng] = c.[Mã KH]
LEFT JOIN Frequency_result d ON a.[Mã khách hàng] = d.[Mã KH]
WHERE b.Score IS NOT NULL AND d.Score IS NOT NULL AND a.Bravo = 'HT'