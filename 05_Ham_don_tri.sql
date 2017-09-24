--Hàm đơn trị - Scalar function
CREATE DATABASE TestDB
GO
USE TestDB
GO
--
CREATE FUNCTION dbo.Dien_tich_hinh_tron (@Ban_kinh float =1.0)
RETURNS float
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
	RETURN PI() * POWER(@Ban_kinh, 2)
END
GO
SELECT dbo.Dien_tich_hinh_tron(10.0)
SELECT dbo.Dien_tich_hinh_tron(2.5)
SELECT dbo.Dien_tich_hinh_tron(NULL)
SELECT dbo.Dien_tich_hinh_tron(DEFAULT)
GO
--
CREATE FUNCTION dbo.Giai_thua (@n int = 1)
RETURNS decimal(38, 0)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
	RETURN
		(CASE
			WHEN @n < 0 THEN NULL
			WHEN @n = 0 THEN 1
			WHEN @n > 1 THEN CAST(@n AS float) * dbo.Giai_thua (@n - 1)
			WHEN @n = 1 THEN 1
		END)
END
GO
SELECT dbo.Giai_thua(5)
SELECT dbo.Giai_thua(32)
SELECT dbo.Giai_thua(33)
GO
USE HumanResource
GO
--
CREATE FUNCTION dbo.Dem_so_nhan_vien(@depid numeric(4,0))
RETURNS smallint
AS
BEGIN
	DECLARE @Kq smallint
	--
	SELECT @Kq = COUNT(*)
	FROM EMPLOYEES
	WHERE DEPARTMENT_ID=@depid
	--
	RETURN @Kq
END
GO
PRINT dbo.Dem_so_nhan_vien(50)
SELECT DEPARTMENT_ID, DEPARTMENT_NAME, dbo.Dem_so_nhan_vien(DEPARTMENT_ID)
FROM DEPARTMENTS
GO
USE QLSinhVien
GO
CREATE FUNCTION dbo.Chuoi_Thong_tin_Sinh_vien(@Ma_sinh_vien char(3))
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @Kq nvarchar(max) = ''
	DECLARE @ho_ten NVARCHAR(50), @ngay_sinh AS DATE, @gioi_tinh AS BIT, @diem_trung_binh DECIMAL(3,1)
	--
	SELECT @ho_ten = Ho_sinh_vien + ' ' + Ten_sinh_vien, @ngay_sinh = Ngay_sinh, @gioi_tinh = Gioi_tinh  
	FROM SINH_VIEN WHERE Ma_sinh_vien=@Ma_sinh_vien
	--
	SELECT @diem_trung_binh=AVG(diem)
	FROM KET_QUA
	WHERE Ma_sinh_vien=@ma_sinh_vien
	--Xử lý in
	SET @Kq = @Kq + N'Mã số: ' + @Ma_sinh_vien + CHAR(13)
	SET @Kq = @Kq + N'Họ tên: ' + @ho_ten + CHAR(13)
	SET @Kq = @Kq + N'Ngày sinh: ' + FORMAT(@ngay_sinh,'dd/MM/yyyy') + CHAR(13)
	SET @Kq = @Kq + N'Phái: ' + IIF(@gioi_tinh=1,N'Nam',N'Nữ') + CHAR(13)
	SET @Kq = @Kq + N'Điểm Trung bình: ' + STR(@diem_trung_binh,4,1) + CHAR(13)
	--
	RETURN @Kq
END
GO
PRINT dbo.Chuoi_Thong_tin_Sinh_vien('C05')
SELECT dbo.Chuoi_Thong_tin_Sinh_vien(Ma_sinh_vien)
FROM SINH_VIEN
WHERE Ma_sinh_vien BETWEEN 'C01' AND 'C10'
GO
--Hàm kiểm tra
USE HumanResource
GO
--
CREATE FUNCTION dbo.Kiem_tra_phong_ban(@depid numeric(4,0))
RETURNS tinyint
AS
BEGIN
	DECLARE @Kq tinyint =0
	--
	IF @Kq=0 AND NOT EXISTS(SELECT NULL FROM DEPARTMENTS WHERE DEPARTMENT_ID=@depid)
		SET @Kq = 1
	IF @Kq=0 AND NOT EXISTS(SELECT NULL FROM EMPLOYEES WHERE DEPARTMENT_ID=@depid)
		SET @Kq = 2
	--
	RETURN @Kq
