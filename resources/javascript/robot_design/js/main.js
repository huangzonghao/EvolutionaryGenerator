"use strict";

////////////////////////////////////////////////////////////////////////
//                             Constants                              //
////////////////////////////////////////////////////////////////////////

const max_ver = 2;
const max_id = 1;
const allowed_num_legs = [2, 3, 4, 5, 6];
const min_num_links_per_leg = 2;
const max_num_links_per_leg = 3;
const leg_pos_range = [0, 1];
const body_scale_range = [0.5, 1.5];
const link_length_range = [0.5, 1.5];
const slider_step = 0.01;

let preset_leg_pos = {};
preset_leg_pos["2"] = [0.25, 0.75];
preset_leg_pos["3"] = [0.01, 0.75, 0.49];
preset_leg_pos["3_alt"] = [0.51, 0.25, 0.99];
preset_leg_pos["4"] = [0.01, 0.49, 0.51, 0.99];
preset_leg_pos["5"] = [0.01, 0.49, 0.51, 0.99, 0.25];
preset_leg_pos["5_alt"] = [0.99, 0.51, 0.49, 0.01, 0.75];
preset_leg_pos["6"] = [0.01, 0.25, 0.49, 0.51, 0.75, 0.99];
const env_to_use = ["ground", "Sine2.obj", "Valley5.obj"];
const body_part_name = ["base", "long", "extra long", "thin", "long & thin", "short & thin"];
const leg_part_name = ["base", "x-wide", "y-wide", "y-wide & short", "y-wide & long", "long", "extra long"];

// TODO: the following 4 values should be read from disk
const num_body_parts = 6;
const num_leg_parts = 7;

const env_mat = new THREE.MeshPhongMaterial( { color: 0x888888, shininess: 50 } );
const unselect_mat = new THREE.MeshPhongMaterial( { color: 0x8796aa, shininess: 50 } );
const select_mat = new THREE.MeshBasicMaterial( { color: 0xff0000 } );

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
        }
        else
            this.position = preset_leg_pos[total_num_legs.toString()][leg_id];
    }
}

class RobotRepresentation {
    constructor() {
        this.env = "";
        this.id = 0;
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

class MeshLibrary {
    constructor() {
        this.bodies = [];
        this.body_size = [];
        this.legs = [];
        this.leg_size = [];

        this.env_names = env_to_use;
        this.env_ids = [];
        for (let i = 0; i < this.env_names.length; ++i) {
            this.env_ids[this.env_names[i]] = i;
        }
        this.envs = [];

        this.loading_done = false;

        let self = this;
        THREE.DefaultLoadingManager.onStart = function (url, itemsLoaded, itemsTotal) {
            self.loading_done = false;
        };
        THREE.DefaultLoadingManager.onLoad = function () {
            self.loading_done = true;
            self.post_load_processing();
            update_drawing();
        };
        let loader = new THREE.OBJLoader();
        for (let i = 0; i < num_body_parts; ++i)
            loader.load('./robot_parts/bodies/' + i + '.obj', function (obj) {self.bodies[i] = obj;});
        for (let i = 0; i < num_leg_parts; ++i)
            loader.load('./robot_parts/legs/' + i + '.obj', function (obj) {self.legs[i] = obj});
        for (let e_name of this.env_names) {
            if (e_name.includes('.obj'))
                loader.load('./maps/' + e_name, function (obj) {self.envs[e_name] = obj});
            else { // basic shapes
                if (e_name == "ground") {
                    self.envs[e_name] = new THREE.Mesh(new THREE.BoxGeometry(2000, 2000, 10));
                }
            }
        }
    }

    post_load_processing() {
        function update_helper(child) { if (child.isMesh) child.material = unselect_mat; }
        function env_update_helper(child) { if (child.isMesh) child.material = env_mat; }
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

        // TODO: for some reason `let obj of this.envs` won't work
        for (let e_name of this.env_names) {
            this.envs[e_name].traverse(env_update_helper);
        }
    }
}

////////////////////////////////////////////////////////////////////////
//                            DOM Handles                             //
////////////////////////////////////////////////////////////////////////

window.addEventListener('resize', onWindowResize);

function onWindowResize(event) {
    renderer.setSize(visual_panel_e.clientWidth, visual_panel_e.clientHeight);
    camera.aspect = visual_panel_e.clientWidth / visual_panel_e.clientHeight;
    camera.updateProjectionMatrix();
}

let left_panel_e = document.getElementById('LeftPanel');
let right_panel_e = document.getElementById('RightPanel');

let visual_panel_e = document.getElementById('RobotCanvas');
visual_panel_e.addEventListener('click', onMouseClick, false);
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
            update_panel_for_new_target();
        }
    }
}

