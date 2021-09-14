"use strict";

////////////////////////////////////////////////////////////////////////
//                             Constants                              //
////////////////////////////////////////////////////////////////////////

const max_ver = 2;
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
preset_leg_pos["3_alt"] = [0.51, 0.25, 0.99];
preset_leg_pos["4"] = [0.01, 0.49, 0.51, 0.99];
preset_leg_pos["5"] = [0.01, 0.49, 0.51, 0.99, 0.25];
preset_leg_pos["5_alt"] = [0.99, 0.51, 0.49, 0.01, 0.75];
preset_leg_pos["6"] = [0.01, 0.25, 0.49, 0.51, 0.75, 0.99];

// TODO: the following 4 values should be read from disk
const num_body_parts = 6;
const num_leg_parts = 7;

const unselect_mat = new THREE.MeshBasicMaterial( { color: 0x444444 } );
const select_mat = new THREE.MeshBasicMaterial( { color: 0xff0000 } );
let current_selected_obj;

////////////////////////////////////////////////////////////////////////
//                               Class                                //
////////////////////////////////////////////////////////////////////////

class RobotLink {
    constructor() {
        this.part_id = 0;
        this.link_length = 1.0;
        this.obj;
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

    update_position(leg_id, total_num_legs, alt = false) {
        if (alt && preset_leg_pos[total_num_legs.toString() + "_alt"] != null) {
            this.position = preset_leg_pos[total_num_legs.toString() + "_alt"][leg_id];
            console.log("alt leg used");
        }
        else
            this.position = preset_leg_pos[total_num_legs.toString()][leg_id];
    }
}

class RobotRepresentation {
    constructor() {
        this.env = "";
        this.ver = 0;
        this.body_obj;
        this.body_id = 0;
        this.body_scales = [1, 1, 1];
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
        this.alt = false;

        this.init_gene = new Array(100).fill(0.5); // Use a long enough gene

        this.reset();
    }

    copy_leg(target_id, source_id) {
        if (target_id == source_id)
            return false;
        let target_leg = this.legs[target_id];
        let source_leg = this.legs[source_id];
        // copy everything but position
        target_leg.num_links = source_leg.num_links;
        for (let i = 0; i < target_leg.num_links; ++i) {
            target_leg.links[i].part_id = source_leg.links[i].part_id;
            target_leg.links[i].link_length = source_leg.links[i].link_length;
        }
        return true;
    }

    reset() {
        this.parse_dv(this.init_gene);
    }

    leg(idx) {
        if (idx < this.num_legs)
            return this.legs[idx];
        else
            console.log("Error: leg idx exceeds total number of legs");
    }

    update_leg_position() {
        for (let i = 0; i < this.num_legs; ++i) {
            this.legs[i].update_position(i, this.num_legs, this.alt);
        }
    }

    update_num_legs(new_num_legs) {
        // there are already enough leg containers in this robot object
        this.num_legs = new_num_legs;
        this.update_leg_position();
    }

    update_leg_layout(new_alt) {
        this.alt = new_alt;
        this.update_leg_position();
    }

    flip_legs() { this.update_leg_layout(!this.alt); }

    // double2double maping is points to points, while int2double mapping is points to bins
    // map a double of range [min, max] to a double in [0, 1]
    scale_down_double(raw, min, max) { return (raw - min) / (max - min); }
    // map an int of range [min, max] to an double in [0, 1)
    // The returned number is placed at the center of each bin
    scale_down_int(raw, min, max) { return (raw - min + 0.5) / (max - min + 1); }

    // map a double of range [0, 1] to a double of [min, max]
    scale_up_double(raw, min, max) { return raw * (max - min) + min; }
    // map a double of range [0, 1) to an int of [min, max]
    scale_up_int(raw, min, max) {
        let ret = Math.floor(raw * (max - min + 1)) + min;
        if (ret > max) // when raw >= 1
            ret = max;
        return ret;
    }

    // gen format: [body_id, body_x, body_y, body_z, num_legs, alt, leg_1, leg_2, ...]
    //     for each leg: [(leg_pos), num_links, link_1_id, link_1_scale]
    compile_dv() {
        this.dv.length = 0;
        this.dv.push(this.scale_down_int(this.body_id, 0, num_body_parts - 1));
        for (let i = 0; i < robot.body_scales.length; ++i) // body scales
            this.dv.push(this.scale_down_double(robot.body_scales[i], body_scale_range[0], body_scale_range[1]));
        this.dv.push(this.scale_down_int(this.num_legs, allowed_num_legs[0], allowed_num_legs[allowed_num_legs.length - 1]));
        this.dv.push(robot.alt ? 1 : 0);
        for (let i = 0; i < this.num_legs; ++i) {
            let this_leg = this.leg(i);
            // this.dv.push(this_leg.position); // temp disable leg_pos
            this.dv.push(this.scale_down_int(this_leg.num_links, min_num_links_per_leg, max_num_links_per_leg));
            for (let j = 0; j < this_leg.num_links; ++j) {
                this.dv.push(this.scale_down_int(this_leg.link(j).part_id, 0, num_leg_parts - 1));
                this.dv.push(this.scale_down_double(this_leg.link(j).link_length, link_length_range[0], link_length_range[1]));
            }
        }
    }

