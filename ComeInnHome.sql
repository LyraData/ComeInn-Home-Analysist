-- 1.Xem chi tiết của các bảng
SELECT * FROM BRANCH
SELECT * FROM ROOMS
SELECT * FROM BEDS
SELECT * FROM PRICE
SELECT * FROM CUSTOMERS
--2.Liệt kê các khách hàng nữ
SELECT FullName, PhoneNumber, Email
FROM CUSTOMERS
WHERE Gender = N'Nữ'
--3.Đếm tổng số khách hàng
SELECT COUNT(*) AS TotalCustomers FROM CUSTOMERS;
--4.Tìm giá thuê cơ bản cao nhất và thấp nhất
SELECT MAX(Price) AS MaxBedPrice, MIN(Price) AS MinBedPrice FROM PRICE;
--5.Xem thông tin phòng
SELECT R.RoomID, R.RoomNumber, R.BedCount, B.Name AS BranchName
FROM ROOMS R
JOIN Branch B ON R.BranchID = B.BranchID;
---6.Update cột IdentityNumber , PhoneNumber
UPDATE CUSTOMERS
SET IdentityNumber = 
  RIGHT('000000000000' + IdentityNumber, 12);

UPDATE CUSTOMERS
SET PhoneNumber = 
  RIGHT('000000000000' + IdentityNumber, 11);
--7.Find rooms with an area greater than 20 square meters and specific amenities
SELECT B.Name, R.RoomID, R.Area, R.RoomGender, R.Amenities
FROM ROOMS R JOIN BRANCH B
ON R.BranchID = B.BranchID
WHERE R.Amenities LIKE '%Wifi%' AND R.Area > 20
--8.Inner Join - Get room details with their branch information
SELECT R.RoomID, R.RoomNumber, R.RoomType, R.RoomGender,R.Area, R.Amenities, B.Name AS BranchName, B.Address
FROM ROOMS R JOIN BRANCH B
ON R.BranchID = B.BranchID
--9.Left Join - List all customers and their contracts (including customers without contracts)
SELECT CU.CustomerID, CU.FullName,CU.PhoneNumber,CO.ID AS ContractID,CO.BedID, CO.StartDate, CO.EndDate
FROM CUSTOMERS CU
LEFT JOIN CONTRACTS CO  ON CU.CustomerID = CO.CustomerID;
--10.Kiểm tra lại hợp đồng
SELECT CO.ID, CO.CustomerID, CU.FullName, CU.Gender, r.RoomID, R.RoomGender
FROM CONTRACTS CO
JOIN CUSTOMERS CU ON CO.CustomerID = CU.CustomerID
JOIN BEDS B ON B.BedID = CO.BedID
JOIN ROOMS R ON R.RoomID = B.RoomID 
WHERE R.RoomGender IN ('Nam','Nữ')
AND CU.Gender <> R.RoomGender
--11.Aggregation - Calculate the total number of rooms per branch
SELECT B.Name AS BranchName, COUNT(R.RoomID) AS TotalRooms
FROM BRANCH B
LEFT JOIN ROOMS R ON B.BranchID = R.BranchID
GROUP BY B.Name
ORDER BY TotalRooms DESC
-- 12.Aggregation with Filtering - Find branches with more than 5 rooms
SELECT B.Name AS BranchName, COUNT(R.RoomID) AS TotalRooms
FROM BRANCH B
LEFT JOIN ROOMS R ON B.BranchID = R.BranchID
GROUP BY b.Name
HAVING COUNT(R.RoomID) > 5;
--13.Find customers who have contracts ending after a specific date

SELECT DISTINCT CU.CustomerID, CU.FullName
FROM CUSTOMERS CU
JOIN CONTRACTS CO ON CU.CustomerID = CO.CustomerID
WHERE CO.EndDate > '2025-03-21';

-- 14.Window Function - Rank rooms by area within each branch
SELECT BranchID, RoomNumber, Area,
       RANK() OVER (PARTITION BY BranchID ORDER BY Area DESC) AS AreaRank
FROM ROOMS;
--15.Window Function - Calculate running total of contract payments per customer
SELECT 
    CO.CustomerID, 
    CU.FullName, 
    CO.ID AS ContractID, 
    P.Price,
    DATEDIFF(MONTH, CO.StartDate, CO.EndDate) + 1 AS MonthsRented,
    (P.Price * (DATEDIFF(MONTH, CO.StartDate, CO.EndDate) + 1)) AS TotalContractPayment,
    SUM(P.Price * (DATEDIFF(MONTH, CO.StartDate, CO.EndDate) + 1)) 
        OVER (PARTITION BY CO.CustomerID ORDER BY CO.StartDate) AS RunningTotalPayment
FROM CONTRACTS CO
INNER JOIN CUSTOMERS CU ON CO.CustomerID = CU.CustomerID
INNER JOIN PRICE P ON CO.BedID = P.BedID;
--16. Date Manipulation - Find contracts expiring 
SELECT 
    CO.ID AS ContractID, 
    CU.FullName, 
    CO.EndDate
FROM CONTRACTS CO
INNER JOIN CUSTOMERS CU  ON CO.CustomerID = CU.CustomerID
WHERE co.EndDate BETWEEN '2025-01-01' AND '2025-03-31'
-- 17.CASE Statement - Categorize rooms by area
SELECT RoomID, RoomNumber, Area,
       CASE 
           WHEN Area < 15 THEN 'Small'
           WHEN Area BETWEEN 15 AND 30 THEN 'Medium'
           ELSE 'Large'
       END AS AreaCategory
FROM ROOMS;
--18.String Functions - Format customer contact information

SELECT CustomerID,
       CONCAT(FullName, ' - ', Email, ' - ', PhoneNumber) AS ContactInfo
FROM CUSTOMERS
WHERE TRIM(AppRegistered) = N'Đã đăng kí';

--20.CTE - Calculate average price per room type