let user_id_e = document.getElementById('UserIDText');

// Robot Config
let env_e = document.getElementById('EnvSelect');
env_e.addEventListener('change', onEnvSelectChange);
function onEnvSelectChange(event) {
    robot.env = env_e.options[env_e.selectedIndex].text;
    draw_env();
}

let robot_id_e = document.getElementById('RobotIDSelect');
robot_id_e.addEventListener('change', onRobotIDSelectChange);
function onRobotIDSelectChange(event) {
    robot.id = robot_id_e.value;
}

let ver_e = document.getElementById('VerSelect');
ver_e.addEventListener('change', onVerSelectChange);
function onVerSelectChange(event) {
    robot.ver = ver_e.value;
}

let body_id_e = document.getElementById('BodyIdSelect');
body_id_e.addEventListener('change', onBodyIdSelectChange);
function onBodyIdSelectChange(event) {
    robot.body_id = parseInt(body_id_e.value);
    update_drawing();
}

let body_x_e = document.getElementById('BodyScaleXText');
body_x_e.addEventListener('change', onBodyScaleXTextChange);
function onBodyScaleXTextChange(event) {
    robot.body_scales[0] = parseFloat(body_x_e.value);
    body_x2_e.value = body_x_e.value;
    update_drawing();
}

let body_x2_e = document.getElementById('BodyScaleXRange');
body_x2_e.addEventListener('change', onBodyScaleXRangeChange);
function onBodyScaleXRangeChange(event) {
    robot.body_scales[0] = parseFloat(body_x2_e.value);
    body_x_e.value = body_x2_e.value;
    update_drawing();
}

let body_y_e = document.getElementById('BodyScaleYText');
body_y_e.addEventListener('change', onBodyScaleYTextChange);
function onBodyScaleYTextChange(event) {
    robot.body_scales[1] = parseFloat(body_y_e.value);
    body_y2_e.value = body_y_e.value;
    update_drawing();
}

let body_y2_e = document.getElementById('BodyScaleYRange');
body_y2_e.addEventListener('change', onBodyScaleYRangeChange);
function onBodyScaleYRangeChange(event) {
    robot.body_scales[1] = parseFloat(body_y2_e.value);
    body_y_e.value = body_y2_e.value;
    update_drawing();
}

let body_z_e = document.getElementById('BodyScaleZText');
body_z_e.addEventListener('change', onBodyScaleZTextChange);
function onBodyScaleZTextChange(event) {
    robot.body_scales[2] = parseFloat(body_z_e.value);
    body_z2_e.value = body_z_e.value;
    update_drawing();
}

let body_z2_e = document.getElementById('BodyScaleZRange');
body_z2_e.addEventListener('change', onBodyScaleZRangeChange);
function onBodyScaleZRangeChange(event) {
    robot.body_scales[2] = parseFloat(body_z2_e.value);
    body_z_e.value = body_z2_e.value;
    update_drawing();
}

let num_legs_e = document.getElementById('NumLegsSelect');
num_legs_e.addEventListener('change', onNumLegsSelectChange);
function onNumLegsSelectChange(event) {
    robot.update_num_legs(parseInt(num_legs_e.value))
    resize_select(copy_leg_e, robot.num_legs);
    update_panel_for_new_target();
    update_drawing();
}

let leg_id_e = document.getElementById('LegIdSelect');
leg_id_e.addEventListener('change', onLegIdSelectChange);
function onLegIdSelectChange(event) {
    update_panel_for_new_target();
}

// let leg_pos_e = document.getElementById('LegPositionText');
// leg_pos_e.addEventListener('change', onLegPositionTextChange);
// function onLegPositionTextChange(event) {
    // robot.leg(leg_id_e.selectedIndex).position = parseFloat(leg_pos_e.value);
    // leg_pos2_e.value = leg_pos_e.value;
    // update_drawing();
// }

// let leg_pos2_e = document.getElementById('LegPositionRange');
// leg_pos2_e.addEventListener('change', onLegPositionRangeChange);
// function onLegPositionRangeChange(event) {
    // robot.leg(leg_id_e.selectedIndex).position = parseFloat(leg_pos2_e.value);
    // leg_pos_e.value = leg_pos2_e.value;
    // update_drawing();
// }

let num_links_e = document.getElementById('NumLinksSelect');
num_links_e.addEventListener('change', onNumLinksSelectChange);
function onNumLinksSelectChange(event) {
    robot.leg(leg_id_e.selectedIndex).num_links = parseInt(num_links_e.value);
    update_panel_for_new_target();
    update_drawing();
}

