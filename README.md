# Finite volume method for shallow water equations

A 2D unstructured finite volume method (FVM) shallow water solver written in C++. Fluxes can be evaluated with the Lax–Friedrichs or the Roe method. Implicit and explicit time stepping is available. Expicit time stepping can be performed with the Euler, the Runge-Kutta 2nd-order, and the Runge-Kutta 4th-order methods. The jacobian used for the implicit time stepping is numerically evaluated and the linear system of equations is solved with the BiCGSTAB method. The Eigen C++ template library for linear algebra is used along with OpenMP. 

Grid

![Dam break grid](https://github.com/KBoychev/fvm_shallow_water/blob/master/dam_break_grid.png "Grid")

Water height

![Dam break water height](https://github.com/KBoychev/fvm_shallow_water/blob/master/dam_break.png "Water height")

Effect of the flux method; Gray surface is Lax-Friedrichs, red is Roe

![Dam break flux method](https://github.com/KBoychev/fvm_shallow_water/blob/master/dam_break_flux_methods.png "Flux method")

Effect of the integration method; Gray surface is Euler, red is Runge-Kutta 2nd order, blue is Runge-Kutta 4th order

![Dam break integration method](https://github.com/KBoychev/fvm_shallow_water/blob/master/dam_break_integration_methods.png "Integration method")

The code solves the following partial differential equations

![Shallow water PDE](https://render.githubusercontent.com/render/math?math=\frac{\partial%20Q}{\partial%20t}%20%2B%20\frac{\partial%20F_{x}}{\partial%20t}%20%2B%20\frac{\partial%20F_{y}}{\partial%20t}=0 "Shallow water PDE")

where

![Vector of conserved variables](https://render.githubusercontent.com/render/math?math=Q=[h,hu,hv]^T "Vector of conserved variables")

![Flux in x-direction](https://render.githubusercontent.com/render/math?math=F_{x}=[hu,hu^2+\frac{1}{2}gh^2,huv]^T "Flux in x-direction")

![Flux in y-direction](https://render.githubusercontent.com/render/math?math=F_{y}=[hv,hvu,hv^2+\frac{1}{2}gh^2]^T "Flux in y-direction")


# Compile

The code requires the Eigen C++ template libary. Download the libary and extract its contents to a folder named Eigen inside the includes folder (includes/Eigen). Once extracted use make to compile the code. The sw_solver binary will be created in the bin folder. 

# Run

To run the code navigate to the folder of the case e.g. dam_coarse_lf and run ../bin/sw_solver dam. The program will solve the dam break problem using the Lax-Friedrichs method for 1000 time steps with a time step of 0.003. The full list of options is:

* dt - timestep
* N_timesteps - number of timesteps
* riemann_solver - Riemman solver; 1 - Lax-Friedrichs, 2 - Roe
* output_frequency - Results output frequency; 0 - no output, i where i > 0 - every ith iteration 
* integrator - Integration method; 0 - Euler, 1 - Runge-Kutta 2nd-order, 2 - Runge-Kutta 4th order
* implicit - Solve the equation explicitly or implicitly; 0 - Explicit, 1 - Implicit 

Note: If the implicit option is set to 1 the integrator option is not used. 