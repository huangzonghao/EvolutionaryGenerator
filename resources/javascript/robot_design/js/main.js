"use strict";

////////////////////////////////////////////////////////////////////////
//                             Constants                              //
////////////////////////////////////////////////////////////////////////

const allowed_num_legs = [4, 6];
const max_num_links_per_leg = 3;
const leg_pos_range = [0, 1];
const link_length_range = [0.5, 1.5];
const slider_step = 0.01;
const init_leg_position = [0.01, 0.99, 0.49, 0.51, 0.25, 0.75];


// TODO: the following 4 values should be read from disk
const num_body_parts = 5;
const num_leg_parts = 11;

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
    constructor(init_pos = 0) {
        this.position = init_pos;
        this.num_links = 1;
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
}

class RobotRepresentation {
    constructor() {
        this.body_id = 0;
        this.leg_order = ["FL", "FR", "BL", "BR", "ML", "MR"];
        this.name = "Robogami_Temp";
        this.num_legs = 4;
        // leg order: FL FR BL BR ML MR
        this.legs = [];
        for (let i = 0; i < allowed_num_legs[allowed_num_legs.length - 1]; ++i)
            this.legs.push(new RobotLeg(init_leg_position[i]));
        this.dv = [];
    }

    leg(idx) {
        if (idx < this.num_legs)
            return this.legs[idx];
        else
            console.log("Error: leg idx exceeds total number of legs");
    }

    sort_legs() {
    // TODO: reorder legs based on their leg_pos
    }

    compile_dv() {
        sort_legs();
        this.dv.length = 0;
        this.dv.push(this.body_id);
        this.dv.push(1); // body_x
        this.dv.push(1); // body_y
        this.dv.push(1); // body_z
        this.dv.push(this.num_legs);
        for (let i = 0; i < this.num_legs; ++i) {
            let this_leg = this.leg(i);
            this.dv.push(this_leg.position);
            this.dv.push(this_leg.num_links);
            for (let j = 0; j < this_leg.num_links; ++j) {
                this.dv.push(this_leg.link(j).part_id);
                this.dv.push(this_leg.link(j).link_length);
            }
        }
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
            loader.load('./models/bodies/' + i + '.obj', function (obj) {self.bodies[i] = obj;});
        for (let i = 0; i < num_leg_parts; ++i)
            loader.load('./models/legs/' + i + '.obj', function (obj) {self.legs[i] = obj});
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

let body_id_e      = document.getElementById('BodyIdSelect');
let num_legs_e     = document.getElementById('NumLegsSelect');
let leg_id_e       = document.getElementById('LegIdSelect');
let leg_pos_e      = document.getElementById('LegPositionText');
let leg_pos2_e     = document.getElementById('LegPositionRange');
let num_links_e    = document.getElementById('NumLinksSelect');
let link_id_e      = document.getElementById('LinkIdSelect');
let part_id_e      = document.getElementById('PartIdSelect');
let link_length_e  = document.getElementById('LinkLengthText');
let link_length2_e = document.getElementById('LinkLengthRange');
let submit_e       = document.getElementById('submitButton');

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

function onBodyIdSelectChange(event) {
    var select = event.target;
    robot.body_id = parseInt(select.value);
    draw_robot();
}

function onNumLegsSelectChange(event) {
    var select = event.target;
    robot.num_legs = parseInt(select.value);
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
    // Num Legs
    for (let i = 0; i < allowed_num_legs.length; ++i) {
        var opt = document.createElement('option');
        opt.value = allowed_num_legs[i];
        opt.innerHTML = allowed_num_legs[i];
        num_legs_e.appendChild(opt);
    }
    num_legs_e.addEventListener('change', onNumLegsSelectChange);

    // Num Links
    for (let i = 0; i < max_num_links_per_leg; ++i) {
        var opt = document.createElement('option');
        opt.value = i + 1;
        opt.innerHTML = i + 1;
        num_links_e.appendChild(opt);
    }
    num_links_e.addEventListener('change', onNumLinksSelectChange);

    // Body ID
    resize_select(body_id_e, num_body_parts);
    body_id_e.addEventListener('change', onBodyIdSelectChange);

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
    scene.add(body_obj);
    let body_size = robo_lib.body_size[robot.body_id];

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
    let json_string = JSON.stringify(robot.dv);
    console.log(json_string);
    alert(json_string);
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

/* Lights setup */
scene.add(new THREE.AmbientLight(0xffffff));
init_dropdown_lists();
render();