let link_id_e = document.getElementById('LinkIdSelect');
link_id_e.addEventListener('change', onLinkIdSelectChange);
function onLinkIdSelectChange(event) {
    update_panel_for_new_target();
}

let part_id_e = document.getElementById('PartIdSelect');
part_id_e.addEventListener('change', onPartIdSelectChange);
function onPartIdSelectChange(event) {
    robot.leg(leg_id_e.selectedIndex).link(parseInt(link_id_e.value)).part_id = part_id_e.selectedIndex;
    update_drawing();
}

let link_length_e = document.getElementById('LinkLengthText');
link_length_e.addEventListener('change', onLinkLengthTextChange);
function onLinkLengthTextChange(event) {
    robot.leg(leg_id_e.selectedIndex).link(parseInt(link_id_e.value)).link_length = parseFloat(link_length_e.value);
    link_length2_e.value = link_length_e.value;
    update_drawing();
}

let link_length2_e = document.getElementById('LinkLengthRange');
link_length2_e.addEventListener('change', onLinkLengthRangeChange);
function onLinkLengthRangeChange(event) {
    robot.leg(leg_id_e.selectedIndex).link(parseInt(link_id_e.value)).link_length = parseFloat(link_length2_e.value);
    link_length_e.value = link_length2_e.value;
    update_drawing();
}

let copy_leg_e = document.getElementById('CopyLegSelect');
let copy_leg_btn_e = document.getElementById('CopyLegButton');
copy_leg_btn_e.addEventListener('click', onCopyLegButtonClick);
function onCopyLegButtonClick(event) {
    if (robot.copy_leg(leg_id_e.value, copy_leg_e.value)) { // if copy happened
        update_panel_for_new_target();
        update_drawing();
    }
}

let flip_btn_e = document.getElementById('FlipButton');
flip_btn_e.addEventListener('click', onFlipButtonClick);
function onFlipButtonClick(event) {
    robot.flip_legs();
    update_drawing();
}

let reset_btn_e = document.getElementById('ResetButton');
reset_btn_e.addEventListener('click', onResetButtonClick);
function onResetButtonClick(event) {
    robot.reset();
    update_panel_for_new_robot();
    update_drawing();
}

// Meta
let load_user_btn_e = document.getElementById('LoadUserButton');
load_user_btn_e.addEventListener('click', onLoadUserButtonClick);
function onLoadUserButtonClick(event) {
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
            user_id_e.innerHTML = user_id;
        }
    }
    input.click();
}

let tg_env_btn_e = document.getElementById('ToggleEnvButton');
tg_env_btn_e.addEventListener('click', onToggleEnvButtonClick);
function onToggleEnvButtonClick(event) {
    if (canvas_show_env) {
        remove_env();
        canvas_show_env = false;
        tg_env_btn_e.innerHTML = 'Show Env';
    } else {
        canvas_show_env = true;
        draw_env();
        tg_env_btn_e.innerHTML = 'Hide Env';
    }
}

let robot_up_btn_e = document.getElementById('MoveRobotUpButton');
robot_up_btn_e.addEventListener('click', onMoveRobotUpButtonClick);
function onMoveRobotUpButtonClick(event) {
    if (!canvas_show_env)
        return;
    // achieve this by moving env down
    env_obj.position.z -= 25;
}

let robot_down_btn_e = document.getElementById('MoveRobotDownButton');
robot_down_btn_e.addEventListener('click', onMoveRobotDownButtonClick);
function onMoveRobotDownButtonClick(event) {
    if (!canvas_show_env)
        return;
    // achieve this by moving env up
    env_obj.position.z += 25;
}

let test_btn_e = document.getElementById('TestButton');
test_btn_e.addEventListener('click', onTestButtonClick);
function onTestButtonClick(event) {
    robot.compile_dv();
    let anchor = document.createElement('a');
    anchor.href = "evogen-uisim:" + robot.env + "," + robot.dv;
    anchor.click();
}

let save_btn_e = document.getElementById('SaveButton');
save_btn_e.addEventListener('click', onSaveButtonClick);
function onSaveButtonClick(event) {
    demo_write();
    let next_ver = parseInt(ver_e.value) + 1;
    let next_id = parseInt(robot_id_e.value);
    if (next_ver > max_ver) {
        next_ver = 0;
        next_id = next_id + 1;
        if (next_id > max_id) {
            next_id = 0;
            alert("You have finished for environment " + robot.env + ", now move to next environment");
        }
        robot.reset();
        update_drawing();
    }
    ver_e.value = next_ver;
    robot_id_e.value = next_id;
    robot.ver = next_ver;
    robot.id = next_id;
}

