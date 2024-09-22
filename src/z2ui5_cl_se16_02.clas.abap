 CLASS z2ui5_cl_se16_02 DEFINITION PUBLIC.

   PUBLIC SECTION.

     INTERFACES z2ui5_if_app.

     DATA mo_variant TYPE REF TO z2ui5add_cl_var_db_api.
     DATA mo_layout TYPE REF TO z2ui5_cl_layout.

     DATA mv_tabname TYPE string VALUE 'USR01'.
     DATA mr_table TYPE REF TO data.
     DATA mt_filter TYPE z2ui5_cl_util=>ty_t_filter_multi.

   PROTECTED SECTION.
     DATA client TYPE REF TO z2ui5_if_client.
     DATA mv_check_initialized TYPE abap_bool.
     METHODS on_event.
     METHODS view_display.
     METHODS set_data.
     METHODS on_navigated.
     METHODS on_init.

   PRIVATE SECTION.
     DATA: mo_multiselect TYPE REF TO z2ui5add_cl_var_selscreen.
 ENDCLASS.



 CLASS z2ui5_cl_se16_02 IMPLEMENTATION.


   METHOD on_event.

     CASE client->get( )-event.

       WHEN `BUTTON_START`.
         set_data( ).
         view_display( ).

       WHEN 'BACK'.
         client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

       WHEN OTHERS.
         z2ui5_cl_pop_display_layout=>on_event_layout( client = client
                                                        layout = mo_layout ).
     ENDCASE.

   ENDMETHOD.

   METHOD set_data.

     "Variante lesen
     "SQL Select machen

     DATA lv_result TYPE string.

     SELECT FROM (mv_tabname)
      FIELDS
      *
      WHERE (lv_result)
      INTO TABLE @mr_table->*
      UP TO 100 ROWS.


   ENDMETHOD.


   METHOD view_display.

     DATA(view) = z2ui5_cl_xml_view=>factory( ).

     DATA(page) = view->shell( )->page( id = `page_main`
              title          = 'abap2UI5 - SE16-CLOUD - ' && mv_tabname
              navbuttonpress = client->_event( 'BACK' )
              floatingfooter = abap_true
              shownavbutton = xsdbool( client->get( )-s_draft-id_prev_app_stack IS NOT INITIAL )
           ).

     z2ui5_cl_xml_builder=>xml_build_table( i_data        = mr_table
                                           i_xml          = page
                                           i_client       = client
                                           i_layout       = mo_layout ).

     page->footer( )->overflow_toolbar(
         )->button( text = `Back` press = client->_event( `BACK` )
         )->toolbar_spacer(
         )->button( text = `Refresh` press = client->_event( `REFRESH` ) ).

     client->view_display( view->stringify( ) ).

   ENDMETHOD.


   METHOD z2ui5_if_app~main.

     me->client = client.

     IF mv_check_initialized = abap_false.
       mv_check_initialized = abap_true.
       on_init( ).
       RETURN.

     ENDIF.

     IF client->get( )-check_on_navigated = abap_true.
       on_navigated( ).
       RETURN.
     ENDIF.

     IF client->get( )-event IS NOT INITIAL.
       on_event( ).
       RETURN.
     ENDIF.

   ENDMETHOD.

   METHOD on_navigated.

     TRY.

         DATA(app) = CAST z2ui5_cl_pop_display_layout( client->get_app( client->get( )-s_draft-id_prev_app ) ).
         mo_layout = app->mo_layout.

         IF app->mv_rerender = abap_true.
           " subcolumns need rerendering to work ..
           view_display( ).
         ELSE.
           "  for all other changes in Layout View Model Update is enough.
           client->view_model_update( ).
         ENDIF.
       CATCH cx_root.
     ENDTRY.


   ENDMETHOD.


   METHOD on_init.

     CREATE DATA mr_table TYPE STANDARD TABLE OF (mv_tabname) WITH EMPTY KEY.
     set_data( ).

     IF mo_layout IS NOT BOUND.

       mo_layout = z2ui5_cl_pop_display_layout=>init_layout( control  = z2ui5_cl_layout=>m_table
                                                data     = mr_table
                                                handle01 =  ''
                                                handle02 =  'Z2UI5_T_01'
                                                handle03 = ''
                                                handle04 = '' ).

     ENDIF.

     view_display( ).

   ENDMETHOD.

 ENDCLASS.
