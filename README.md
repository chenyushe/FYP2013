FYP2013
=======

System Description:

SDRAM_HW.v is the top-level memory controller. 

Sdram_Controller.v is second level of the memory controller. 

It is constructed with command.v, control_interface.v and sdr_data_path.v.

The Sdram_Params.h is used to define the timing contraints of the memory controller.

Address mif files are stored in folder 'FYP2013 / testingData / Address set /'.

The AddrRam need to be pre-loaded with the mif file stored in this folder.


State Machine description:

State 0,1 and 2

These three states are for initialisation.

State 3

The state 3 here has three main tasks. 

Firstly, it will go into the delay loop after the final write operation is finished. 

Secondly, it will act as a transition state that point to either write operation loop (state 4&5) or read operation loop(state 6&7). 

Lastly, it will also write feedback to MyRAM indicating the status of the memory address after the data's intactness have been checked.

State 4

3 tasks:

1st it will enable write signal and prepare writein data.

2nd it will read the address from Address RAM (AddrRAM) to the memory controller.

3nd it will update new delay time with the granularity after the last write operation

State 5

In this state, it will wait until write operation finish and terminate the write enable signal. 

It will also increment write count.

State 6

2 main tasks:

1st it will enable read signal.

2nd it will read the address stored in the AddrRAM.

State 7

It will wait until read operation finished and check the intactness.

The read enable signal will also be terminated. 

Read counter increment.

State 8

Since after the last read operation, the trial is going to finish. 

Instead of guide to state 3 to write the status to the result RAM.(MyRAM)

After the last read operation, state machine will go to this state to write in the status of the last read memory cell.

State 9

This is the last state.

It will write in corresponding end of trial signal like, '01FF'. (end of trial 2)

Trial count will also be updated.

If trial counter is larger than trial countrol, the whole testing will terminate.

Disable Refresh:

Firstly, I deleted the code corresponding to decode the refresh command from Sdram_controller.v in control_interface.v.

So there is no refresh request from control_interface.v to command.v. 

Secondly, since in this testing a close-page policy memory controller is needed, after every read/write operation a precharge is needed.

What I did is, add precharge request at the control timing after every read/write operation in Sdram_controller.v. 



Testing Results:

The exel files with 'Analysed_ ' shows the analysed version of the raw data.

Analysed_RowFixCol.xlsx shows the results of Random-Row Fixed-Column test.

Analysed_ColFixRow.xlsx shows the results of Random-Col Fixed-Row test.

Analysed_ColFixRow_1.xlsx shows the raw data for Bank 0 3D retention time diagram.

Analysed_Precision.xlsx shows the precision results.

Analysed_Temperature.xlsx shows the results of 3 temperature test.

Analysed_3TempComparison.xlsx combine 3 temperature results.


ModifyResult.m is the matlab file used to sort the raw data collected from QuartusII.

All the raw data in mif file collected from QuartusII are stored in "FYP2013 / testingData / result /" folder.
