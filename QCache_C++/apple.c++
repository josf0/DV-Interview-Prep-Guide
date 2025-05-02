//traverse through a 3D matrix and print the elements
void traverse3D(const vector<vector<vector<int>>>& matrix) {
    int X = matrix.size(); //number of 2D slices 
    int Y = matrix[0].size(); //number of rows
    int Z = matrix[0][0].size(); //number of columns

    for(int x = 0; x < S; x++) {
        for(int y = 0; y < Y; y++) {
            for(int z = 0; z < Z; z++) {
                cout << matrix[x][y][z] << "";
            }
        }
    }
}