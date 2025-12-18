SET SERVEROUTPUT ON;

BEGIN
    ADMIN_PKG.GenerateTestOrders(p_NumberOfOrders => 100000);
END;
/

DECLARE
    v_JsonData CLOB;
BEGIN
    v_JsonData := ADMIN_PKG.ExportOrdersToJSON(p_Limit => NULL);

    DBMS_XSLPROCESSOR.CLOB2FILE(v_JsonData, 'MEDIA_DIR', 'export.json');
    
    DBMS_OUTPUT.PUT_LINE('Файл export.json успешно перезаписан актуальными данными!');
END;
/

BEGIN
    DELETE FROM Orders;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Таблица Orders очищена для теста импорта.');
END;
/

DECLARE
    v_AdminId NUMBER;
BEGIN
    v_AdminId := CLIENT_PKG.LoginUser('admin@cinema.com', 'AdminPassword123');
    
    DBMS_OUTPUT.PUT_LINE('Запуск импорта...');
    
    ADMIN_PKG.ImportOrdersFromJSON_File(
        p_CurrentUserId => v_AdminId,
        p_DirectoryName => 'MEDIA_DIR',
        p_FileName      => 'export.json'
    );
END;
/

SELECT COUNT(*) as "Импортировано заказов" 
FROM Orders 
WHERE OrderStatus = 'Импортирован';
