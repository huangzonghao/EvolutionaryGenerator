# Evolutionary Generator

This project provides the full tool set to study the effects of human inputs over
the performance of evolutionary algorithm. The tools include:
* A JavaScript Robot Designer (`resources/javascript/robot_design/`) for user
    to participate the user study in which they design and test robots. This designer
    can also read and inspect any previous designs.
* A CPP CMD tool (`Process_User_Inputs`) that gathers all of the raw user design
    files, do some pre-processing (evaluating fitness, updating format, putting all
    files together, etc) and output processed user designs.
* A Matlab User Input Analyzer (`resources/matlab/user_input_analysis/`) that computes
    statistics and generate plots of user designs, and generate bags of user designs
    that would be used in training.
* A Matlab Task Scheduler (`resources/matlab/task_scehduler/`) that schedules jobs
    for training and generates the job scheduling files.
* A CPP CMD tool (`Evolutionary_Generator`) that does the actual training.
* A Python Task Launcher (`cmake/task_launcher.py.in`) that manages the execution of
    `Evolutionary_Generator` automatically according to the specified job scheduling
    file generated by the Task Scheduler.
* A Matlab Result Analyzer (`resources/matlab/result_analysis`) that loads in and processes
    the training results, build statistical data, generate plots and conduct statistical
    tests. This tool also let user interactively select and inspect any robot on
    any generation's archive map.

There are some other helper tools.
* A CPP CMD tool (`Export_Robogami_Library`) that exports the protobuf based Robogami
    library to stl or obj meshes.
* A CPP CMD tool (`Genotype_Visualizer`) that used by Matlab Result Analyzer to
    run simulation.
* A CPP CMD tool (`User_Design_Simulator`) that used by JavaScript Robot Designer
    to run simulation for users.
* A CMake compile target (`Generate_Javascript_UI`) that configures and exports
    the JavaScript Robot Designer to the specified location.
* A CPP CMD tool (`Convert_Mesh_Models`) converts the STL mesh files (body parts,
    leg parts, environments) to OBJ files that required by the simulator, and place
    them to the correct locations.
* A CMake compile target (`Show_Mesh_Info`) that shows the information of the mesh
    objects (body parts, leg parts, environmens) that currently in the repo.


Detailed usage of the tools can be found below.

## Setup on Windows
Currently only the setup has only been tested on Windows 10 with Visual Studio 2019.
Setup instructions on Mac and Linux might be added in the future.

### Dependencies
#### Boost
This project requires some compiled boost components. Therefore the boost needs
to be compiled first. To to that, navigate to the boost root
directory, run the bootstrap script (`bootstrap.bat` or `bootstrap.sh`) and follow
the prompted instruction.

#### Robogami
* Follow the [Robogami Installation Instruction](./Robogami/Backend/readme.md)
* Can be omitted if the `ENABLE_ROBOGAMI` flag is set to false in CMake.

