"use strict";

////////////////////////////////////////////////////////////////////////
//                             Constants                              //
////////////////////////////////////////////////////////////////////////

const max_ver = 10;
const g_robots_per_env = 1;
const allowed_num_legs = [2, 3, 4, 5, 6];
const min_num_links_per_leg = 2;
const max_num_links_per_leg = 3;
const leg_pos_range = [0, 1];
const body_scale_range = [0.5, 1.5];
const link_length_range = [0.5, 1.5];
const slider_step = 0.01;
const minimum_test_gap = 20;
const training_session_minutes = 10;

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

////////////////////////////////////////////////////////////////////////
//                          Global Variables                          //
////////////////////////////////////////////////////////////////////////

const env_mat = new THREE.MeshPhongMaterial( { color: 0x888888, shininess: 50 } );
const unselect_mat = new THREE.MeshPhongMaterial( { color: 0x8796aa, shininess: 50 } );
const select_mat = new THREE.MeshBasicMaterial( { color: 0xff0000 } );

////////////////////////////////////////////////////////////////////////
//                           Console Tools                            //
////////////////////////////////////////////////////////////////////////

let admin_is_on = false;
function admin() {
    if (admin_is_on) {
        user_study.admin_off();
        admin_is_on = false;
    } else {
        user_study.admin_on();
        admin_is_on = true;
    }
}

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

        this.reset_design();
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
        this.env = "";
        this.id = 0;
        this.ver = 0;
        this.reset_design();
    }

    reset_design() {
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

    // TODO: mesh objs can be reused, do not create a new one everytime
    build_robot() {
        let robot_obj = new THREE.Object3D();
        robot_obj.clear();
        // Add body
        let body_obj = mesh_lib.bodies[this.body_id].clone();
        body_obj.scale.x *= this.body_scales[0];
        body_obj.scale.y *= this.body_scales[1];
        body_obj.scale.z *= this.body_scales[2];
        this.body_obj = body_obj;
        robot_obj.add(body_obj);
        let body_size = mesh_lib.body_size[this.body_id].clone();
        body_size.x *= this.body_scales[0];
        body_size.y *= this.body_scales[1];
        body_size.z *= this.body_scales[2];

        // Add legs
        let leg_pos_x = 0;
        let leg_pos_y = 0;
        let leg_pos_gene = 0;
        let leg_total_length = 0;
        let link_size_z = 0;
        for (let leg_id = 0; leg_id < this.num_legs; ++leg_id) {
            leg_total_length = 0;
            leg_pos_gene = this.leg(leg_id).position;
            if (leg_pos_gene < 0.5) {
                leg_pos_x = (0.25 - leg_pos_gene) * 2 * body_size.x;
                leg_pos_y = body_size.y / 2 + mesh_lib.leg_size[this.leg(leg_id).link(0).part_id].y;
            } else {
                leg_pos_x = (leg_pos_gene - 0.75) * 2 * body_size.x;
                leg_pos_y = -(body_size.y / 2 + mesh_lib.leg_size[this.leg(leg_id).link(0).part_id].y);
            }
            for (let i = 0; i < this.leg(leg_id).num_links; ++i) {
                let link_obj = mesh_lib.legs[this.leg(leg_id).link(i).part_id].clone();
                link_size_z = mesh_lib.leg_size[this.leg(leg_id).link(i).part_id].z * this.leg(leg_id).link(i).link_length;
                link_obj.scale.z *= this.leg(leg_id).link(i).link_length;
                link_obj.position.x = leg_pos_x;
                link_obj.position.y = leg_pos_y;
                link_obj.position.z = -leg_total_length - link_size_z / 2;
                link_obj.leg_id = leg_id;
                link_obj.link_id = i;
                this.leg(leg_id).link(i).obj = link_obj;
                robot_obj.add(link_obj);

                leg_total_length += link_size_z + 2; // note in the UI the mesh are not scaled, so 2 means 0.02 in evogen
            }
        }
        return robot_obj;
    }
}

