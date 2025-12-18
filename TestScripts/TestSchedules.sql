SET SERVEROUTPUT ON;

DECLARE
    v_ManagerId NUMBER;
    v_HallId NUMBER;
    v_MovieId NUMBER;
    v_NewScheduleId NUMBER;
    v_ShowTime TIMESTAMP := TO_TIMESTAMP('2025-12-15 20:50:00', 'YYYY-MM-DD HH24:MI:SS');
BEGIN
    v_ManagerId := CLIENT_PKG.LoginUser('manager@cinema.com', 'ManagerPassword123');
    v_MovieId := CLIENT_PKG.GETMOVIEIDBYTITLE('Джокер');
    v_HallId := CLIENT_PKG.GETHALLIDBYNAME('Зал 2');
    MANAGER_PKG.ADDSCHEDULE(v_ManagerId, v_MovieId, v_HallId, v_ShowTime, v_NewScheduleId);
END;
/

DECLARE
    v_ManagerId NUMBER;
    v_ScheduleId NUMBER;
    v_MovieId NUMBER;
    v_HallId NUMBER;
    v_NewTime TIMESTAMP := TO_TIMESTAMP('2025-12-15 21:00:00', 'YYYY-MM-DD HH24:MI:SS');
    v_OldTime TIMESTAMP := TO_TIMESTAMP('2025-12-15 18:00:00', 'YYYY-MM-DD HH24:MI:SS');
BEGIN
    v_ManagerId := CLIENT_PKG.LoginUser('manager@cinema.com', 'ManagerPassword123');
    v_MovieId := CLIENT_PKG.GetMovieIdByTitle('Джокер');
    v_HallId := CLIENT_PKG.GETHALLIDBYNAME('Зал 2');
    v_ScheduleId := CLIENT_PKG.GetScheduleId(v_MovieId, v_HallId, v_OldTime);
    MANAGER_PKG.UPDATESCHEDULETIME(v_ManagerId, v_ScheduleId, v_NewTime);
END;
/

DECLARE
    v_ManagerId NUMBER;
    v_ScheduleId NUMBER;
    v_MovieId     NUMBER;
    v_HallId      NUMBER;
    v_TargetTime  TIMESTAMP := TO_TIMESTAMP('2025-12-15 21:00:00', 'YYYY-MM-DD HH24:MI:SS');
BEGIN
    v_ManagerId := CLIENT_PKG.LoginUser('ivan1@gmail.com', 'Password456');
    v_MovieId := CLIENT_PKG.GetMovieIdByTitle('Джокер');
    v_HallId := CLIENT_PKG.GETHALLIDBYNAME('Зал 2');
    v_ScheduleId := CLIENT_PKG.GetScheduleId(v_MovieId, v_HallId, v_TargetTime);
    MANAGER_PKG.DeleteSchedule(v_ManagerId, v_ScheduleId);
END;
/