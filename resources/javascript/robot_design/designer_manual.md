# EvoGen - Robot Designer Manual
## Introduction
* This user study is going to take around 30 mins per person.
* Each user is going to design 2 robots per environment for 3 environments.
    * The 2 robots for the same environment are expected to be as much different as possible
    * The robots for different environments could be similar.
    * Each robot can be iterated up to 2 times.

## Design Workflow
### Fill in Meta Info
* **Participant ID**
    * A random six-digit participant ID would be automatically generated at start.
    * User can generate a new random ID by pressing the `Generate New`. Or input
        an ID of their choice.
* Use the `Environment` drop-down list to select the environment that the robot
    is designed for.
* The rest of the Meta Info are optional.

### Design Robot
* **Version**
    * Use the `Version` drop-down list to indicate the number of times that the
        robot has been iterated.
* **Body**
    * Use the `Body ID` drop-down list to select different body meshes.
    * Use the slider or text box to change the x, y and z scale of the body mesh.
        * The range of scales are [0.5, 1.5];
* **Legs**
    * Use the `Num_Legs` drop-down list to select a different number of legs for the robot.
        * The robot can have 2, 3, 4, 5, or 6 legs
        * The legs would be attached to the body according to predefined layouts.
        * For the asymmetrical layouts of 3- or 5-leg robots, use the `Flip Legs`
            button to flip to mirrored layout. And this button would be ignored for symmetrical layouts.
    * Use the `Leg ID` drop-down list to select a **target leg** to edit.
        * This could also be done by clicking any link of that leg.
    * Use the `# Links` drop-down list to change the number of links for the **target leg**.
        * Each leg could have 2 or 3 links.
    * Use the `Link ID` drop-down list to select a **target link** of the **target leg**  to edit.
        * This could also be done by clicking the link directly. And the selected
            link would be highlighted in red.
    * Use the `Part ID` drop-down list to select different meshes for the highlighted link.
    * Use the slider or text box to change the length scale of the mesh for the highlighted link.
        * The range of length scale is [0.5, 1.5];
    * Use the `Test` button to get a command from the pop-up message box that can be
        passed to the test exe to run a test simulation.
    * Use the `Save` button to save the design to file.

### Test Simulation
* Generate the test command by pressing the `Test` button.
* Copy the command and run the text executable with it.
