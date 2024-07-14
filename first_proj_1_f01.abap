*&---------------------------------------------------------------------*
*& Include          ZCCD_PROJET_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data_from_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_from_file .
    lv_line = p_file.
  
  * We use GUI_UPLOAD function module to upload file from desktop to the internal table
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = lv_line
        filetype                = 'ASC'
      TABLES
        data_tab                = lt_file
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        OTHERS                  = 17.
  
  
  ENDFORM.
  
  
  
  *&---------------------------------------------------------------------*
  *& Form prepare_data
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM prepare_data .
  
    DELETE lt_file INDEX 1.
  
    FIELD-SYMBOLS: <lv_field>.
  
  * Remove ";" from the file and inserting the data into a table of type string
  
    LOOP AT lt_file ASSIGNING FIELD-SYMBOL(<lw_data>).
      lv_count = 0.
  
  * here lt_file2 type table of ty_csv (data elemnts are string), it is just titles of the fileds, field names
  
      APPEND INITIAL LINE TO lt_file2 ASSIGNING FIELD-SYMBOL(<lw_data_split>).
  
  * Do 14 times because we have 14 field names for each row
  
      DO 14 TIMES.
        SPLIT <lw_data> AT ';' INTO lv_column <lw_data>.
        IF lv_column IS NOT INITIAL.
          lv_count = lv_count + 1.
          ASSIGN COMPONENT sy-index OF STRUCTURE <lw_data_split> TO <lv_field>.
          IF sy-subrc = 0.
            <lv_field> = lv_column.
          ENDIF.
        ENDIF.
      ENDDO.
  
  * check if a line contains any empty fields and removing errors
  
      IF lv_count <> 14.
        DELETE lt_file2 INDEX lv_index.
        lv_index = lv_index - 1.
      ENDIF.
      lv_index = lv_index + 1.
  
    ENDLOOP.
  
  * If deleting empty fields and ";" is successfull or not, show a message
    IF sy-subrc <> 0.
      MESSAGE e016(zgco_msg).
    ELSE.
      MESSAGE s017(zgco_msg).
    ENDIF.
  
  
  
  ************************************** CHECK DOCUMENT TYPES ***************************************************************************
  
  * Check document types, first use STVARV TCODE? create select options use name ZGCO_DOC_TYPE
  * Go to the SE11 and write the name of the table TVARVC, click  contenu and execute to see the table
  * you will see ZGCO_DOC_TYPE, now select all fields from TVARVC
  
    SELECT  *
    FROM tvarvc
    INTO TABLE @DATA(lr_dir_range)
    WHERE name = 'ZGCO_DOC_TYPE' "The variable name given in STVARV
    AND type = 'S'. "Select Option
  
  * Declare a variable as a type boolean
    DATA: true_false TYPE boolean VALUE 't'.
  
  
  * add data from the string table (ltfile2, model csv_ty)to the table that has the correct type
    LOOP AT lt_file2 ASSIGNING FIELD-SYMBOL(<ls_file2>).
  
      true_false = 'f'.
  
  * Loop at if doc type of the tvarvc-low is equal to our doc type, accept true_false variable as true
  
      LOOP AT lr_dir_range ASSIGNING FIELD-SYMBOL(<ls_dir_range>).
        IF <ls_dir_range>-low = <ls_file2>-doc_type.
          true_false = 't'.
        ENDIF.
      ENDLOOP.
  
  * Thus, if the variable is true fill the fields in the final structure and append our structure to the final table
  
      IF true_false = 'f'.
      ELSE.
        ls_final-id_commande =  <ls_file2>-id_commande.
        ls_final-doc_type =   <ls_file2>-doc_type.
        ls_final-sales_org =   <ls_file2>-sales_org.
        ls_final-distr_chan =   <ls_file2>-distr_chan.
        ls_final-sect_act =   <ls_file2>-sect_act.
        ls_final-partn_role_ag =   <ls_file2>-partn_role_ag.
        ls_final-partn_numb_ag =   <ls_file2>-partn_numb_ag.
        ls_final-partn_role_we =   <ls_file2>-partn_role_we.
        ls_final-partn_numb_we =   <ls_file2>-partn_numb_we.
        ls_final-itm_numb =   <ls_file2>-itm_numb.
        ls_final-material =   <ls_file2>-material.
        ls_final-plant =   <ls_file2>-plant.
        ls_final-quantity =   <ls_file2>-quantity.
        ls_final-quantity_unit =   <ls_file2>-quantity_unit.
        APPEND ls_final TO lt_final.
      ENDIF.
  
    ENDLOOP.
  
  * Verify data, call data_verification
    DATA : lo_alv TYPE REF TO cl_salv_table.
  
    CALL METHOD cl_salv_table=>factory
      IMPORTING
        r_salv_table = lo_alv
      CHANGING
        t_table      = lt_final.
  
    CALL METHOD lo_alv->display.
    PERFORM data_verification.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form bapi
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM bapi .
  
  * first clear  ls_final
  
    CLEAR ls_final.
  
  * loop in the lt_final table to use the bapi wlth the file data
  
    LOOP AT lt_final INTO ls_final.
  
  * Data initialization for structure ls_order_header_inx
  
      ls_order_header_inx-updateflag = 'I'.
      ls_order_header_inx-req_date_h = 'X'.
      ls_order_header_inx-doc_type = 'X'.
      ls_order_header_inx-sales_org = 'X'.
      ls_order_header_inx-distr_chan = 'X'.
      ls_order_header_inx-division = 'X'.
  
      ls_order_header_in-req_date_h = sy-datum.
      ls_order_header_in-doc_type = ls_final-doc_type.
      ls_order_header_in-sales_org = ls_final-sales_org.
      ls_order_header_in-distr_chan = ls_final-distr_chan.
      ls_order_header_in-division = ls_final-sect_act.
  
  * Data initialization for structure ls_order_items_inx
  
      ls_order_items_inx-itm_number = 'X'.
      ls_order_items_inx-material = 'X'.
      ls_order_items_inx-plant = 'X'.
      ls_order_items_inx-po_quan = 'X'.
      ls_order_items_inx-po_unit = 'X'.
      APPEND ls_order_items_inx TO lt_order_items_inx.
      CLEAR ls_order_items_inx.
  
      ls_order_items_in-itm_number = ls_final-itm_numb.
      ls_order_items_in-material = ls_final-material.
      ls_order_items_in-plant = ls_final-plant.
      ls_order_items_inx-po_quan = ls_final-quantity.
      ls_order_items_inx-po_unit = ls_final-quantity_unit.
      APPEND ls_order_items_in TO lt_order_items_in.
      CLEAR ls_order_items_in.
  
      ls_order_partners-partn_role = ls_final-partn_role_ag.
      ls_order_partners-partn_numb = ls_final-partn_numb_ag.
      APPEND ls_order_partners TO lt_order_partners.
      CLEAR ls_order_partners.
  
      ls_order_partners-partn_role = ls_final-partn_role_we.
      ls_order_partners-partn_numb = ls_final-partn_numb_we.
      APPEND ls_order_partners TO lt_order_partners.
      CLEAR ls_order_partners.
  
  * Call BAPI sales order module function
  
      CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
        EXPORTING
          order_header_in  = ls_order_header_in
          order_header_inx = ls_order_header_inx
        IMPORTING
          salesdocument    = lv_vbeln
        TABLES
          order_items_in   = lt_order_items_in
          order_items_inx  = lt_order_items_inx
          order_partners   = lt_order_partners
          return           = lt_return.
  
  * clear return table, we will use it for error messages
  
      CLEAR lt_return.
  
      LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<fs_bapiret>) WHERE type = 'E'.
        EXIT.
      ENDLOOP.
  
  * if sales document is not initial call this function
  
      IF lv_vbeln IS NOT INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
  
        ls_return_msg-id_commande = ls_final-id_commande.
        ls_return_msg-result = 'Successfull'.
        ls_return_msg-num_com = lv_vbeln.
        ls_return_msg-message = ' OK '.
  
        APPEND ls_return_msg TO lt_return_msg.
        CLEAR ls_return_msg.
  
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  
        ls_return_msg-id_commande = ls_final-id_commande.
        ls_return_msg-result = 'Not successfull'.
        ls_return_msg-num_com = lv_vbeln.
        ls_return_msg-message = ' NOT OK '.
  
        APPEND ls_return_msg TO lt_return_msg.
        CLEAR ls_return_msg.
  
      ENDIF.
  
    ENDLOOP.
  
    DATA : lo_alv TYPE REF TO cl_salv_table.
    CALL METHOD cl_salv_table=>factory
      IMPORTING
        r_salv_table = lo_alv
      CHANGING
        t_table      = lt_return_msg.
    CALL METHOD lo_alv->display.
  
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *& Form display
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  
  FORM select_display .
  
    SELECT
       vbak~vbeln, "Numéro de la commande de vente
  
       vbak~auart, "Type de doc. De vente
  
       vbak~erdat, "Date de création de la commande
  
       vbak~erzet, "Heure de création
  
       vbak~vdatu, "Date de livraison souhaitée
  
       vbak~vkorg, "Organisation commerciale
  
       vbak~vtweg, "Canal de distribution
  
       vbak~spart, "Secteur d’activité
  
       vbap~kunnr_ana, "Client donneur d’ordre
  
       kna1~ernam, "Nom du donneur d’ordre
  
       vbap~kunwe_ana, "Client réceptionnaire
  
       kna1~name1, "Nom du client réceptionnaire
  
        'ADRESSE | Post code :  ' && kna1~pstlz && ' | City :  ' && kna1~ort01 && ' | Country : ' && kna1~land1  AS Adresse,
  
       vbap~posnr, "Numéro de poste Com.
  
       vbap~matnr, "Article
  
       makt~maktx, "Désignation article
  
       vbap~werks, "Division
  
       vbap~zmeng, "Quantité commandée
  
       vbap~zieme, "Unité de quantité
  
       mara~ntgew, "Poids net de l’article
  
       mara~gewei, "Unité de poids
  
  * Total post weight = Quantité commandée  VBAP-KWMENG * Poids net de l’article MARA-NTGEW *
  
     CAST( vbap~zmeng AS INT8 ) * CAST( mara~ntgew AS INT8 ) AS total_post_weight
  
  * Total order weight = Quantité commandée  VBAP-KWMENG * Poids net de l’article MARA-NTGEW * ?
  
  
     FROM vbak
  
     INNER JOIN  vbap ON vbap~vbeln = vbak~vbeln
     INNER JOIN  kna1 ON vbap~kunnr_ana = kna1~kunnr
     INNER JOIN  mara ON mara~matnr = vbap~matnr
     INNER JOIN  makt ON makt~matnr = vbap~matnr
  
     WHERE  makt~spras = 'F'
     AND vbak~ernam IN @s_ernam
     AND vbak~auart IN @s_auart
     AND vbak~vbeln IN @s_vbeln
     AND vbak~vkorg IN @s_vkorg
     AND vbak~vtweg IN @s_vtweg
     AND vbak~spart IN @s_spart
     AND vbap~kunnr_ana IN @s_kunnr
     AND vbap~matnr IN @s_matnr
     AND vbap~werks IN @s_werks
     AND vbak~erdat IN @s_erdat
  
     ORDER BY vbak~erdat DESCENDING, vbak~erzet DESCENDING
  
     INTO TABLE @DATA(lt_data).
  
    IF sy-subrc <> 0.
      MESSAGE e013(zgco_msg).
      LEAVE LIST-PROCESSING.
    ELSE.
      MESSAGE s014(zgco_msg).
    ENDIF.
  
    DATA : lo_alv TYPE REF TO cl_salv_table.
  
    CALL METHOD cl_salv_table=>factory
      IMPORTING
        r_salv_table = lo_alv
      CHANGING
        t_table      = lt_data.
  
    CALL METHOD lo_alv->display.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form data_verification
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM data_verification .
  
  * A check must be carried out on the content of the file to ensure that the values exist in the SAP database
  * For example (Client, article, org. Com, channel distrib, sa, etc.)
  
  * Selection of data in the mara, knvp, vbap, vbak tables and insert them into an internal table to serve as verification data
  * vbak~vkorg , organisation commercial
  * vbak~vtweg , Canal de distribution
  * vbak~spart , Secteur d'activité
  * vbak~bukrs_vf , Société à facturer
  * vbap~posnr , Poste de document de vente
  * mara~matnr , Numéro d'article
  * knvp~parvw , Rôle partenaire
  * knvp~kunnr , Numéro de client
  
    SELECT vbak~vkorg, vbak~vtweg, vbak~spart, knvp~parvw, knvp~kunnr, vbap~posnr, mara~matnr, vbak~bukrs_vf FROM vbak
    INNER JOIN vbap ON vbap~vbeln = vbak~vbeln
    INNER JOIN knvp ON knvp~kunnr = vbak~kunnr
    INNER JOIN mara ON mara~matnr = vbap~matnr
     INTO TABLE @DATA(lt_select) .
  
  
  * loop on the lt_final table which contains the data of the file to verify the data with the verification table.
  
    LOOP AT lt_final ASSIGNING FIELD-SYMBOL(<ls_final>).
  
      lv_boolean = 't'.
  * data verification
  * TRANSPORTING NO FIELDS will be used to check for a particular condition without using its contents
  * READ TABLE IT_KNA1 WITH KEY LAND1 = 'DE' TRANSPORTING NO FIELDS, for example in this example, this only needs to check whether the country ->
  * for customer is Germany or not. But it does not need the contents of the lt_kna1
  * If TRANSPORTING NO FIELDS is used, the statement READ TABLE only checks whether the row that is being searched for exists, and fills the system fields sy-subrc
  
      READ TABLE lt_select TRANSPORTING NO FIELDS       "vkorg  sales_org
        WITH KEY vkorg = <ls_final>-sales_org.
      IF sy-subrc = 0.
        READ TABLE lt_select TRANSPORTING NO FIELDS
        WITH KEY vtweg = <ls_final>-distr_chan.  "vtweg  distr_chan
        IF sy-subrc = 0.
          READ TABLE lt_select TRANSPORTING NO FIELDS   "spart  sect_act
          WITH KEY spart = <ls_final>-sect_act.
          IF sy-subrc = 0.
            READ TABLE lt_select TRANSPORTING NO FIELDS   "parvw partn_role_ag
            WITH KEY parvw = <ls_final>-partn_role_ag.
            IF sy-subrc = 0.
              READ TABLE lt_select TRANSPORTING NO FIELDS
              WITH KEY kunnr = <ls_final>-partn_numb_ag.  "kunnr partn_numb_ag
              IF sy-subrc = 0.
                READ TABLE lt_select TRANSPORTING NO FIELDS
                WITH KEY parvw = <ls_final>-partn_role_we. "parvw partn_role_we
                IF sy-subrc = 0.
                  READ TABLE lt_select TRANSPORTING NO FIELDS   "kunnr partn_numb_we
                  WITH KEY kunnr = <ls_final>-partn_numb_we.
                  IF sy-subrc = 0.
                    READ TABLE lt_select TRANSPORTING NO FIELDS "posnr  itm_numb
                    WITH KEY posnr = <ls_final>-itm_numb.
                    IF sy-subrc = 0.
                      READ TABLE lt_select TRANSPORTING NO FIELDS   "matnr  material
                      WITH KEY matnr = <ls_final>-material.
                      IF sy-subrc = 0.
                        READ TABLE lt_select TRANSPORTING NO FIELDS   "bukrs_vf plant
                        WITH KEY bukrs_vf = <ls_final>-plant.
                        IF sy-subrc = 0.
  
                        ELSE.
                          lv_boolean = 'f' .
                        ENDIF.
                      ELSE.
                        lv_boolean = 'f' .
                      ENDIF.
                    ELSE.
                      lv_boolean = 'f' .
                    ENDIF.
                  ELSE.
                    lv_boolean = 'f' .
                  ENDIF.
                ELSE.
                  lv_boolean = 'f' .
                ENDIF.
              ELSE.
                lv_boolean = 'f' .
              ENDIF.
            ELSE.
              lv_boolean = 'f' .
            ENDIF.
          ELSE.
            lv_boolean = 'f' .
          ENDIF.
        ELSE.
          lv_boolean = 'f' .
        ENDIF.
      ELSE.
        lv_boolean = 'f' .
      ENDIF.
  
  * delete rows if there are some missing data
  
      IF lv_boolean = 'f' .
        DELETE lt_final INDEX lv_index_1.
        lv_index_1 = lv_index_1 - 1.
      ENDIF.
      lv_index_1 = lv_index_1 + 1.
    ENDLOOP.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form batch_input
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  *FORM batch_input .
  *
  *  DATA : lv_id_com  TYPE zid_com_po,
  *         lv_quant   TYPE string,
  *         lv_poste   TYPE i,
  *         lt_message TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE.
  *
  *  TYPES: BEGIN OF ty_cr,
  *           statut  TYPE zkde_icon,
  *           message TYPE zkde_message,
  *         END OF ty_cr.
  *
  *  DATA : gt_cr TYPE STANDARD TABLE OF ty_cr,
  *         ls_cr TYPE ty_cr.
  *
  *  LOOP AT lt_final ASSIGNING FIELD-SYMBOL(<fs_data>).
  *
  *    CLEAR bdcdata.
  *
  *    IF <fs_data>-id_commande = lv_id_com.
  *      CONTINUE.
  *    ENDIF.
  *
  *    lv_id_com = <fs_data>-id_commande.
  *  ENDLOOP.
  *
  ** VBAK is the table header, go to TCODE VA01
  ** type commande client JRE
  ** org. com.1710
  ** sec. dac. 00
  ** canal dist. 10
  ** click right, click aide and techniq inf.
  *
  *  PERFORM   bdc_dynpro USING  'SAPMV45A' '0101'.
  *  PERFORM bdc_field USING 'bdc_cursor' 'vbak-auart'.
  *
  *  PERFORM bdc_field USING 'vbak-auart' <fs_data>-doc_type.
  *  PERFORM bdc_field USING 'bdc_cursor' 'vbak-vkorg'.
  *  PERFORM bdc_field USING 'vbak-vkorg' <fs_data>-sales_org.
  *  PERFORM bdc_field USING 'bdc_cursor' 'vbak-vtweg'.
  *  PERFORM bdc_field USING 'vbak-vtweg' <fs_data>-distr_chan.
  *  PERFORM bdc_field USING 'bdc_cursor' 'vbak-spart'.
  *  PERFORM bdc_field USING 'vbak-vtweg' <fs_data>-sect_act.
  *
  *
  *  PERFORM   bdc_dynpro USING  'SAPMV45A' '4001'.
  *  PERFORM bdc_field USING 'bdc_cursor' 'kuagv-kunnr'.
  *  PERFORM bdc_field USING 'kuagv-kunnr' <fs_data>-partn_numb_ag.
  *  PERFORM bdc_field USING 'bdc_cursor' 'kuwev-kunnr'.
  *  PERFORM bdc_field USING 'kuwev-kunnr' <fs_data>-partn_numb_we.
  *  PERFORM bdc_field  USING 'BDC_CURSOR' 'VBKD-BSTKD'.
  *  PERFORM bdc_field  USING 'VBKD-BSTKD' '1234'.
  *  PERFORM bdc_field  USING 'BDC_CURSOR' 'VBAK-AUGRU'.
  *  PERFORM bdc_field  USING 'VBAK-AUGRU' '007'.
  *  PERFORM bdc_field  USING 'BDC_SUBSCR' 'SAPMV45A'.
  *
  ** We must now retrieve all the position data of the same order
  ** to add them all to our Batch Input data table
  *
  *  LOOP AT lt_final ASSIGNING FIELD-SYMBOL(<fs_data2>) WHERE id_commande = <fs_data>-id_commande .
  *    CLEAR lv_quant.
  *
  *    lv_poste = lv_poste + 1.
  *
  ** We convert the quantity field so that it is adapted to the DYNPRO field
  *    MOVE <fs_data2>-quantity TO lv_quant.
  *
  *    CASE lv_poste.
  *      WHEN 1.
  *        PERFORM bdc_field USING 'bdc_cursor' 'RV45A-MABNR(01)'.
  *        PERFORM bdc_field USING 'RV45A-MABNR(01)' <fs_data2>-material.
  *        PERFORM bdc_dynpro USING 'SAPMV45A' '4001'.
  *        PERFORM bdc_field USING 'bdc_cursor' 'RV45A-KWMENG(01)'.
  *        PERFORM bdc_field USING 'RV45A-KWMENG(01)' lv_quant.
  *
  *      WHEN 2.
  *        PERFORM bdc_field USING 'bdc_cursor' 'RV45A-MABNR(02)'.
  *        PERFORM bdc_field USING 'RV45A-MABNR(02)' <fs_data2>-material.
  *        PERFORM bdc_field USING 'bdc_cursor' 'RV45A-KWMENG(02)'.
  *        PERFORM bdc_field USING 'RV45A-KWMENG(02)' lv_quant.
  *
  *      WHEN 3.
  *        PERFORM bdc_field USING 'bdc_cursor' 'RV45A-MABNR(03)'.
  *        PERFORM bdc_field USING 'RV45A-MABNR(03)' <fs_data2>-material.
  *        PERFORM bdc_field USING 'bdc_cursor' 'RV45A-KWMENG(03)'.
  *        PERFORM bdc_field USING 'RV45A-KWMENG(03)' lv_quant.
  *
  *    ENDCASE.
  *  ENDLOOP.
  *
  *  PERFORM bdc_dynpro USING 'SAPMV45A' '4001'.
  *  PERFORM bdc_field USING 'BDC_OKCODE' '=SICH'.
  *  CLEAR lv_poste.
  *
  *
  *  CALL TRANSACTION 'VA01' USING bdcdata MODE 'E' MESSAGES INTO lt_message.
  *
  *  LOOP AT lt_message.
  *    CLEAR ls_cr.
  *
  *    CASE lt_message-msgtyp.
  *      WHEN 'S'.
  *        ls_cr-statut = '@08@'.
  *        MESSAGE s020(zgco_msg) WITH lt_message-msgv2  <fs_data>-id_commande INTO ls_cr-message.
  *        APPEND ls_cr TO gt_cr.
  *      WHEN 'E'.
  *        ls_cr-statut = '@0A@'.
  *        MESSAGE s021(zgco_msg) WITH lt_message-msgv2  <fs_data>-id_commande INTO ls_cr-message.
  *        APPEND ls_cr TO gt_cr.
  *      WHEN OTHERS.
  *    ENDCASE.
  *
  *  ENDLOOP.
  *
  *  CLEAR lt_message[].
  *
  *ENDLOOP.
  *
  *ENDFORM.