SET SERVEROUTPUT ON;

DECLARE
    v_AdminId NUMBER;
    v_NewHallId NUMBER;
BEGIN
    v_AdminId := CLIENT_PKG.LoginUser('admin@cinema.com', 'AdminPassword123');
    ADMIN_PKG.ADDHALL(v_AdminId, 'Зал 2', 120, 'Малый', v_NewHallId);
END;
/

DECLARE
    v_ManagerId NUMBER;
    v_NewHallId NUMBER;
BEGIN
    v_ManagerId := CLIENT_PKG.LoginUser('manager@cinema.com', 'ManagerPassword123');
    ADMIN_PKG.ADDHALL(v_ManagerId, 'Зал 2', 120, 'Малый', v_NewHallId);
END;
/

DECLARE
    v_AdminId NUMBER;
    v_HallId NUMBER;
BEGIN
    v_AdminId := CLIENT_PKG.LoginUser('admin@cinema.com', 'AdminPassword123');
    v_HallId := CLIENT_PKG.GETHALLIDBYNAME('Зал 2');
    ADMIN_PKG.UPDATEHALLINFO(v_AdminId, v_HallId, 'Зал 2', 90, 'Малый');
END;
/

DECLARE
    v_AdminId NUMBER;
    v_HallId NUMBER;
BEGIN
    v_AdminId := CLIENT_PKG.LoginUser('admin@cinema.com', 'AdminPassword123');
    v_HallId := CLIENT_PKG.GETHALLIDBYNAME('Зал 2');
    ADMIN_PKG.DELETEHALL(v_AdminId, v_HallId);
END;
/
