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
	}

	// Run time loop
	////////////////////////////////////////////////////////////////////

	std::cout << "Performing " << sw.N_timesteps << " explicit steps..." << std::endl;

	double t = 0;

	for (int n = 0; n < sw.N_timesteps; n++)
	{

		std::cout << "Step " << n << ", t=" << t << std::endl;

		// Set cell residuals to 0
		for (int i = 0; i < sw.N_cells; i++)
		{
			sw.cells[i].R(0) = 0;
			sw.cells[i].R(1) = 0;
			sw.cells[i].R(2) = 0;
		}

		// Flux calculation
		// #pragma omp parallel for
		for (int i = 0; i < sw.N_edges; i++)
		{
			int celll, cellr;
			double l;
			Eigen::Vector3d n, Ql, Qr, delta, F;

			celll = sw.edges[i].celll;
			cellr = sw.edges[i].cellr;
			n = sw.edges[i].n;
			l = sw.edges[i].l;

			// Left conservative variables
			Ql = sw.cells[celll].Q;

			// Right conservative variables
			if (cellr != -1) // Check if right cell exists
			{
				Qr = sw.cells[cellr].Q;
			}
			else
			{
				Qr = Ql;
				Qr(1) = -Qr(1);
				Qr(2) = -Qr(2);
			}

			F = flux(Ql, Qr, n, sw.riemann_solver);

			// Subtract flux from left cell
			sw.cells[celll].R -= F * l;
			if (cellr != -1) // Check if right cell exists
			{
				// Add flux to right cell
				sw.cells[cellr].R += F * l;
			}
		}

		// Time integration
		for (int i = 0; i < sw.N_cells; i++)
		{
			sw.cells[i].Q -= (sw.dt / sw.cells[i].S) * sw.cells[i].R;
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
