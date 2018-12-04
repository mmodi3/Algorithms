/*******************************************************************************
 * Name        : shortestpaths.cpp
 * Author      : Mitra Modi and Mathew Seedhom
 * Date        : Nov 27, 2018
 * Description : 
 * Pledge      : I pledge my honor that I have abided by the Stevens Honor System.
 ******************************************************************************/
#include <iostream>
#include <sstream>
#include <fstream>
#include <algorithm>
#include <iomanip>

using namespace std;

int num_vertices = 0;
long INF = numeric_limits<long>::max();

string indirect_path(int i, int j, long** const intermediate_vertices){
	string path = "";
	long intermediate = intermediate_vertices[i][intermediate_vertices[i][j]];
	if (intermediate != INF){
		path = path + " -> ";
		path.push_back(static_cast<char>(intermediate_vertices[i][intermediate_vertices[i][j]])+'A');
		path += indirect_path(intermediate, j, intermediate_vertices);
	}
	return path;
}

string find_int_paths(int i, int j, long** const intermediate_vertices){
	string path = "";
	path.push_back(static_cast<char>(i+'A'));
	if (i == j){
		return path;
	}else if (intermediate_vertices[i][j] == INF){
		return path + " -> " + static_cast<char>(j+'A');
	} else {
		return path + indirect_path(i, j, intermediate_vertices) + " -> " + find_int_paths(intermediate_vertices[i][j], j, intermediate_vertices);
	}
}

/*
 * Displays all the paths between vertices with weights
 */
void display_paths(long** const path_lengths, long** const intermediate_vertices) {
	for (int i = 0; i < num_vertices; i++){
		for (int j = 0; j < num_vertices; j++){
			if (i == num_vertices-1 && j == num_vertices-1){
				cout << static_cast<char>(i+'A') << " -> " << static_cast<char>(j+'A') << ", distance: ";
				if (path_lengths[i][j] == 9223372036854775807){
					cout << "infinity";
				} else {
					cout << path_lengths[i][j];
				}
				cout << ", path: "<< find_int_paths(i, j, intermediate_vertices);
			}else{
				cout << static_cast<char>(i+'A') << " -> " << static_cast<char>(j+'A') << ", distance: ";
				if (path_lengths[i][j] == 9223372036854775807){
					cout << "infinity" << ", path: "<< "none" << endl;
				} else {
					cout << path_lengths[i][j] << ", path: "<< find_int_paths(i, j, intermediate_vertices) << endl;
				}
			}
		}
	}
}

/*
 * Finds shortest weighted path between all nodes.
 */
void floyd(long** const org_matrix, long** path_matrix, long** int_matrix){
	for (int k = 0; k < num_vertices; k++){
		for (int i = 0; i < num_vertices; i++){
			for (int j = 0; j < num_vertices; j++){
				long pos1 = path_matrix[i][k];
				long pos2 = path_matrix[k][j];
				if (!(pos1 == INF || pos2 == INF) && (pos1 + pos2 < path_matrix[i][j])){
					path_matrix[i][j] = path_matrix[i][k] + path_matrix[k][j];
					int_matrix[i][j] = k;
				}
			}
		}
	}
}

