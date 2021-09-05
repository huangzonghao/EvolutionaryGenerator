# EvoGen - Robot Designer Manual
## Introduction
* This user study is going to take around 30 mins per person.
* Each user is going to design 2 robots per environment.
    * The 2 robots for the same environment are expected to be as much different as possible
    * The robots for different environments could be similar.

## Design Workflow
### Update Robot Name
* Update the robot name as `YourName_MapName_TaskDescription`.
    * E.g. If John is going to design a robot to walk forward on the ground environment,
        the name would be `john_ground_walkforward`.

### Design Robot
* **Body**
    * Use the `Body ID` drop-down list to select different body meshes.
    * Use the slider or text box to change the x, y and z scale of the body mesh.
        * The range of scales are [0.5, 1.5];
* **Legs**
    * Use `Num_Legs` drop-down list to select different number of legs for the robot.
        * The robot can have 2, 3, 4, 5, or 6 legs
        * The legs would be attached to the body according to predefined layouts.
        * For the asymmetrical layouts of 3- or 5-leg robots, use the `Flip Legs`
            button to flip to mirrored layout. And this button would be ignored for symetrical layouts.
    * Use `Leg ID` drop-down list to select a **target leg** to edit.
        * This could also be done by clicking any link of that leg.
    * Use `# Links` drop-down list to change the number of links for the **target leg**.
        * Each leg could have 2 or 3 links.
    * Use `Link ID` drop-down list to select a **target link** of the **target leg**  to edit.
        * This could also be done by clicking the link directly. And the selected
            link would be highlighted in red.
    * Use `Part ID` drop-down list to select different meshes for the highlighted link.
    * Use the slider or text box to change the length scale of the mesh for the highlighted link.
        * The range of length scale is [0.5, 1.5];
    * Use `Test` button to get a command from the pop-up message box that can be
        passed to the test exe to run a test simulation.
    * Use `Save` button to save the design to file.

### Test Simulation
* Generate the test command by pressing the `Test` button.
* Copy the command and run the text executable with the it.