let load_btn_e = document.getElementById('LoadButton');
load_btn_e.addEventListener('click', onLoadButtonClick);
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
            robot.id = json_dict.id;
            robot.ver = json_dict.ver;
            robot.parse_dv(json_dict.gene);

            update_panel_for_new_robot();
            update_drawing();
        }
    }
    input.click();
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
            let opt = document.createElement('option');
            opt.value = i;
            opt.innerHTML = i;
            select.appendChild(opt);
        }
    }
}

// Setup callbacks, generate select lists that will not be changed through out
// the design process.
function init_panel() {
    // Environment Select
    for (let i = 0; i < mesh_lib.env_names.length; ++i) {
        let opt = document.createElement('option');
        opt.value = i;
        opt.innerHTML = mesh_lib.env_names[i];
        env_e.appendChild(opt);
    }
    robot.env = env_e.options[env_e.selectedIndex].text;

    // Robot ID Select
    resize_select(robot_id_e, max_id + 1);
    resize_select(ver_e, max_ver + 1);

    // Num Legs
    for (let i = 0; i < allowed_num_legs.length; ++i) {
        let opt = document.createElement('option');
        opt.value = allowed_num_legs[i];
        opt.innerHTML = allowed_num_legs[i];
        num_legs_e.appendChild(opt);
    }

    // Num Links
    for (let i = min_num_links_per_leg; i < max_num_links_per_leg + 1; ++i) {
        let opt = document.createElement('option');
        opt.value = i;
        opt.innerHTML = i;
        num_links_e.appendChild(opt);
    }

    // Body ID
    resize_select(body_id_e, num_body_parts);
    for (let i = 0; i < body_id_e.options.length; ++i) {
        body_id_e.options[i].text = body_part_name[i];
    }

    // Body Scale
    body_x2_e.min = body_scale_range[0];
    body_x2_e.max = body_scale_range[1];
    body_x2_e.step = slider_step;

    body_y2_e.min = body_scale_range[0];
    body_y2_e.max = body_scale_range[1];
    body_y2_e.step = slider_step;

    body_z2_e.min = body_scale_range[0];
    body_z2_e.max = body_scale_range[1];
    body_z2_e.step = slider_step;

    // Part ID
    resize_select(part_id_e, num_leg_parts);
    for (let i = 0; i < part_id_e.options.length; ++i) {
        part_id_e.options[i].text = leg_part_name[i];
    }

    // Link Scale
    link_length2_e.min = link_length_range[0];
    link_length2_e.max = link_length_range[1];
    link_length2_e.step = slider_step;

    // Leg Position
    // leg_pos2_e.min = leg_pos_range[0];
    // leg_pos2_e.max = leg_pos_range[1];
    // leg_pos2_e.step = slider_step;

    tg_env_btn_e.innerHTML = 'Show Env';

    update_panel_for_new_robot();
}

// Update the values and lists that might be changed after loading a new robot.
function update_panel_for_new_robot() {
    user_id_e.innerHTML = user_id;
    env_e.value = mesh_lib.env_ids[robot.env];
    robot_id_e.value = robot.id;
    ver_e.value = robot.ver;
    body_id_e.value = robot.body_id;
    body_x_e.value = robot.body_scales[0];
    body_x2_e.value = robot.body_scales[0];
    body_y_e.value = robot.body_scales[1];
    body_y2_e.value = robot.body_scales[1];
    body_z_e.value = robot.body_scales[2];
    body_z2_e.value = robot.body_scales[2];
    num_legs_e.value = robot.num_legs; // num_legs only need auto update here
    resize_select(copy_leg_e, robot.num_legs);

    update_panel_for_new_target();
}

// Update the values and lists that might be changed after selecting a new target link.
function update_panel_for_new_target() {
    // Leg ID -- might be changed after num_legs being changed
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
    if (mesh_lib.loading_done) {
        mark_body(current_selected_obj, false);
        current_selected_obj = robot.leg(parseInt(leg_id_e.value)).link(parseInt(link_id_e.value)).obj;
        mark_body(current_selected_obj, true);
    }
}

function init_canvas() {
    // Lights setup
    const amb_light = new THREE.AmbientLight(0xffffff, 0.2); // color and intensity
    // for dir light, set the "from" pos (light pos) and "to" pos (light.target pos)
    // const dir_light = new THREE.DirectionalLight(0xffffff, 1); // color and intensity
    const point_light = new THREE.PointLight(0xffffff, 1); // color and intensity
    // explictily add camera to scene, since the light is a child of camera.
    // otherwise the camera would be automatically added (not sure to where, maybe renderer)
    scene.add(camera);
    scene.add(amb_light);
    camera.add(point_light); // so that the light follows the camera
    // Display axis
    const axes_obj = new THREE.AxesHelper(200);
    scene.add(axes_obj);
}