class MeshLibrary {
    constructor() {
        this.bodies = [];
        this.body_size = [];
        this.legs = [];
        this.leg_size = [];

        this.env_names = env_to_use;
        this.env_names.unshift("Training.obj");
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
            canvas.update_drawing();
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

class UserStudyManager {
    constructor() {
        this.init_user_id = "000000";
        this.user_id = this.init_user_id;
        this.current_ver = 0;
        this.current_id = 0;
        this.updates_per_robot = max_ver;
        this.robots_per_env = g_robots_per_env;
        this.env_ids;
        this.env_string = "";
        this.env_cursor = 0; // the cursor for this.env_ids

        this.in_training = false;
        this.in_user_study = false;
        this.robot_config_blind_e;

        this.stop();
    }

    load_user(new_user_id) {
        this.user_id = new_user_id;
        user_id_e.innerHTML = new_user_id;
        if (this.user_id != 0) {
            training_btn_e.disabled = false;
            user_study_btn_e.disabled = false;
        }
    }

    start_training() {
        this.in_training = true;
        canvas.load_env_by_id(0); // training map is always the first

        training_btn_e.innerHTML = "Stop Training";
        user_study_btn_e.disabled = true;
        user_study_label_e.innerHTML = "Training in progress";
        robot_meta_panel_e.style.display = "none";
        new_user_btn_e.disabled = true;
        load_user_btn_e.disabled = true;

        let self_class = this;
        // set up the timer
        let start = Date.now();
        let interval_sec = training_session_minutes * 60 * 1000;
        let training_interval = setInterval(function self_func() {
            if (!self_class.in_training) {
                clearInterval(training_interval);
                return;
            }
            let diff = Date.now() - start;
            let ns = (((interval_sec - diff) / 1000) >> 0);
            let m = (ns / 60) >> 0
            let s = ns - m * 60;
            user_study_timer_e.innerHTML = "&emsp;" + m + ':' + ((''+s).length > 1 ? '' : '0') + s;
            if(diff > interval_sec) {
                clearInterval(training_interval);
                self_class.stop_training();
            }
            return self_func;
        }(), 1000);
    }

    stop_training() {
        this.in_training = false;
        user_study_label_e.innerHTML = "Training done";
        training_btn_e.innerHTML = "Start Training";
        training_btn_e.disabled = true;
        user_study_timer_e.textContent = '';
        user_study_btn_e.disabled = false;
        this.freeze_robot_config();
        alert("Training done\nProceed to user study next");
    }

    init_user_study() {
        this.in_user_study = true;
        this.unfreeze_robot_config();
        user_study_label_e.innerHTML = "User Study in Progress";
        user_study_label_e.style.color = "red";
        user_study_progress_label_e.innerHTML = this.current_ver;
        user_study_total_label_e.innerHTML = this.updates_per_robot + 1;
        user_study_status_e.style.visibility = "visible";
        save_btn_e.disabled = true;
        robot_meta_panel_e.style.display = "none";
        new_user_btn_e.disabled = true;
        load_user_btn_e.disabled = true;
        training_btn_e.disabled = true;
        user_study_btn_e.disabled = true;
    }

    start_new_user_study() {
        reset_robot(true); // full reset
        this.init_user_study();

        let tmp_array = new Array(mesh_lib.env_names.length - 1);
        for (let i = 0; i < tmp_array.length; ++i) {
            tmp_array[i] = i + 1;
        }
        this.env_ids = this.shuffle(tmp_array);
        let tmp_string = '';
        for (let i = 0; i < this.env_ids.length; ++i) {
            tmp_string += mesh_lib.env_names[this.env_ids[i]];
            if (i != this.env_ids.length - 1) {
                tmp_string += ", ";
            }
        }
        this.env_string = tmp_string;

        // init env
        this.env_cursor = 0;
        this.load_env();

        this.dump_meta();
    }

    stop() {
        this.in_user_study = false;
        new_user_btn_e.disabled = false;
        load_user_btn_e.disabled = false;
        user_study_label_e.innerHTML = "Testing";
        user_study_label_e.style.color = "black";
        user_study_status_e.style.visibility = "hidden";
        save_btn_e.disabled = false;
        robot_meta_panel_e.style.display = "block";
        // Disable need to remove user id
        this.user_id = this.init_user_id;
        user_id_e.innerHTML = this.user_id;

        test_btn_e.disabled = false;
        test_btn_e.innerHTML = "Test";

        training_btn_e.disabled = true;
        training_btn_e.innerHTML = "Start Training";
        user_study_btn_e.disabled = true;
        user_study_btn_e.innerHTML = "Start User Study";
    }

    load_setup(json_dict) {
        this.user_id = json_dict.user_id;
        user_id_e.innerHTML = this.user_id;
        this.env_ids = json_dict.env_ids;
        this.updates_per_robot = json_dict.updates_per_robot;
        this.robots_per_env = json_dict.robots_per_env;

        user_study_label_e.innerHTML = "User Study Setup Loaded<br>Load a progress file to resume"
    }

    load_progress(json_dict) {
        if (this.user_id != json_dict.user_id) {
            alert("The loaded user id (" + this.user_id +
                  ") doesn't match in user id in file (" + json_dict.user_id +
                  ")\nLoading aborted");
            return;
        }

        robot.id = json_dict.id;
        robot.ver = json_dict.ver;
        this.current_ver = robot.ver;
        user_study_progress_label_e.innerHTML = this.current_ver;
        robot.parse_dv(json_dict.gene);
        update_panel_for_new_robot();
        canvas.update_drawing();

        this.init_user_study();

        // load environment -- find the value for env cursor
        for(this.env_cursor = 0; this.env_cursor < this.env_ids.length; ++this.env_cursor) {
            if (mesh_lib.env_names[this.env_ids[this.env_cursor]] == json_dict.environment)
                break;
        }
        if (mesh_lib.env_names[this.env_ids[this.env_cursor]] != json_dict.environment) {
            alert("Unkown environment in the progress file: " + json_dict.environment);
            return;
        }
        this.load_env();

        // jump to next ver since we are already done with the current ver
        this.next_ver();
    }

    // Turn on admin mode
    admin_on() {
        admin_panel_e.style.visibility = "visible";
    }

    // Turn off admin mode
    admin_off() {
        admin_panel_e.style.visibility = "hidden";
    }

    post_test() {
        test_btn_e.disabled = true;
        test_btn_e.innerHTML = "Click Canvas";

        this.dump_robot();

        this.freeze_screen();
    }

    pre_next_test() {
        this.next_ver();

        if (this.current_ver != 0) {
            // Set up the test button freezing timer
            let timer_counter = minimum_test_gap;
            let test_btn_interval = setInterval(function f() {
                test_btn_e.textContent= "Wait " + timer_counter;
                if(timer_counter-- == 0) {
                    test_btn_e.disabled = false;
                    test_btn_e.innerHTML = "Test";
                    clearInterval(test_btn_interval);
                }
                return f; // so that this function is called at the beginning of interval
            }(), 1000);
        } else {
            test_btn_e.disabled = false;
            test_btn_e.innerHTML = "Test";
        }
    }

    dump_meta() {
        let date = new Date();
        let timestamp = date.getFullYear().toString() +
                        twodigit_str((date.getMonth()+1)) +
                        twodigit_str(date.getDate()) + "_" +
                        twodigit_str(date.getHours()) +
                        twodigit_str(date.getMinutes()) +
                        twodigit_str(date.getSeconds());

        let json_dict = {
            user_id: this.user_id,
            env_ids: this.env_ids,
            env_string: this.env_string,
            updates_per_robot: this.updates_per_robot,
            robots_per_env: this.robots_per_env,
            datetime: timestamp
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
        anchor.download = "UserStudy_" + user_study.user_id.toString() + "_" + timestamp + ".txt";
        anchor.click();
    }

    dump_robot() {
        let date = new Date();
        let timestamp = date.getFullYear().toString() +
                        twodigit_str((date.getMonth()+1)) +
                        twodigit_str(date.getDate()) + "_" +
                        twodigit_str(date.getHours()) +
                        twodigit_str(date.getMinutes()) +
                        twodigit_str(date.getSeconds());

        robot.compile_dv();
        let json_dict = {
            user_id: this.user_id,
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
        anchor.download = "evogen_" + this.user_id.toString() + "_" + robot.env + "_" + robot.id + "." + robot.ver + '.txt';
        anchor.click();
    }

    // Private Functions
    next_ver() {
        let next_ver = this.current_ver + 1;

        if (this.current_ver == this.updates_per_robot) {
            user_study_progress_label_e.innerHTML = this.current_ver + 1;
            this.next_id();
            next_ver = 0;
        }

        ver_e.value = next_ver;
        user_study_progress_label_e.innerHTML = next_ver;
        robot.ver = next_ver;
        this.current_ver = next_ver;
    }

    next_id() {
        let next_id = this.current_id + 1;

        if (this.current_id + 1 >= this.robots_per_env) {
            this.next_env();
            next_id = 0;
        }

        robot.reset_design();
        robot.id = next_id;
        robot_id_e.value = next_id;
        update_panel_for_new_robot();
        canvas.update_drawing();
        this.current_id = next_id;
    }

    next_env() {
        if (this.env_cursor == this.env_ids.length - 1) {
            alert("Thank you! You have finished the user study!");
            this.stop();
            return;
        }
        let curr_env = robot.env;
        this.env_cursor += 1;
        robot.env = mesh_lib.env_names[this.env_ids[this.env_cursor]]; // TODO: currently useless, as canvas.load_env_by_id also sets robot.env
        alert("You have finished for environment " + curr_env +
              ", now move to next environment " + robot.env);

        this.load_env();
    }

    load_env() {
        canvas.load_env_by_id(this.env_ids[this.env_cursor]);
        let tmp_string = '';
        for (let i = 0; i < this.env_ids.length; ++i) {
            if (i == this.env_cursor) {
                tmp_string += "<strong>" + mesh_lib.env_names[this.env_ids[i]] + "</strong>";
            } else {
                tmp_string += mesh_lib.env_names[this.env_ids[i]].fontcolor("grey");
            }

            if (i != this.env_ids.length - 1) {
                tmp_string += ", ";
            }
        }
        user_study_env_list_label_e.innerHTML = tmp_string;
    }

    freeze_screen() {
        let self = this;
        let blind_e = document.createElement("div");
        blind_e.id = "Blind";
        blind_e.classList.add("blind");
        blind_e.addEventListener("click", function(event) {
            self.pre_next_test();
            let blind_e = document.getElementById('Blind');
            blind_e.remove();
        });
        document.body.appendChild(blind_e)
    }

    freeze_robot_config() {
        this.robot_config_blind_e = document.createElement("div");
        this.robot_config_blind_e.id = "RightPanelBlind";
        this.robot_config_blind_e.classList.add("blind");
        this.robot_config_blind_e.style.top = right_panel_e.offsetTop;
        right_panel_e.appendChild(this.robot_config_blind_e)
    }

    unfreeze_robot_config() {
        if (this.robot_config_blind_e) this.robot_config_blind_e.remove();
    }

    shuffle(array) {
        let currentIndex = array.length,  randomIndex;

        // While there remain elements to shuffle...
        while (currentIndex != 0) {

            // Pick a remaining element...
            randomIndex = Math.floor(Math.random() * currentIndex);
            currentIndex--;

            // And swap it with the current element.
            [array[currentIndex], array[randomIndex]] = [
                array[randomIndex], array[currentIndex]];
        }
        return array;
    }
}

// Manages the THREE.js canvas
class CanvasManager {
    constructor() {
        this.env_enabled = false;
        this.current_env_name = "";
        this.current_selected_obj;
        this.env_obj;
        this.robot_obj = new THREE.Object3D();

        this.hide_env();

        // Set up scene, renderer, camera and trackball control
        this.scene = new THREE.Scene();
        this.renderer = new THREE.WebGLRenderer({ alpha: true });
        this.renderer.setSize(visual_panel_e.clientWidth, visual_panel_e.clientHeight);
        visual_panel_e.appendChild(this.renderer.domElement);

        this.camera = new THREE.PerspectiveCamera(75, visual_panel_e.clientWidth / visual_panel_e.clientHeight, 0.1, 4000);
        this.camera.position.set(238, 270, 100);
        this.camera.up.set(0.35, 0.4, 0.8); // set the up direction of the camera

        this.controls = new THREE.TrackballControls(this.camera, this.renderer.domElement);
        this.controls.rotateSpeed = 1;
        this.controls.zoomSpeed = 0.1;
        this.controls.panSpeed = 0.2;

        // Raycaster
        this.raycaster = new THREE.Raycaster();
        this.mouse = new THREE.Vector2();

        // Lights setup
        this.amb_light = new THREE.AmbientLight(0xffffff, 0.2); // color and intensity
        // for dir light, set the "from" pos (light pos) and "to" pos (light.target pos)
        // const dir_light = new THREE.DirectionalLight(0xffffff, 1); // color and intensity
        this.point_light = new THREE.PointLight(0xffffff, 1); // color and intensity
        // explictily add camera to scene, since the light is a child of camera.
        // otherwise the camera would be automatically added (not sure to where, maybe renderer)
        this.scene.add(this.camera);
        this.scene.add(this.amb_light);
        this.camera.add(this.point_light); // so that the light follows the camera
        // Display axis
        this.axes_obj = new THREE.AxesHelper(200);
        this.scene.add(this.axes_obj);
    }

    draw_env() {
        if (!this.env_enabled)
            return;
        if (this.current_env_name != robot.env) {
            // remove env from scene
            this.scene.remove(this.env_obj);
            // add new env
            this.env_obj = mesh_lib.envs[robot.env].clone();
            this.env_obj.position.z = -100;
            this.current_env_name = robot.env;
        }
        this.scene.add(this.env_obj);
    }

    show_env() {
        this.env_enabled = true;
        this.draw_env();
        tg_env_btn_e.innerHTML = 'Hide Env';
        robot_up_btn_e.disabled = false;
        robot_down_btn_e.disabled = false;
    }

    hide_env() {
        this.current_env_name = "";
        if (this.env_obj != null)
            this.env_obj.removeFromParent();
        this.env_enabled = false;
        tg_env_btn_e.innerHTML = 'Show Env';
        robot_up_btn_e.disabled = true;
        robot_down_btn_e.disabled = true;
    }

    mark_body(body_obj, selected = true) {
        if (selected)
            body_obj.traverse(function(child){if (child.isMesh) child.material = select_mat;});
        else
            body_obj.traverse(function(child){if (child.isMesh) child.material = unselect_mat;});
    }

    load_env_by_id(new_env_id) {
        new_env_id = Math.min(Math.max(0, new_env_id), mesh_lib.env_names.length - 1);
        env_e.selectedIndex = new_env_id;
        // TODO: decouple canvas env and robot env (and user_study env)
        robot.env = mesh_lib.env_names[new_env_id];
        this.draw_env();
    }

    update_drawing() {
        if (!mesh_lib.loading_done)
            return;

        this.scene.remove(this.robot_obj);
        this.robot_obj = robot.build_robot();
        this.scene.add(this.robot_obj);

        this.current_selected_obj = robot.leg(parseInt(leg_id_e.value)).link(parseInt(link_id_e.value)).obj;
        this.mark_body(canvas.current_selected_obj, true);
    }
}

////////////////////////////////////////////////////////////////////////
//                            DOM Handles                             //
////////////////////////////////////////////////////////////////////////

window.addEventListener('resize', onWindowResize);

function onWindowResize(event) {
    canvas.renderer.setSize(visual_panel_e.clientWidth, visual_panel_e.clientHeight);
    canvas.camera.aspect = visual_panel_e.clientWidth / visual_panel_e.clientHeight;
    canvas.camera.updateProjectionMatrix();
}

let left_panel_e = document.getElementById('LeftPanel');
let right_panel_e = document.getElementById('RightPanel');

let visual_panel_e = document.getElementById('RobotCanvas');
visual_panel_e.addEventListener('click', onMouseClick, false);
function onMouseClick(event) {
    const rect = visual_panel_e.getBoundingClientRect();
    canvas.mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    canvas.mouse.y = - ((event.clientY - rect.top) / rect.height) * 2 + 1;
    // raycaster
    canvas.raycaster.setFromCamera(canvas.mouse, canvas.camera);
    // calculate objects intersecting the picking ray
    const intersects = canvas.raycaster.intersectObjects(canvas.scene.children, true);
    if (intersects.length > 0) {
        // not sure why, but the obj returned by raycaster is a different obj
        // than the one passed to scene, and has an id 1 larger than the orig obj
        const orig_obj = canvas.scene.getObjectById(intersects[0].object.id - 1);
        if (orig_obj && orig_obj.leg_id != null) { // only obj of leg links has this defined
            leg_id_e.value = orig_obj.leg_id;
            link_id_e.value = orig_obj.link_id;
            update_panel_for_new_target();
        }
    }
}

let user_study_label_e = document.getElementById('UserStudyModeLabel');
let user_study_timer_e = document.getElementById('UserStudyTimerLabel');
let user_study_status_e = document.getElementById('UserStudyStatusLabel');
let user_study_progress_label_e = document.getElementById('UserStudyProgressLabel');
let user_study_total_label_e = document.getElementById('UserStudyTotalLabel');
let user_study_env_list_label_e = document.getElementById('UserStudyEnvListLabel');

let user_id_e = document.getElementById('UserIDText');

// Robot Config
let robot_meta_panel_e = document.getElementById('RobotMetaPanel');
let env_e = document.getElementById('EnvSelect');
env_e.addEventListener('change', onEnvSelectChange);
function onEnvSelectChange(event) {
    canvas.load_env_by_id(env_e.selectedIndex);
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
    canvas.update_drawing();
}

let body_x_e = document.getElementById('BodyScaleXText');
body_x_e.addEventListener('change', onBodyScaleXTextChange);
function onBodyScaleXTextChange(event) {
    let tmp_scale = clamp(parseFloat(body_x_e.value), body_scale_range);
    body_x_e.value = tmp_scale;
    robot.body_scales[0] = tmp_scale;
    body_x2_e.value = body_x_e.value;
    canvas.update_drawing();
}

let body_x2_e = document.getElementById('BodyScaleXRange');
body_x2_e.addEventListener('change', onBodyScaleXRangeChange);
function onBodyScaleXRangeChange(event) {
    robot.body_scales[0] = parseFloat(body_x2_e.value);
    body_x_e.value = body_x2_e.value;
    canvas.update_drawing();
}

let body_y_e = document.getElementById('BodyScaleYText');
body_y_e.addEventListener('change', onBodyScaleYTextChange);
function onBodyScaleYTextChange(event) {
    let tmp_scale = clamp(parseFloat(body_y_e.value), body_scale_range);
    body_y_e.value = tmp_scale;
    robot.body_scales[1] = tmp_scale
    body_y2_e.value = body_y_e.value;
    canvas.update_drawing();
}

let body_y2_e = document.getElementById('BodyScaleYRange');
body_y2_e.addEventListener('change', onBodyScaleYRangeChange);
function onBodyScaleYRangeChange(event) {
    robot.body_scales[1] = parseFloat(body_y2_e.value);
    body_y_e.value = body_y2_e.value;
    canvas.update_drawing();
}

let body_z_e = document.getElementById('BodyScaleZText');
body_z_e.addEventListener('change', onBodyScaleZTextChange);
function onBodyScaleZTextChange(event) {
    let tmp_scale = clamp(parseFloat(body_z_e.value), body_scale_range);
    body_z_e.value = tmp_scale;
    robot.body_scales[2] = tmp_scale;
    body_z2_e.value = body_z_e.value;
    canvas.update_drawing();
}

let body_z2_e = document.getElementById('BodyScaleZRange');
body_z2_e.addEventListener('change', onBodyScaleZRangeChange);
function onBodyScaleZRangeChange(event) {
    robot.body_scales[2] = parseFloat(body_z2_e.value);
    body_z_e.value = body_z2_e.value;
    canvas.update_drawing();
}

let num_legs_e = document.getElementById('NumLegsSelect');
num_legs_e.addEventListener('change', onNumLegsSelectChange);
function onNumLegsSelectChange(event) {
    robot.update_num_legs(parseInt(num_legs_e.value))
    resize_select(copy_leg_e, robot.num_legs);
    update_panel_for_new_target();
    canvas.update_drawing();
}

let leg_id_e = document.getElementById('LegIdSelect');
leg_id_e.addEventListener('change', onLegIdSelectChange);
function onLegIdSelectChange(event) {
    update_panel_for_new_target();
}

// let leg_pos_e = document.getElementById('LegPositionText');
// leg_pos_e.addEventListener('change', onLegPositionTextChange);
// function onLegPositionTextChange(event) {
    // let tmp_pos = clamp(parseFloat(leg_pos_e.value), leg_pos_range);
    // leg_pos_e.value = tmp_pos;
    // robot.leg(leg_id_e.selectedIndex).position = tmp_pos;
    // leg_pos2_e.value = leg_pos_e.value;
    // canvas.update_drawing();
// }

// let leg_pos2_e = document.getElementById('LegPositionRange');
// leg_pos2_e.addEventListener('change', onLegPositionRangeChange);
// function onLegPositionRangeChange(event) {
    // robot.leg(leg_id_e.selectedIndex).position = parseFloat(leg_pos2_e.value);
    // leg_pos_e.value = leg_pos2_e.value;
    // canvas.update_drawing();
// }

let num_links_e = document.getElementById('NumLinksSelect');
num_links_e.addEventListener('change', onNumLinksSelectChange);
function onNumLinksSelectChange(event) {
    robot.leg(leg_id_e.selectedIndex).num_links = parseInt(num_links_e.value);
    update_panel_for_new_target();
    canvas.update_drawing();
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
    canvas.update_drawing();
}

let link_length_e = document.getElementById('LinkLengthText');
link_length_e.addEventListener('change', onLinkLengthTextChange);
function onLinkLengthTextChange(event) {
    let tmp_length = clamp(parseFloat(link_length_e.value), link_length_range);
    link_length_e.value = tmp_length;
    robot.leg(leg_id_e.selectedIndex).link(parseInt(link_id_e.value)).link_length = tmp_length;
    link_length2_e.value = link_length_e.value;
    canvas.update_drawing();
}

let link_length2_e = document.getElementById('LinkLengthRange');
link_length2_e.addEventListener('change', onLinkLengthRangeChange);
function onLinkLengthRangeChange(event) {
    robot.leg(leg_id_e.selectedIndex).link(parseInt(link_id_e.value)).link_length = parseFloat(link_length2_e.value);
    link_length_e.value = link_length2_e.value;
    canvas.update_drawing();
}

let copy_leg_e = document.getElementById('CopyLegSelect');
let copy_leg_btn_e = document.getElementById('CopyLegButton');
copy_leg_btn_e.addEventListener('click', onCopyLegButtonClick);
function onCopyLegButtonClick(event) {
    if (robot.copy_leg(leg_id_e.value, copy_leg_e.value)) { // if copy happened
        update_panel_for_new_target();
        canvas.update_drawing();
    }
}

let flip_btn_e = document.getElementById('FlipButton');
flip_btn_e.addEventListener('click', onFlipButtonClick);
function onFlipButtonClick(event) {
    robot.flip_legs();
    canvas.update_drawing();
}

let reset_btn_e = document.getElementById('ResetButton');
reset_btn_e.addEventListener('click', e => { reset_robot() });
function reset_robot(fullreset = false) {
    if (fullreset) {
        robot.reset();
    } else {
        robot.reset_design();
    }
    update_panel_for_new_robot();
    canvas.update_drawing();
}

// Meta
let new_user_btn_e = document.getElementById('NewUserButton');
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
            user_study.load_user(json_dict.user_id);
        }
    }
    input.click();
}

let training_btn_e = document.getElementById('TrainingButton');
training_btn_e.addEventListener('click', onTrainingButtonClick);
function onTrainingButtonClick(event) {
    if (user_study.in_training) {
        user_study.stop_training();
    } else {
        user_study.start_training();
    }
}

let user_study_btn_e = document.getElementById('UserStudyButton');
user_study_btn_e.addEventListener('click', e => { user_study.start_new_user_study(); });

let tg_env_btn_e = document.getElementById('ToggleEnvButton');
tg_env_btn_e.addEventListener('click', onToggleEnvButtonClick);
function onToggleEnvButtonClick(event) {
    if (canvas.env_enabled) {
        canvas.hide_env();
    } else {
        canvas.show_env();
    }
}

let robot_up_btn_e = document.getElementById('MoveRobotUpButton');
robot_up_btn_e.addEventListener('click', onMoveRobotUpButtonClick);
function onMoveRobotUpButtonClick(event) {
    if (!canvas.env_enabled)
        return;
    // achieve this by moving env down
    canvas.env_obj.position.z -= 25;
}

let robot_down_btn_e = document.getElementById('MoveRobotDownButton');
robot_down_btn_e.addEventListener('click', onMoveRobotDownButtonClick);
function onMoveRobotDownButtonClick(event) {
    if (!canvas.env_enabled)
        return;
    // achieve this by moving env up
    canvas.env_obj.position.z += 25;
}

let test_btn_e = document.getElementById('TestButton');
test_btn_e.addEventListener('click', onTestButtonClick);
function onTestButtonClick(event) {
    robot.compile_dv();
    let anchor = document.createElement('a');
    anchor.href = "evogen-uisim:" + robot.env + "," + robot.dv;
    anchor.click();

    if (user_study.in_user_study) {
        user_study.post_test();
    }
}

let save_btn_e = document.getElementById('SaveButton');
save_btn_e.addEventListener('click', onSaveButtonClick);
function onSaveButtonClick(event) {
    user_study.dump_robot();
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

            if (!user_study.in_user_study) {
                user_study.load_user(json_dict.user_id);
                robot.env = json_dict.environment;
                robot.id = json_dict.id;
                robot.ver = json_dict.ver;
            }
            robot.parse_dv(json_dict.gene);

            update_panel_for_new_robot();
            canvas.update_drawing();
        }
    }
    input.click();
}