WITH RoomPrice AS (
	SELECT R.RoomType,P.Price
	FROM ROOMS R
	INNER JOIN BEDS B ON R.RoomID = B.RoomID
	INNER JOIN PRICE P ON P.BedID = B.BedID
)
SELECT RoomType, AVG(Price) AS AvgPrice
FROM RoomPrice
GROUP BY RoomType
--21.Self Join - Find rooms in the same branch with the same room type
-- Mục đích tìm những phòng tương tự để tối ưu hóa quản lý - có thể tư vấn hỗ trợ ghép khách
SELECT R1.RoomID AS Room1, R2.RoomID AS Room2, R1.BranchID, R1.RoomType
FROM ROOMS R1
INNER JOIN ROOMS R2  ON R1.BranchID = R2.BranchID AND R1.RoomType = R2.RoomType
WHERE R1.RoomID < R2.RoomID;
--22.EXISTS - Find branches with at least one active contract
--Đây là câu truy vấn để kiểm tra và quản lý tình trạng sử dụng phòng của các chi nhánh.Nó giúp bạn nắm rõ được hiện trạng hoạt động thực tế của các chi nhánh.
SELECT B.Name AS BranchName
FROM BRANCH B
WHERE EXISTS (
    SELECT 1
    FROM ROOMS r
    INNER JOIN BEDS bed ON bed.RoomID = r.RoomID
    INNER JOIN CONTRACTS co ON co.BedID = bed.BedID
    WHERE r.BranchID = B.BranchID
      AND co.CheckoutDate IS NULL
);
--23.Liệt kê tên khách hàng, mã hợp đồng, và giá thuê cơ bản (Price) của giường
SELECT CU.FullName, CO.ID AS ContractID, P.BedID, P.Price AS BaseRentPrice
FROM CUSTOMERS CU
INNER JOIN CONTRACTS CO ON CU.CustomerID = CO.CustomerID
INNER JOIN PRICE P ON CO.BedID = P.BedID;
-- Số giường của chi nhánh
SELECT B.Name AS BranchName, COUNT (BEDS.BedID) AS NumberOfBeds
FROM BRANCH B
JOIN ROOMS R ON R.BranchID = B.BranchID
JOIN BEDS ON BEDS.RoomID = R.RoomID
GROUP BY B.Name
ORDER BY NumberOfBeds
--24.Số phòng, số giường
SELECT B.Name AS BranchName,
	   R.RoomType, 
	   COUNT(*) AS RoomCount,
	   STRING_AGG (R.RoomID, ', ') AS ListRoomIDs
FROM ROOMS R INNER JOIN BRANCH B ON R.BranchID = B.BranchID
GROUP BY B.Name , R.RoomType
ORDER BY B.Name, R.RoomType
--25.Tổng tiền của tất cả khách
WITH ContractDetails AS (
    SELECT
        CO.ID,
        CO.CustomerID,
        CO.StartDate,
        CO.EndDate,
        P.Price,
        DATEDIFF(MONTH, CO.StartDate, CO.EndDate) AS RentalMonths,
        DATEDIFF(MONTH, CO.StartDate, CO.EndDate) * P.Price AS ContractAmount
    FROM CONTRACTS CO
    INNER JOIN Price P ON CO.BedID = P.BedID
),
CustomerTotalRevenue AS (
    SELECT
        CustomerID,
        SUM(ContractAmount) AS TotalRevenue
    FROM ContractDetails
    GROUP BY CustomerID
)

--26.
SELECT
    CU.FullName,
    CU.PhoneNumber,
    CD.StartDate,
    CD.EndDate,
    CD.Price,
    CD.RentalMonths,
    CD.ContractAmount,
    CTR.TotalRevenue
FROM CUSTOMERS CU
INNER JOIN ContractDetails CD ON CU.CustomerID = CD.CustomerID
INNER JOIN CustomerTotalRevenue CTR ON CU.CustomerID = CTR.CustomerID
ORDER BY CTR.TotalRevenue DESC, CU.FullName;
--27.Xếp hạng tổng tiền thuê nhiều nhất của khachsh hàng
WITH ContractDetails AS (
    SELECT
        CO.CustomerID,
        CO.StartDate,
        CO.EndDate,
        p.Price,
        CASE 
            WHEN CO.StartDate <= CO.EndDate THEN DATEDIFF(MONTH, CO.StartDate, CO.EndDate)
            ELSE 0
        END AS RentalMonths,
        CASE 
            WHEN CO.StartDate <= CO.EndDate THEN DATEDIFF(MONTH, CO.StartDate, CO.EndDate) * p.Price
            ELSE 0
        END AS ContractAmount
    FROM CONTRACTS CO
    INNER JOIN Price P ON CO.BedID = P.BedID
),
CustomerTotalRevenue AS (
    SELECT
        CustomerID,
        SUM(ContractAmount) AS TotalRevenue
    FROM ContractDetails
    GROUP BY CustomerID
)
SELECT
    CU.FullName,
    ctr.TotalRevenue,
    RANK() OVER (ORDER BY ctr.TotalRevenue DESC) AS RevenueRank
FROM CUSTOMERS CU
INNER JOIN CustomerTotalRevenue ctr ON CU.CustomerID = ctr.CustomerID;

--28.Tính tổng doanh thu (base rent) lũy kế theo ngày bắt đầu hợp đồng
SELECT
    CO.ID AS ContractID,
    CU.CustomerID,
    CU.FullName,
    CO.StartDate,
    CO.BedID,
    P.Price AS ContractPrice,
    CASE
        WHEN CO.StartDate <= CO.EndDate THEN 
            DATEDIFF(MONTH, CO.StartDate, CO.EndDate)
            + CASE WHEN DAY(CO.EndDate) > DAY(CO.StartDate) THEN 1 ELSE 0 END
        ELSE 0
    END AS RentalMonths,
    CASE
        WHEN CO.StartDate <= CO.EndDate THEN 
            (DATEDIFF(MONTH, CO.StartDate, CO.EndDate)
            + CASE WHEN DAY(CO.EndDate) > DAY(CO.StartDate) THEN 1 ELSE 0 END) * P.Price
        ELSE 0
    END AS ContractAmount,
    SUM(
        CASE
            WHEN CO.StartDate <= CO.EndDate THEN 
                (DATEDIFF(MONTH, CO.StartDate, CO.EndDate)
                + CASE WHEN DAY(CO.EndDate) > DAY(CO.StartDate) THEN 1 ELSE 0 END) * P.Price
            ELSE 0
        END
    ) OVER (ORDER BY CO.StartDate, CO.ID) AS CumulativeRevenue
FROM CONTRACTS CO
INNER JOIN Price P ON CO.BedID = P.BedID
INNER JOIN CUSTOMERS CU ON CO.CustomerID = CU.CustomerID
ORDER BY CO.StartDate, CO.ID;
--29.Tính thời hạn của mỗi hợp đồng (số ngày)
SELECT ID, StartDate, EndDate, DATEDIFF(MONTH, StartDate, EndDate) AS ContractDurationDays
FROM CONTRACTS;

-- 30.Liệt kê các hợp đồng đang còn hiệu lực
SELECT CO.ID, CO.CustomerID, CU.FullName, CO.BedID, StartDate, EndDate, B.Name AS BranchName
FROM CONTRACTS CO
JOIN CUSTOMERS CU ON CO.CustomerID = CU.CustomerID
JOIN BEDS ON BEDS.BedID = CO.BedID
JOIN ROOMS R ON R.RoomID = BEDS.RoomID
JOIN BRANCH B ON B.BranchID = R.BranchID
WHERE StartDate <= '2025-01-01' AND EndDate >= '2025-01-01'
--31. Bao nhiêu phòng nam, bao nhiêu phần nữ trong một chi nhánh
SELECT 
    B.Name AS BranchName,
    R.RoomType,
    R.RoomGender,
    COUNT(*) AS TotalRooms
