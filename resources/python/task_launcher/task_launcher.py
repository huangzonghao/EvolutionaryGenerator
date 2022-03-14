# This file launches and stops training exe at given length of period
# Input: exe_path (full path)
#        job_file_path (full path)
#        class_time (optional)

import os.path # os.path.exists
import time # sleep
import sys
import json
import subprocess

need_to_return = False
evogen_exe_path = sys.argv[1];
job_file = sys.argv[2]
if not os.path.exists(evogen_exe_path):
    print("Error: " + evogen_exe_path + " does not exist")
    need_to_return = True
if not os.path.exists(job_file):
    print("Error: " + job_file + " does not exist")
    need_to_return = True
if need_to_return:
    time.sleep(5) # let error message stay for a moment before cmd window is closed
    exit()

period = 30 # default period is 30 mins
# prioritize command line input over job file
if len(sys.argv) > 3:
    period = int(sys.argv[3])
else:
    fileobj = open(job_file)
    jsobj = json.load(fileobj)
    if 'session_time' in jsobj:
        period = jsobj['session_time']

print("EvoGen Python Trainer")
print("Training with peroid of " + str(period) + " minutes\n\n")

num_class = 0
while True:
    print("================= Class " + str(num_class) + " =================")
    print("Class time: " + str(period) + " mins\n")
    try:
        ret = subprocess.run([evogen_exe_path, 'job', job_file],
                             timeout = period * 60, # timeout is in seconds
                             stderr = subprocess.STDOUT)

        # if subprocess finished, all jobs has been done
        if ret.returncode == 0:
            print("All jobs has finished, return from task_launcher")
            exit()
    except subprocess.TimeoutExpired:
        print("\nClass " + str(num_class) + " time's up")
    except:
        print("\nUnexcepted error")
    print("\n\n--------------------------------------------")
    print("Class " + str(num_class) + " finished\n\n")
    num_class = num_class + 1
