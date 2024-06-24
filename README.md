# RFM segmentation SQL server
Phân loại khách hàng cho công ty dựa trên doanh số bán, tần suất bán và thời gian mua gần nhất. Sử dụng SQL server để kéo và xử lý dữ liệu phân loại khách hàng thành hơn 100 tập khác nhau tùy theo khai báo trong bảng định nghĩa <br/>

<h1>Sơ lược về phân tích RFM</h1>
Mô hình RFM <Strong>(Recency, Frequency, Monetary)</Strong> là một mô hình phân tích khách hàng trong lĩnh vực tiếp thị và quản lý quan hệ khách hàng. Mô hình RFM đánh giá, chấm điểm các khía cạnh quan trọng của hành vi mua hàng của khách hàng dựa trên 3 yếu tố:<br/>
<br/>
- Recency (Thời gian gần nhất mua hàng)<br/>
- Frequency (Tần suất)<br/>
- Monetary (Giá trị tiền mỗi lần mua hàng)<br/>
<br/>
Dựa vào phân tích RFM ta có thể phân tập khách hàng để từ đó có các chính sách phù hợp hơn như hình dưới đây <br/>

![image](https://github.com/ngdvietha/RFM-segmentation-SQL-server-/assets/71718604/c0478b23-855b-4b34-bb7e-50b00d2cfa84)

<h1>Flow chạy của dữ liệu</h1>
- Đầu tiên các database vận hành sẽ đổ vào trong database warehouse  Link tập dữ liệu mẫu để test sample file back up database phục vụ cho việc restore: liên hệ https://www.facebook.com/ngdvietha/ <br/>
<br/>
- Trong database sẽ có các bảng input vào mô hình như sau:<br/>
  + 2 bảng dữ liệu chính: <Strong>Transaction detail</Strong> (chứa thông tin về đơn hàng của khách) và <Strong>CustomerList</Strong>  (chứa thông tin về khách hàng)<br/>
  + 3 bảng khai báo định nghĩa RFM đối với từng khách hàng (tên bảng <Strong> Monetary, Frequency, Recency</Strong>)<br/>
  <br/>
- Sau đó  batch job trên SQL server management studio sẽ chạy các code SQL thời điểm cố định hàng ngày theo thứ tự như trong hình dưới để tiến hành kéo dữ liệu và tính toán phân loại RFM. Các code của từng bước trong batch job được đính kèm trong <Strong>các file SQL</Strong> <br/>
 <br/>
- Đầu ra là một bảng dữ liệu phân chia tập khách hàng rõ ràng dựa theo lý thuyết RFM, sample output của bảng được thể hiện trong file <Strong> excel Sample output data </Strong> <br/>
<br/>

![image](https://github.com/ngdvietha/RFM-segmentation-SQL-server-/assets/71718604/665d91c7-1790-4c18-afe6-60b72d1b86d3)