    parse_dv(gene) {
        let counter = 0;
        this.body_id = this.scale_up_int(gene[counter++], 0, num_body_parts - 1);
        for (let i = 0; i < this.body_scales.length; ++i) // body scales
            this.body_scales[i] = this.scale_up_double(gene[counter++], body_scale_range[0], body_scale_range[1]);
        this.update_num_legs(this.scale_up_int(gene[counter++], allowed_num_legs[0], allowed_num_legs[allowed_num_legs.length - 1]));
        this.update_leg_layout(gene[counter++] > 0.5 ? true : false);
        for (let i = 0; i < this.num_legs; ++i) {
            let this_leg = this.leg(i);
            // this_leg.position = gene[counter++]; // temp disable leg_pos
            this_leg.num_links = this.scale_up_int(gene[counter++], min_num_links_per_leg, max_num_links_per_leg);
            for (let j = 0; j < this_leg.num_links; ++j) {
                this_leg.link(j).part_id = this.scale_up_int(gene[counter++], 0, num_leg_parts - 1);
                this_leg.link(j).link_length = this.scale_up_double(gene[counter++], link_length_range[0], link_length_range[1]);
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
            loader.load('./robot_parts/bodies/' + i + '.obj', function (obj) {self.bodies[i] = obj;});
        for (let i = 0; i < num_leg_parts; ++i)
            loader.load('./robot_parts/legs/' + i + '.obj', function (obj) {self.legs[i] = obj});
    }

    post_load_processing() {
        function update_helper(child) { if (child.isMesh) child.material = unselect_mat; }
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

class EnvironmentLibrary {
    constructor() {
        this.env_list = ["ground", "Sine2.obj", "Valley5.obj"];
    }

    check_env_id(env_name) {
        for (let i = 0; i < this.env_list.length; ++i) {
            if (env_name == this.env_list[i])
                return i;
        }
        return -1;
    }
}

////////////////////////////////////////////////////////////////////////
//                            DOM Handles                             //
////////////////////////////////////////////////////////////////////////

let config_panel_e = document.getElementById('RobotConfigPanel');
let visual_panel_e = document.getElementById('RobotVisualPanel');
let user_id_e      = document.getElementById('UserIDText');

// Robot Config
let env_e          = document.getElementById('EnvSelect');
let ver_e          = document.getElementById('VerSelect');
let body_id_e      = document.getElementById('BodyIdSelect');
let body_x_e       = document.getElementById('BodyScaleXText');
let body_x2_e      = document.getElementById('BodyScaleXRange');
let body_y_e       = document.getElementById('BodyScaleYText');
let body_y2_e      = document.getElementById('BodyScaleYRange');
let body_z_e       = document.getElementById('BodyScaleZText');
let body_z2_e      = document.getElementById('BodyScaleZRange');
let num_legs_e     = document.getElementById('NumLegsSelect');
let leg_id_e       = document.getElementById('LegIdSelect');
// let leg_pos_e      = document.getElementById('LegPositionText');
// let leg_pos2_e     = document.getElementById('LegPositionRange');
let num_links_e    = document.getElementById('NumLinksSelect');
let link_id_e      = document.getElementById('LinkIdSelect');
let part_id_e      = document.getElementById('PartIdSelect');
let link_length_e  = document.getElementById('LinkLengthText');
let link_length2_e = document.getElementById('LinkLengthRange');
let copy_leg_e     = document.getElementById('CopyLegSelect');
let copy_leg_btn_e = document.getElementById('CopyLegButton');
let flip_btn_e     = document.getElementById('FlipButton');
let reset_btn_e    = document.getElementById('ResetButton');

// IO
let submit_btn_e   = document.getElementById('SubmitButton');
let save_btn_e     = document.getElementById('SaveButton');
let load_btn_e     = document.getElementById('LoadButton');

////////////////////////////////////////////////////////////////////////
//                             Callbacks                              //
////////////////////////////////////////////////////////////////////////

function onWindowResize(event) {
    renderer.setSize(visual_panel_e.clientWidth, visual_panel_e.clientHeight);
    camera.aspect = visual_panel_e.clientWidth / visual_panel_e.clientHeight;
    camera.updateProjectionMatrix();
}

function onMouseClick(event) {
    const rect = visual_panel_e.getBoundingClientRect();
    mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    mouse.y = - ((event.clientY - rect.top) / rect.height) * 2 + 1;
    // raycaster
    raycaster.setFromCamera(mouse, camera);
    // calculate objects intersecting the picking ray
    const intersects = raycaster.intersectObjects(scene.children, true);
    if (intersects.length > 0) {
        // not sure why, but the obj returned by raycaster is a different obj
        // than the one passed to scene, and has an id 1 larger than the orig obj
        const orig_obj = scene.getObjectById(intersects[0].object.id - 1);
        if (orig_obj && orig_obj.leg_id != null) { // only obj of leg links has this defined
            leg_id_e.value = orig_obj.leg_id;
            link_id_e.value = orig_obj.link_id;
            update_dropdown_lists();
        }
    }
}

function onUserIDTextChange(event) {
    var select = event.target;
    user_id = select.value;
}

function onEnvSelectChange(event) {
    var select = event.target;
    robot.env = select.options[select.selectedIndex].text;
}

function onVerSelectChange(event) {
    var select = event.target;
    robot.ver = select.value;
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
    resize_select(copy_leg_e, robot.num_legs);
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

// function onLegPositionTextChange(event) {
    // var select = event.target;
    // robot.leg(leg_id_e.selectedIndex).position = parseFloat(select.value);
    // leg_pos2_e.value = select.value;
    // draw_robot();
// }

// function onLegPositionRangeChange(event) {
    // var select = event.target;
    // robot.leg(leg_id_e.selectedIndex).position = parseFloat(select.value);
    // leg_pos_e.value = select.value;
    // draw_robot();
// }

function onCopyLegButtonClick(event) {
    if (robot.copy_leg(leg_id_e.value, copy_leg_e.value)) { // if copy happened
        update_dropdown_lists();
        draw_robot();
    }
}

function onSubmitButtonClick(event) {
    export_robot();
}

function onSaveButtonClick(event) {
    demo_write();
}

function onLoadButtonClick(event) {
    let input = document.createElement('input');
    input.type = 'file';
    input.onchange = e => {
        let file = e.target.files[0];
        let reader = new FileReader();
        reader.readAsText(file,'UTF-8');
        reader.onload = readerEvent => {
            let json_str = readerEvent.target.result;
            let json_dict = JSON.parse(json_str);

            user_id = json_dict.user_id;
            robot.env = json_dict.environment;
            robot.ver = json_dict.ver;
            robot.parse_dv(json_dict.gene);

            update_meta_display();
            update_dropdown_lists();
            draw_robot();
        }
    }
    input.click();
}

function onFlipButtonClick(event) {
    robot.flip_legs();
    draw_robot();
}

function onResetButtonClick(event) {
    robot.reset();
    update_meta_display();
    update_dropdown_lists();
    draw_robot();
}

////////////////////////////////////////////////////////////////////////
//                            Subfunctions                            //
////////////////////////////////////////////////////////////////////////

function resize_select(select, new_size) {
    if (select.length == new_size) {
        return;
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
    user_id_e.value = user_id;
    user_id_e.addEventListener('change', onUserIDTextChange);

    // Environment Select
    for (let i = 0; i < env_lib.env_list.length; ++i) {
        var opt = document.createElement('option');
        opt.value = i;
        opt.innerHTML = env_lib.env_list[i];
        env_e.appendChild(opt);
    }
    env_e.addEventListener('change', onEnvSelectChange);
    robot.env = env_e.options[env_e.selectedIndex].text;

    // Ver Select
    resize_select(ver_e, max_ver + 1);
    ver_e.value = robot.ver;
    ver_e.addEventListener('change', onVerSelectChange);

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
    body_id_e.value = robot.body_id;

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

    // Copy Leg
    resize_select(copy_leg_e, robot.num_legs);
    copy_leg_btn_e.addEventListener('click', onCopyLegButtonClick)

    // Leg Position
    // leg_pos_e.addEventListener('change', onLegPositionTextChange);
    // leg_pos2_e.addEventListener('change', onLegPositionRangeChange);
    // leg_pos2_e.min = leg_pos_range[0];
    // leg_pos2_e.max = leg_pos_range[1];
    // leg_pos2_e.step = slider_step;

    // IO Buttons
    submit_btn_e.addEventListener('click', onSubmitButtonClick)
    save_btn_e.addEventListener('click', onSaveButtonClick)
    load_btn_e.addEventListener('click', onLoadButtonClick)

    // Robot Config Buttons
    flip_btn_e.addEventListener('click', onFlipButtonClick)
    reset_btn_e.addEventListener('click', onResetButtonClick)

    update_dropdown_lists();
}

function update_meta_display() {
    user_id_e.value = user_id;
    env_e.value = env_lib.check_env_id(robot.env);
    ver_e.value = robot.ver;
    num_legs_e.value = robot.num_legs.toString(); // num_legs only need auto update here
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
    // leg_pos_e.value = robot_leg.position;
    // leg_pos2_e.value = robot_leg.position;

    // Update visualization of selected link part
    if (robo_lib.loading_done) {
        mark_body(current_selected_obj, false);
        current_selected_obj = robot.leg(parseInt(leg_id_e.value)).link(parseInt(link_id_e.value)).obj;
        mark_body(current_selected_obj, true);
    }
}

// TODO: mesh objs can be reused, do not create a new one everytime
function draw_robot() {
    if (!robo_lib.loading_done)
        return;
    scene.clear();

    // Display axis
    const axesHelper = new THREE.AxesHelper(200);
    axesHelper.material.linewidth = 5;
    scene.add(axesHelper);

    // Add body
    let body_obj = robo_lib.bodies[robot.body_id].clone();
    body_obj.scale.x *= robot.body_scales[0];
    body_obj.scale.y *= robot.body_scales[1];
    body_obj.scale.z *= robot.body_scales[2];
    robot.body_obj = body_obj;
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
            link_obj.leg_id = leg_id;
            link_obj.link_id = i;
            robot.leg(leg_id).link(i).obj = link_obj;
            scene.add(link_obj);

            leg_total_length += link_size_z;
        }
    }

    current_selected_obj = robot.leg(parseInt(leg_id_e.value)).link(parseInt(link_id_e.value)).obj;
    mark_body(current_selected_obj, true);
}

function mark_body(body_obj, selected = true) {
    if (selected)
        body_obj.traverse(function(child){if (child.isMesh) child.material = select_mat;})
    else
        body_obj.traverse(function(child){if (child.isMesh) child.material = unselect_mat;})
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

    robot.compile_dv();
    let json_dict = {
        user_id: user_id,
        environment: robot.env,
        ver: robot.ver,
        datetime: timestamp,
        gene: robot.dv
    };

    // this long command formats the generated json string and keeps array on the same line
    let json_str = JSON.stringify(json_dict, function(k,v) { if(v instanceof Array) return JSON.stringify(v); return v; }, 2)
                   .replace(/\\/g, '')
                   .replace(/\"\[/g, '[')
                   .replace(/\]\"/g,']')
                   .replace(/\"\{/g, '{')
                   .replace(/\}\"/g,'}');

    let anchor = document.createElement('a');
    anchor.href = "data:application/octet-stream,"+encodeURIComponent(json_str);
    anchor.download = "evogen_" + user_id.toString() + "_" + robot.env + "_" + robot.ver + '.txt';
    anchor.click();
}

////////////////////////////////////////////////////////////////////////
//                           Main Function                            //
////////////////////////////////////////////////////////////////////////

var user_id = "000000";
var robot = new RobotRepresentation();
var robo_lib = new RobogamiLibrary();
var env_lib = new EnvironmentLibrary();

const scene = new THREE.Scene();
scene.rotateOnAxis(new THREE.Vector3(1, 0, 0), -Math.PI / 2);
const renderer = new THREE.WebGLRenderer({ alpha: true });
renderer.setSize(visual_panel_e.clientWidth, visual_panel_e.clientHeight);
visual_panel_e.appendChild(renderer.domElement);
window.addEventListener('resize', onWindowResize);

const camera = new THREE.PerspectiveCamera(75, visual_panel_e.clientWidth / visual_panel_e.clientHeight, 0.1, 1000);
camera.position.x = 200;
camera.position.y = 100;
camera.position.z = -300;

// Trackball Control setup
var controls = new THREE.TrackballControls(camera, renderer.domElement);
controls.rotateSpeed = 1;
controls.zoomSpeed = 0.1;
controls.panSpeed = 0.2;

// Raycaster
const raycaster = new THREE.Raycaster();
const mouse = new THREE.Vector2();
visual_panel_e.addEventListener('click', onMouseClick, false);

// Lights setup
scene.add(new THREE.AmbientLight(0xffffff));
init_dropdown_lists();
render();
