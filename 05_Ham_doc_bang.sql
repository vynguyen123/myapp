CREATE DATABASE TestDB
GO
USE TestDB
GO
USE HumanResource
GO
--Tra cứu nhân viên
CREATE FUNCTION dbo.Danh_sach_nhan_vien(@depid numeric(3,0))
RETURNS table
AS
	RETURN 
		SELECT * 
		FROM EMPLOYEES 
		WHERE DEPARTMENT_ID=@depid OR @depid=0
GO
--Test
SELECT * FROM dbo.Danh_sach_nhan_vien(90)
SELECT * FROM dbo.Danh_sach_nhan_vien(0)
SELECT * FROM dbo.Danh_sach_nhan_vien(NULL)
GO
--
CREATE FUNCTION dbo.Danh_sach_nhan_vien_Vi_tri(@loc numeric(4,0))
RETURNS table
AS
	RETURN 
		SELECT e.* 
		FROM EMPLOYEES e JOIN DEPARTMENTS d ON e.DEPARTMENT_ID=d.DEPARTMENT_ID
		WHERE d.LOCATION_ID=@loc
GO
--Test
SELECT * FROM dbo.Danh_sach_nhan_vien_Vi_tri(1400)
GO
--
CREATE FUNCTION dbo.Danh_sach_Quan_ly()
RETURNS table
AS
	RETURN 
		SELECT * 
		FROM EMPLOYEES 
		WHERE EMPLOYEE_ID IN (SELECT DISTINCT MANAGER_ID FROM EMPLOYEES)
GO
--Test
SELECT * FROM dbo.Danh_sach_Quan_ly()
GO
--
CREATE FUNCTION dbo.Danh_sach_Quan_ly_Vi_tri(@loc numeric(4,0))
RETURNS table
AS
	RETURN 
		SELECT q.* 
		FROM dbo.Danh_sach_Quan_ly() q JOIN DEPARTMENTS d
			ON q.DEPARTMENT_ID=d.DEPARTMENT_ID
		WHERE d.LOCATION_ID=@loc
GO
--Test
SELECT * FROM dbo.Danh_sach_Quan_ly_Vi_tri(1700)
GO


