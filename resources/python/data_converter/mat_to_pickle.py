# This file converts the .mat data file to python pickle
# Dependencies: numpy, h5py, mat73
# Input: result_path: path to the result dir
#        output_path: path where the pkl file would be saved


import sys
import os.path # os.path.exists
import mat73
import pickle

def verify_result(result_path):
    valid = True
    if not os.path.exists(result_path + '/archive.mat'):
        valid = False
    elif not os.path.exists(result_path + '/robots.mat'):
        valid = False
    elif not os.path.exists(result_path + '/robots_dump.mat'):
        valid = False
    elif not os.path.exists(result_path + '/stat.mat'):
        valid = False

    return valid

def convert_mat_to_pickle(result_path, output_path):
    # get result dirname, and output to output_path/result_dir.pkl
    if not verify_result(result_path):
        return

    archive_mat = mat73.loadmat(result_path + '/archive.mat')
    robots_mat = mat73.loadmat(result_path + '/robots.mat')
    robots_dump_mat = mat73.loadmat(result_path + '/robots_dump.mat')
    stat_mat = mat73.loadmat(result_path + '/stat.mat')

    result = {};
    result['archive'] = archive_mat['archive']
    result['robots_info'] = robots_mat['robots']
    result['robots_gene'] = robots_dump_mat['robots_dump']
    result['stat'] = stat_mat['stat']

    # Output
    output_filename = output_path + '/' + os.path.basename(result_path) + '.pkl'
    with open(output_filename, 'wb') as handle:
        pickle.dump(result, handle, protocol=pickle.HIGHEST_PROTOCOL)

if __name__ == "__main__":
    result_path = sys.argv[1]
    output_path = sys.argv[2]

    convert_mat_to_pickle(result_path, output_path)
    #  input("Press ENTER to exit")
