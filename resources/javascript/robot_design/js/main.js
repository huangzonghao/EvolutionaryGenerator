"use strict";

////////////////////////////////////////////////////////////////////////
//                             Constants                              //
////////////////////////////////////////////////////////////////////////

const allowed_num_legs = [2, 3, 4, 5, 6];
const min_num_links_per_leg = 2;
const max_num_links_per_leg = 3;
const leg_pos_range = [0, 1];
const body_scale_range = [0.5, 1.5];
const link_length_range = [0.5, 1.5];
const slider_step = 0.01;

var preset_leg_pos = {};
preset_leg_pos["2"] = [0.25, 0.75];
preset_leg_pos["3"] = [0.01, 0.75, 0.49];
preset_leg_pos["4"] = [0.01, 0.49, 0.51, 0.99];
preset_leg_pos["5"] = [0.01, 0.49, 0.51, 0.99, 0.25];
preset_leg_pos["6"] = [0.01, 0.25, 0.49, 0.51, 0.75, 0.99];

// TODO: the following 4 values should be read from disk
const num_body_parts = 5;
const num_leg_parts = 7;

////////////////////////////////////////////////////////////////////////
//                               Class                                //
////////////////////////////////////////////////////////////////////////

class RobotLink {
    constructor() {
        this.part_id = 0;
        this.link_length = 1.0;
    }
}

class RobotLeg {
    constructor() {
        this.position = 0;
        this.num_links = min_num_links_per_leg;
        this.links = [];
        // define an array of 3 links
        for (let i = 0; i < max_num_links_per_leg; ++i)
            this.links.push(new RobotLink());
    }

    link(idx) {
        if (idx < this.num_links)
            return this.links[idx];
        else
            console.log("Error: link idx exceeds total number of links");
    }

    update_position(leg_id, total_num_legs) {
        this.position = preset_leg_pos[total_num_legs.toString()][leg_id];
    }
}

class RobotRepresentation {
    constructor() {
        this.body_id = 0;
        this.body_scales = [1, 1, 1];
        this.name = "Robogami_Temp";
        this.num_legs = 4;
        // leg order: FL ML BL BR MR FR
        this.legs = [];
        // add enough containers for maximum number of legs and this legs array
        //     will not be resized later
        for (let i = 0; i < allowed_num_legs[allowed_num_legs.length - 1]; ++i)
            this.legs.push(new RobotLeg());
        // init as a valid robot
        for (let i = 0; i < this.num_legs; ++i)
            this.legs[i].update_position(i, this.num_legs);
        this.dv = [];
    }

    leg(idx) {
        if (idx < this.num_legs)
            return this.legs[idx];
        else
            console.log("Error: leg idx exceeds total number of legs");
    }

    update_num_legs(new_num_legs) {
        this.num_legs = new_num_legs;
        for (let i = 0; i < this.num_legs; ++i) {
            this.legs[i].update_position(i, this.num_legs);
        }
    }

    // map a number of range [min, max] to a double in [0, 1]
    scale_down(raw, min, max) {
        return (raw - min) / (max - min);
    }

    // gen format: [body_id, body_x, body_y, body_z, num_legs, leg_1, leg_2, ...]
    //     for each leg: [leg_pos, num_links, link_1_id, link_1_scale]
    compile_dv() {
        this.dv.length = 0;
        this.dv.push(this.scale_down(this.body_id, 0, num_body_parts - 1));
        for (let i = 0; i < robot.body_scales.length; ++i) // body scales
            this.dv.push(this.scale_down(robot.body_scales[i], body_scale_range[0], body_scale_range[1]));
        this.dv.push(this.scale_down(this.num_legs, allowed_num_legs[0], allowed_num_legs[allowed_num_legs.length - 1]));
        for (let i = 0; i < this.num_legs; ++i) {
            let this_leg = this.leg(i);
            // this.dv.push(this_leg.position); // temp disable leg_pos
            this.dv.push(this.scale_down(this_leg.num_links, min_num_links_per_leg, max_num_links_per_leg));
            for (let j = 0; j < this_leg.num_links; ++j) {
                this.dv.push(this.scale_down(this_leg.link(j).part_id, 0, num_leg_parts - 1));
                this.dv.push(this.scale_down(this_leg.link(j).link_length, link_length_range[0], link_length_range[1]));
            }
        }
    }

