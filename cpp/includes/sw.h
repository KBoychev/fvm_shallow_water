
#include <iostream>
#include <iomanip>
#include <vector>
#include <fstream>
#include <string>
#include <sstream>
#include <regex>
#include <Eigen/Dense>

#include "cell.h"

//Solver structure
struct sw
{
    std::fstream file;
    std::string case_name;
    double dt;
    int N_timesteps;
    int N_cells;
    int N_edges;
    std::vector<cell> cells;
    int output_frequency;
    int riemann_solver;
    std::vector<edge> edges;
    std::vector<Eigen::Vector3d> vertices;
    int N_vertices;
};

//Solver functions
void read_config(sw &);
void read_grid(sw &);
void find_cell_neighbours(sw &);
void write_results(sw &, int);
Eigen::Vector3d flux(Eigen::Vector3d, Eigen::Vector3d, Eigen::Vector3d, int);
