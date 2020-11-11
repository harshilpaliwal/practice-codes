# -*- coding: utf-8 -*-
import numpy as np
np.random.seed(1)

vec1 = np.array([0, 0, 0])
mat1 = np.array([[1, 0, 0], [0, 1, 0], [0, 0, 1]])
sample_for_class1 = np.random.multivariate_normal(vec1, mat1, 20).T
assert sample_for_class1.shape == (3, 20), "The dimension of the sample_for_class1 matrix is 3x20"

vec2 = np.array([1, 1, 1])
mat2 = np.array([[1, 0, 0], [0, 1, 0], [0, 0, 1]])
sample_for_class2 = np.random.multivariate_normal(vec2, mat2, 20).T
assert sample_for_class2.shape == (3, 20), "The dimension of the sample_for_class2 matrix is 3x20"

all_data = np.concatenate((sample_for_class1, sample_for_class2), axis=1)
assert all_data.shape == (3, 40), "The dimension of the all_data matrix is 3x20"

mean_dim1 = np.mean(all_data[0, :])
mean_dim2 = np.mean(all_data[1, :])
mean_dim3 = np.mean(all_data[2, :])

mean_vector = np.array([[mean_dim1], [mean_dim2], [mean_dim3]])

print('The Mean Vector:\n', mean_vector)

scatter_matrix = np.zeros((3,3))
for i in range(all_data.shape[1]):
    scatter_matrix += (all_data[:, i].reshape(3, 1) - mean_vector).dot((all_data[:, i].reshape(3, 1) - mean_vector).T)
print('The Scatter Matrix is :\n', scatter_matrix)
    
eig_val, eig_vec = np.linalg.eig(scatter_matrix)

for ev in eig_vec:
    np.testing.assert_array_almost_equal(1.0, np.linalg.norm(ev))

# We Make a list of tuple containing (eigenvalue, eigenvector)
eig_pairs = [(np.abs(eig_val[i]), eig_vec[:,i]) for i in range(len(eig_val))]

# We then Sort list of tuples by the eigenvalue
eig_pairs.sort(key=lambda x: x[0], reverse=True)

# verify that the list is correctly sorted by decreasing eigenvalues
for i in eig_pairs:
    print(i[0])

matrix_w = np.hstack((eig_pairs[0][1].reshape(3,1), eig_pairs[1][1].reshape(3,1)))
print('Matrix W:\n', matrix_w)

    
transformed = matrix_w.T.dot(all_data)
assert transformed.shape == (2,40), "The matrix is 2x40 dimensional."
print('Matrix transformed:\n', transformed)