FROM ROOMS R
JOIN BRANCH B ON R.BranchID = B.BranchID
GROUP BY B.Name, R.RoomType, R.RoomGender
ORDER BY B.Name, R.RoomType, R.RoomGender
--32.Liệt kê các hợp đồng sẽ hết hạn trong 30 ngày tới tính từ ngày 31/03/2025
SELECT 
    ID, CustomerID, BedID,  EndDate
FROM 
    Contracts
WHERE 
    EndDate BETWEEN '2025-02-28' AND DATEADD(DAY, 31, '2025-02-28');

--33.Danh sách các phòng trống trong khoảng từ 01/03/2024 đến 30/06/2024
SELECT 
    B.BedID,
    R.RoomID,
    R.RoomGender,
    BR.Name AS BranchName
FROM 
    BEDS B
JOIN ROOMS R ON B.RoomID = R.RoomID
JOIN BRANCH BR ON R.BranchID = BR.BranchID
WHERE 
    B.BedID NOT IN (
        SELECT DISTINCT CO.BedID
        FROM CONTRACTS CO
        WHERE 
            -- Nếu hợp đồng giao nhau với khoảng cần kiểm tra
            CO.StartDate <= '2024-06-30'
            AND CO.EndDate >= '2024-03-01'
    )
ORDER BY BR.Name, R.RoomID, B.BedID;
-- 34.Phân loại khách hàng dựa trên số lượng hợp đồng đã ký
WITH CustomerContractCounts AS (
    SELECT
        CustomerID,
        COUNT(ID) AS NumContracts
    FROM CONTRACTS
    GROUP BY CustomerID
)
SELECT
    CU.FullName,
    COALESCE(ccc.NumContracts, 0) AS NumberOfContracts,
    CASE
        WHEN COALESCE(ccc.NumContracts, 0) = 1 THEN N'Khách hàng mới'
        WHEN COALESCE(ccc.NumContracts, 0) BETWEEN 2 AND 4 THEN N'Khách hàng thân thiết'
        ELSE N'Khách VIP'
    END AS CustomerSegment
FROM CUSTOMERS CU
LEFT JOIN CustomerContractCounts ccc ON CU.CustomerID = ccc.CustomerID
ORDER BY NumberOfContracts DESC;

--35. TOP 10  khách trung thành

WITH ContractDuration AS (
    SELECT 
        CU.CustomerID,
        CU.FullName,
        b.Name AS BranchName,
        r.RoomType,
        r.RoomGender,
        DATEDIFF(DAY, CO.StartDate, COALESCE(CO.CheckOutDate, CO.EndDate, '2025-03-31')) AS DurationDays
    FROM CONTRACTS CO
    JOIN CUSTOMERS CU ON CU.CustomerID = CO.CustomerID
    JOIN BEDS  ON CO.BedID = BEDS.BedID
    JOIN ROOMS R ON  BEDS.RoomID = R.RoomID
    JOIN BRANCH B ON r.BranchID = b.BranchID
)
SELECT TOP 10 
    CustomerID,
    FullName,
    BranchName,
    RoomType,
    RoomGender,
    DurationDays,
    RANK() OVER (ORDER BY DurationDays DESC) AS Rank
FROM ContractDuration
ORDER BY DurationDays DESC;
--36. Doanh thu trong 3 tháng dầu năm 2025
WITH BranchRevenue AS (
    SELECT 
        b.Name AS BranchName,
        SUM(p.price) AS TotalRevenue
    FROM CONTRACTS c
    JOIN Price p ON c.BedID = p.BedID
    JOIN BEDS bd ON c.BedID = bd.BedID
    JOIN ROOMS r ON bd.RoomID = r.RoomID
    JOIN Branch b ON r.BranchID = b.BranchID
    WHERE
        -- Hợp đồng có thời gian giao với khoảng 01/01 - 31/03/2025
        COALESCE(c.CheckOutDate, c.EndDate, '9999-12-31') >= '2025-01-01'
        AND c.StartDate <= '2025-03-31'
    GROUP BY b.Name  --Thêm dòng này để fix lỗi
)
SELECT 
    BranchName,
    TotalRevenue,
    RANK() OVER (ORDER BY TotalRevenue DESC) AS RevenueRank,
    PERCENT_RANK() OVER (ORDER BY TotalRevenue) AS PercentileRank
FROM BranchRevenue;

---37.Bạn muốn biết mỗi tháng có bao nhiêu hợp đồng mới được ký và so sánh với tháng trước đó để biết xu hướng tăng/giảm.
WITH MonthlyCount AS (
    SELECT 
        DATEPART(YEAR, CO.startdate) AS Year,
        DATEPART(MONTH, CO.startdate) AS Month,
        COUNT(*) AS NewContracts
    FROM CONTRACTS CO
    WHERE CO.startdate >= '2023-01-01' AND CO.startdate <= '2025-03-31'
    GROUP BY DATEPART(YEAR, CO.startdate), DATEPART(MONTH, CO.startdate)
),
CustomerRegistrationTrend AS (
    SELECT *,
        LAG(NewContracts, 1) OVER (ORDER BY Year, Month) AS PrevMonthCount
    FROM MonthlyCount
)
SELECT 
    Year,
    Month,
    NewContracts,
    PrevMonthCount,
    CASE 
        WHEN PrevMonthCount IS NULL THEN NULL
        ELSE ROUND((NewContracts - PrevMonthCount) * 100.0 / PrevMonthCount, 2)
    END AS MoMGrowthRate
FROM CustomerRegistrationTrend
ORDER BY Year, Month;


-- 38.Tìm top 5 khách hàng thuê nhiều hợp đồng nhất
SELECT TOP 5 CO.CustomerID, CU.FullName, COUNT(*) AS ContractCount
FROM CONTRACTS CO
JOIN  CUSTOMERS CU ON CO.CustomerID = CU.CustomerID
GROUP BY CO.CustomerID, CU.FullName
ORDER BY ContractCount DESC;
--39.Tính tháng khách hàng thuê giường và ước lượng tổng phí
SELECT 
    CO.ID, 
    CU.FullName,
	P.PRICE ,
    DATEDIFF(MONTH, CO.StartDate, ISNULL(CO.CheckoutDate, CO.EndDate)) AS RentedMonths,
    DATEDIFF(MONTH, CO.StartDate, ISNULL(CO.CheckoutDate, CO.EndDate)) * P.Price AS EstimatedCost
