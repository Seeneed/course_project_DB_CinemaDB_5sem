--пакет для клиента
CREATE OR REPLACE PACKAGE CLIENT_PKG AS
    PROCEDURE RegisterUser (
        p_Name         IN  Users.Name%TYPE,
        p_Surname      IN  Users.Surname%TYPE,
        p_Email        IN  Users.Email%TYPE,
        p_Password     IN  Users.Password%TYPE,
        p_NewUserId    OUT Users.Id%TYPE
    );

    FUNCTION LoginUser (
        p_Email    IN Users.Email%TYPE,
        p_Password IN Users.Password%TYPE
    ) RETURN NUMBER;

    PROCEDURE UpdateUserEmail (
        p_CurrentUserId    IN Users.Id%TYPE,
        p_NewEmail         IN Users.Email%TYPE
    );

    FUNCTION GetOrderHistory (
        p_CurrentUserId IN Users.Id%TYPE,
        p_TargetUserId  IN Users.Id%TYPE,
        p_FilterStartDate IN DATE DEFAULT NULL,
        p_FilterEndDate   IN DATE DEFAULT NULL,
        p_FilterMinSum    IN Orders.TotalPrice%TYPE DEFAULT NULL,
        p_FilterMaxSum    IN Orders.TotalPrice%TYPE DEFAULT NULL,
        p_FilterStatus    IN Orders.OrderStatus%TYPE DEFAULT NULL
    ) RETURN SYS_REFCURSOR;

    PROCEDURE CreateOrder (
        p_CurrentUserId    IN  Users.Id%TYPE,
        p_ScheduleId       IN  Orders.ScheduleId%TYPE,
        p_Seats            IN  Orders.Seats%TYPE,
        p_TotalPrice       IN  Orders.TotalPrice%TYPE,
        p_NewOrderId       OUT Orders.Id%TYPE
    );

    PROCEDURE CancelOrder (
        p_CurrentUserId    IN Users.Id%TYPE,
        p_OrderId          IN Orders.Id%TYPE
    );

    FUNCTION FindMovies (
        p_TitleQuery IN Movies.Title%TYPE DEFAULT NULL,
        p_GenreQuery IN Movies.Genre%TYPE DEFAULT NULL,
        p_SortBy     IN VARCHAR2 DEFAULT 'rating'
    ) RETURN SYS_REFCURSOR;

    FUNCTION GetUserIdByEmail (
        p_Email IN Users.Email%TYPE
    ) RETURN NUMBER;

    FUNCTION GetMovieIdByTitle (
        p_Title IN Movies.Title%TYPE
    ) RETURN NUMBER;

    FUNCTION GetHallIdByName (
        p_Name IN Halls.Name%TYPE
    ) RETURN NUMBER;
    
    FUNCTION GetScheduleId (
        p_MovieId IN NUMBER, 
        p_HallId IN NUMBER, 
        p_ShowTime IN TIMESTAMP
        ) RETURN NUMBER;

    FUNCTION GetLastOrderId (
        p_CurrentUserId IN NUMBER
    ) RETURN NUMBER;

END CLIENT_PKG;
/