// TODO: mesh objs can be reused, do not create a new one everytime
function build_robot() {
    robot_obj.clear();
    // Add body
    let body_obj = mesh_lib.bodies[robot.body_id].clone();
    body_obj.scale.x *= robot.body_scales[0];
    body_obj.scale.y *= robot.body_scales[1];
    body_obj.scale.z *= robot.body_scales[2];
    robot.body_obj = body_obj;
    robot_obj.add(body_obj);
    let body_size = mesh_lib.body_size[robot.body_id].clone();
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
            leg_pos_y = body_size.y / 2 + mesh_lib.leg_size[robot.leg(leg_id).link(0).part_id].y;
        } else {
            leg_pos_x = (leg_pos_gene - 0.75) * 2 * body_size.x;
            leg_pos_y = -(body_size.y / 2 + mesh_lib.leg_size[robot.leg(leg_id).link(0).part_id].y);
        }
        for (let i = 0; i < robot.leg(leg_id).num_links; ++i) {
            let link_obj = mesh_lib.legs[robot.leg(leg_id).link(i).part_id].clone();
            link_size_z = mesh_lib.leg_size[robot.leg(leg_id).link(i).part_id].z * robot.leg(leg_id).link(i).link_length;
            link_obj.scale.z *= robot.leg(leg_id).link(i).link_length;
            link_obj.position.x = leg_pos_x;
            link_obj.position.y = leg_pos_y;
            link_obj.position.z = -leg_total_length - link_size_z / 2;
            link_obj.leg_id = leg_id;
            link_obj.link_id = i;
            robot.leg(leg_id).link(i).obj = link_obj;
            robot_obj.add(link_obj);

            leg_total_length += link_size_z + 2; // note in the UI the mesh are not scaled, so 2 means 0.02 in evogen
        }
    }

    current_selected_obj = robot.leg(parseInt(leg_id_e.value)).link(parseInt(link_id_e.value)).obj;
    mark_body(current_selected_obj, true);
}

function mark_body(body_obj, selected = true) {
    if (selected)
        body_obj.traverse(function(child){if (child.isMesh) child.material = select_mat;});
    else
        body_obj.traverse(function(child){if (child.isMesh) child.material = unselect_mat;});
}

function draw_env() {
    if (!canvas_show_env)
        return;
    if (current_env_name != robot.env) {
        // remove env from scene
        scene.remove(env_obj);
        // add new env
        env_obj = mesh_lib.envs[robot.env].clone();
        env_obj.position.z = -100;
        current_env_name = robot.env;
    }
    scene.add(env_obj);
}

function remove_env() {
    current_env_name = "";
    env_obj.removeFromParent();
}

function update_drawing() {
    if (!mesh_lib.loading_done)
        return;

    scene.remove(robot_obj);
    build_robot();
    scene.add(robot_obj);
}

function animate() {
    window.requestAnimationFrame(animate);
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
        id: robot.id,
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
    anchor.download = "evogen_" + user_id.toString() + "_" + robot.env + "_" + robot.id + "." + robot.ver + '.txt';
    anchor.click();
}

////////////////////////////////////////////////////////////////////////
//                           Main Function                            //
////////////////////////////////////////////////////////////////////////

let user_id = "000000";
let robot = new RobotRepresentation();
let mesh_lib = new MeshLibrary();
let current_selected_obj;
let canvas_show_env = false;
let current_env_name = "";
let env_obj;
let robot_obj = new THREE.Object3D();

// Set up scene, renderer, camera and trackball control
const scene = new THREE.Scene();
const renderer = new THREE.WebGLRenderer({ alpha: true });
renderer.setSize(visual_panel_e.clientWidth, visual_panel_e.clientHeight);
visual_panel_e.appendChild(renderer.domElement);

const camera = new THREE.PerspectiveCamera(75, visual_panel_e.clientWidth / visual_panel_e.clientHeight, 0.1, 4000);
camera.position.set(238, 270, 100);
camera.up.set(0.35, 0.4, 0.8); // set the up direction of the camera

let controls = new THREE.TrackballControls(camera, renderer.domElement);
controls.rotateSpeed = 1;
controls.zoomSpeed = 0.1;
controls.panSpeed = 0.2;

// Raycaster
const raycaster = new THREE.Raycaster();
const mouse = new THREE.Vector2();

init_panel();
init_canvas();
animate(); // starts the animation
