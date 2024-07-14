

* 1- we have two radio buttons, first one to create of sales orders via a file
* Second one to display of sales orders created via an ALV

* 2- First block, Create general secreen block which includes two radio buttons

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

* 5- radio buttons (for file and table) are in the same screen (in the general screen)

  PARAMETERS: rb_file  RADIOBUTTON GROUP rb1 USER-COMMAND test DEFAULT 'X'.


*****************  Selection screen for file

* 3- Second block for choosing a file

  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.

* 6- First parameter  to choose a file

    PARAMETERS: p_file  TYPE localfile MODIF ID abc.



  SELECTION-SCREEN END OF BLOCK b2.


* 5-radio buttons (for file and table) are in the same screen (in the general screen)

  PARAMETERS:  rb_table RADIOBUTTON GROUP rb1.

  PARAMETERS:  rb_batch RADIOBUTTON GROUP rb1 MODIF ID def.

****************** selection screen for table

* 4- Third block for table

  SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003.

* 7- select options for table

    SELECT-OPTIONS :
    s_ernam FOR vbak-ernam MODIF ID xyz,
    s_auart FOR vbak-auart MODIF ID xyz,
    s_vbeln FOR vbak-vbeln MODIF ID xyz,
    s_vkorg FOR vbak-vkorg MODIF ID xyz,
    s_vtweg FOR vbak-vtweg MODIF ID xyz,
    s_spart FOR vbak-spart MODIF ID xyz,
    s_kunnr FOR vbap-kunnr_ana MODIF ID xyz,
    s_matnr FOR vbap-matnr MODIF ID xyz,
    s_werks FOR vbap-werks MODIF ID xyz,
    s_erdat FOR vbak-erdat MODIF ID xyz.

  SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN END OF BLOCK b1.

* 9- Use AT SELECTION-SCREEN OUTPUT event which gets triggered before generating the Selection Screen
AT SELECTION-SCREEN OUTPUT.

* 10- Loop the screen
  LOOP AT SCREEN.

* 11- Active screen "1"
    IF rb_file EQ 'X' AND screen-group1 = 'ABC'.
      screen-active = 1.
      MODIFY SCREEN.
      CONTINUE.

    ELSEIF rb_table EQ 'X' AND screen-group1 = 'XYZ'.
      screen-active = 1.
      MODIFY SCREEN.
      CONTINUE.

    ELSEIF rb_batch EQ 'X' AND screen-group1 = 'DEF'.
      screen-active = 1.
      MODIFY SCREEN.
      CONTINUE.

* 12- Hide screen "0"
    ELSEIF rb_file EQ ' ' AND screen-group1 = 'ABC'.
      screen-active = 0.
      MODIFY SCREEN.
      CONTINUE.

    ELSEIF rb_table EQ ' ' AND screen-group1 = 'XYZ'.
      screen-active = 0.
      MODIFY SCREEN.
      CONTINUE.

    ELSEIF rb_batch EQ 'X' AND screen-group1 = 'DEF'.
      screen-active = 0.
      MODIFY SCREEN.
      CONTINUE.

    ENDIF.

  ENDLOOP.


* 13- This event is necessery to display the possible values to be entered into the input field.
* 14- but its place is very important, it works only after loop

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

* 15- Call function 'F4_FILENAME' to enter field and file name
* 16- The actual purpose of this Fm is to be able to open a file select dialog box

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'p_file'
    IMPORTING
      file_name     = p_file.








***********************************************************************************************
********************************* selection screen example ***************************


*SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE TEXT-001.
*
*
*  SELECTION-SCREEN BEGIN OF BLOCK b1.
*
*    PARAMETERS : rb_name  RADIOBUTTON GROUP rb1 USER-COMMAND test DEFAULT 'X',
*                 p_fname  TYPE char10 MODIF ID abc,
*                 p_lname  TYPE char10 MODIF ID abc,
*                 rb_adrs  RADIOBUTTON GROUP rb1,
*                 p_city   TYPE char10 MODIF ID def,
*                 p_contry TYPE char10 MODIF ID def,
*                 rb_phone RADIOBUTTON GROUP rb1,
*                 p_home   TYPE char10 MODIF ID xyz,
*                 p_office TYPE char10 MODIF ID xyz.
*
*
*  SELECTION-SCREEN END OF BLOCK b1.
*
*
*SELECTION-SCREEN END OF BLOCK b0.
*
*AT SELECTION-SCREEN OUTPUT.
*
*  LOOP AT SCREEN.
*
*    IF rb_name EQ 'X' AND screen-group1 = 'ABC'.
*     screen-active = 1.
*      MODIFY SCREEN.
*      CONTINUE.
*
*    ELSEIF rb_adrs EQ 'X' AND screen-group1 = 'DEF'.
*      screen-active = 1.
*      MODIFY SCREEN.
*      CONTINUE.
*
*    ELSEIF rb_phone EQ 'X' AND screen-group1 = 'XYZ'.
*      screen-active = 1.
*      MODIFY SCREEN.
*      CONTINUE.
*
*      "hide
*
*    ELSEIF rb_name EQ ' ' AND screen-group1 = 'ABC'.
*      screen-active = 0.
*      MODIFY SCREEN.
*      CONTINUE.
*
*    ELSEIF rb_adrs EQ ' ' AND screen-group1 = 'DEF'.
*      screen-active = 0.
*      MODIFY SCREEN.
*      CONTINUE.
*
*    ELSEIF rb_phone EQ ' ' AND screen-group1 = 'XYZ'.
*      screen-active = 0.
*      MODIFY SCREEN.
*      CONTINUE.
*
*    ENDIF.
*
*  ENDLOOP.