*&---------------------------------------------------------------------*
*& Report ZPRJ_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------*
REPORT zprj_2.

INCLUDE ZPRJ_2_top. "Déclaration de mes variables globales, global variable declaration
INCLUDE ZPRJ_2_scr. "Déclaration de notre écran de sélection, declaration of the selection screen
INCLUDE ZPRJ_2_f01. "Traitements effectués sur les données, data processing

START-OF-SELECTION.

* First, get data from file, preapare data, create bapi
  IF rb_file = 'X'.
    PERFORM get_data_from_file.
    PERFORM prepare_data .
    PERFORM bapi.
  ENDIF.

* second, select data, display data
  IF rb_table = 'X'.
    PERFORM select_display.
  ENDIF.

*   IF rb_batch = 'X'.
*    PERFORM batch_input.
*  ENDIF.