    export_json() {
        this.compile_dv();
        let robot_json = {name: this.name, gene: this.dv};
        // this long command formats the generated json string and keeps array on the same line
        return JSON.stringify(robot_json, function(k,v) { if(v instanceof Array) return JSON.stringify(v); return v; }, 2).replace(/\\/g, '') .replace(/\"\[/g, '[') .replace(/\]\"/g,']') .replace(/\"\{/g, '{') .replace(/\}\"/g,'}');
    }
}

class RobogamiLibrary {
    constructor() {
        this.bodies = [];
        this.body_size = [];
        this.legs = [];
        this.leg_size = [];
        this.loading_done = false;

        var self = this;

        THREE.DefaultLoadingManager.onStart = function (url, itemsLoaded, itemsTotal) {
            self.loading_done = false;
        };

        THREE.DefaultLoadingManager.onLoad = function () {
            self.loading_done = true;
            self.post_load_processing();
            draw_robot();
        };

        let loader = new THREE.OBJLoader();
        for (let i = 0; i < num_body_parts; ++i)
            loader.load('./robot_parts/bodies/' + i + '.obj', function (obj) {self.bodies[i] = obj;});
        for (let i = 0; i < num_leg_parts; ++i)
            loader.load('./robot_parts/legs/' + i + '.obj', function (obj) {self.legs[i] = obj});
    }

