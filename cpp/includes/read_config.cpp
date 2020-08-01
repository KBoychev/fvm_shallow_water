#include "sw.h"

void read_config(sw &sw)
{

    sw.file.open(sw.case_name + ".conf", std::fstream::in);

    if (sw.file.is_open())
    {
        std::string file_line;
        std::smatch file_line_match;
        std::regex file_line_regex;
        file_line_match.empty();

        sw.dt = 1.0;
        sw.N_timesteps = 1;
        sw.N_cells = 0;
        sw.output_frequency = 0;
        sw.riemann_solver = 0;

        while (std::getline(sw.file, file_line))
        {

            file_line_regex.assign("(.+)(?: = )(.+)");

            if (std::regex_search(file_line, file_line_match, file_line_regex))
            {

                if (file_line_match[1].compare("dt") == 0)
                {
                    sw.dt = std::stod(file_line_match[2]);
                    if (sw.dt <= 0)
                    {
                        std::cout << "Timestep (dt) must be greater than 0!" << std::endl;
                        std::exit(-1);
                    }
                }
                if (file_line_match[1].compare("N_timesteps") == 0)
                {
                    sw.N_timesteps = std::stoi(file_line_match[2]);
                    if (sw.N_timesteps <= 0)
                    {
                        std::cout << "Number of timesteps (N_timesteps) must be greater than 0!" << std::endl;
                        std::exit(-1);
                    }
                }
                if (file_line_match[1].compare("riemann_solver") == 0)
                {
                    sw.riemann_solver = std::stoi(file_line_match[2]);

                    if (sw.riemann_solver < 0 && sw.riemann_solver > 1)
                    {
                        std::cout << "Riemann solver (riemann_solver) must be 0 or 1!" << std::endl;
                        std::exit(-1);
                    }
                }
                if (file_line_match[1].compare("output_frequency") == 0)
                {
                    sw.output_frequency = std::stoi(file_line_match[2]);

                    if (sw.output_frequency < 0)
                    {
                        std::cout << "Output frequency (output_frequency) must be 0 or greater!" << std::endl;
                        std::exit(-1);
                    }
                }
            }
        }

        sw.file.close();
    }
    else
    {
        std::cout << "Failed reading config file!" << std::endl;
        std::exit(-1);
    }
}