END
GO
CREATE PROCEDURE spud_Dem_so_nhan_vien @depid numeric(4,0)
AS
	DECLARE @loi tinyint = dbo.Kiem_tra_phong_ban(@depid)
	--
	IF @loi=0
	BEGIN
		DECLARE @so_nhan_vien smallint
		SET @so_nhan_vien = dbo.Dem_so_nhan_vien(@depid)
		PRINT CONCAT(N'Số nhân viên: ', @so_nhan_vien)
	END
	ELSE IF @loi=1
		PRINT N'Mã phòng không hợp lệ!'
	ELSE IF @loi=2
		PRINT N'Phòng này không có nhân viên!'
GO
--Test ...
EXEC spud_Dem_so_nhan_vien 80
EXEC spud_Dem_so_nhan_vien 800
EXEC spud_Dem_so_nhan_vien 200
GO
--
CREATE TABLE THONG_BAO_LOI
(
	ID int IDENTITY PRIMARY KEY,
	Ten_bang nvarchar(30),
	Ma_loi int,
	Thong_bao nvarchar(max)
)
GO
INSERT INTO THONG_BAO_LOI(Ten_bang, Ma_loi, Thong_bao) 
VALUES(N'DEPARTMENTS', 1, N'Mã phòng không hợp lệ!')
INSERT INTO THONG_BAO_LOI(Ten_bang, Ma_loi, Thong_bao) 
VALUES(N'DEPARTMENTS', 2, N'Phòng này không có nhân viên!')
GO
CREATE FUNCTION dbo.Doc_Thong_bao_Loi(@Ten_bang nvarchar(30), @Ma_loi int)
RETURNS nvarchar(max)
AS
BEGIN
	RETURN (SELECT Thong_bao FROM THONG_BAO_LOI WHERE Ten_bang=@Ten_bang AND Ma_loi=@Ma_loi)
END
GO
ALTER PROCEDURE spud_Dem_so_nhan_vien @depid numeric(4,0)
AS
	DECLARE @loi tinyint = dbo.Kiem_tra_phong_ban(@depid)
	DECLARE @so_nhan_vien smallint
	--
	IF @loi=0
	BEGIN
		SET @so_nhan_vien = dbo.Dem_so_nhan_vien(@depid)
		PRINT CONCAT(N'Số nhân viên: ', @so_nhan_vien)
	END
	ELSE
		PRINT dbo.Doc_Thong_bao_Loi('DEPARTMENTS', @loi)
GO
--Test ...
EXEC spud_Dem_so_nhan_vien 80
EXEC spud_Dem_so_nhan_vien 800
EXEC spud_Dem_so_nhan_vien 200
GO
USE TestDB
GO
CREATE TYPE udt_Danh_sach_Chuoi AS TABLE
(
	Chuoi nvarchar(50)
)
GO
CREATE FUNCTION dbo.Tao_chuoi(@Chuoi nvarchar(1000), @Danh_sach udt_Danh_sach_Chuoi READONLY)
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @Kq nvarchar(max) = @Chuoi
	DECLARE @bang_tam table(id int identity, chuoi nvarchar(50))
	--
	INSERT INTO @bang_tam(chuoi)
	SELECT Chuoi FROM @Danh_sach
	--
	DECLARE @i tinyint =1
	WHILE @i <= (SELECT COUNT(*) FROM @bang_tam)
	BEGIN
		DECLARE @chuoi_thay nvarchar(50) = (SELECT chuoi FROM @bang_tam WHERE id=@i)
		SET @Kq = REPLACE(@Kq, CONCAT('{',@i,'}'), @chuoi_thay)
		--
		SET @i = @i+1
	END
	--
	RETURN @Kq
END
GO
--Test ...
SET NOCOUNT ON
DECLARE @Danh_sach_tri udt_Danh_sach_Chuoi
INSERT INTO @Danh_sach_tri
VALUES (12), (14), (26)
--
DECLARE @Chuoi nvarchar(1000) =N'Tổng của {1} và {2} là {3}'
DECLARE @Ket_qua nvarchar(max) = dbo.Tao_chuoi(@Chuoi, @Danh_sach_tri)
PRINT @Ket_qua
GO
DECLARE @nam_thang char(6) = '201610'
DECLARE @ngay date = CAST(LEFT(@nam_thang,4) + '-' + RIGHT(@nam_thang,2) + '-' + '01' AS date)
SET @ngay = DATEADD(m, 1, @ngay)
DECLARE @nam_thang_ke char(6) = CONVERT(char(6), @ngay, 112)
PRINT @nam_thang_ke