FROM  CONTRACTS CO
JOIN CUSTOMERS CU ON CO.CustomerID = CU.CustomerID
JOIN Price P ON CO.BedID = P.BedID;
--40.Tìm phòng có nhiều giường nhất mỗi chi nhánh
SELECT R1.BranchID, R1.RoomID, R1.BedCount
FROM ROOMS R1
WHERE R1.BedCount = (
    SELECT MAX(R2.BedCount)
    FROM ROOMS R2
    WHERE R2.BranchID = R1.BranchID
);
----41. Lấy danh sách khách hàng đã đăng ký tạm trú
SELECT * FROM CUSTOMERS
WHERE TemporaryResidenceRegistered LIKE N'Tạm trú'


---42.
SELECT 
    TemporaryResidenceRegistered,
    COUNT(*) AS Total
 FROM CUSTOMERS
GROUP BY TemporaryResidenceRegistered;
--43.Số lượng khách có xe đăng ký (dựa vào VehiclePlate)

SELECT COUNT(*) AS CustomersWithVehicle
FROM CUSTOMERS 
WHERE VehiclePlateType IS NOT NULL AND VehiclePlateType <> '';
--44.Những khách hàng đăng ký app nhưng không đăng ký tạm trú
SELECT FullName, Email, AppRegistered,TemporaryResidenceRegistered
FROM CUSTOMERS 
WHERE AppRegistered = N'Đã đăng kí' AND TemporaryResidenceRegistered = N'Chưa đăng kí';
---45.Danh sách khách hàng có đk app có  đăng kí tạm trú và đang ở
SELECT 
    CU.FullName, 
    CU.Email, 
    CU.AppRegistered,
    CU.TemporaryResidenceRegistered,
    CO.StartDate,
    CO.EndDate,
    CO.CheckoutDate
FROM CUSTOMERS CU
JOIN CONTRACTS CO  ON CU.CustomerID = CO.CustomerID
WHERE 
    CU.AppRegistered = N'Đã đăng kí'
    AND CU.TemporaryResidenceRegistered <> N'Chưa đăng kí'
    AND CO.StartDate <= GETDATE()
    AND (CO.CheckoutDate IS NULL OR CO.CheckoutDate > '2025-01-01');

----46.
SELECT R.RoomID,BranchID, BedCount, Area,RoomGender, Amenities,Position,Price,ElectricityPrice_per_kWh,ParkingFee_per_vehicle,WaterPrice_per_person
FROM ROOMS R 
JOIN BEDS B ON R.RoomID = B.RoomID
JOIN PRICE P ON B.BedID = P.BedID
---47.Lịch sử thuê phòng gần nhất của mỗi khách hàng
WITH RankedContracts AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY customerID ORDER BY startdate DESC) AS rn
    FROM CONTRACTS
)
SELECT C.fullname, RC.startdate, RC.enddate
FROM RankedContracts RC
JOIN CUSTOMERS C ON RC.customerID = c.customerID
WHERE RC.RN = 1 
--48.Đếm số Nam/Nữ theo từng chi nhánh
SELECT 
	B.Name AS BrandName,
	COUNT(CASE WHEN Gender = 'Nam' THEN 1 END ) AS Male,
	COUNT(CASE WHEN Gender = N'Nữ' THEN 1 END ) AS Female
FROM CUSTOMERS CU
JOIN CONTRACTS CO ON CU.CustomerID = CO.CustomerID
JOIN BEDS ON BEDS.BedID = CO.BedID
JOIN ROOMS R ON BEDS.RoomID = R.RoomID
JOIN BRANCH B ON R.BranchID = B.BranchID
GROUP BY B.Name
---49.Tỷ lệ giới tính khách hàng ở mỗi chi nhánh
SELECT 
	B.Name AS BrandName,
	COUNT(CU.CustomerID) AS  NumberOfCustomers
FROM CUSTOMERS CU
JOIN CONTRACTS CO ON CU.CustomerID = CO.CustomerID
JOIN BEDS ON BEDS.BedID = CO.BedID
JOIN ROOMS R ON BEDS.RoomID = R.RoomID
JOIN BRANCH B ON R.BranchID = B.BranchID
GROUP BY B.Name
-- 51.Bao nhiêu khách thuộc nhóm tuổi nào 
SELECT AgeGroup,COUNT( CustomerID) NumOfCustomer
FROM CUSTOMERS
GROUP BY AgeGroup
--52. Thống kê số giường trống của các chi nhánh theo từng quý
SELECT 
    BR.Name AS ChiNhanh,
    COUNT(*) AS SoGiuongTrong,
    N'Q1: 2024-03-01 đến 2024-05-31' AS ThoiGian
FROM BEDS B
    JOIN ROOMS R ON B.RoomID = R.RoomID
    JOIN BRANCH BR ON R.branchID = BR.branchID
WHERE B.BedID NOT IN (
    SELECT BedID FROM CONTRACTS
    WHERE Status IN ('Ongoing','Overdue')
      AND startdate <= '2024-05-31' AND enddate >= '2024-03-01'
)
GROUP BY BR.Name
UNION ALL
SELECT 
    BR.Name AS ChiNhanh,
    COUNT(*) AS SoGiuongTrong,
    N'Q2: 2024-06-01 đến 2024-08-31' AS ThoiGian
FROM BEDS B
    JOIN ROOMS R ON B.RoomID = R.RoomID
    JOIN BRANCH BR ON R.branchID = BR.branchID
WHERE B.BedID NOT IN (
    SELECT BedID FROM CONTRACTS
    WHERE Status IN ('Ongoing','Overdue')
      AND startdate <= '2024-08-31' AND enddate >= '2024-06-01'
)
GROUP BY BR.Name
UNION ALL
SELECT 
    BR.Name AS ChiNhanh,
    COUNT(*) AS SoGiuongTrong,
    N'Q3: 2024-09-01 đến 2024-11-30' AS ThoiGian
FROM BEDS B
    JOIN ROOMS R ON B.RoomID = R.RoomID
    JOIN BRANCH BR ON R.branchID = BR.branchID
WHERE B.BedID NOT IN (
    SELECT BedID FROM CONTRACTS
    WHERE Status IN ('Ongoing','Overdue')
      AND startdate <= '2024-11-30' AND enddate >= '2024-09-01'
)
GROUP BY BR.Name
UNION ALL
SELECT 
    BR.Name AS ChiNhanh,
    COUNT(*) AS SoGiuongTrong,
    N'Q4: 2024-12-01 đến 2025-02-28' AS ThoiGian
FROM BEDS B
    JOIN ROOMs R ON B.RoomID = R.RoomID
    JOIN BRANCH BR ON R.branchID = BR.branchID
