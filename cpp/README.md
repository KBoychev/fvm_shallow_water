

# Compile

The code requires the Eigen C++ libary. Download the libary and extract its contents to a folder named Eigen inside the includes folder. Once done run make to compile the code. The sw_solver binary will be created in the bin folder. 

# Run

To run the code navigate to the folder of the case e.g. dam_coarse_lf and run ../bin/sw_solver dam. The program will solve the dam break problem using the Lax-Friedrichs method for 1000 time steps with a time step of 0.003.
