# Finite volume method for shallow water equations

The code solves the shallow water equations for a dam break problem using the finite volume method on an 2D unstructured grid. The cell normals must point in the positive z-direction. Fluxes can be evaluated with the Lax-Friedrichs or Roe methods and the expicit time stepping is performed with the Euler method. The code is for teaching/learning purposes and is not optimised in any way. A C++ and a Matlab version of the code are available.

![Dam break grid](https://github.com/KBoychev/fvm_shallow_water/blob/master/dam_break_grid.png "Grid")

![Dam break water height](https://github.com/KBoychev/fvm_shallow_water/blob/master/dam_break.png "Water height")

<video controls="true" >
    <source src="https://github.com/KBoychev/fvm_shallow_water/blob/master/dam_break.ogv" type="video/ogg">
</video>

# Run

To run the code open the main.m file with Matlab. The case name, number of time steps, the step size, and the output friequency can be adjusted. 

