SET SERVEROUTPUT ON;

BEGIN
    ADMIN_PKG.GenerateTestOrders(p_NumberOfOrders => 100000);
    
    DECLARE
        v_AdminId NUMBER;
        v_ScheduleId NUMBER;
        v_NewId NUMBER;
    BEGIN
        v_AdminId := CLIENT_PKG.LoginUser('admin@cinema.com', 'AdminPassword123'); 
        SELECT Id INTO v_ScheduleId FROM Schedules FETCH FIRST 1 ROW ONLY;

        INSERT INTO Orders (Seats, TotalPrice, UserId, ScheduleId, OrderStatus) 
        VALUES ('VIP Тест', 999, v_AdminId, v_ScheduleId, 'Оплачен');
        COMMIT;
    END;

    DBMS_STATS.GATHER_TABLE_STATS(USER, 'ORDERS', cascade=>TRUE);
    
    DBMS_OUTPUT.PUT_LINE('Данные готовы: 100000+ строк. Статистика собрана.');
END;
/

BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_orders_userid'; 
EXCEPTION WHEN OTHERS THEN NULL; END;
/

DECLARE
    v_AdminId NUMBER;
BEGIN
    v_AdminId := CLIENT_PKG.LoginUser('admin@cinema.com', 'AdminPassword123');

    EXECUTE IMMEDIATE 'EXPLAIN PLAN SET STATEMENT_ID=''NO_IDX'' FOR SELECT * FROM Orders WHERE UserId = ' || v_AdminId;
END;
/

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'NO_IDX'));

CREATE INDEX idx_orders_userid ON Orders(UserId);

DECLARE
    v_AdminId NUMBER;
BEGIN
    v_AdminId := CLIENT_PKG.LoginUser('admin@cinema.com', 'AdminPassword123');
    EXECUTE IMMEDIATE 'EXPLAIN PLAN SET STATEMENT_ID=''WITH_IDX'' FOR SELECT * FROM Orders WHERE UserId = ' || v_AdminId;
END;
/

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'WITH_IDX'));