/*
* Displays the matrix on the screen formatted as a table.
*/
void display_table(long** const matrix, const string &label, const bool use_letters = false) {
	cout << label << endl;
	long max_val = 0;
	for (int i = 0; i < num_vertices; i++) {
		for (int j = 0; j < num_vertices; j++) {
			long cell = matrix[i][j];
			if (cell < INF && cell > max_val) {
				max_val = matrix[i][j];
			}
		}
	}
	int max_cell_width = to_string(max(static_cast<long>(num_vertices), max_val)).length();
	cout << ' ';
	for (int j = 0; j < num_vertices; j++) {
		cout << setw(max_cell_width + 1) << static_cast<char>(j + 'A');
	}
	cout << endl;
	for (int i = 0; i < num_vertices; i++) {
		cout << static_cast<char>(i + 'A');
		for (int j = 0; j < num_vertices; j++) {
			cout << " " << setw(max_cell_width);
			if (matrix[i][j] == INF) {
				cout << "-";
			} else if (use_letters) {
				cout << static_cast<char>(matrix[i][j] + 'A');
			} else {
				cout << matrix[i][j];
			}
		}
		cout << endl;
	}
	cout << endl;
}
int main(int argc, char * const argv[]) {
    int error = 0;
    if (argc != 2){
        cerr << "Usage: ./shortestpaths <filename>";
        return 1;
    }
    string line;
    ifstream file (argv[1]);
    if (file.is_open()){
        string to, from;
        string weigh;
        long weight;
        int linenum = 1;
        getline(file, line);
        istringstream ss(line);
        if (!(ss >> num_vertices)){
            ss >> line;
            cerr << "Error: Invalid number of vertices '"<< line <<"' on line 1.";
            return 1;
        }else if (num_vertices < 1){
            cerr << "Error: Invalid number of vertices '"<< num_vertices <<"' on line 1.";
            return 1;
        }
        long** contents = new long*[num_vertices];
        long** paths = new long* [num_vertices];
        for (int i = 0; i < num_vertices; i++){
            contents[i] = new long[num_vertices];
            paths[i] = new long[num_vertices];
            for (int j = 0; j < num_vertices; j++){
                if (i == j){
                    contents[i][j] = 0;
                    paths[i][j] = 0;
                }else{
                    contents[i][j] = INF;
                    paths[i][j] = INF;
                }
            }
        }
        long** middle_paths = new long* [num_vertices];
        for (int i = 0; i < num_vertices; i++){
            middle_paths[i] = new long[num_vertices];
            for (int j = 0; j < num_vertices; j++){
                middle_paths[i][j] = INF;
            }
        }
 
        while (getline(file, line)){
            stringstream linebuff(line), linecheck(line);
            int count = 0;
            linenum++;
            while (linebuff >> to){
                count ++;
            }
            if (count != 3){
                cerr << "Error: Invalid edge data '" << line << "' on line " << linenum << ".";
                error = 1;
                goto cleanup;
            }
            linecheck >> from;
            linecheck >> to;
            if (from[0] - 64 > num_vertices || from[0] < 65 || from[0] > 90){
                cerr << "Error: Starting vertex '" << from << "' on line " << linenum << " is not among valid values A-" << static_cast<char>(num_vertices-1+'A') << ".";
                error = 1;
                goto cleanup;
            }else if (to[0] - 64 > num_vertices || to.size() > 1 || to[0] < 65 || to[0] > 90){
                cerr << "Error: Ending vertex '" << to << "' on line " << linenum << " is not among valid values A-" << static_cast<char>(num_vertices-1+'A') << ".";
                error = 1;
                goto cleanup;
            }
            if (!(linecheck >> weight)){
                linecheck >> weigh;
                cerr << "Error: Invalid edge weight '" << weigh << "' on line "<< linenum << ".";
                error = 1;
                goto cleanup;
            } else if (weight <= 0){
                cerr << "Error: Invalid edge weight '" << weight << "' on line "<< linenum << ".";
                error = 1;
                goto cleanup;
            }
            contents[static_cast<int>(from[0]) - 65][static_cast<int>(to[0]) - 65] = weight;
            paths[static_cast<int>(from[0]) - 65][static_cast<int>(to[0]) - 65] = weight;
        }
 
        display_table(contents, "Distance matrix:");
        floyd(contents, paths, middle_paths);
        display_table(paths, "Path lengths:");
        display_table(middle_paths, "Intermediate vertices:", true);
        display_paths(paths, middle_paths);
        goto cleanup;
 
        cleanup:
            for (int i = 0; i < num_vertices; i++){
                delete [] contents[i];
                delete [] paths[i];
                delete [] middle_paths[i];
            }
            delete [] contents;
            delete [] paths;
            delete [] middle_paths;
    }else{
        cerr << "Error: Cannot open file '" << argv[1] << "'.";
        return 1;
    }
    if (error == 1){
        return 1;
    }else{
        return 0;
    }
}

