SET SERVEROUTPUT ON;

--содержимое тела пакета для администратора
CREATE OR REPLACE PACKAGE BODY ADMIN_PKG AS

    PROCEDURE DeleteUser (p_CurrentUserId IN Users.Id%TYPE, p_TargetUserId IN Users.Id%TYPE) IS
        v_CurrentUserRole Roles.Name%TYPE;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole != 'Администратор' THEN RAISE_APPLICATION_ERROR(-20140, 'Ошибка доступа: Недостаточно прав.'); END IF;
        IF p_CurrentUserId = p_TargetUserId THEN RAISE_APPLICATION_ERROR(-20220, 'Нельзя удалить управляющие роли.'); END IF;
        DELETE FROM Users WHERE Id = p_TargetUserId;
        IF SQL%ROWCOUNT > 0 THEN COMMIT; DBMS_OUTPUT.PUT_LINE('Пользователь '||p_TargetUserId||' и все его данные удалены.'); END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END DeleteUser;

    PROCEDURE AssignManagerRole (p_CurrentUserId IN Users.Id%TYPE, p_TargetUserId IN Users.Id%TYPE) IS
        v_CurrentUserRole Roles.Name%TYPE; v_ManagerRoleId Roles.Id%TYPE; v_TargetUserRole Roles.Name%TYPE;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole != 'Администратор' THEN RAISE_APPLICATION_ERROR(-20200, 'Только Администратор может назначать менеджеров.'); END IF;
        SELECT r.Name INTO v_TargetUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_TargetUserId;
        IF v_TargetUserRole = 'Менеджер' THEN RAISE_APPLICATION_ERROR(-20210, 'Пользователь уже является менеджером.'); END IF;
        SELECT Id INTO v_ManagerRoleId FROM Roles WHERE Name = 'Менеджер';
        UPDATE Users SET RoleId = v_ManagerRoleId WHERE Id = p_TargetUserId;
        IF SQL%ROWCOUNT > 0 THEN COMMIT; DBMS_OUTPUT.PUT_LINE('Пользователю '||p_TargetUserId||' присвоена роль Менеджера.'); END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20222, 'Пользователь с таким ID не найден.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END AssignManagerRole;

    PROCEDURE AddHall (p_CurrentUserId IN Users.Id%TYPE, p_Name IN Halls.Name%TYPE, p_Capacity IN Halls.Capacity%TYPE, p_Type IN Halls.Type%TYPE, p_NewHallId OUT Halls.Id%TYPE) IS
        v_CurrentUserRole Roles.Name%TYPE;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole != 'Администратор' THEN RAISE_APPLICATION_ERROR(-20140, 'Ошибка доступа: Недостаточно прав.'); END IF;
        INSERT INTO Halls (Name, Capacity, Type) VALUES (p_Name, p_Capacity, p_Type) RETURNING Id INTO p_NewHallId;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Зал "'||p_Name||'" добавлен с ID: '||p_NewHallId);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы.');
        WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20102, 'Такой зал уже существует.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END AddHall;

    PROCEDURE UpdateHallInfo (p_CurrentUserId IN Users.Id%TYPE, p_HallId IN Halls.Id%TYPE, p_NewName IN Halls.Name%TYPE DEFAULT NULL, p_NewCapacity IN Halls.Capacity%TYPE DEFAULT NULL, p_NewType IN Halls.Type%TYPE DEFAULT NULL) IS
        v_CurrentUserRole Roles.Name%TYPE;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole != 'Администратор' THEN RAISE_APPLICATION_ERROR(-20140, 'Ошибка доступа: Недостаточно прав.'); END IF;
        UPDATE Halls SET Name = NVL(p_NewName, Name), Capacity = NVL(p_NewCapacity, Capacity), Type = NVL(p_NewType, Type) WHERE Id = p_HallId;
        IF SQL%ROWCOUNT = 0 THEN RAISE_APPLICATION_ERROR(-20114, 'Зал не найден.'); END IF;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Зал ID '||p_HallId||' обновлен.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END UpdateHallInfo;

    PROCEDURE DeleteHall (p_CurrentUserId IN Users.Id%TYPE, p_HallId IN Halls.Id%TYPE) IS
        v_CurrentUserRole Roles.Name%TYPE;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole != 'Администратор' THEN RAISE_APPLICATION_ERROR(-20140, 'Ошибка доступа: Недостаточно прав.'); END IF;
        DELETE FROM Halls WHERE Id = p_HallId;
        IF SQL%ROWCOUNT = 0 THEN RAISE_APPLICATION_ERROR(-20114, 'Зал не найден.'); END IF;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Зал '||p_HallId||' и все связанные данные удалены.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END DeleteHall;

    PROCEDURE GenerateTestOrders (p_NumberOfOrders IN NUMBER) IS
        v_TestUserId     Users.Id%TYPE; v_TestScheduleId Schedules.Id%TYPE;
    BEGIN
        BEGIN INSERT INTO Roles (Name) VALUES ('Тестовый'); COMMIT; EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL; END;
        BEGIN INSERT INTO Users (Name, Surname, Email, Password, RoleId) VALUES ('TestGen', 'User', 'testgen@user.com', '123', (SELECT Id FROM Roles WHERE Name = 'Тестовый')); COMMIT; EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL; END;
        BEGIN INSERT INTO Movies (Title) VALUES ('Test Movie for Generation'); INSERT INTO Halls (Name, Capacity) VALUES ('Test Hall for Generation', 200000); INSERT INTO Schedules (MovieId, HallId, ShowTime) VALUES ((SELECT MAX(Id) FROM Movies WHERE Title = 'Test Movie for Generation'), (SELECT MAX(Id) FROM Halls WHERE Name = 'Test Hall for Generation'), SYSTIMESTAMP); COMMIT; EXCEPTION WHEN OTHERS THEN NULL; END;
        SELECT Id INTO v_TestUserId FROM Users WHERE Email = 'testgen@user.com';
        SELECT MAX(Id) INTO v_TestScheduleId FROM Schedules;
        DBMS_OUTPUT.PUT_LINE('Начинаем генерацию ' || p_NumberOfOrders || ' заказов...');
        FOR i IN 1..p_NumberOfOrders LOOP
            INSERT INTO Orders (Seats, TotalPrice, UserId, ScheduleId, OrderStatus) VALUES ('Ряд ' || TRUNC(DBMS_RANDOM.VALUE(1, 100)) || ', Место ' || TRUNC(DBMS_RANDOM.VALUE(1, 100)), ROUND(DBMS_RANDOM.VALUE(10, 50), 2), v_TestUserId, v_TestScheduleId, CASE WHEN MOD(i, 20) = 0 THEN 'Отменен' ELSE 'Оплачен' END);
            IF MOD(i, 10000) = 0 THEN COMMIT; DBMS_OUTPUT.PUT_LINE('... добавлено ' || i || ' заказов'); END IF;
        END LOOP;
        COMMIT; DBMS_OUTPUT.PUT_LINE('Генерация завершена. Успешно добавлено ' || p_NumberOfOrders || ' заказов.');
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Критическая ошибка: ' || SQLERRM); ROLLBACK;
    END GenerateTestOrders;

    FUNCTION ExportOrdersToJSON (p_Limit IN NUMBER DEFAULT NULL) RETURN CLOB IS
    v_JsonData CLOB; 
    v_Cursor SYS_REFCURSOR; 
    v_RowCount NUMBER;
    v_LF CHAR(1) := CHR(10);
    BEGIN
    SELECT COUNT(*) INTO v_RowCount FROM Orders;
    
    DBMS_LOB.CREATETEMPORARY(v_JsonData, TRUE);
    
    DBMS_LOB.WRITEAPPEND(v_JsonData, 
        LENGTH('{"export_details":{"timestamp":"' || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS.FF') || '","row_count":' || v_RowCount || '},"orders":[' || v_LF), 
               '{"export_details":{"timestamp":"' || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS.FF') || '","row_count":' || v_RowCount || '},"orders":[' || v_LF);
    
    OPEN v_Cursor FOR 'SELECT JSON_OBJECT (''seats'' VALUE o.Seats, ''total_price'' VALUE o.TotalPrice, ''status'' VALUE o.OrderStatus, ''user_id'' VALUE o.UserId, ''schedule_id'' VALUE o.ScheduleId) FROM (SELECT * FROM Orders ORDER BY BookingTimestamp DESC FETCH FIRST NVL(:lim, 999999999) ROWS ONLY) o' USING p_Limit;
    
    DECLARE
        v_JsonObject VARCHAR2(4000); 
        v_IsFirst BOOLEAN := TRUE;
    BEGIN
        LOOP
            FETCH v_Cursor INTO v_JsonObject; EXIT WHEN v_Cursor%NOTFOUND;
            
            IF NOT v_IsFirst THEN 
                DBMS_LOB.WRITEAPPEND(v_JsonData, 2, ',' || v_LF); 
            END IF;
            
            DBMS_LOB.WRITEAPPEND(v_JsonData, 2, '  '); 
            
            DBMS_LOB.WRITEAPPEND(v_JsonData, LENGTH(v_JsonObject), v_JsonObject);
            
            v_IsFirst := FALSE;
        END LOOP;
    END;
    CLOSE v_Cursor;
    
    DBMS_LOB.WRITEAPPEND(v_JsonData, 3, v_LF || ']}');
    
    RETURN v_JsonData;
    END ExportOrdersToJSON;

    PROCEDURE ImportOrdersFromJSON_File (p_CurrentUserId IN Users.Id%TYPE, p_DirectoryName IN VARCHAR2, p_FileName IN VARCHAR2) IS
        v_UserRole Roles.Name%TYPE; v_JsonData CLOB; v_RowsInserted NUMBER;
    BEGIN
        SELECT r.Name INTO v_UserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_UserRole NOT IN ('Администратор') THEN RAISE_APPLICATION_ERROR(-20140, 'Доступ запрещен.'); END IF;
        DECLARE
            lob_loc BFILE; dest_offset INTEGER := 1; src_offset INTEGER := 1; lang_ctx INTEGER := DBMS_LOB.DEFAULT_LANG_CTX; warning INTEGER;
        BEGIN
            DBMS_LOB.CREATETEMPORARY(v_JsonData, TRUE);
            lob_loc := BFILENAME(p_DirectoryName, p_FileName);
            DBMS_LOB.FILEOPEN(lob_loc, DBMS_LOB.FILE_READONLY);
            DBMS_LOB.LOADCLOBFROMFILE(v_JsonData, lob_loc, DBMS_LOB.GETLENGTH(lob_loc), dest_offset, src_offset, DBMS_LOB.DEFAULT_CSID, lang_ctx, warning);
            DBMS_LOB.FILECLOSE(lob_loc);
        END;
        INSERT INTO Orders (Seats, TotalPrice, OrderStatus, UserId, ScheduleId)
        SELECT j.Seats, j.TotalPrice, 'Импортирован', j.UserId, j.ScheduleId 
        FROM JSON_TABLE(v_JsonData, '$.orders[*]' 
        COLUMNS (Seats NVARCHAR2(255) PATH '$.seats', TotalPrice NUMBER(10, 2) PATH '$.total_price', UserId NUMBER PATH '$.user_id', ScheduleId NUMBER PATH '$.schedule_id')) j WHERE EXISTS (SELECT 1 FROM Users WHERE Id = j.UserId) 
        AND EXISTS (SELECT 1 FROM Schedules WHERE Id = j.ScheduleId);
        v_RowsInserted := SQL%ROWCOUNT;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(v_RowsInserted || ' заказов импортировано.');
        DBMS_LOB.FREETEMPORARY(v_JsonData);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END ImportOrdersFromJSON_File;

END ADMIN_PKG;
/

--содержимое тела пакета для менеджера
CREATE OR REPLACE PACKAGE BODY MANAGER_PKG AS

    PROCEDURE AddMovie (
        p_CurrentUserId    IN  Users.Id%TYPE, p_Title            IN  Movies.Title%TYPE,
        p_Director         IN  Movies.Director%TYPE, p_Description      IN  Movies.Description%TYPE,
        p_Genre            IN  Movies.Genre%TYPE, p_Duration         IN  Movies.Duration%TYPE,
        p_Rating           IN  Movies.Rating%TYPE, p_AgeRestriction   IN  Movies.AgeRestriction%TYPE,
        p_NewMovieId       OUT Movies.Id%TYPE
    ) IS
        v_CurrentUserRole Roles.Name%TYPE;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole NOT IN ('Администратор', 'Менеджер') THEN RAISE_APPLICATION_ERROR(-20140, 'Ошибка доступа: Недостаточно прав.'); END IF;
        INSERT INTO Movies (Title, Director, Description, Genre, Duration, Rating, AgeRestriction) VALUES (p_Title, p_Director, p_Description, p_Genre, p_Duration, p_Rating, p_AgeRestriction) RETURNING Id INTO p_NewMovieId;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Фильм "'||p_Title||'" добавлен с ID: '||p_NewMovieId);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20103, 'Такое название фильма уже существует.');
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END AddMovie;

    PROCEDURE UpdateMovieInfo (
        p_CurrentUserId     IN Users.Id%TYPE, 
        p_MovieId           IN Movies.Id%TYPE,
        p_NewTitle          IN Movies.Title%TYPE DEFAULT NULL, 
        p_NewDirector       IN Movies.Director%TYPE DEFAULT NULL,
        p_NewDescription    IN Movies.Description%TYPE DEFAULT NULL,
        p_NewGenre          IN Movies.Genre%TYPE DEFAULT NULL,
        p_NewDuration       IN Movies.Duration%TYPE DEFAULT NULL,
        p_NewRating         IN Movies.Rating%TYPE DEFAULT NULL,
        p_NewAgeRestriction IN Movies.AgeRestriction%TYPE DEFAULT NULL
    ) IS
        v_CurrentUserRole Roles.Name%TYPE;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole NOT IN ('Администратор', 'Менеджер') THEN RAISE_APPLICATION_ERROR(-20140, 'Ошибка доступа: Недостаточно прав.'); END IF;
        UPDATE Movies SET Title = NVL(p_NewTitle, Title), Director = NVL(p_NewDirector, Director), Description = NVL(p_NewDescription, Description), Genre = NVL(p_NewGenre, Genre), Duration = NVL(p_NewDuration, Duration), Rating = NVL(p_NewRating, Rating), AgeRestriction = NVL(p_NewAgeRestriction, AgeRestriction) WHERE Id = p_MovieId;
        IF SQL%ROWCOUNT = 0 THEN RAISE_APPLICATION_ERROR(-20114, 'Фильм не найден.'); END IF;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Фильм ID '||p_MovieId||' обновлен.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END UpdateMovieInfo;

    PROCEDURE DeleteMovie (p_CurrentUserId IN Users.Id%TYPE, p_MovieId IN Movies.Id%TYPE) IS
        v_CurrentUserRole Roles.Name%TYPE;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole NOT IN ('Администратор', 'Менеджер') THEN RAISE_APPLICATION_ERROR(-20140, 'Ошибка доступа: Недостаточно прав.'); END IF;
        DELETE FROM Movies WHERE Id = p_MovieId;
        IF SQL%ROWCOUNT = 0 THEN RAISE_APPLICATION_ERROR(-20114, 'Фильм не найден.'); END IF;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Фильм ID '||p_MovieId||' и все связанные данные удалены.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END DeleteMovie;

    PROCEDURE UpdateMoviePoster (p_CurrentUserId IN Users.Id%TYPE, p_MovieId IN Movies.Id%TYPE, p_DirectoryName IN VARCHAR2, p_FileName IN VARCHAR2) IS
        v_CurrentUserRole Roles.Name%TYPE; dest_lob BLOB; src_bfile BFILE; dest_offset INTEGER := 1; src_offset INTEGER := 1;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole NOT IN ('Администратор', 'Менеджер') THEN RAISE_APPLICATION_ERROR(-20140, 'Ошибка доступа: Недостаточно прав.'); END IF;
        UPDATE Movies SET Poster = EMPTY_BLOB() WHERE Id = p_MovieId RETURNING Poster INTO dest_lob;
        IF dest_lob IS NULL THEN RAISE_APPLICATION_ERROR(-20114, 'Фильм не найден.'); END IF;
        src_bfile := BFILENAME(p_DirectoryName, p_FileName);
        DBMS_LOB.FILEOPEN(src_bfile, DBMS_LOB.FILE_READONLY);
        DBMS_LOB.LOADBLOBFROMFILE(dest_lob, src_bfile, DBMS_LOB.GETLENGTH(src_bfile), dest_offset, src_offset);
        DBMS_LOB.FILECLOSE(src_bfile);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Постер для фильма ID '||p_MovieId||' загружен.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END UpdateMoviePoster;

    PROCEDURE UpdateMovieTrailer (p_CurrentUserId IN Users.Id%TYPE, p_MovieId IN Movies.Id%TYPE, p_DirectoryName IN VARCHAR2, p_FileName IN VARCHAR2) IS
        v_CurrentUserRole Roles.Name%TYPE; dest_lob BLOB; src_bfile BFILE; dest_offset INTEGER := 1; src_offset INTEGER := 1;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole NOT IN ('Администратор', 'Менеджер') THEN RAISE_APPLICATION_ERROR(-20140, 'Ошибка доступа: Недостаточно прав.'); END IF;
        UPDATE Movies SET Trailer = EMPTY_BLOB() WHERE Id = p_MovieId RETURNING Trailer INTO dest_lob;
        IF dest_lob IS NULL THEN RAISE_APPLICATION_ERROR(-20114, 'Фильм не найден.'); END IF;
        src_bfile := BFILENAME(p_DirectoryName, p_FileName);
        DBMS_LOB.FILEOPEN(src_bfile, DBMS_LOB.FILE_READONLY);
        DBMS_LOB.LOADBLOBFROMFILE(dest_lob, src_bfile, DBMS_LOB.GETLENGTH(src_bfile), dest_offset, src_offset);
        DBMS_LOB.FILECLOSE(src_bfile);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Трейлер для фильма ID '||p_MovieId||' загружен.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END UpdateMovieTrailer;

    PROCEDURE AddSchedule (p_CurrentUserId IN Users.Id%TYPE, p_MovieId IN Schedules.MovieId%TYPE, p_HallId IN Schedules.HallId%TYPE, p_ShowTime IN Schedules.ShowTime%TYPE, p_NewScheduleId OUT Schedules.Id%TYPE) IS
        v_CurrentUserRole Roles.Name%TYPE; v_MovieDuration Movies.Duration%TYPE; v_NewSessionEnd TIMESTAMP; v_ConflictCount NUMBER;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole NOT IN ('Администратор', 'Менеджер') THEN RAISE_APPLICATION_ERROR(-20140, 'Ошибка доступа: Недостаточно прав.'); END IF;
        SELECT Duration INTO v_MovieDuration FROM Movies WHERE Id = p_MovieId;
        v_NewSessionEnd := p_ShowTime + NUMTODSINTERVAL(v_MovieDuration, 'MINUTE');
        SELECT COUNT(*) INTO v_ConflictCount FROM Schedules s JOIN Movies m ON s.MovieId = m.Id WHERE s.HallId = p_HallId AND (p_ShowTime < (s.ShowTime + NUMTODSINTERVAL(m.Duration, 'MINUTE'))) AND (v_NewSessionEnd > s.ShowTime);
        IF v_ConflictCount > 0 THEN RAISE_APPLICATION_ERROR(-20132, 'Зал уже занят в это время.'); END IF;
        INSERT INTO Schedules (MovieId, HallId, ShowTime) VALUES (p_MovieId, p_HallId, p_ShowTime) RETURNING Id INTO p_NewScheduleId;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Сеанс создан с ID: '||p_NewScheduleId);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20114, 'Фильм или зал не найдены.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END AddSchedule;

    PROCEDURE UpdateScheduleTime (p_CurrentUserId IN Users.Id%TYPE, p_ScheduleId IN Schedules.Id%TYPE, p_NewShowTime IN Schedules.ShowTime%TYPE) IS
        v_CurrentUserRole Roles.Name%TYPE; v_MovieId Schedules.MovieId%TYPE; v_HallId Schedules.HallId%TYPE; v_MovieDuration Movies.Duration%TYPE; v_NewSessionEnd TIMESTAMP; v_ConflictCount NUMBER;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole NOT IN ('Администратор', 'Менеджер') THEN RAISE_APPLICATION_ERROR(-20140, 'Ошибка доступа: Недостаточно прав.'); END IF;
        SELECT MovieId, HallId INTO v_MovieId, v_HallId FROM Schedules WHERE Id = p_ScheduleId;
        SELECT Duration INTO v_MovieDuration FROM Movies WHERE Id = v_MovieId;
        v_NewSessionEnd := p_NewShowTime + NUMTODSINTERVAL(v_MovieDuration, 'MINUTE');
        SELECT COUNT(*) INTO v_ConflictCount FROM Schedules s JOIN Movies m ON s.MovieId = m.Id WHERE s.HallId = v_HallId AND s.Id != p_ScheduleId AND (p_NewShowTime < (s.ShowTime + NUMTODSINTERVAL(m.Duration, 'MINUTE'))) AND (v_NewSessionEnd > s.ShowTime);
        IF v_ConflictCount > 0 THEN RAISE_APPLICATION_ERROR(-20132, 'Зал уже занят в новое время.'); END IF;
        UPDATE Schedules SET ShowTime = p_NewShowTime WHERE Id = p_ScheduleId;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Время сеанса ID '||p_ScheduleId||' обновлено.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20115, 'Сеанс или связанный фильм не найдены.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END UpdateScheduleTime;

    PROCEDURE DeleteSchedule (p_CurrentUserId IN Users.Id%TYPE, p_ScheduleId IN Schedules.Id%TYPE) IS
        v_CurrentUserRole Roles.Name%TYPE;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole NOT IN ('Администратор', 'Менеджер') THEN RAISE_APPLICATION_ERROR(-20140, 'Ошибка доступа: Недостаточно прав.'); END IF;
        DELETE FROM Schedules WHERE Id = p_ScheduleId;
        IF SQL%ROWCOUNT = 0 THEN RAISE_APPLICATION_ERROR(-20115, 'Сеанс не найден.'); END IF;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Сеанс ID '||p_ScheduleId||' и связанные заказы удалены.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END DeleteSchedule;

    PROCEDURE UpdateOrderStatus (p_CurrentUserId IN Users.Id%TYPE, p_OrderId IN Orders.Id%TYPE, p_NewStatus IN Orders.OrderStatus%TYPE) IS
        v_CurrentUserRole Roles.Name%TYPE;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole NOT IN ('Администратор', 'Менеджер') THEN RAISE_APPLICATION_ERROR(-20140, 'Ошибка доступа: Недостаточно прав.'); END IF;
        IF p_NewStatus NOT IN ('Оплачен', 'Отменен', 'Возвращен', 'Забронирован') THEN RAISE_APPLICATION_ERROR(-20150, 'Недопустимый статус.'); END IF;
        UPDATE Orders SET OrderStatus = p_NewStatus WHERE Id = p_OrderId;
        IF SQL%ROWCOUNT = 0 THEN RAISE_APPLICATION_ERROR(-20151, 'Заказ не найден.'); END IF;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Статус заказа ID '||p_OrderId||' изменен.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END UpdateOrderStatus;

    FUNCTION GetAllOrders (p_CurrentUserId IN Users.Id%TYPE, p_StartDate IN DATE DEFAULT NULL, p_EndDate IN DATE DEFAULT NULL, p_Status IN Orders.OrderStatus%TYPE DEFAULT NULL) RETURN SYS_REFCURSOR IS
        v_CurrentUserRole Roles.Name%TYPE; v_ResultCursor SYS_REFCURSOR;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole NOT IN ('Администратор', 'Менеджер') THEN RAISE_APPLICATION_ERROR(-20140, 'Ошибка доступа: Недостаточно прав.'); END IF;
        OPEN v_ResultCursor FOR SELECT o.Id, o.BookingTimestamp, u.Email, m.Title, o.Seats, o.TotalPrice, o.OrderStatus FROM Orders o JOIN Users u ON o.UserId = u.Id JOIN Schedules s ON o.ScheduleId = s.Id JOIN Movies m ON s.MovieId = m.Id WHERE (TRUNC(o.BookingTimestamp) >= p_StartDate OR p_StartDate IS NULL) AND (TRUNC(o.BookingTimestamp) <= p_EndDate OR p_EndDate IS NULL) AND (o.OrderStatus = p_Status OR p_Status IS NULL) ORDER BY o.BookingTimestamp DESC;
        RETURN v_ResultCursor;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы.');
        WHEN OTHERS THEN RAISE;
    END GetAllOrders;

END MANAGER_PKG;
/

--содержимое тела пакета для клиента
CREATE OR REPLACE PACKAGE BODY CLIENT_PKG AS

    PROCEDURE RegisterUser (p_Name IN Users.Name%TYPE, p_Surname IN Users.Surname%TYPE, p_Email IN Users.Email%TYPE, p_Password IN Users.Password%TYPE, p_NewUserId OUT Users.Id%TYPE) IS
        v_DefaultRoleId Roles.Id%TYPE;
    BEGIN
        IF p_Email IS NULL OR p_Password IS NULL THEN RAISE_APPLICATION_ERROR(-20004, 'Логин и пароль не могут быть пустыми.'); END IF;
        SELECT Id INTO v_DefaultRoleId FROM Roles WHERE Name = 'Пользователь';
        INSERT INTO Users (Name, Surname, Email, Password, RoleId) VALUES (p_Name, p_Surname, p_Email, p_Password, v_DefaultRoleId) RETURNING Id INTO p_NewUserId;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Пользователь '||p_Email||' зарегистрирован с ID: '||p_NewUserId);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20004, 'Критическая ошибка: Роль "Пользователь" не найдена.');
        WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20001, 'Пользователь с таким логином уже существует.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END RegisterUser;

    FUNCTION LoginUser (p_Email IN Users.Email%TYPE, p_Password IN Users.Password%TYPE) RETURN NUMBER IS
        v_UserId Users.Id%TYPE := NULL;
    BEGIN
        SELECT Id INTO v_UserId FROM Users WHERE Email = p_Email AND Password = p_Password;
        RETURN v_UserId;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20002, 'Неверный логин или пароль.');
        WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20003, 'Пользователь не найден (непредвиденная ошибка).');
    END LoginUser;

    PROCEDURE UpdateUserEmail (
            p_CurrentUserId    IN Users.Id%TYPE,
            p_NewEmail         IN Users.Email%TYPE
        ) IS
        BEGIN
            UPDATE Users
            SET Email = p_NewEmail
            WHERE Id = p_CurrentUserId;

            IF SQL%ROWCOUNT = 0 THEN
                RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы (пользователь не найден).');
            END IF;
            
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Ваш email успешно обновлен на ' || p_NewEmail);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20001, 'Пользователь с таким логином (email) уже существует.');
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
    END UpdateUserEmail;

    FUNCTION GetOrderHistory (
        p_CurrentUserId   IN Users.Id%TYPE,
        p_TargetUserId    IN Users.Id%TYPE,
        p_FilterStartDate IN DATE DEFAULT NULL,
        p_FilterEndDate   IN DATE DEFAULT NULL,
        p_FilterMinSum    IN Orders.TotalPrice%TYPE DEFAULT NULL,
        p_FilterMaxSum    IN Orders.TotalPrice%TYPE DEFAULT NULL,
        p_FilterStatus    IN Orders.OrderStatus%TYPE DEFAULT NULL
    ) RETURN SYS_REFCURSOR IS
        v_CurrentUserRole Roles.Name%TYPE;
        v_ResultCursor  SYS_REFCURSOR;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        IF v_CurrentUserRole NOT IN ('Администратор', 'Менеджер') AND p_CurrentUserId != p_TargetUserId THEN
            RAISE_APPLICATION_ERROR(-20310, 'Вы не можете просматривать чужой заказ.');
        END IF;

        OPEN v_ResultCursor FOR
            SELECT o.Id, o.BookingTimestamp, m.Title, s.ShowTime, o.Seats, o.TotalPrice, o.OrderStatus
            FROM Orders o
            JOIN Schedules s ON o.ScheduleId = s.Id
            JOIN Movies m ON s.MovieId = m.Id
            WHERE
                o.UserId = p_TargetUserId
                AND (TRUNC(o.BookingTimestamp) >= p_FilterStartDate OR p_FilterStartDate IS NULL)
                AND (TRUNC(o.BookingTimestamp) <= p_FilterEndDate OR p_FilterEndDate IS NULL)
                AND (o.TotalPrice >= p_FilterMinSum OR p_FilterMinSum IS NULL)
                AND (o.TotalPrice <= p_FilterMaxSum OR p_FilterMaxSum IS NULL)
                AND (o.OrderStatus = p_FilterStatus OR p_FilterStatus IS NULL)
            ORDER BY o.BookingTimestamp DESC;
        RETURN v_ResultCursor;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20301, 'Вы не авторизованы.');
        WHEN OTHERS THEN RAISE;
    END GetOrderHistory;

    PROCEDURE CreateOrder (p_CurrentUserId IN Users.Id%TYPE, p_ScheduleId IN Orders.ScheduleId%TYPE, p_Seats IN Orders.Seats%TYPE, p_TotalPrice IN Orders.TotalPrice%TYPE, p_NewOrderId OUT Orders.Id%TYPE) IS
        v_HallCapacity Halls.Capacity%TYPE; 
        v_TicketsSold NUMBER; 
        v_UserTicketsCount NUMBER; 
        v_SeatOccupied NUMBER; 
        v_TicketLimitPerUser CONSTANT NUMBER := 5;
    BEGIN
        SELECT COUNT(*) INTO v_UserTicketsCount FROM Orders WHERE UserId = p_CurrentUserId AND ScheduleId = p_ScheduleId AND OrderStatus != 'Отменен';
        IF v_UserTicketsCount >= v_TicketLimitPerUser THEN RAISE_APPLICATION_ERROR(-20330, 'Количество билетов превышает лимит ('||v_TicketLimitPerUser||').'); END IF;

        SELECT h.Capacity INTO v_HallCapacity FROM Schedules s JOIN Halls h ON s.HallId = h.Id WHERE s.Id = p_ScheduleId;
        SELECT COUNT(*) INTO v_TicketsSold FROM Orders WHERE ScheduleId = p_ScheduleId AND OrderStatus != 'Отменен';
        IF v_TicketsSold >= v_HallCapacity THEN RAISE_APPLICATION_ERROR(-20331, 'Все билеты на сеанс проданы.'); END IF;

        SELECT COUNT(*) INTO v_SeatOccupied 
        FROM Orders 
        WHERE ScheduleId = p_ScheduleId 
            AND Seats = p_Seats      
            AND OrderStatus != 'Отменен';

        IF v_SeatOccupied > 0 THEN 
            RAISE_APPLICATION_ERROR(-20332, 'Выбранное место ('||p_Seats||') уже занято.'); 
        END IF;

        INSERT INTO Orders (Seats, TotalPrice, UserId, ScheduleId, OrderStatus) VALUES (p_Seats, p_TotalPrice, p_CurrentUserId, p_ScheduleId, 'Оплачен') RETURNING Id INTO p_NewOrderId;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Заказ '||p_NewOrderId||' создан для пользователя ID='||p_CurrentUserId);
        EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20322, 'Сеанс или зал не найдены.');
        WHEN OTHERS THEN ROLLBACK; IF SQLCODE = -2291 THEN RAISE_APPLICATION_ERROR(-20300, 'Для оформления заказа нужно авторизоваться.'); ELSE RAISE; END IF;
    END CreateOrder;

    PROCEDURE CancelOrder (p_CurrentUserId IN Users.Id%TYPE, p_OrderId IN Orders.Id%TYPE) IS
        v_CurrentUserRole Roles.Name%TYPE; v_OrderOwnerId Users.Id%TYPE; v_ShowTime Schedules.ShowTime%TYPE; v_OrderStatus Orders.OrderStatus%TYPE; v_HoursBeforeShow NUMBER;
    BEGIN
        SELECT r.Name INTO v_CurrentUserRole FROM Users u JOIN Roles r ON u.RoleId = r.Id WHERE u.Id = p_CurrentUserId;
        SELECT o.UserId, o.OrderStatus, s.ShowTime INTO v_OrderOwnerId, v_OrderStatus, v_ShowTime FROM Orders o JOIN Schedules s ON o.ScheduleId = s.Id WHERE o.Id = p_OrderId;
        IF v_CurrentUserRole NOT IN ('Администратор', 'Менеджер') AND p_CurrentUserId != v_OrderOwnerId THEN RAISE_APPLICATION_ERROR(-20320, 'Нет прав на отмену этого заказа.'); END IF;
        IF v_OrderStatus = 'Отменен' THEN RAISE_APPLICATION_ERROR(-20321, 'Заказ уже отменен.'); END IF;
        v_HoursBeforeShow := (CAST(v_ShowTime AS DATE) - CAST(SYSTIMESTAMP AS DATE)) * 24;
        IF v_CurrentUserRole NOT IN ('Администратор', 'Менеджер') AND v_HoursBeforeShow <= 2 THEN RAISE_APPLICATION_ERROR(-20321, 'Отмена невозможна: до сеанса менее 2 часов.'); END IF;
        UPDATE Orders SET OrderStatus = 'Отменен' WHERE Id = p_OrderId;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Заказ '||p_OrderId||' успешно отменен.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20322, 'Пользователь или заказ/сеанс не найдены.');
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END CancelOrder;

    FUNCTION FindMovies (
        p_TitleQuery IN Movies.Title%TYPE DEFAULT NULL,
        p_GenreQuery IN Movies.Genre%TYPE DEFAULT NULL,
        p_SortBy     IN VARCHAR2 DEFAULT 'rating'
    ) RETURN SYS_REFCURSOR IS
        v_ResultCursor SYS_REFCURSOR;
        BEGIN
        OPEN v_ResultCursor FOR
            SELECT Id, Title, Director, Description, Genre, Duration, Rating, AgeRestriction
            FROM Movies
            WHERE
                (LOWER(Title) LIKE '%' || LOWER(p_TitleQuery) || '%' OR p_TitleQuery IS NULL)
                AND (LOWER(Genre) LIKE '%' || LOWER(p_GenreQuery) || '%' OR p_GenreQuery IS NULL)
            ORDER BY
                CASE WHEN p_SortBy = 'title' THEN Title END ASC,
                CASE WHEN p_SortBy = 'rating' THEN Rating END DESC,
                Title ASC;
        RETURN v_ResultCursor;
    END FindMovies;

    FUNCTION GetUserIdByEmail (p_Email IN Users.Email%TYPE) RETURN NUMBER IS
        v_UserId Users.Id%TYPE;
    BEGIN
        SELECT Id INTO v_UserId FROM Users WHERE Email = p_Email;
        RETURN v_UserId;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END GetUserIdByEmail;

    FUNCTION GetMovieIdByTitle (p_Title IN Movies.Title%TYPE) RETURN NUMBER IS
        v_MovieId Movies.Id%TYPE;
    BEGIN
        SELECT Id INTO v_MovieId FROM Movies WHERE Title = p_Title;
        RETURN v_MovieId;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END GetMovieIdByTitle;

    FUNCTION GetHallIdByName (p_Name IN Halls.Name%TYPE) RETURN NUMBER IS
        v_HallId Halls.Id%TYPE;
    BEGIN
        SELECT Id INTO v_HallId FROM Halls WHERE Name = p_Name;
        RETURN v_HallId;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END GetHallIdByName;

    FUNCTION GetScheduleId (p_MovieId IN NUMBER, p_HallId IN NUMBER, p_ShowTime IN TIMESTAMP) RETURN NUMBER IS
        v_ScheduleId Schedules.Id%TYPE;
    BEGIN
        SELECT Id INTO v_ScheduleId FROM Schedules WHERE MovieId = p_MovieId AND HallId = p_HallId AND ShowTime = p_ShowTime;
        RETURN v_ScheduleId;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END GetScheduleId;

    FUNCTION GetLastOrderId (p_CurrentUserId IN NUMBER) RETURN NUMBER IS
        v_OrderId Orders.Id%TYPE;
    BEGIN
        SELECT Id
        INTO v_OrderId
        FROM Orders
        WHERE UserId = p_CurrentUserId
        ORDER BY BookingTimestamp DESC
        FETCH FIRST 1 ROW ONLY;

        RETURN v_OrderId;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GetLastOrderId;

END CLIENT_PKG;
/
