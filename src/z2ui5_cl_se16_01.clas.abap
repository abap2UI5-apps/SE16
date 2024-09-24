 CLASS z2ui5_cl_se16_01 DEFINITION PUBLIC.

   PUBLIC SECTION.

     INTERFACES z2ui5_if_app.

     DATA:
       BEGIN OF ms_sel,
         tabname        TYPE string,
         number_entries TYPE i,
         check_autoload TYPE abap_bool,
         s_layout       TYPE  z2ui5_cl_layout=>ty_s_layout,
       END OF ms_sel.
     DATA mt_filter_tab TYPE z2ui5_cl_util=>ty_t_filter_multi.

     DATA mo_selscreen   TYPE REF TO z2ui5_cl_selscreen.

   PROTECTED SECTION.
     DATA client TYPE REF TO z2ui5_if_client.
     DATA mv_check_initialized TYPE abap_bool.
     METHODS on_event.
     METHODS view_display.

   PRIVATE SECTION.

 ENDCLASS.



 CLASS z2ui5_cl_se16_01 IMPLEMENTATION.

   METHOD on_event.

     CASE client->get( )-event.

       WHEN 'DISPLAY_POPUP_SELECT_LAYOUT'.

         DATA lr_table TYPE REF TO data.
         CREATE DATA lr_table TYPE TABLE OF spfli.
         DATA(lo_layout) = z2ui5_cl_layout=>factory( control  = z2ui5_cl_layout=>m_table
                                      data     = lr_table
                                      handle01 = 'Z2UI5_CL_SE16'
                                      handle02 = 'Z2UI5_T_01'
                                      handle03 = ''
                                      handle04 = '' ).

         client->nav_app_call( z2ui5_cl_pop_display_layout=>factory(
                                 layout        = lo_layout
                                 open_layout   = 'X' ) ).



       WHEN 'BACK'.
         client->nav_app_leave( ).

       WHEN 'GO'.
         DATA(lo_tab_output) = NEW z2ui5_cl_se16_02( ).
         client->nav_app_call( lo_tab_output ).

       WHEN OTHERS.
         mo_selscreen->on_event( client ).

     ENDCASE.

   ENDMETHOD.


   METHOD view_display.

     DATA(view) = z2ui5_cl_xml_view=>factory( ).

     DATA(page) = view->shell( )->page( id = `page_main`
              title          = 'abap2UI5 - SE16 CLOUD - Start'
              navbuttonpress = client->_event( 'BACK' )
              shownavbutton = xsdbool( client->get( )-s_draft-id_prev_app_stack IS NOT INITIAL )
           ).

     IF mo_selscreen->mv_tabname IS NOT INITIAL.

       mo_selscreen->paint(
         view   = page
         client = client ).

     ENDIF.

     page->footer( )->overflow_toolbar(
         )->button( text = `Clear` press = client->_event( `CLEAR` )
         )->checkbox( selected = client->_bind_edit( ms_sel-check_autoload )  text = `A`
         )->input( value = client->_bind_edit( ms_sel-s_layout-s_head-descr ) width = `20%` description = `Layout`
                showvaluehelp = abaP_true
                valuehelprequest = client->_event( `DISPLAY_POPUP_SELECT_LAYOUT` )
                valuehelponly = abap_true
                )->toolbar_spacer(
         )->input( value = client->_bind_edit( ms_sel-number_entries ) width = `10%` description = `Number`
         )->button( text = `Count Entries` press = client->_event( `GO` )
         )->button( text = `Go` type = `Emphasized` press = client->_event( `GO` ) ).

     client->view_display( view->stringify( ) ).

   ENDMETHOD.


   METHOD z2ui5_if_app~main.
     TRY.

         me->client = client.

         IF mv_check_initialized = abap_false.
           mv_check_initialized = abap_true.
           mo_selscreen = NEW z2ui5_cl_selscreen( ).
           mo_selscreen->mv_tabname = `USR01`.
           ms_sel-number_entries = 100.
           view_display( ).
           RETURN.
         ENDIF.

         IF client->get( )-check_on_navigated = abap_true.
           TRY.
               DATA(lo_layout) = CAST z2ui5_cl_pop_display_layout( client->get_app( client->get( )-s_draft-id_prev_app ) ).
               ms_sel-s_layout = lo_layout->mo_layout->ms_layout.
               RETURN.
             CATCH cx_root.
           ENDTRY.
           mo_selscreen->on_navigated( client ).
         ENDIF.

         IF client->get( )-event IS NOT INITIAL.
           on_event( ).
         ENDIF.

       CATCH cx_root INTO DATA(x).
         client->message_box_display(
           text              =  x->get_text( )
           type              = `error` ).
     ENDTRY.
   ENDMETHOD.

 ENDCLASS.
