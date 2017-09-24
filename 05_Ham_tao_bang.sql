USE HumanResource
GO
--
CREATE FUNCTION dbo.Thong_ke_nhan_vien()
RETURNS @bang table(Maphong numeric(3,0), Tenphong nvarchar(30), Sonv tinyint)
AS
BEGIN
	INSERT INTO @bang
	SELECT e.DEPARTMENT_ID, d.DEPARTMENT_NAME, COUNT(*) FROM EMPLOYEES e JOIN DEPARTMENTS d ON e.DEPARTMENT_ID=d.DEPARTMENT_ID
	GROUP BY e.DEPARTMENT_ID, d.DEPARTMENT_NAME
	--
	RETURN
END
GO
--Test ...
--fix user
SELECT * FROM dbo.Thong_ke_nhan_vien()
GO
--
CREATE TYPE kieu_Danh_sach_Chuoi AS TABLE
(
	chuoi nvarchar(100)
)
GO
CREATE PROC spud_Danh_sach_nhan_vien(@Danh_sach_phong kieu_Danh_sach_Chuoi READONLY)
AS
	SET NOCOUNT ON
	--
	SELECT *
	FROM EMPLOYEES
	WHERE DEPARTMENT_ID IN (SELECT chuoi FROM @Danh_sach_phong)
	ORDER BY DEPARTMENT_ID
GO
--Test ...
DECLARE @Danh_sach kieu_Danh_sach_Chuoi
INSERT INTO @Danh_sach VALUES(70)
INSERT INTO @Danh_sach VALUES(80)
INSERT INTO @Danh_sach VALUES(90)
EXEC spud_Danh_sach_nhan_vien @Danh_sach
GO
--
CREATE FUNCTION dbo.Tach_chuoi(@Chuoi nvarchar(max), @dau_cach char(1) =' ')
RETURNS @bang_ket_qua table(chuoi nvarchar(100))
AS
BEGIN
	IF RIGHT(@Chuoi,1) != @dau_cach
		SET @Chuoi = @Chuoi + @dau_cach
	--
	WHILE CHARINDEX(@dau_cach,@Chuoi) > 0
	BEGIN
		DECLARE @i int = CHARINDEX(@dau_cach, @Chuoi)
		DECLARE @chuoi_con nvarchar(100) = SUBSTRING(@Chuoi, 1, @i-1)
		SET @chuoi_con = RTRIM(LTRIM(@chuoi_con))
		INSERT INTO @bang_ket_qua VALUES(@chuoi_con)
		SET @Chuoi = STUFF(@Chuoi, 1, @i,'')
	END
	--
	RETURN
END
GO
--Test ...
SELECT * FROM dbo.Tach_chuoi(N'Ao thu lạnh lẽo nước trong veo', DEFAULT)
SELECT * FROM dbo.Tach_chuoi(N'C01, C02, C03, C04', ',')
GO
--
CREATE PROC spud_Danh_sach_nhan_vien_Phong @Chuoi nvarchar(max)
AS
	SET NOCOUNT ON
	--
	DECLARE @Danh_sach kieu_Danh_sach_Chuoi
	--
	INSERT INTO @Danh_sach
	SELECT chuoi FROM dbo.Tach_chuoi(@Chuoi, DEFAULT)
	--
	EXEC spud_Danh_sach_nhan_vien @Danh_sach
GO
--Test ...
EXEC spud_Danh_sach_nhan_vien_Phong '70 80 90'
GO
CREATE FUNCTION Danh_sach_nhan_vien_Phong(@Chuoi nvarchar(max))
RETURNS table
AS
	RETURN
		SELECT *
		FROM EMPLOYEES
		WHERE DEPARTMENT_ID IN (SELECT chuoi 
								FROM dbo.Tach_chuoi(@Chuoi, DEFAULT))
GO
--Test
SELECT * FROM dbo.Danh_sach_nhan_vien_Phong('70 80 90')
