FYP2013
=======

System Description:

SDRAM_HW.v is the top-level memory controller. 

Sdram_Controller.v is second level of the memory controller. 

It is constructed with command.v, control_interface.v and sdr_data_path.v.

The Sdram_Params.h is used to define the timing contraints of the memory controller.

Address mif files are stored in folder 'FYP2013 / testingData / Address set /'.

The AddrRam need to be pre-loaded with the mif file stored in this folder.


Testing Results:

The exel files with 'Analysed_ ' shows the analysed version of the raw data.

Analysed_RowFixCol.xlsx shows the results of Random-Row Fixed-Column test.

Analysed_ColFixRow.xlsx shows the results of Random-Col Fixed-Row test.

Analysed_ColFixRow_1.xlsx shows the raw data for Bank 0 3D retention time diagram.

Analysed_Precision.xlsx shows the precision results.

Analysed_Temperature.xlsx shows the results of 3 temperature test.

Analysed_3TempComparison.xlsx combine 3 temperature results.


ModifyResult.m is the matlab file used to sort the raw data collected from QuartusII.

All the raw data collected from QuartusII are stored in "result" folder.
