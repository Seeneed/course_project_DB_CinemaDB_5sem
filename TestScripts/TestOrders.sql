SET SERVEROUTPUT ON;

DECLARE
    v_ClientId NUMBER;
    v_MovieId NUMBER;
    v_HallId NUMBER;
    v_ScheduleId NUMBER;
    v_ShowTime TIMESTAMP;
    v_NewOrderId NUMBER;
BEGIN
    v_ClientId := CLIENT_PKG.LoginUser('ivan@gmail.com', 'Password456');    
    v_MovieId  := CLIENT_PKG.GetMovieIdByTitle('Джокер');
    v_HallId   := CLIENT_PKG.GetHallIdByName('Зал 2');
    v_ShowTime := TO_TIMESTAMP('2025-12-15 21:00:00', 'YYYY-MM-DD HH24:MI:SS');
    v_ScheduleId := CLIENT_PKG.GetScheduleId(v_MovieId, v_HallId, v_ShowTime);
    CLIENT_PKG.CREATEORDER(v_ClientId, v_ScheduleId, 'Ряд 5, место 10', 30.00, v_NewOrderId);
END;
/

DECLARE
    v_ClientId NUMBER;
    v_OrderId NUMBER;
BEGIN
    v_ClientId := CLIENT_PKG.LoginUser('ivan@gmail.com', 'Password456');    
    v_OrderId := CLIENT_PKG.GetLastOrderId(p_CurrentUserId => v_ClientId);
    CLIENT_PKG.CANCELORDER(v_ClientId, v_OrderId);
END;
/

VARIABLE rc REFCURSOR;
DECLARE
    v_ClientId NUMBER;
BEGIN
    v_ClientId := CLIENT_PKG.LoginUser('admin@cinema.com', 'AdminPassword123');    
    :rc := CLIENT_PKG.GetOrderHistory(v_ClientId, v_ClientId);
END;
/
PRINT rc;

VARIABLE rc REFCURSOR;
DECLARE
    v_ClientId NUMBER;
BEGIN
    v_ClientId := CLIENT_PKG.LoginUser('ivan@gmail.com', 'Password456');    
    :rc := CLIENT_PKG.GetOrderHistory(
        p_CurrentUserId => v_ClientId,
        p_TargetUserId  => v_ClientId,
        p_FilterStatus        => 'Отменен'
    );
END;
/
PRINT rc;

DECLARE
    v_ClientId NUMBER;
BEGIN
    v_ClientId := CLIENT_PKG.LoginUser('testgen@user.com', '123');
    
    :rc := CLIENT_PKG.GetOrderHistory(
        p_CurrentUserId => v_ClientId,
        p_TargetUserId  => v_ClientId,
        p_FilterMinSum  => 15.00
    );
END;
/
PRINT rc;

DECLARE
    v_ClientId NUMBER;
BEGIN
    v_ClientId := CLIENT_PKG.LoginUser('ivan@gmail.com', 'Password456');
    
    :rc := CLIENT_PKG.GetOrderHistory(
        p_CurrentUserId => v_ClientId,
        p_TargetUserId  => v_ClientId,
        p_FilterStartDate => TO_DATE('2025-01-01', 'YYYY-MM-DD'),
        p_FilterEndDate => TO_DATE('2025-12-31', 'YYYY-MM-DD'),
        p_FilterStatus => 'Оплачен'
    );
END;
/
PRINT rc;

declare
    v_ManagerId NUMBER;
    v_ClientId  NUMBER;
    v_OrderId NUMBER;
BEGIN
    v_ManagerId := CLIENT_PKG.LoginUser('manager@cinema.com', 'ManagerPassword123');
    v_ClientId := CLIENT_PKG.GetUserIdByEmail('ivan@gmail.com');
    v_OrderId  := CLIENT_PKG.GetLastOrderId(v_ClientId);
    MANAGER_PKG.UPDATEORDERSTATUS(v_ManagerId, v_OrderId, 'Забронирован');
END;
/

VARIABLE rc REFCURSOR;
DECLARE
    v_ManagerId NUMBER;
BEGIN
    v_ManagerId := CLIENT_PKG.LoginUser('admin@cinema.com', 'AdminPassword123');
    :rc := MANAGER_PKG.GETALLORDERS(v_ManagerId);
END;
/
PRINT rc;

DECLARE
    v_ManagerId NUMBER;
BEGIN
    v_ManagerId := CLIENT_PKG.LoginUser('admin@cinema.com', 'AdminPassword123');
    
    :rc := MANAGER_PKG.GetAllOrders(
        p_CurrentUserId => v_ManagerId,
        p_Status        => 'Отменен'
    );
END;
/
PRINT rc;

DECLARE
    v_ManagerId NUMBER;
BEGIN
    v_ManagerId := CLIENT_PKG.LoginUser('manager@cinema.com', 'ManagerPassword123');
    
    :rc := MANAGER_PKG.GetAllOrders(
        p_CurrentUserId => v_ManagerId,
        p_StartDate     => TRUNC(SYSDATE),
        p_EndDate       => TRUNC(SYSDATE)
    );
END;
/
PRINT rc;