WHERE B.BedID NOT IN (
    SELECT BedID FROM CONTRACTS
    WHERE Status IN ('Ongoing','Overdue')
      AND startdate <= '2025-02-28' AND enddate >= '2024-12-01'
)
GROUP BY BR.Name;
--53.Kiểm tra mức độ hồ thiên hồ sơ của các chi nhánh
SELECT 
    BR.Name AS ChiNhanh,
    COUNT(*) AS TongSoKhach,
    
    SUM(
        CASE 
            WHEN C.FullName IS NOT NULL AND
                 C.DateOfBirth IS NOT NULL AND
                 C.Gender IS NOT NULL AND
                 C.IdentityNumber IS NOT NULL AND
                 C.PhoneNumber IS NOT NULL AND
                 C.Address IS NOT NULL AND
                 C.AppRegistered IS NOT NULL AND
                 C.TemporaryResidenceRegistered IS NOT NULL AND
                 C.TempResidenceExpiryDate IS NOT NULL
            THEN 1 ELSE 0
        END
    ) AS SoKhachDayDuHoSo,
    
    SUM(
        CASE 
            WHEN (
                C.FullName IS NULL OR
                C.DateOfBirth IS NULL OR
                C.Gender IS NULL OR
                C.IdentityNumber IS NULL OR
                C.PhoneNumber IS NULL OR
                C.Address IS NULL OR
                C.AppRegistered IS NULL OR
                C.TemporaryResidenceRegistered IS NULL OR
                C.TempResidenceExpiryDate IS NULL
            )
            THEN 1 ELSE 0
        END
    ) AS SoKhachThieuHoSo
    
FROM 
    CUSTOMERS C
    LEFT JOIN CONTRACTS CT ON C.CustomerID = CT.CustomerID
    LEFT JOIN BEDS B ON CT.BedID = B.BedID
    LEFT JOIN ROOMS R ON B.RoomID = R.RoomID
    LEFT JOIN BRANCH BR ON R.BranchID = BR.BranchID

GROUP BY 
    BR.Name
ORDER BY 
    BR.Name;

--54.Thống kê theo chi nhánh & mức độ hoàn thiện

WITH HoSo AS (
    SELECT 
        C.CustomerID,
        BR.Name AS ChiNhanh,
        
        -- Tính số trường đầy đủ
        (
            IIF(C.FullName IS NOT NULL, 1, 0) +
            IIF(C.DateOfBirth IS NOT NULL, 1, 0) +
            IIF(C.Gender IS NOT NULL, 1, 0) +
            IIF(C.IdentityNumber IS NOT NULL, 1, 0) +
            IIF(C.PhoneNumber IS NOT NULL, 1, 0) +
            IIF(C.Address IS NOT NULL, 1, 0) +
            IIF(C.AppRegistered IS NOT NULL, 1, 0) +
            IIF(C.TemporaryResidenceRegistered IS NOT NULL, 1, 0) +
            IIF(C.TempResidenceExpiryDate IS NOT NULL, 1, 0)
        ) AS DiemHoSo
    FROM 
        CUSTOMERS C
        LEFT JOIN CONTRACTS CT ON C.CustomerID = CT.CustomerID
        LEFT JOIN BEDS B ON CT.BedID = B.BedID
        LEFT JOIN ROOMS R ON B.RoomID = R.RoomID
        LEFT JOIN BRANCH BR ON R.BranchID = BR.BranchID
)

SELECT 
    ChiNhanh,
    
    COUNT(*) AS TongKhach,
    
    SUM(CASE WHEN DiemHoSo = 9 THEN 1 ELSE 0 END) AS HoanThien100,
    SUM(CASE WHEN DiemHoSo BETWEEN 7 AND 8 THEN 1 ELSE 0 END) AS HoanThien70_99,
    SUM(CASE WHEN DiemHoSo BETWEEN 4 AND 6 THEN 1 ELSE 0 END) AS TrungBinh40_69,
    SUM(CASE WHEN DiemHoSo BETWEEN 1 AND 3 THEN 1 ELSE 0 END) AS ThieuSot1_39,
    SUM(CASE WHEN DiemHoSo = 0 THEN 1 ELSE 0 END) AS KhongCoThongTin

FROM HoSo
GROUP BY ChiNhanh
ORDER BY ChiNhanh;
-- 55.Tỷ lệ phòng trống từng quý từ 1/3/24 đến 31/3/15 tỉ lệ phòng trống
WITH Quarters AS (
    SELECT 1 AS QuarterID, '2024-03-01' AS StartDate, '2024-05-31' AS EndDate
    UNION ALL
    SELECT 2, '2024-06-01', '2024-08-31'
    UNION ALL
    SELECT 3, '2024-09-01', '2024-11-30'
    UNION ALL
    SELECT 4, '2024-12-01', '2025-02-28'
    UNION ALL
    SELECT 5, '2025-03-01', '2025-03-31'
),

OccupiedBeds AS (
    SELECT 
        Q.QuarterID,
        B.BedID
    FROM 
        CONTRACTS C
        JOIN BEDS B ON C.BedID = B.BedID
        JOIN Quarters Q 
            ON C.StartDate <= Q.EndDate AND C.EndDate >= Q.StartDate
        WHERE C.Status NOT IN ('Terminated Early', 'Terminated Late') -- lọc hợp đồng hủy sớm, muộn
        GROUP BY Q.QuarterID, B.BedID
),

TotalBeds AS (
    SELECT 
        B.BedID
    FROM BEDS B
),

Result AS (
    SELECT 
        Q.QuarterID,
        Q.StartDate,
        Q.EndDate,
        COUNT(DISTINCT TB.BedID) AS TotalBeds,
        COUNT(DISTINCT OB.BedID) AS BedsOccupied,
        COUNT(DISTINCT TB.BedID) - COUNT(DISTINCT OB.BedID) AS BedsEmpty
    FROM Quarters Q
    CROSS JOIN TotalBeds TB
    LEFT JOIN OccupiedBeds OB 
        ON TB.BedID = OB.BedID AND Q.QuarterID = OB.QuarterID
    GROUP BY Q.QuarterID, Q.StartDate, Q.EndDate
)

SELECT 
    'Q' + CAST(QuarterID AS VARCHAR) AS Quy,
    StartDate,
    EndDate,
    TotalBeds,
    BedsEmpty,
    CAST(BedsEmpty * 100.0 / NULLIF(TotalBeds, 0) AS DECIMAL(5,2)) AS TyLePhongTrong
FROM Result
ORDER BY QuarterID;
---56. Tỉ lệ phòng trồng từng quý của từng chi nhánh
WITH Quarters AS (
    SELECT 1 AS QuarterID, '2024-03-01' AS StartDate, '2024-05-31' AS EndDate
    UNION ALL
    SELECT 2, '2024-06-01', '2024-08-31'
    UNION ALL
    SELECT 3, '2024-09-01', '2024-11-30'
    UNION ALL
    SELECT 4, '2024-12-01', '2025-02-28'
    UNION ALL
    SELECT 5, '2025-03-01', '2025-03-31'
),

