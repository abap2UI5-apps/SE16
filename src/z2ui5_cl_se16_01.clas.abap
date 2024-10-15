 CLASS z2ui5_cl_se16_01 DEFINITION PUBLIC.

   PUBLIC SECTION.

     INTERFACES z2ui5_if_app.
     DATA mo_ui_ranges TYPE REF TO z2ui5_cl_ui_build_ranges.
     DATA mo_layout    TYPE REF TO  z2ui5_cl_layout.

   PROTECTED SECTION.
     DATA client TYPE REF TO z2ui5_if_client.
     DATA mv_check_initialized TYPE abap_bool.

     METHODS on_event.
     METHODS view_display.
     METHODS on_navigated.
     METHODS on_init.

   PRIVATE SECTION.
 ENDCLASS.


 CLASS z2ui5_cl_se16_01 IMPLEMENTATION.

   METHOD on_event.

     CASE client->get( )-event.

       WHEN 'DISPLAY_POPUP_SELECT_LAYOUT'.

         client->nav_app_call( z2ui5_cl_layout=>choose_layout(
              handle01 = 'z2ui5_cl_se16_01'
              handle02 = mo_ui_ranges->mo_sql->ms_sql-tabname
         ) ).
       WHEN 'BACK'.
         client->nav_app_leave( ).

       WHEN 'GO'.
         DATA(lo_tab_output) = NEW z2ui5_cl_se16_02( ).
         lo_tab_output->mo_sql = z2ui5_cl_util_sql=>factory( mo_ui_ranges->mo_sql->ms_sql ).
         client->nav_app_call( lo_tab_output ).

       WHEN OTHERS.
         mo_ui_ranges->on_event( client ).

     ENDCASE.

   ENDMETHOD.


   METHOD view_display.

     DATA(view) = z2ui5_cl_xml_view=>factory( ).

     DATA(page) = view->shell( )->page( id = `page_main`
              title          = 'abap2UI5 - SE16 CLOUD - Start'
              navbuttonpress = client->_event( 'BACK' )
              shownavbutton = xsdbool( client->get( )-s_draft-id_prev_app_stack IS NOT INITIAL )
           ).

     IF mo_ui_ranges->mo_sql->ms_sql-tabname IS NOT INITIAL.
       mo_ui_ranges->paint( view = page client = client ).
     ENDIF.

     page->footer( )->overflow_toolbar(
         )->button( text = `Go` type = `Emphasized` press = client->_event( `GO` ) ).

     client->view_display( view->stringify( ) ).

   ENDMETHOD.


   METHOD z2ui5_if_app~main.
     TRY.

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

       CATCH cx_root INTO DATA(x).
         client->message_box_display( text = x->get_text( ) type = `error` ).
     ENDTRY.
   ENDMETHOD.


   METHOD on_navigated.

     TRY.
         DATA(lo_layout) = CAST z2ui5_cl_pop_display_layout( client->get_app( client->get( )-s_draft-id_prev_app ) ).
         mo_layout = lo_layout->mo_layout.
         RETURN.
       CATCH cx_root.
     ENDTRY.

     TRY.
         CAST z2ui5_cl_se16_02( client->get_app( client->get( )-s_draft-id_prev_app ) ).
         view_display( ).
         RETURN.
       CATCH cx_root.
     ENDTRY.

     mo_ui_ranges->on_navigated( client ).

   ENDMETHOD.


   METHOD on_init.

     mo_ui_ranges = NEW z2ui5_cl_ui_build_ranges( ).
     mo_ui_ranges->mo_sql = NEW #( ).
     mo_ui_ranges->mo_sql->ms_sql-tabname = `USR01`.
     mo_ui_ranges->mo_sql->ms_sql-count   = `500`.

     DATA lr_table TYPE REF TO data.
     CREATE DATA lr_table TYPE TABLE OF spfli.
     mo_layout = z2ui5_cl_layout=>factory( control = z2ui5_cl_layout=>m_table
                                     data     = lr_table
                                     handle01 = 'Z2UI5_CL_SE16'
                                     handle02 = 'Z2UI5_T_01'
                                     handle03 = ''
                                     handle04 = '' ).

     view_display( ).

   ENDMETHOD.

 ENDCLASS.