    post_load_processing() {
        const mat_tmp = new THREE.MeshBasicMaterial( { color: 0x444444 } );
        function update_helper(child) { if (child.isMesh) child.material = mat_tmp; }
        // need to generate the bounding box of each mesh
        for (let i = 0; i < num_body_parts; ++i) {
            this.bodies[i].traverse(update_helper);
            let bbox = new THREE.Box3().setFromObject(this.bodies[i]);
            this.body_size[i] = new THREE.Vector3();
            bbox.getSize(this.body_size[i]);
        }

        for (let i = 0; i < num_leg_parts; ++i) {
            let obj = this.legs[i];
            obj.traverse(update_helper);
            let bbox = new THREE.Box3().setFromObject(obj);
            this.leg_size[i] = new THREE.Vector3();
            bbox.getSize(this.leg_size[i]);
        }
    }
}

////////////////////////////////////////////////////////////////////////
//                            DOM Handles                             //
////////////////////////////////////////////////////////////////////////

let robot_name_e   = document.getElementById('RobotNameText');
let body_id_e      = document.getElementById('BodyIdSelect');
let body_x_e       = document.getElementById('BodyScaleXText');
let body_x2_e      = document.getElementById('BodyScaleXRange');
let body_y_e       = document.getElementById('BodyScaleYText');
let body_y2_e      = document.getElementById('BodyScaleYRange');
let body_z_e       = document.getElementById('BodyScaleZText');
let body_z2_e      = document.getElementById('BodyScaleZRange');
let num_legs_e     = document.getElementById('NumLegsSelect');
let leg_id_e       = document.getElementById('LegIdSelect');
let leg_pos_e      = document.getElementById('LegPositionText');
let leg_pos2_e     = document.getElementById('LegPositionRange');
let num_links_e    = document.getElementById('NumLinksSelect');
let link_id_e      = document.getElementById('LinkIdSelect');
let part_id_e      = document.getElementById('PartIdSelect');
let link_length_e  = document.getElementById('LinkLengthText');
let link_length2_e = document.getElementById('LinkLengthRange');
let submit_e       = document.getElementById('SubmitButton');
let save_e         = document.getElementById('SaveButton');

////////////////////////////////////////////////////////////////////////
//                             Callbacks                              //
////////////////////////////////////////////////////////////////////////

function onWindowResize(event) {
    const containerWidth = container.clientWidth;
    const containerHeight = container.clientHeight;
    renderer.setSize(containerWidth, containerHeight);
    camera.aspect = containerWidth / containerHeight;
    camera.updateProjectionMatrix();
}

function onRobotNameTextChange(event) {
    var select = event.target;
    robot.name = select.value;
}

function onBodyIdSelectChange(event) {
    var select = event.target;
    robot.body_id = parseInt(select.value);
    draw_robot();
}

function onBodyScaleXTextChange(event) {
    var select = event.target;
    robot.body_scales[0] = parseFloat(select.value);
    body_x2_e.value = select.value;
    draw_robot();
}

function onBodyScaleXRangeChange(event) {
    var select = event.target;
    robot.body_scales[0] = parseFloat(select.value);
    body_x_e.value = select.value;
    draw_robot();
}

function onBodyScaleYTextChange(event) {
    var select = event.target;
    robot.body_scales[1] = parseFloat(select.value);
    body_y2_e.value = select.value;
    draw_robot();
}

function onBodyScaleYRangeChange(event) {
    var select = event.target;
    robot.body_scales[1] = parseFloat(select.value);
    body_y_e.value = select.value;
    draw_robot();
}

function onBodyScaleZTextChange(event) {
    var select = event.target;
    robot.body_scales[2] = parseFloat(select.value);
    body_z2_e.value = select.value;
    draw_robot();
}

function onBodyScaleZRangeChange(event) {
    var select = event.target;
    robot.body_scales[2] = parseFloat(select.value);
    body_z_e.value = select.value;
    draw_robot();
}

function onNumLegsSelectChange(event) {
    var select = event.target;
    robot.update_num_legs(parseInt(select.value))
    update_dropdown_lists();
    draw_robot();
}

function onLegIdSelectChange(event) {
    update_dropdown_lists();
}

function onNumLinksSelectChange(event) {
    var select = event.target;
    robot.leg(leg_id_e.selectedIndex).num_links = parseInt(select.value);
    update_dropdown_lists();
    draw_robot();
}

function onLinkIdSelectChange(event) {
    var select = event.target;
    update_dropdown_lists();
}

function onPartIdSelectChange(event) {
    var select = event.target;
    robot.leg(leg_id_e.selectedIndex).link(parseInt(link_id_e.value)).part_id = select.selectedIndex;
    draw_robot();
}

function onLinkLengthTextChange(event) {
    var select = event.target;
    robot.leg(leg_id_e.selectedIndex).link(parseInt(link_id_e.value)).link_length = parseFloat(select.value);
    link_length2_e.value = select.value;
    draw_robot();
}

function onLinkLengthRangeChange(event) {
    var select = event.target;
    robot.leg(leg_id_e.selectedIndex).link(parseInt(link_id_e.value)).link_length = parseFloat(select.value);
    link_length_e.value = select.value;
    draw_robot();
}

function onLegPositionTextChange(event) {
    var select = event.target;
    robot.leg(leg_id_e.selectedIndex).position = parseFloat(select.value);
    leg_pos2_e.value = select.value;
    draw_robot();
}

function onLegPositionRangeChange(event) {
    var select = event.target;
    robot.leg(leg_id_e.selectedIndex).position = parseFloat(select.value);
    leg_pos_e.value = select.value;
    draw_robot();
}

function onSubmitButtonClick(event) {
    export_robot();
}

function onSaveButtonClick(event) {
    demo_write();
}

////////////////////////////////////////////////////////////////////////
//                            Subfunctions                            //
////////////////////////////////////////////////////////////////////////

function resize_select(select, new_size) {
    if (select.length == new_size) {
        return
    } else if (select.length > new_size) {
        if (select.selectedIndex > new_size - 1)
            select.selectedIndex = new_size - 1;
        for (let i = select.length - 1; i > new_size - 1; --i)
            select.remove(i);
    } else {
        for (let i = select.length; i < new_size; ++i) {
            var opt = document.createElement('option');
            opt.value = i;
            opt.innerHTML = i;
            select.appendChild(opt);
        }
    }
}

function init_dropdown_lists() {
    // Robot Name
    robot_name_e.value = robot.name;
    robot_name_e.addEventListener('change', onRobotNameTextChange);

    // Num Legs
    for (let i = 0; i < allowed_num_legs.length; ++i) {
        var opt = document.createElement('option');
        opt.value = allowed_num_legs[i];
        opt.innerHTML = allowed_num_legs[i];
        num_legs_e.appendChild(opt);
    }
    num_legs_e.value = robot.num_legs.toString();
    num_legs_e.addEventListener('change', onNumLegsSelectChange);

    // Num Links
    for (let i = min_num_links_per_leg; i < max_num_links_per_leg + 1; ++i) {
        var opt = document.createElement('option');
        opt.value = i;
        opt.innerHTML = i;
        num_links_e.appendChild(opt);
    }
    num_links_e.addEventListener('change', onNumLinksSelectChange);

    // Body ID
    resize_select(body_id_e, num_body_parts);
    body_id_e.addEventListener('change', onBodyIdSelectChange);

    // Body Scale
    body_x_e.addEventListener('change', onBodyScaleXTextChange);
    body_x2_e.addEventListener('change', onBodyScaleXRangeChange);
    body_x2_e.min = body_scale_range[0];
    body_x2_e.max = body_scale_range[1];
    body_x2_e.step = slider_step;
    body_x_e.value = robot.body_scales[0];
    body_x2_e.value = robot.body_scales[0];

    body_y_e.addEventListener('change', onBodyScaleYTextChange);
    body_y2_e.addEventListener('change', onBodyScaleYRangeChange);
    body_y2_e.min = body_scale_range[0];
    body_y2_e.max = body_scale_range[1];
    body_y2_e.step = slider_step;
    body_y_e.value = robot.body_scales[1];
    body_y2_e.value = robot.body_scales[1];

    body_z_e.addEventListener('change', onBodyScaleZTextChange);
    body_z2_e.addEventListener('change', onBodyScaleZRangeChange);
    body_z2_e.min = body_scale_range[0];
    body_z2_e.max = body_scale_range[1];
    body_z2_e.step = slider_step;
    body_z_e.value = robot.body_scales[2];
    body_z2_e.value = robot.body_scales[2];

    // Leg ID
    resize_select(leg_id_e, robot.num_legs);
    leg_id_e.addEventListener('change', onLegIdSelectChange);

    // Link ID
    resize_select(link_id_e, parseInt(num_links_e.value));
    link_id_e.addEventListener('change', onLinkIdSelectChange);

    // Part ID
    resize_select(part_id_e, num_leg_parts);
    part_id_e.addEventListener('change', onPartIdSelectChange);

    // Link Scale
    link_length_e.addEventListener('change', onLinkLengthTextChange);
    link_length2_e.addEventListener('change', onLinkLengthRangeChange);
    link_length2_e.min = link_length_range[0];
    link_length2_e.max = link_length_range[1];
    link_length2_e.step = slider_step;

    // Leg Position
    leg_pos_e.addEventListener('change', onLegPositionTextChange);
    leg_pos2_e.addEventListener('change', onLegPositionRangeChange);
    leg_pos2_e.min = leg_pos_range[0];
    leg_pos2_e.max = leg_pos_range[1];
    leg_pos2_e.step = slider_step;

    // Submit Button
    submit_e.addEventListener('click', onSubmitButtonClick)

    // Save Button
    save_e.addEventListener('click', onSaveButtonClick)

    update_dropdown_lists();
}

function update_dropdown_lists() {
    // Leg ID
    resize_select(leg_id_e, robot.num_legs);
    let robot_leg = robot.leg(leg_id_e.selectedIndex);

    // Num Links
    num_links_e.value = robot_leg.num_links;

    // Link ID
    resize_select(link_id_e, robot_leg.num_links);

    // the following fields need to be updated no matter what
    // Part ID
    let leg_link = robot_leg.links[parseInt(link_id_e.value)];
    part_id_e.selectedIndex = leg_link.part_id;

    // Link Scale
    link_length_e.value = leg_link.link_length;
    link_length2_e.value = leg_link.link_length;

    // Leg Position
    leg_pos_e.value = robot_leg.position;
    leg_pos2_e.value = robot_leg.position;
}

// TODO: highlight selected link
function draw_robot() {
    if (!robo_lib.loading_done)
        return;
    scene.clear();
    // Add body
    let body_obj = robo_lib.bodies[robot.body_id].clone();
    body_obj.scale.x *= robot.body_scales[0];
    body_obj.scale.y *= robot.body_scales[1];
    body_obj.scale.z *= robot.body_scales[2];
    scene.add(body_obj);
    let body_size = robo_lib.body_size[robot.body_id].clone();
    body_size.x *= robot.body_scales[0];
    body_size.y *= robot.body_scales[1];
    body_size.z *= robot.body_scales[2];

    // Add legs
    let leg_pos_x = 0;
    let leg_pos_y = 0;
    let leg_pos_gene = 0;
    let leg_total_length = 0;
    let link_size_z = 0;
    for (let leg_id = 0; leg_id < robot.num_legs; ++leg_id) {
        leg_total_length = 0;
        leg_pos_gene = robot.leg(leg_id).position;
        if (leg_pos_gene < 0.5) {
            leg_pos_x = (0.25 - leg_pos_gene) * 2 * body_size.x;
            leg_pos_y = body_size.y / 2 + robo_lib.leg_size[robot.leg(leg_id).link(0).part_id].y;
        } else {
            leg_pos_x = (leg_pos_gene - 0.75) * 2 * body_size.x;
            leg_pos_y = -(body_size.y / 2 + robo_lib.leg_size[robot.leg(leg_id).link(0).part_id].y);
        }
        for (let i = 0; i < robot.leg(leg_id).num_links; ++i) {
            let link_obj = robo_lib.legs[robot.leg(leg_id).link(i).part_id].clone();
            link_size_z = robo_lib.leg_size[robot.leg(leg_id).link(i).part_id].z * robot.leg(leg_id).link(i).link_length;
            link_obj.scale.z *= robot.leg(leg_id).link(i).link_length;
            link_obj.position.x = leg_pos_x;
            link_obj.position.y = leg_pos_y;
            link_obj.position.z = -leg_total_length - link_size_z / 2;
            scene.add(link_obj);

            leg_total_length += link_size_z;
        }
    }
}

function render() {
    window.requestAnimationFrame(render);
    renderer.render(scene, camera);
    controls.update();
}

function export_robot() {
    robot.compile_dv();
    console.log(robot.dv);
    alert(robot.dv);
}

function twodigit_str(n) {
    return n > 9 ? "" + n : "0" + n;
}

function demo_write() {
    let date = new Date();
    let timestamp = date.getFullYear().toString() +
                    twodigit_str((date.getMonth()+1)) +
                    twodigit_str(date.getDate()) + "_" +
                    twodigit_str(date.getHours()) +
                    twodigit_str(date.getMinutes()) +
                    twodigit_str(date.getSeconds());

    let anchor = document.createElement('a');
    anchor.href = "data:application/octet-stream,"+encodeURIComponent(robot.export_json());
    anchor.download = robot.name + "_" + timestamp + '.txt';
    anchor.click();
}

////////////////////////////////////////////////////////////////////////
//                           Main Function                            //
////////////////////////////////////////////////////////////////////////
var robot = new RobotRepresentation();
var robo_lib = new RobogamiLibrary();

const container = document.getElementById("RobotVisualPanel");
const scene = new THREE.Scene();
scene.rotateOnAxis(new THREE.Vector3(1, 0, 0), -Math.PI / 2);
const renderer = new THREE.WebGLRenderer({ alpha: true });
renderer.setSize(container.clientWidth, container.clientHeight);
container.appendChild(renderer.domElement);
window.addEventListener('resize', onWindowResize);

const camera = new THREE.PerspectiveCamera(75, container.clientWidth/container.clientHeight, 0.1, 1000);
camera.position.x = 0;
camera.position.y = 40;
camera.position.z = 300;

// Trackball Control setup
var controls = new THREE.TrackballControls(camera, renderer.domElement);
controls.rotateSpeed = 1;
controls.zoomSpeed = 0.1;
controls.panSpeed = 0.2;

// Lights setup
scene.add(new THREE.AmbientLight(0xffffff));
init_dropdown_lists();
render();