#### Chrono
* Download and install [Chrono 6.0.0](https://github.com/projectchrono/chrono/releases/tag/6.0.0)

* Note this project relies on API provided in Chrono version 6.0.0., which has
    been subsequently modified in the current dev branch. Checking out and
    compiling the lastest code from its [github repo](https://github.com/projectchrono/chrono)
    won't work.

<!-- * Clone the Project Chrono [repo](https://github.com/projectchrono/chrono.git) -->
<!-- * Follow [these instructions](http://api.projectchrono.org/tutorial_install_chrono.html) to compile the project -->
<!-- * You could either choose to install Chrono to the installation directory, or simply leave Chrono in the build directory. The choice here would affect `Chrono_DIR` which would be used later. -->

### Compile Project
* This project is managed by CMake and requires a minimum CMake version of 3.16
* Make a build directory.
* Launch CMake and set the source and build directories to the correct location.
* Following the prompts of the CMake output to link external dependencies to the project.

### Structure of Generated VS Project
The generated VS project is organized in directories, and only the targets in the
`Tools` folder are meant to directly executed by users. And the rest will be used
by various scripts or UI in this repo.

If any "dll not found" error occurred when executing a binary, build the corresponding `COPY_DLLS` target. This will copy the required dlls to the right location.

## File Structure
A fresh cloned repo contains the following directories.
* `cmake` - CMake helper scripts and uncompleted code files that would be completed
    by CMake at the configuration time, and moved to new locations.
* `generator` - Cpp code of evolutionary algorithm and other helper tools.
* `simulator` - Cpp code of simulator and controller.
* `resources`
    * `autohotkey` - an AutoHotKey script that automatically launches and restarts
        the training exe in visual studio. Deprecated.
    * `javascript` - Tools written in JS.
    * `matlab` - Tools written in Matlab.
    * `maps` - Environments used in simulation. File format in `.bmp` and `.obj`.
    * `robot_parts` - Robot mesh parts used in simulation. File format in `.obj`.
* `Robogami` - Robogami repos
* `thirdparty` - Third-party libraries that could be automatically configured
    by the CMake script.

Upon successful compilation for the first time, a user specified `build` directory
would appear, which contains the following.
* `build`
    * `include` - configured `.h` headers.
    * `Matlab` - Matlab working directory. All Matlab tools should be called within
        this directory.
    * `Workspace`
        * `JavascriptUI` - export directory of JS Robot Designer. Only the designer
            found here is useable. The original copy in repo lacks the parts lib.
        * `Jobs` - working directory of task scheduler and task launcher.
        * `Meshes` - working directory of meshes.
        * `Results` - output directory of training results and records.
        * `Robots` - output directory of sample robots. Deprecated.
        * `Params` - working directory of evolution related and simulation related
            parameters.
        * `UserInput` - working directory of user inputs.

## Robot Designer
Robot Designer is a browser based application, and runs in Chrome, Firefox, Safari.
### Setup
The source files locate in `resources/javascript/robot_design`. The website won't
run directly off the source location, as it lack some other components. We need to
copy `resources/maps` and `resources/robot_parts` to the website's root. This can
be done automatically by executing the make target `Generate_Javascript_UI`, and
a completed website would be generated in `build/Workspace/JavascriptUI`.

Generally the website needs to be served by a web server like Apache2 or Nginx, as
it contains JavaScript components. We can run this site locally in firefox by 
* Go to `about:config`
* Toggle `privacy.file_unique_origin` from `true` to `false`

The test button in the UI would launch a simulation on the local machine. To get
this working
* Make sure CMake has successfully configured the project.
* Compile the `User_Design_Simulator` target.
    * If in Visual Studio on Windows, also execute the `User_Design_Simulator_COPY_DLLS`
        target to make sure all the required dlls are copied to the right place`
* Setup the protocol for browser to launch local executable
    * On Windows, double click `build/Workspace/add_js_ui_simulation_protocol.reg`.
        This would inject the protocol to the registry. The injection can be reversed
        by double clicking `build/Workspace/remove_js_ui_simulation_protocol.reg`

#### Other Tweaks
* To download `.txt` file automatically in firefox:
    * Go to `Help/More troubleshooting information`
    * Open `Profile Folder`
    * Add the entry for `.txt` to `handlers.json`
    * Need to restart firefox

### Usage
* This tool does the user study.
* This tool loads and simulates the json representation of the robot.
    * User can freely alter the loaded robot and re-evaluate the fitness.
    * A json representation can be directly saved by this tool, or exported from
        training results by the Result Analyzer.

#### Output Format
When a user finished a user study, there would be a bunch of robot files with naming
convention `evogen_<user_id>_<env>_<robot_id>_<version_id>.txt` and a meta file
`UserStudy_<user_id>_<time_stamp>.txt` appear in the default `Downloads` folder
of browser. Create a new folder named by the user ID and drop all the files into
that folder (**raw user data folder**), and that folder would be the raw user data collected.

## User Input Processor
User Input Processor process the raw user data and converts them to a compact
and intermediate file that can be used by other tools.

### Setup
Compile the `Process_User_Inputs` target.

### Usage
* Put the **raw user data folder** to `build/Workspace/UserInput/Raw`.
    * Multiple raw user data folders can be dropped there together alongside each other.
* Run the exe and the tool would automatically
    * Evaluate the fitness of each user designed robot
    * Compute the features
    * Write the user designs to a condensed file (**condensed user data file**)
        named `build/Workspace/UserInput/<user_id>.json`.

## User Input Analyzer
User Input Analyzer is a Matlab tool that loads in the **condensed user data file**
that are placed in `build/Workspace/UserInput` and let user do various analyzing
and manipulation.

### Usage
* Launch Matlab and change working directory to `build/Matlab`.
* Run `user_input_analysis`.
    * If `user_input_analysis.m` is not present in `build/Matlab`, check if
        the CMake configuration has finished successfully.
    * If Matlab reports path error, run the CMake configuration again, so that
        the auto configured paths could be updated.
* In the GUI, click the `RefreshList` button to refresh the list of available 
    user designs.

We also generate the **robot bag file**s with this tool. A **robot bag file**
is a file containing information of multiple robots, and could be read in by the
evolutionary trainer as population.
* The `Bag Name` and `Comments` text fields can be used to add annotations to the
    bag file.
* The bag files would be saved to `build/Workspace/UserInput/Bags/Bag_<bag_name>_<timestamp>.json`.

## Task Scheduler
Task scheduler is a Matlab tool that helps users to customize and schedule multiple
jobs for the trainer to run in advance and generates a **job file**.

### Usage
* Launch Matlab and change working directory to `build/Matlab`.
* Run `task_scheduler`.
    * If `task_scheduler.m` is not present in `build/Matlab`, check if
        the CMake configuration has finished successfully.
    * If Matlab reports path error, run the CMake configuration again, so that
        the auto configured paths could be updated.
* Upon going into GUI, a list of available **robot bag file**s in
    `build/Workspace/UserInput/Bags` should be shown in the list box.
    * If not, or new bag files has been added since last refresh, click the refresh button.
* For each job, we can specify
    * Which **robot bag file** to use as initial population.
    * Environment
    * Number of generations to train, population size, simulation time.
    * Whether to ignore the random robots to use in the bag file.
        * If set to true, the trainer would ignore the random robots in the bag
            file and generate its own random robots.
    * Nickname - a human readable name that differentiates the result of this task
        from others.
    * Job Comments - comments that would be carried over to the **result folder**
        of this task.
* Repeats of a task is considered to be duplications of the task and have different
    nicknames from the original one.
* Multiple jobs created together is considered to be a **job group** and share
    the same group name and group comments, which would also be carried over to
    their individual **result folder**.
* The results of different jobs of the same group would be placed in the same
    directory named after the group by the trainer.
* The generated job files would be saved to `build/Workspace/Jobs/Job_<output_file_name>_<time_stamp>.json`.

## Task Launcher
Task Launcher is a Python tool that automatically executes the jobs described in
the given **job file**.

### Usage
* Find the python script at `build/Workspace/task_launcher.py`
    * If the file is not present, check if the CMake configuration has
        finished successfully.
    * If the script reports  path error, run the CMake configuration again, so that
        the auto configured paths could be updated.
* Launch the python script with the desired **job file** as the only input.

## Trainer
Trainer is the executable that called by task scheduler that does the actual training
and recording. We only document the output format here.

### Output Format
The result of each job is placed in a folder named
`build/Workspace/Results/<group_name>/<group_name>_<result_nickname>_<time_stamp>`
And the `<time_stamp>` is defined by the time when the job is firstly launched.

Inside the result folder, we have the following.
* `dumps` - contains the memory dump of each generation, which can be used to resume
    the training from any generation.
* `gridmaps` - archive map of each generation.
* `gridstats` - number of updates of each archive map.
* `robot_pats` - mesh of robot parts used in simulation. Copied from
    `resources/robot_parts` when the job is executed for the first time.
* Environment file - mesh of environment used in simulation. Copied from
    `resources/maps` when the job is executed for the first time.
    * No environment file will present for Ground environment, since Ground is
        an environment embedded in the simulator.
* `robots` - all the robot generated of each generation during training.
* `evo_params.xml` and `sim_params.xml` - parameters used in evolution and simulation..
* `git_commit_hash` - hash of git commit of the repo when the job is executed for the first time.
* `name.txt` - nickname of the job.
* Bag file - Bag file used in this job.
* `job_report.txt` - a summary report of the execution of the job, including
    when the job started, when the job finished, number of runs of the job, etc.
* `progress.txt` and `status.txt` - tells user about the current progress of the
    training. Both are updated after each generation is finished.
    * Note when inspecting these two files, use a non-blocking editor/viewer. If the
        trainer find it unable to update any of the files, the training would stop.

### Data Recording Format
* For each genome/phen, the system would record its fitness, descriptor and grid ID.
    The descriptor is a vector with all of its elements in [0, 1]. And the grid ID is
    the index of cell that the genome is assigned to, which makes it non-negative.
    And the follow information are encoded into descriptor and grid ID with negative
    values
    * 1) Descriptor be -2: The genome is invalid and cannot be developed
        into a phen.
    * 1) Descriptor be -3: The genome is valid, but the developed robot
        is self-colliding.
    * 1) Grid ID be -1: The genome is valid, developed
        robot has been evaluated, but was not added into the archive due to fitness
        competition.

## Result Analyzer
The Matlab tool that helps user deal with the training results.

### Usage
* Launch Matlab and change working directory to `build/Matlab`.
* Run `result_analysis`.
    * If `result_analysis.m` is not present in `build/Matlab`, check if
        the CMake configuration has finished successfully.
    * If Matlab reports path error, run the CMake configuration again, so that
        the auto configured paths could be updated.
* Load a **result group** by clicking the `Load Group` button and select the group folder.
* All results within that group folder will be listed in the list box.
    * If the selected group folder do contain results, but nothing showed up in the list box,
        click the `refresh` button. This happens when a group is opened for the first time.
    * If the result has a nickname specified, nickname will be used in the listing,
        otherwise folder name of the result folder is used.
    * A leading `*` indicates the result is fresh off the trainer, with no post
        processing being done yet. Select the unbuilt ones and click `Build` to
        start processing those results and generate necessary statistical data.
* Use `Export Group` button to export a **statistics only** copy of the currently
    loaded result group. Comparing to the original copy, the **sattistics only**
    contains only the information necessary to recreate all the plots and redo
    all the statistical tests, while stripping down the data for training resumption
    and robots simualtion. This much smaller and condensed copy can be easily
    transferred to another location. 

## Todo
* Unified config file
