/* Tạo ra bảng đánh giá Recency khách hàng
từ bảng khai báo định nghĩa Recency
Insert kết quả vào bảng Recency_result
*/

USE HTAUTO
--DROP bảng kết quả trước khi thực hiện
DROP TABLE IF EXISTS Recency_result
--Gán thời gian khách chưa mua hàng dài nhất cho cận xa nhất của Recency
DECLARE @LONGEST_BUYING_GAP int 
SET 
  @LONGEST_BUYING_GAP = (
    SELECT 
      DATEDIFF(
        DAY, 
        MIN(Ngày), 
        GETDATE()
      ) + 10 
    FROM 
      [dbo].[Transaction_Detail] a 
      LEFT JOIN Customer_list b ON a.[Mã KH] = b.[Mã khách hàng] AND b.Bravo = 'HT'
    WHERE 
      a.Bravo = 'HT' 
      AND (
        [TK dư nợ DT] = 1311 
        OR [TK dư nợ DT] = 1312 
        OR [TK dư nợ DT] = 5212
      ) 
      AND [Mã nhóm 1] != 'DICHVU' 
      AND [Mã nhóm 1] != 'CHATLONG' 
      AND [Mã nhóm 1] != 'HT-CHATLONG' 
      AND [Mã KH] != 'ASP'
	  AND LEFT(Số,2) <> 'TL'
      AND UPPER(a.[NV phụ tùng]) NOT IN (
        'THANGPHAM', 'HUONGHOANG', 'HUYENTRAN', 
        'QUYNHBUI'
      )
  ) 
UPDATE 
  Recency 
SET 
  [Cận trên] = @LONGEST_BUYING_GAP 
WHERE 
  Recency.Stt = 1

GO

--Đánh giá Recency từng khách bàng join bất đối xứng và select kết quả vào bảng Recency_result
WITH CTE AS (
SELECT 
[Mã KH],
CASE
	WHEN b.[Tên phân loại] IS NULL OR b.[Tên phân loại] = '' THEN N'KHÁCH LẺ'
	ELSE UPPER(b.[Tên phân loại])
END Loại_KH_chuỗi,
MAX(Ngày) Ngày_mua_gần_nhất,
DATEDIFF(DAY,MAX(Ngày), GETDATE()) SL_ngày
FROM [dbo].[Transaction_Detail] a
LEFT JOIN Customer_list b ON a.[Mã KH] = b.[Mã khách hàng] AND b.Bravo = 'HT'
WHERE a.Bravo = 'HT' 
AND ( [TK dư nợ DT] = 1311 OR [TK dư nợ DT] =  1312 OR [TK dư nợ DT] = 5212) 
AND [Mã nhóm 1] != 'DICHVU' 
AND [Mã nhóm 1] != 'CHATLONG' 
AND [Mã nhóm 1] != 'HT-CHATLONG'
AND [Mã KH] != 'ASP' 
AND UPPER(a.[NV phụ tùng]) NOT IN ( 'THANGPHAM','HUONGHOANG','HUYENTRAN','QUYNHBUI')
AND LEFT(Số,2) <> 'TL'
GROUP BY [Mã KH], b.[Tên phân loại])

SELECT a.[Mã KH], a.Loại_KH_chuỗi, Ngày_mua_gần_nhất,a.SL_ngày Buying_gap, Score,[Tên phân loại] into Recency_result FROM CTE a
LEFT JOIN Recency b ON a.Loại_KH_chuỗi = b.[Loại Kh] AND a.SL_ngày <= b.[Cận trên] AND SL_ngày > b.[Cận dưới]