-- Tính giường đã được sử dụng theo từng quý và từng chi nhánh
OccupiedBeds AS (
    SELECT 
        Q.QuarterID,
        BR.Name AS BranchName,
        B.BedID
    FROM CONTRACTS C
    JOIN BEDS B ON C.BedID = B.BedID
    JOIN ROOMS R ON B.RoomID = R.RoomID
    JOIN BRANCH BR ON R.BranchID = BR.BranchID
    JOIN Quarters Q 
        ON C.StartDate <= Q.EndDate AND C.EndDate >= Q.StartDate
    WHERE C.Status NOT IN ('Terminated Early', 'Terminated Late') 
    GROUP BY Q.QuarterID, BR.Name, B.BedID
),

-- Lấy tất cả giường và chi nhánh của giường đó
TotalBeds AS (
    SELECT 
        BR.Name AS BranchName,
        B.BedID
    FROM BEDS B
    JOIN ROOMS R ON B.RoomID = R.RoomID
    JOIN BRANCH BR ON R.BranchID = BR.BranchID
),

-- Kết hợp để tính tổng số giường, giường trống theo quý và chi nhánh
Result AS (
    SELECT 
        Q.QuarterID,
        Q.StartDate,
        Q.EndDate,
        TB.BranchName,
        COUNT(DISTINCT TB.BedID) AS TotalBeds,
        COUNT(DISTINCT OB.BedID) AS BedsOccupied,
        COUNT(DISTINCT TB.BedID) - COUNT(DISTINCT OB.BedID) AS BedsEmpty
    FROM Quarters Q
    CROSS JOIN (SELECT DISTINCT BranchName FROM TotalBeds) Branches
    JOIN TotalBeds TB ON TB.BranchName = Branches.BranchName
    LEFT JOIN OccupiedBeds OB 
        ON TB.BedID = OB.BedID AND Q.QuarterID = OB.QuarterID
    GROUP BY Q.QuarterID, Q.StartDate, Q.EndDate, TB.BranchName
)

-- Xuất kết quả
SELECT 
    BranchName,
    'Q' + CAST(QuarterID AS VARCHAR) AS Quy,
    StartDate,
    EndDate,
    TotalBeds,
    BedsEmpty,
    CAST(BedsEmpty * 100.0 / NULLIF(TotalBeds, 0) AS DECIMAL(5,2)) AS TyLePhongTrong
FROM Result
ORDER BY BranchName, QuarterID;



------------------------------Tính doanh thu thực nhận của mỗi hợp đồng tới thời điểm 31/3/2025
SELECT 
    C.ID, 
    C.CustomerID, 
    C.BedID, 
    C.StartDate,
    C.EndDate,
    C.CheckoutDate,
    P.Price,

    -- Ngày kết thúc thực tế: nếu CheckoutDate có thì lấy CheckoutDate, không thì lấy EndDate
    CASE 
        WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
        ELSE C.EndDate
    END AS ActualEndDate,

    -- Ngày tính doanh thu: lấy ngày nhỏ nhất giữa ActualEndDate và 31/03/2025
    CASE 
        WHEN 
            CASE 
                WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                ELSE C.EndDate
            END < '2025-03-31' 
        THEN 
            CASE 
                WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                ELSE C.EndDate
            END
        ELSE '2025-03-31'
    END AS RevenueEndDate,

    -- Tính số tháng thực thuê = tháng tròn từ StartDate đến RevenueEndDate
    CASE 
        WHEN DAY(
            CASE 
                WHEN 
                    CASE 
                        WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                        ELSE C.EndDate
                    END < '2025-03-31' 
                THEN 
                    CASE 
                        WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                        ELSE C.EndDate
                    END
                ELSE '2025-03-31'
            END
        ) >= DAY(C.StartDate)
        THEN DATEDIFF(MONTH, C.StartDate, 
            CASE 
                WHEN 
                    CASE 
                        WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                        ELSE C.EndDate
                    END < '2025-03-31' 
                THEN 
                    CASE 
                        WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                        ELSE C.EndDate
                    END
                ELSE '2025-03-31'
            END
        )
        ELSE DATEDIFF(MONTH, C.StartDate, 
            CASE 
                WHEN 
                    CASE 
                        WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                        ELSE C.EndDate
                    END < '2025-03-31' 
                THEN 
                    CASE 
                        WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                        ELSE C.EndDate
                    END
                ELSE '2025-03-31'
            END
        ) - 1
    END + 1 AS TrueMonths,

    -- Tính doanh thu thực = TrueMonths * Price
    CASE 
        WHEN C.StartDate > '2025-03-31' THEN 0
        ELSE
            (
            CASE 
                WHEN DAY(
                    CASE 
                        WHEN 
                            CASE 
                                WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                                ELSE C.EndDate
                            END < '2025-03-31' 
                        THEN 
                            CASE 
                                WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                                ELSE C.EndDate
                            END
                        ELSE '2025-03-31'
                    END
                ) >= DAY(C.StartDate)
                THEN DATEDIFF(MONTH, C.StartDate, 
                    CASE 
                        WHEN 
                            CASE 
                                WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                                ELSE C.EndDate
                            END < '2025-03-31' 
                        THEN 
                            CASE 
                                WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                                ELSE C.EndDate
                            END
                        ELSE '2025-03-31'
                    END
                )
                ELSE DATEDIFF(MONTH, C.StartDate, 
                    CASE 
                        WHEN 
                            CASE 
                                WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                                ELSE C.EndDate
                            END < '2025-03-31' 
                        THEN 
                            CASE 
                                WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                                ELSE C.EndDate
                            END
                        ELSE '2025-03-31'
                    END
                ) - 1
            END + 1
            ) * P.Price
    END AS Revenue_Until_31_03_2025

FROM CONTRACTS C
JOIN PRICE P ON C.BedID = P.BedID
WHERE C.StartDate <= '2025-03-31'

