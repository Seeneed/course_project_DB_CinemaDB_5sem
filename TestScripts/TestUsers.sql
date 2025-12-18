SET SERVEROUTPUT ON;

DECLARE
    v_NewId NUMBER;
BEGIN
    CLIENT_PKG.RegisterUser('Иван', 'Иванов', 'ivan1@gmail.com', 'Password456', v_NewId);
END;
/

DECLARE
    v_UserId NUMBER;
BEGIN
    v_UserId := CLIENT_PKG.LOGINUSER('ivan1@gmail.com', 'Password456');
    DBMS_OUTPUT.PUT_LINE('Авторизация успешна. ID: ' || v_UserId);
END;
/

DECLARE
    v_UserId NUMBER;
BEGIN
    v_UserId := CLIENT_PKG.LoginUser('ivan1@gmail.com', 'Password456');    
    CLIENT_PKG.UPDATEUSEREMAIL(v_UserId, 'IvanIvanov@gmail.com');
END;
/

DECLARE
    v_AdminId NUMBER;
    v_TargetId NUMBER;
BEGIN
    v_AdminId := CLIENT_PKG.LoginUser('admin@cinema.com', 'AdminPassword123');
    v_TargetId := CLIENT_PKG.GETUSERIDBYEMAIL('IvanIvanov@gmail.com');
    ADMIN_PKG.AssignManagerRole(v_AdminId, v_TargetId);
END;
/

DECLARE
    v_AdminId NUMBER;
    v_TargetId NUMBER;
BEGIN
    v_AdminId := CLIENT_PKG.LoginUser('admin@cinema.com', 'AdminPassword123');
    v_TargetId := CLIENT_PKG.GETUSERIDBYEMAIL('IvanIvanov@gmail.com');
    ADMIN_PKG.DELETEUSER(v_AdminId, v_TargetId);
END;
/