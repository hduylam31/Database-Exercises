﻿CREATE DATABASE QuanLyHoaDon
Go
USE QuanLyHoaDon

CREATE TABLE KHACHHANG (
	MAKH char(10) PRIMARY KEY,
	HO nvarchar(20) NOT NULL,
	TEN nvarchar(20) NOT NULL,
	NGSINH SMALLDATETIME NOT NULL,
	SONHA int NOT NULL,
	DUONG nvarchar(40) NOT NULL,
	QUAN nvarchar(40) NOT NULL,
	TPHO nvarchar(40) NOT NULL,
	DTHOAI nvarchar(12)
)
CREATE TABLE HOADON (
	MAHD char(10) PRIMARY KEY,
	MAKH char(10) NOT NULL,
	NGAYLAP SMALLDATETIME NOT NULL,
	TONGTIEN MONEY NULL,

	CONSTRAINT FK_MaKH_HOADON_KHACHHANG FOREIGN KEY (MAKH) REFERENCES KHACHHANG(MAKH)
)
CREATE TABLE SANPHAM (
	MASP char(10) PRIMARY KEY,
	TENSP nvarchar(40) NOT NULL,
	SOLUONGTON int NOT NULL,
	MOTA nvarchar(100),
	GIA int NOT NULL
)
CREATE TABLE CT_HOADON (
	MAHD char(10) NOT NULL,
	MASP char(10) NOT NULL,
	SOLUONG INT NOT NULL,
	GIABAN MONEY NOT NULL,
	GIAGIAM MONEY NULL, 
	THANHTIEN MONEY NULL
	CONSTRAINT PK_CTHD PRIMARY KEY (MAHD, MASP),

	CONSTRAINT FK_Mahd_CTHD_HOADON FOREIGN KEY (MAHD) REFERENCES HOADON(MAHD),
	CONSTRAINT FK_Masp_CTHD_SANPHAM FOREIGN KEY (MASP) REFERENCES SANPHAM(MASP)
)
---trigger 1
CREATE TRIGGER trg_CTDH
ON CT_HOADON
AFTER INSERT AS
BEGIN
	UPDATE CT_HOADON
	SET THANHTIEN = (inserted.GIABAN - inserted.GIAGIAM) * inserted.SOLUONG
	FROM inserted, CT_HOADON	
	WHERE inserted.MAHD = CT_HOADON.MAHD and inserted.MASP = CT_HOADON.MASP
END

----trigger 2
CREATE TRIGGER trg_CTDH_HD
ON CT_HOADON
AFTER INSERT AS
BEGIN
	UPDATE HOADON
	SET TONGTIEN = (SELECT SUM(CT_HOADON.THANHTIEN)
					FROM CT_HOADON where CT_HOADON.MAHD = inserted.MAHD)
	FROM HOADON
	JOIN inserted ON HOADON.MAHD = inserted.MAHD
END
---trigger SLTon
CREATE TRIGGER trg_SLT
ON CT_HOADON
AFTER INSERT AS
BEGIN
	UPDATE SANPHAM
	SET SOLUONGTON = SOLUONGTON-(SELECT SOLUONG
					FROM inserted where MASP=SANPHAM.MASP)
	FROM SANPHAM
	JOIN inserted ON SANPHAM.MASP = inserted.MASP
END
--
SELECT DISTINCT MONTH(NGAYLAP) AS THANG , YEAR(NGAYLAP) AS NAM
FROM HOADON
ORDER BY MONTH(NGAYLAP) ASC

CREATE PROC USP_selectHOADON
AS
BEGIN
	SELECT DISTINCT MONTH(NGAYLAP) AS THANG , YEAR(NGAYLAP) AS NAM, SUM(TONGTIEN) AS DANHTHU
	FROM HOADON
	GROUP BY MONTH(NGAYLAP), YEAR(NGAYLAP)
	ORDER BY MONTH(NGAYLAP) ASC
END

EXECUTE USP_selectHOADON