----------------Doanh thu tổng
WITH RevenueData AS (
    SELECT 
        C.ID, 
        C.CustomerID, 
        C.BedID, 
        C.StartDate,
        C.EndDate,
        C.CheckoutDate,
        P.Price,
        CASE 
            WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
            ELSE C.EndDate
        END AS ActualEndDate,
        CASE 
            WHEN 
                CASE 
                    WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                    ELSE C.EndDate
                END < '2025-03-31' 
            THEN 
                CASE 
                    WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                    ELSE C.EndDate
                END
            ELSE '2025-03-31'
        END AS RevenueEndDate,
        CASE 
            WHEN DAY(
                CASE 
                    WHEN 
                        CASE 
                            WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                            ELSE C.EndDate
                        END < '2025-03-31' 
                    THEN 
                        CASE 
                            WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                            ELSE C.EndDate
                        END
                    ELSE '2025-03-31'
                END
            ) >= DAY(C.StartDate)
            THEN DATEDIFF(MONTH, C.StartDate, 
                CASE 
                    WHEN 
                        CASE 
                            WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                            ELSE C.EndDate
                        END < '2025-03-31' 
                    THEN 
                        CASE 
                            WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                            ELSE C.EndDate
                        END
                    ELSE '2025-03-31'
                END
            )
            ELSE DATEDIFF(MONTH, C.StartDate, 
                CASE 
                    WHEN 
                        CASE 
                            WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                            ELSE C.EndDate
                        END < '2025-03-31' 
                    THEN 
                        CASE 
                            WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                            ELSE C.EndDate
                        END
                    ELSE '2025-03-31'
                END
            ) - 1
        END + 1 AS TrueMonths,
        CASE 
            WHEN C.StartDate > '2025-03-31' THEN 0
            ELSE
                (
                CASE 
                    WHEN DAY(
                        CASE 
                            WHEN 
                                CASE 
                                    WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                                    ELSE C.EndDate
                                END < '2025-03-31' 
                            THEN 
                                CASE 
                                    WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                                    ELSE C.EndDate
                                END
                            ELSE '2025-03-31'
                        END
                    ) >= DAY(C.StartDate)
                    THEN DATEDIFF(MONTH, C.StartDate, 
                        CASE 
                            WHEN 
                                CASE 
                                    WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                                    ELSE C.EndDate
                                END < '2025-03-31' 
                            THEN 
                                CASE 
                                    WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                                    ELSE C.EndDate
                                END
                            ELSE '2025-03-31'
                        END
                    )
                    ELSE DATEDIFF(MONTH, C.StartDate, 
                        CASE 
                            WHEN 
                                CASE 
                                    WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                                    ELSE C.EndDate
                                END < '2025-03-31' 
                            THEN 
                                CASE 
                                    WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
                                    ELSE C.EndDate
                                END
                            ELSE '2025-03-31'
                        END
                    ) - 1
                END + 1
                ) * P.Price
        END AS Revenue_Until_31_03_2025
    FROM CONTRACTS C
    JOIN PRICE P ON C.BedID = P.BedID
    WHERE C.StartDate <= '2025-03-31'
)
SELECT SUM(Revenue_Until_31_03_2025) AS TotalRevenue_Until_31_03_2025
FROM RevenueData;
-------------------- Tỉ lệ lắp đày vào tháng 3/2025
SELECT 
    CAST(COUNT(DISTINCT C.BedID) AS FLOAT) / COUNT(B.BedID) AS OccupiedRate
FROM 
    BEDS B
LEFT JOIN CONTRACTS C ON B.BedID = C.BedID AND C.Status IN ('Overdue','Ongoing');

-----------------------------------
--------- TÍNH DOANH THU TỪNG THÁNG TỪ 3/2024- 3/2025

-- 1. Tạo danh sách các tháng từ 03/2024 đến 03/2025
WITH Months AS (
    SELECT CAST('2024-03-01' AS DATE) AS MonthStart
    UNION ALL
    SELECT DATEADD(MONTH, 1, MonthStart)
    FROM Months
    WHERE MonthStart < '2025-03-01'
),

-- 2. Tính ngày kết thúc thực tế của từng hợp đồng
ContractsAdjusted AS (
    SELECT 
        C.ID,
        C.CustomerID,
        C.BedID,
        C.StartDate,
        C.EndDate,
        C.CheckoutDate,
        P.Price,
        CASE 
            WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
            ELSE C.EndDate
        END AS ActualEndDate
    FROM CONTRACTS C
    JOIN PRICE P ON C.BedID = P.BedID
    WHERE C.StartDate <= '2025-03-31'
),

-- 3. Tính doanh thu chi tiết theo từng hợp đồng và từng tháng
RevenueDetail AS (
    SELECT
        FORMAT(M.MonthStart, 'yyyy-MM') AS Month,
        CASE 
            WHEN M.MonthStart BETWEEN 
                 DATEFROMPARTS(YEAR(CA.StartDate), MONTH(CA.StartDate), 1) 
                 AND DATEFROMPARTS(YEAR(CA.ActualEndDate), MONTH(CA.ActualEndDate), 1)
            THEN CA.Price
            ELSE 0
        END AS RevenuePerMonth
    FROM ContractsAdjusted CA
    CROSS JOIN Months M
    WHERE NOT (
        CA.StartDate > EOMONTH(M.MonthStart) OR
        CA.ActualEndDate < M.MonthStart
    )
),

-- 4. Tổng doanh thu theo từng tháng
RevenueByMonth AS (
    SELECT 
        Month,
        SUM(RevenuePerMonth) AS TotalRevenue
    FROM RevenueDetail
    GROUP BY Month
)

-- 5. Xuất kết quả + dòng tổng, dùng thêm cột sắp xếp
SELECT 
    Month,
    TotalRevenue,
    0 AS SortOrder
FROM RevenueByMonth

UNION ALL

SELECT 
    N'Tổng cộng',
    SUM(TotalRevenue),
    1
FROM RevenueByMonth

ORDER BY SortOrder, Month
OPTION (MAXRECURSION 1000);
------------- TÍNH DOANH THU THEO TỪNG CHI NHÁNH
-- 1. Tạo danh sách các tháng từ 03/2024 đến 03/2025
WITH Months AS (
    SELECT CAST('2024-03-01' AS DATE) AS MonthStart
    UNION ALL
    SELECT DATEADD(MONTH, 1, MonthStart)
    FROM Months
    WHERE MonthStart < '2025-03-01'
),

-- 2. Tính ngày kết thúc thực tế và gắn BranchName cho từng hợp đồng
ContractsAdjusted AS (
    SELECT 
        C.ID,
        C.CustomerID,
        C.BedID,
        C.StartDate,
        C.EndDate,
        C.CheckoutDate,
        P.Price,
        BRC.Name,
        CASE 
            WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
            ELSE C.EndDate
        END AS ActualEndDate
    FROM CONTRACTS C
    JOIN PRICE P ON C.BedID = P.BedID
    JOIN BEDS BD ON P.BedID= BD.BedID
    JOIN ROOMS R ON BD.RoomID = R.RoomID
    JOIN BRANCH BRC ON R.BranchID = BRC.BranchID
    WHERE C.StartDate <= '2025-03-31'
),

-- 3. Tính doanh thu chi tiết theo từng hợp đồng, tháng, và chi nhánh
RevenueDetail AS (
    SELECT
        CA.Name,
        FORMAT(M.MonthStart, 'yyyy-MM') AS Month,
        CASE 
            WHEN M.MonthStart BETWEEN 
                 DATEFROMPARTS(YEAR(CA.StartDate), MONTH(CA.StartDate), 1) 
                 AND DATEFROMPARTS(YEAR(CA.ActualEndDate), MONTH(CA.ActualEndDate), 1)
            THEN CA.Price
            ELSE 0
        END AS RevenuePerMonth
    FROM ContractsAdjusted CA
    CROSS JOIN Months M
    WHERE NOT (
        CA.StartDate > EOMONTH(M.MonthStart) OR
        CA.ActualEndDate < M.MonthStart
    )
),

