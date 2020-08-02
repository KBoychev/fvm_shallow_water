#include <iostream>
#include <string>
#include <chrono>

#include "sw.h"

int main(int argc, char *argv[])
{
	if (argc < 2)
	{
		std::cout << "Usage: sw_solver <case>" << std::endl;
		std::exit(-1);
	}

	sw sw;
	sw.case_name = argv[1];

	// Read config
	////////////////////////////////////////////////////////////////////

	std::cout << "Reading config...";
	read_config(sw);
	std::cout << "Done!" << std::endl;

	std::cout << std::endl;
	std::cout << "dt = " << sw.dt << std::endl;
	std::cout << "N_timesteps = " << sw.N_timesteps << std::endl;
	std::cout << "output_frequency = " << sw.output_frequency << std::endl;
	std::cout << "riemann_solver = " << sw.riemann_solver << std::endl;
	std::cout << "integrator = " << sw.integrator << std::endl;
	std::cout << std::endl;

	// Read grid
	////////////////////////////////////////////////////////////////////

	std::cout << "Reading grid...";
	read_grid(sw);
	std::cout << "Done!" << std::endl;

	std::cout << "N_vertices=" << sw.N_vertices << std::endl;
	std::cout << "N_cells=" << sw.N_cells << std::endl;
	std::cout << "N_edges=" << sw.N_edges << std::endl;

	//Set initial conditions
	////////////////////////////////////////////////////////////////////

	Eigen::VectorXd Q, Q_tmp, k1, k2, k3, k4;

	Q = Eigen::VectorXd::Zero(3 * sw.N_cells);

	for (int i = 0; i < sw.N_cells; i++)
	{
		if (sw.cells[i].r[0] <= -0.3)
		{
			sw.cells[i].Q(0) = 1.5;
			sw.cells[i].Q(1) = 0;
			sw.cells[i].Q(2) = 0;
		}
		else
		{
			sw.cells[i].Q(0) = 1;
			sw.cells[i].Q(1) = 0;
			sw.cells[i].Q(2) = 0;
		}

		Q(3 * i) = sw.cells[i].Q(0);
		Q(3 * i + 1) = sw.cells[i].Q(1);
		Q(3 * i + 2) = sw.cells[i].Q(2);
	}

	// Run time loop
	////////////////////////////////////////////////////////////////////

	std::cout << "Performing " << sw.N_timesteps << " explicit steps..." << std::endl;

	double t = 0;

	for (int n = 0; n < sw.N_timesteps; n++)
	{

		std::cout << "Step " << n << ", t=" << t << std::endl;

		if (sw.integrator == 0) //Euler 1st-order integration
		{
			Q += sw.dt * residual(sw, Q);
		}
		if (sw.integrator == 1) //Runge-kutta 2nd-order integration
		{
			k1 = sw.dt * residual(sw, Q);
			Q_tmp = Q + k1 / 2.0;
			k2 = sw.dt * residual(sw, Q_tmp);
			Q += k2;
		}
		if (sw.integrator == 2) //Runge-kutta 4th-order integration
		{
			k1 = sw.dt * residual(sw, Q);
			Q_tmp = Q + k1 / 2.0;
			k2 = sw.dt * residual(sw, Q_tmp);
			Q_tmp = Q + k2 / 2.0;
			k3 = sw.dt * residual(sw, Q_tmp);
			Q_tmp = Q + k3;
			k4 = sw.dt * residual(sw, Q_tmp);
			Q += 1.0 / 6.0 * (k1 + 2.0 * k2 + 2.0 * k3 + k4);
		}

		t += sw.dt;

		// Results output
		if (sw.output_frequency > 0)
		{
			if (n % sw.output_frequency == 0)
			{
				write_results(sw, n);
			}
		}
	}

	std::cout << "Done!" << std::endl;

	return 0;
}