--пакет для менеджера
CREATE OR REPLACE PACKAGE MANAGER_PKG AS
    PROCEDURE AddMovie (
        p_CurrentUserId    IN  Users.Id%TYPE,
        p_Title            IN  Movies.Title%TYPE,
        p_Director         IN  Movies.Director%TYPE,
        p_Description      IN  Movies.Description%TYPE,
        p_Genre            IN  Movies.Genre%TYPE,
        p_Duration         IN  Movies.Duration%TYPE,
        p_Rating           IN  Movies.Rating%TYPE,
        p_AgeRestriction   IN  Movies.AgeRestriction%TYPE,
        p_NewMovieId       OUT Movies.Id%TYPE
    );

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
    );

    PROCEDURE DeleteMovie (
        p_CurrentUserId IN Users.Id%TYPE,
        p_MovieId       IN Movies.Id%TYPE
    );

    PROCEDURE UpdateMoviePoster (
        p_CurrentUserId    IN Users.Id%TYPE,
        p_MovieId          IN Movies.Id%TYPE,
        p_DirectoryName    IN VARCHAR2,
        p_FileName         IN VARCHAR2
    );

    PROCEDURE UpdateMovieTrailer (
        p_CurrentUserId    IN Users.Id%TYPE,
        p_MovieId          IN Movies.Id%TYPE,
        p_DirectoryName    IN VARCHAR2,
        p_FileName         IN VARCHAR2
    );

    PROCEDURE AddSchedule (
        p_CurrentUserId    IN  Users.Id%TYPE,
        p_MovieId          IN  Schedules.MovieId%TYPE,
        p_HallId           IN  Schedules.HallId%TYPE,
        p_ShowTime         IN  Schedules.ShowTime%TYPE,
        p_NewScheduleId    OUT Schedules.Id%TYPE
    );

    PROCEDURE UpdateScheduleTime (
        p_CurrentUserId    IN Users.Id%TYPE,
        p_ScheduleId       IN Schedules.Id%TYPE,
        p_NewShowTime      IN Schedules.ShowTime%TYPE
    );

    PROCEDURE DeleteSchedule (
        p_CurrentUserId IN Users.Id%TYPE,
        p_ScheduleId    IN Schedules.Id%TYPE
    );

    PROCEDURE UpdateOrderStatus (
        p_CurrentUserId    IN Users.Id%TYPE,
        p_OrderId          IN Orders.Id%TYPE,
        p_NewStatus        IN Orders.OrderStatus%TYPE
    );

    FUNCTION GetAllOrders (
        p_CurrentUserId    IN Users.Id%TYPE,
        p_StartDate        IN DATE DEFAULT NULL,
        p_EndDate          IN DATE DEFAULT NULL,
        p_Status           IN Orders.OrderStatus%TYPE DEFAULT NULL
    ) RETURN SYS_REFCURSOR;
END MANAGER_PKG;
/

--пакет для администратора
CREATE OR REPLACE PACKAGE ADMIN_PKG AS
    PROCEDURE DeleteUser (
        p_CurrentUserId    IN Users.Id%TYPE,
        p_TargetUserId     IN Users.Id%TYPE
    );

    PROCEDURE AssignManagerRole (
        p_CurrentUserId    IN Users.Id%TYPE,
        p_TargetUserId     IN Users.Id%TYPE
    );

    PROCEDURE AddHall (
        p_CurrentUserId    IN  Users.Id%TYPE,
        p_Name             IN  Halls.Name%TYPE,
        p_Capacity         IN  Halls.Capacity%TYPE,
        p_Type             IN  Halls.Type%TYPE,
        p_NewHallId        OUT Halls.Id%TYPE
    );

    PROCEDURE UpdateHallInfo (
        p_CurrentUserId    IN Users.Id%TYPE,
        p_HallId           IN Halls.Id%TYPE,
        p_NewName          IN Halls.Name%TYPE DEFAULT NULL,
        p_NewCapacity      IN Halls.Capacity%TYPE DEFAULT NULL,
        p_NewType          IN Halls.Type%TYPE DEFAULT NULL
    );

    PROCEDURE DeleteHall (
        p_CurrentUserId    IN Users.Id%TYPE,
        p_HallId           IN Halls.Id%TYPE
    );

    PROCEDURE GenerateTestOrders (
        p_NumberOfOrders IN NUMBER
    );

    FUNCTION  ExportOrdersToJSON (
        p_Limit IN NUMBER DEFAULT NULL
    ) RETURN CLOB;

    PROCEDURE ImportOrdersFromJSON_File (
        p_CurrentUserId IN Users.Id%TYPE,
        p_DirectoryName IN VARCHAR2, 
        p_FileName IN VARCHAR2
    );
END ADMIN_PKG;
/