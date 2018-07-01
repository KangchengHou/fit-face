#include "GCoptimization.h"	
#include <string>
#include <iostream>
#include <fstream>
#include <cmath>
using namespace std;
double diff_norm(const double *m1, const double *m2, int n) {
	double result = 0;
	for (int i = 0; i < n; i++) {
		result = result + pow((m1[i] - m2[i]), 2);
	}
	result = sqrt(result);
	return result;
}
struct Mat {
	Mat(string path) {
		ifstream file;
		file.open(path);
		// first line contains the rows and cols
		file >> rows >> cols;
		data = new double*[rows];
		for (int i = 0; i < rows; i++) {
			data[i] = new double[cols];
		}
		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < cols; j++) {
				file >> data[i][j];
			}
		}
		file.close();
	}
	~Mat() {
		for (int i = 0; i < rows; i++) {
			delete[] data[i];
		}
		delete[]data;
	}
	void print_info() const {
		std::cout << "rows: " << rows << ", cols: " << cols << std::endl;
	}
	double **data;
	int rows;
	int cols;
};


struct SmoothData {
	SmoothData(string root) {
		// the gradient information of two image
		// in shape M * N x 6
		string grad1_path = root + "grad1.txt";
		string grad2_path = root + "grad2.txt";
		grad1 = new Mat(grad1_path);
		grad2 = new Mat(grad2_path);
	}
	~SmoothData() {
		delete grad1;
		delete grad2;
	}
	Mat *grad1;
	Mat *grad2;
};



double smooth_function(int p, int q, int lp, int lq, void * data)
{
	// input: pixel p, pixel q, label of pixel p, lalebl of pixel q
	// return the cost of such configuration
	
	// weight 1e-2 works for elizabeth olsen
	double weight = 1e-2;
	SmoothData * smooth_data = (SmoothData *)data;
	int cols = smooth_data->grad1->cols;
	double* grad1p = smooth_data->grad1->data[p];
	double* grad2p = smooth_data->grad2->data[p];
	double* grad1q = smooth_data->grad1->data[q];
	double* grad2q = smooth_data->grad2->data[q];
	//std::cout << diff_norm(grad1p, grad2p, cols) << std::endl;
	if (lp == lq) {
		return 0.;
	}
	else {
		return weight * (diff_norm(grad1p, grad2p, cols) + diff_norm(grad1q, grad2q, cols));
	}
}

double data_function(int s, int l, void * data)
{
	double weight = 1;
	double cost = 0;
	Mat * mat = (Mat*)data;
	// in this data, mat[s][l] represents the data
	
	if (l == 1) {
		// if label = 0, outside the crop region
		cost = mat->data[s][0];
	}
	else {
		// if label = 1, inside the crop region
		cost = (1 - mat->data[s][0]);
	}
	return weight * cost;
}


int main(int argc, char ** argv) {
	// read input
	std::string root = "C:/Users/david/Desktop/swapface/graph_cut/data/";
	Mat * data_mat = new Mat(root + "data_cost.txt");
	Mat * neighbor_mat = new Mat(root + "edges.txt");
	//neighbor_mat->print_info();
	
	SmoothData * smooth_data = new SmoothData(root);
	int num_pixels = data_mat->rows;
	int num_labels = 2;
	try {
		GCoptimizationGeneralGraph* gc = new GCoptimizationGeneralGraph(num_pixels, num_labels);
		// 1. set data cost	
		gc->setDataCost(data_function, (void*)data_mat);
		// 2. set smooth cost
		gc->setSmoothCost(smooth_function, (void*)smooth_data);
		// 3. set neighbors
		for (int i = 0; i < neighbor_mat->rows; i++) {
			gc->setNeighbors(neighbor_mat->data[i][0], neighbor_mat->data[i][1]);
		}
		printf("\nBefore optimization energy is %f", gc->compute_energy());
		gc->expansion(10); // run expansion for 2 iterations. For swap use gc->swap(num_iterations);
		printf("\nAfter optimization energy is %f", gc->compute_energy());
		int *result = new int[num_pixels];
		for (int i = 0; i < num_pixels; i++) {
			result[i] = gc->whatLabel(i);
		}
		delete gc;

		// output result
		ofstream result_file;
		result_file.open(root + "result.txt");
		for (int i = 0; i < num_pixels; i++) {
			result_file << result[i] << endl;
		}
		result_file.close();
		//getchar();
	}
	catch (GCException e) {
		e.Report();
	}
}