// Admin Panel
let admin_panel_e = document.getElementById('AdminPanel');

// TODO: move env and robot id & ver to admin panel
let load_setup_btn_e = document.getElementById('AdminLoadUserStudySetupButton');
load_setup_btn_e.addEventListener('click', function(e) {
    let input = document.createElement('input');
    input.type = 'file';
    input.onchange = e => {
        let file = e.target.files[0];
        let reader = new FileReader();
        reader.readAsText(file,'UTF-8');
        reader.onload = readerEvent => {
            let json_str = readerEvent.target.result;
            let json_dict = JSON.parse(json_str);
            user_study.load_setup(json_dict);
        }
    }
    input.click();

});

let load_progress_btn_e = document.getElementById('AdminLoadUserStudyProgressButton');
load_progress_btn_e.addEventListener('click', function(e) {
    let input = document.createElement('input');
    input.type = 'file';
    input.onchange = e => {
        let file = e.target.files[0];
        let reader = new FileReader();
        reader.readAsText(file,'UTF-8');
        reader.onload = readerEvent => {
            let json_str = readerEvent.target.result;
            let json_dict = JSON.parse(json_str);
            user_study.load_progress(json_dict);
        }
    }
    input.click();

});
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
    resize_select(robot_id_e, g_robots_per_env);
    resize_select(ver_e, user_study.updates_per_robot + 1);

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
    user_id_e.innerHTML = user_study.user_id;
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
        canvas.mark_body(canvas.current_selected_obj, false);
        canvas.current_selected_obj = robot.leg(parseInt(leg_id_e.value)).link(parseInt(link_id_e.value)).obj;
        canvas.mark_body(canvas.current_selected_obj, true);
    }
}

// TODO: for some reason this function cannot be part of the canvas manager class
// otherwise the self call won't work
function animate() {
    window.requestAnimationFrame(animate);
    canvas.renderer.render(canvas.scene, canvas.camera);
    canvas.controls.update();
}

function export_robot() {
    robot.compile_dv();
    console.log(robot.dv);
    alert(robot.dv);
}

function clamp(raw, min, max) {
    return Math.min(Math.max(raw, min), max);
}

// range = [min, max]
function clamp(raw, range) {
    return Math.min(Math.max(raw, range[0]), range[1]);
}

function twodigit_str(n) {
    return n > 9 ? "" + n : "0" + n;
}

////////////////////////////////////////////////////////////////////////
//                           Main Function                            //
////////////////////////////////////////////////////////////////////////

let robot = new RobotRepresentation();
let mesh_lib = new MeshLibrary();
let user_study = new UserStudyManager();
let canvas = new CanvasManager();

init_panel();
animate(); // starts the animation
