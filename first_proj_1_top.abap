*&---------------------------------------------------------------------*
*& Include          ZCCD_PROJET_TOP
*&---------------------------------------------------------------------*
TABLES: vbap,vbak.


DATA : lv_line TYPE string.


***************************** Split method  *************************************
* 1) First create model for internal table, it containes the name of the fields as string
* this model is created for split method, it containes the filed names of the table

TYPES: BEGIN OF ty_csv,
         id_commande   TYPE string,
         doc_type      TYPE string,
         sales_org     TYPE string,
         distr_chan    TYPE string,
         sect_act      TYPE string,
         partn_role_ag TYPE string,
         partn_numb_ag TYPE string,
         partn_role_we TYPE string,
         partn_numb_we TYPE string,
         itm_numb      TYPE string,
         material      TYPE string,
         plant         TYPE string,
         quantity      TYPE string,
         quantity_unit TYPE string,
       END OF ty_csv.


* 2) decalare internal table file as string
* 3) declare internal table file 2 to use this model
* 4) declare structure from this model, here if you use directly model name, you have to use TYPE TABLE OF
* If you use internal table name, you have to use LIKE LINE OF

DATA: lt_file       TYPE STANDARD TABLE OF string,
       lt_file2      TYPE TABLE OF ty_csv,
       ls_table_line TYPE ty_csv.
*      ls_table_line LIKE LINE OF lt_file2.

DATA: lv_count  TYPE i,
      lv_index  TYPE i VALUE 1,
      lv_column TYPE string.

****************************** FINAL TABLE ***********************************************

* create model for final, it containes real data types

TYPES: BEGIN OF ty_csv2,
         id_commande   TYPE char8,
         doc_type      TYPE auart,
         sales_org     TYPE vkorg,
         distr_chan    TYPE vtweg,
         sect_act      TYPE spart,
         partn_role_ag TYPE parvw,
         partn_numb_ag TYPE kunnr,
         partn_role_we TYPE parvw,
         partn_numb_we TYPE kunnr,
         itm_numb      TYPE posnr,
         material      TYPE matnr,
         plant         TYPE bukrs,
         quantity      TYPE bstmg,
         quantity_unit TYPE bstme,
       END OF ty_csv2.

* From this model declare final table and final structure

DATA: lt_final TYPE TABLE OF ty_csv2,
      ls_final TYPE ty_csv2.
*     ls_final LIKE LINE OF lt_final,

************************************** prepare data, data verification  *****************************************

DATA: lv_index_1 TYPE i VALUE '1'.
DATA: lv_boolean TYPE boolean VALUE 't'.


************************************** BAPI *************************************************

* declare importation parameters, internal table and structure

DATA : lt_order_header_in TYPE  bapisdhd1,
       ls_order_header_in TYPE  bapisdhd1.

DATA : lt_order_header_inx TYPE bapisdhd1x,
       ls_order_header_inx TYPE  bapisdhd1x.

* declare exortation parameters, sales document

DATA : lv_vbeln TYPE bapivbeln-vbeln.

* declare tables parameters

DATA : lt_return TYPE TABLE OF bapiret2,
       ls_return TYPE  bapiret2.

DATA : lt_order_items_in TYPE TABLE OF  bapisditm,
       ls_order_items_in TYPE  bapisditm.

DATA : lt_order_items_inx TYPE TABLE OF  bapisditmx,
       ls_order_items_inx TYPE  bapisditmx.

DATA : lt_order_partners TYPE TABLE OF  bapiparnr,
       ls_order_partners TYPE bapiparnr.


************************************* BAPI return message ********************************

* Create a small model for internal table to see the result of the return error message

TYPES: BEGIN OF ty_return,
         id_commande TYPE char8,
         result      TYPE char15,
         num_com     TYPE vbeln,
         message     TYPE string,
       END OF ty_return.

DATA: lt_return_msg TYPE TABLE OF ty_return,
      ls_return_msg TYPE ty_return.


DATA : bdcdata LIKE bdcdata OCCURS 0 WITH HEADER LINE.


********************************** FORMULAIRE *************************

TYPES: BEGIN OF ty_form_h,
         id_commande TYPE char8,
         result      TYPE char15,
         num_com     TYPE vbeln,
         message     TYPE string,
       END OF ty_form_h.