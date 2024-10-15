CLASS z2ui5_cl_util_sql DEFINITION PUBLIC.
  PUBLIC SECTION.

    INTERFACES if_serializable_object.

    CLASS-METHODS factory
      IMPORTING
        i_sql           TYPE z2ui5_cl_util=>ty_s_sql OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_util_sql.

    DATA ms_sql  TYPE z2ui5_cl_util=>ty_s_sql.

    METHODS read.
    METHODS count.

ENDCLASS.

CLASS z2ui5_cl_util_sql IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->ms_sql = i_sql.

  ENDMETHOD.

  METHOD read.


    IF ms_sql-t_ref IS NOT BOUND.
      CREATE DATA ms_sql-t_ref  TYPE STANDARD TABLE OF (ms_sql-tabname) WITH EMPTY KEY.
    ENDIF.

    "Variante lesen
    "SQL Select machen

    DATA lv_result TYPE string.

    SELECT FROM (ms_sql-tabname)
     FIELDS
     *
     WHERE (lv_result)
     INTO TABLE @ms_sql-t_ref->*
     UP TO @ms_sql-count ROWS.


  ENDMETHOD.


  METHOD count.


    IF ms_sql-t_ref IS NOT BOUND.
      CREATE DATA ms_sql-t_ref  TYPE STANDARD TABLE OF (ms_sql-tabname) WITH EMPTY KEY.
    ENDIF.

    "Variante lesen
    "SQL Select machen

    DATA lv_result TYPE string.

    SELECT FROM (ms_sql-tabname)
     FIELDS
     COUNT( * )
     WHERE (lv_result)
     INTO @ms_sql-count.

  ENDMETHOD.

ENDCLASS.
