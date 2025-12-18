SET SERVEROUTPUT ON;

DECLARE
    v_ManagerId NUMBER;
    v_MovieId NUMBER;
BEGIN
    v_ManagerId := CLIENT_PKG.LoginUser('manager@cinema.com', 'ManagerPassword123');
    MANAGER_PKG.ADDMOVIE(v_ManagerId, 'Джокер', 'Тодд Филлипс', 'Готэм, начало 1980-х годов. Комик Артур Флек живет с больной матерью, которая с детства учит его «ходить с улыбкой». Пытаясь нести в мир хорошее и дарить людям радость, Артур сталкивается с человеческой жестокостью и постепенно приходит к выводу, что этот мир получит от него не добрую улыбку, а ухмылку злодея Джокера.', 'драма, криминал, триллер', 162, 8.0, '18+', v_MovieId);
END;
/

DECLARE
    v_ManagerId NUMBER;
    v_MovieId NUMBER;
BEGIN
    v_ManagerId := CLIENT_PKG.LoginUser('manager@cinema.com', 'ManagerPassword123');
    v_MovieId := CLIENT_PKG.GETMOVIEIDBYTITLE('Джокер');
    MANAGER_PKG.UPDATEMOVIEINFO(v_ManagerId, v_MovieId, 'Джокер', 'Тодд Филлипс', 'Готэм, начало 1980-х годов. Комик Артур Флек живет с больной матерью, которая с детства учит его «ходить с улыбкой». Пытаясь нести в мир хорошее и дарить людям радость, Артур сталкивается с человеческой жестокостью и постепенно приходит к выводу, что этот мир получит от него не добрую улыбку, а ухмылку злодея Джокера.', 'драма, криминал, триллер', 162, 8.0, '16+');
END;
/

DECLARE
    v_ManagerId NUMBER;
    v_MovieId NUMBER;
BEGIN
    v_ManagerId := CLIENT_PKG.LoginUser('manager@cinema.com', 'ManagerPassword123');
    v_MovieId := CLIENT_PKG.GETMOVIEIDBYTITLE('Джокер');
    MANAGER_PKG.DELETEMOVIE(v_ManagerId, v_MovieId);
END;
/

DECLARE
    v_ManagerId NUMBER;
    v_MovieId NUMBER;
BEGIN
    v_ManagerId := CLIENT_PKG.LoginUser('manager@cinema.com', 'ManagerPassword123');
    v_MovieId := CLIENT_PKG.GETMOVIEIDBYTITLE('Джокер');
    MANAGER_PKG.UPDATEMOVIEPOSTER(v_ManagerId, v_MovieId, 'MEDIA_DIR', 'Joker.jpg');
END;
/

DECLARE
    v_ManagerId NUMBER;
    v_MovieId NUMBER;
BEGIN
    v_ManagerId := CLIENT_PKG.LoginUser('manager@cinema.com', 'ManagerPassword123');
    v_MovieId := CLIENT_PKG.GETMOVIEIDBYTITLE('Джокер');
    MANAGER_PKG.UPDATEMOVIETRAILER(v_ManagerId, v_MovieId, 'MEDIA_DIR', 'Joker.mp4');
END;
/

VARIABLE rc REFCURSOR;
DECLARE
    v_ClientId NUMBER;
BEGIN
    v_ClientId := CLIENT_PKG.LoginUser('ivan@gmail.com', 'Password456');
    :rc := CLIENT_PKG.FINDMOVIES(p_GenreQuery => 'триллер');
END;
/
PRINT rc;

VARIABLE rc REFCURSOR;
DECLARE
    v_ClientId NUMBER;
BEGIN
    v_ClientId := CLIENT_PKG.LoginUser('ivan@gmail.com', 'Password456');
    :rc := CLIENT_PKG.FINDMOVIES(p_TitleQuery => 'Джокер');
END;
/
PRINT rc;

VARIABLE rc REFCURSOR;
DECLARE
    v_ClientId NUMBER;
BEGIN
    v_ClientId := CLIENT_PKG.LoginUser('ivan@gmail.com', 'Password456');
    :rc := CLIENT_PKG.FINDMOVIES(p_SortBy => 'rating');
END;
/
PRINT rc;