-- 4. Tổng doanh thu theo chi nhánh
RevenueByBranch AS (
    SELECT 
      Name,
        SUM(RevenuePerMonth) AS TotalRevenue
    FROM RevenueDetail
    GROUP BY Name
)

-- 5. Xuất kết quả + dòng tổng
SELECT 
    Name,
    TotalRevenue,
    0 AS SortOrder
FROM RevenueByBranch

UNION ALL

SELECT 
    N'Tổng cộng',
    SUM(TotalRevenue),
    1
FROM RevenueByBranch

ORDER BY SortOrder, Name
OPTION (MAXRECURSION 1000);




-----TÍNH TĂNG TRƯỞNG DOANH THU THEO QUÝ TỪ 3/2024 - 3/2025
-- 1. Tạo danh sách các tháng từ 03/2024 đến 03/2025
WITH Months AS (
    SELECT CAST('2024-03-01' AS DATE) AS MonthStart
    UNION ALL
    SELECT DATEADD(MONTH, 1, MonthStart)
    FROM Months
    WHERE MonthStart < '2025-03-01'
),

-- Các CTE khác giữ nguyên như bạn đã viết

ContractsAdjusted AS (
    SELECT 
        C.ID,
        C.BedID,
        C.StartDate,
        C.EndDate,
        C.CheckoutDate,
        P.Price,
        CASE 
            WHEN C.CheckoutDate IS NOT NULL AND C.CheckoutDate < C.EndDate THEN C.CheckoutDate
            ELSE C.EndDate
        END AS ActualEndDate
    FROM CONTRACTS C
    JOIN PRICE P ON C.BedID = P.BedID
    WHERE C.StartDate <= '2025-03-31'
),

ContractMonths AS (
    SELECT 
        CA.ID AS ContractID,
        STRING_AGG(FORMAT(M.MonthStart, 'yyyy-MM'), ', ') WITHIN GROUP (ORDER BY M.MonthStart) AS ContractMonthsList
    FROM ContractsAdjusted CA
    JOIN Months M
      ON M.MonthStart BETWEEN DATEFROMPARTS(YEAR(CA.StartDate), MONTH(CA.StartDate), 1)
                         AND DATEFROMPARTS(YEAR(CA.ActualEndDate), MONTH(CA.ActualEndDate), 1)
    GROUP BY CA.ID
),

RevenueDetail AS (
    SELECT
        FORMAT(M.MonthStart, 'yyyy-MM') AS Month,
        YEAR(M.MonthStart) AS RevenueYear,
        DATEPART(QUARTER, M.MonthStart) AS RevenueQuarter,
        CA.ID AS ContractID,
        CA.BedID,
        CA.Price,
        CASE 
            WHEN M.MonthStart BETWEEN 
                 DATEFROMPARTS(YEAR(CA.StartDate), MONTH(CA.StartDate), 1) 
                 AND DATEFROMPARTS(YEAR(CA.ActualEndDate), MONTH(CA.ActualEndDate), 1)
            THEN CA.Price
            ELSE 0
        END AS RevenuePerMonth
    FROM ContractsAdjusted CA
    CROSS JOIN Months M
    WHERE NOT (
        CA.StartDate > EOMONTH(M.MonthStart) OR
        CA.ActualEndDate < M.MonthStart
    )
),

RevenueByQuarter AS (
    SELECT 
        CONCAT('Q', RevenueQuarter, '/', RevenueYear) AS Quarter,
        RevenueYear,
        RevenueQuarter,
        SUM(RevenuePerMonth) AS TotalRevenue
    FROM RevenueDetail
    GROUP BY RevenueYear, RevenueQuarter
),

RevenueWithGrowth AS (
    SELECT 
        RB.Quarter,
        RB.TotalRevenue,
        RB.RevenueYear,
        RB.RevenueQuarter,
        LAG(RB.TotalRevenue) OVER (ORDER BY RB.RevenueYear, RB.RevenueQuarter) AS PrevRevenue,
        ROUND(
            CASE 
                WHEN LAG(RB.TotalRevenue) OVER (ORDER BY RB.RevenueYear, RB.RevenueQuarter) IS NOT NULL 
                     AND LAG(RB.TotalRevenue) OVER (ORDER BY RB.RevenueYear, RB.RevenueQuarter) > 0
                THEN 
                    CAST(RB.TotalRevenue - LAG(RB.TotalRevenue) OVER (ORDER BY RB.RevenueYear, RB.RevenueQuarter) AS FLOAT) 
                    / LAG(RB.TotalRevenue) OVER (ORDER BY RB.RevenueYear, RB.RevenueQuarter)
                ELSE NULL
            END, 4
        ) AS GrowthRate
    FROM RevenueByQuarter RB
),

-- Tạo danh sách tháng theo quý
MonthsByQuarter AS (
    SELECT
        CONCAT('Q', DATEPART(QUARTER, MonthStart), '/', YEAR(MonthStart)) AS Quarter,
        STRING_AGG(FORMAT(MonthStart, 'yyyy-MM'), ', ') WITHIN GROUP (ORDER BY MonthStart) AS MonthsInQuarter
    FROM Months
    GROUP BY YEAR(MonthStart), DATEPART(QUARTER, MonthStart)
)

-- Lấy kết quả cuối cùng
SELECT 
    RQ.Quarter,
    RQ.TotalRevenue,
    ISNULL(RQ.GrowthRate * 100, 0) AS GrowthPercent,
    MQ.MonthsInQuarter
FROM RevenueWithGrowth RQ
LEFT JOIN MonthsByQuarter MQ ON RQ.Quarter = MQ.Quarter
ORDER BY RQ.RevenueYear, RQ.RevenueQuarter
OPTION (MAXRECURSION 1000);



---------------
WITH Quarters AS (
    SELECT 'Q1/2024' AS Quarter, '2024-03-01' AS StartDate, '2024-03-31' AS EndDate
    UNION ALL
    SELECT 'Q2/2024', '2024-04-01', '2024-06-30'
    UNION ALL
    SELECT 'Q3/2024', '2024-07-01', '2024-09-30'
    UNION ALL
    SELECT 'Q4/2024', '2024-10-01', '2024-12-31'
    UNION ALL
    SELECT 'Q1/2025', '2025-01-01', '2025-03-31'
),
ContractWithQuarter AS (
    SELECT 
        Q.Quarter,
        C.CustomerID
    FROM Quarters Q
    JOIN CONTRACTS C 
        ON (
            (C.StartDate BETWEEN Q.StartDate AND Q.EndDate)
            OR 
            (C.EndDate BETWEEN Q.StartDate AND Q.EndDate)
        )
)

SELECT 
    Quarter,
    COUNT(DISTINCT CustomerID) AS CustomerCount
FROM ContractWithQuarter
GROUP BY Quarter
ORDER BY Quarter;
