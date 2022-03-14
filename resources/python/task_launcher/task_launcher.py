# This file launches and stops training exe at given length of period
# Input: exe_path (full path)
#        job_file_path (full path)
#        class_time (optional)

import os.path # os.path.exists
import time # sleep
import sys
import json
import subprocess

# set period to -1 to load period from job file
def launch_trainer(evogen_exe_path, job_file_path, period):
    need_to_return = False
    if not os.path.exists(evogen_exe_path):
        print("EvoGen Python Trainer Error: " + evogen_exe_path + " does not exist")
        need_to_return = True
    if not os.path.exists(job_file_path):
        print("EvoGen Python Trainer Error: " + job_file_path + " does not exist")
        need_to_return = True
    if need_to_return:
        time.sleep(5) # let error message stay for a moment before cmd window is closed
        return

    if period == -1: # no period given by user
        fileobj = open(job_file_path)
        jsobj = json.load(fileobj)
        if 'session_time' in jsobj:
            period = jsobj['session_time']
        fileobj.close()

    print("EvoGen Python Trainer")
    print("Training with peroid of " + str(period) + " minutes\n\n")

    num_class = 0
    while True:
        print("================= Class " + str(num_class) + " =================")
        print("Class time: " + str(period) + " mins\n")
        try:
            ret = subprocess.run([evogen_exe_path, 'job', job_file_path],
                                 timeout = period * 60, # timeout is in seconds
                                 stderr = subprocess.STDOUT)

            # if subprocess finished, all jobs have been done
            if ret.returncode == 0:
                print("\nEvogen Python Trainer: All jobs done. Return")
                return
        except subprocess.TimeoutExpired:
            print("\nClass " + str(num_class) + " time's up")
        except:
            print("\nUnexcepted error")
        print("\n\n--------------------------------------------")
        print("Class " + str(num_class) + " finished\n\n")
        num_class = num_class + 1

if __name__ == "__main__":
    evogen_exe_path = sys.argv[1]
    job_file_path = sys.argv[2]
    period = -1
    if len(sys.argv) > 3:
        period = int(sys.argv[3])

    launch_trainer(evogen_exe_path, job_file_path, period)
