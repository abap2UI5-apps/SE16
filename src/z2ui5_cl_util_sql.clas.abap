CLASS z2ui5_cl_util_sql DEFINITION PUBLIC.
  PUBLIC SECTION.

    INTERFACES if_serializable_object.

    types: begin of t_go_button,
             event_name type string,
             icon_name type string,
             text type string,
           end of t_go_button.

    CLASS-METHODS factory
      IMPORTING
        i_sql           TYPE z2ui5_cl_util=>ty_s_sql OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_util_sql.

    DATA ms_sql  TYPE z2ui5_cl_util=>ty_s_sql.

    METHODS read.
    METHODS count.

    class-methods go_button
                    returning
                      value(r_val) type z2ui5_cl_util_sql=>t_go_button.

ENDCLASS.

CLASS z2ui5_cl_util_sql IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->ms_sql = i_sql.

  ENDMETHOD.


  METHOD go_button.

    r_val = value #( event_name = `GO`
                     icon_name = `sap-icon://simulate`
                     text = 'Go'(001) ).

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
