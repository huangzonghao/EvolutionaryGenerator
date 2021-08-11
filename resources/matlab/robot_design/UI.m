function UI(evogen_params_path, evogen_exe_path, evogen_tmp_parts_dir, result_output_dir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                             UI Layout                             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Main Figure
main_fig.ui_title = 'EvoGen';
main_fig.canvas_size = [1000, 720];
main_fig.init_pos = [10, 10];
main_fig.fig = ui_make_figure(main_fig);

%% Panels
% position definition: [leftbottom_x, leftbottom_y, width, height]
robot_panel.title = 'Robot';
robot_panel.position = [0.25, 0, 0.75, 1];
robot_panel.panel = ui_make_panel(robot_panel);

robot_config_panel.title = 'NumLegs';
robot_config_panel.position = [0, 0.9, 0.25, 0.1];
robot_config_panel.panel = ui_make_panel(robot_config_panel);

leg_config_panel.title = 'Leg Config';
leg_config_panel.position = [0, 0, 0.25, 0.8];
leg_config_panel.panel = ui_make_panel(leg_config_panel);

body_config_panel.title = 'Body Config';
body_config_panel.position = [0, 0.8, 0.25, 0.1];
body_config_panel.panel = ui_make_panel(body_config_panel);

%% Axes
robot_ax.parent = robot_panel;
robot_ax.tag = robot_panel.title;
robot_ax.position = [0.05, 0.05, 0.7, 0.9];
robot_ax.ax = ui_make_axes(robot_ax);

%% Dropdown Menus and Labels
% body id
% TODO: read from library directly
bodyid_lb.parent_panel = body_config_panel.panel;
bodyid_lb.position = [0.05, 0.5, 0.40, 0.4];
bodyid_lb.text = 'Body ID';
bodyid_lb.lb = ui_make_label(bodyid_lb);

bodyid_dd.parent_panel = body_config_panel.panel;
bodyid_dd.position = [0.45, 0.5, 0.4, 0.4];
bodyid_dd.items = {'1', '2', '3', '4', '5'};
bodyid_dd.itemsdata = [1, 2, 3, 4, 5];
bodyid_dd.value = 1;
bodyid_dd.valuechange_callback = @bodyid_dd_callback;
bodyid_dd.dd = ui_make_dropdown(bodyid_dd);

% num of legs
numleg_dd.parent_panel = robot_config_panel.panel;
numleg_dd.position = [0.05, 0.05, 0.9, 0.8];
numleg_dd.items = {'4', '6'};
numleg_dd.itemsdata = [4, 6];
numleg_dd.value = 4;
numleg_dd.valuechange_callback = @numleg_dd_callback;
numleg_dd.dd = ui_make_dropdown(numleg_dd);

% leg id
legid_lb.parent_panel = leg_config_panel.panel;
legid_lb.position = [0.05, 0.95, 0.20, 0.05];
legid_lb.text = 'Leg ID';
legid_lb.lb = ui_make_label(legid_lb);

legid_dd.parent_panel = leg_config_panel.panel;
legid_dd.position = [0.25, 0.95, 0.25, 0.05];
legid_dd.valuechange_callback = @legid_dd_callback;
legid_dd.dd = ui_make_dropdown(legid_dd);

% num of links
numlink_lb.parent_panel = leg_config_panel.panel;
numlink_lb.position = [0.55, 0.95, 0.20, 0.05];
numlink_lb.text = '# Links';
numlink_lb.lb = ui_make_label(numlink_lb);

numlink_dd.parent_panel = leg_config_panel.panel;
numlink_dd.position = [0.75, 0.95, 0.25, 0.05];
numlink_dd.items = {'1', '2', '3'};
numlink_dd.itemsdata = [1, 2, 3];
numlink_dd.value = 1;
numlink_dd.valuechange_callback = @numlink_dd_callback;
numlink_dd.dd = ui_make_dropdown(numlink_dd);

% link id
linkid_lb.parent_panel = leg_config_panel.panel;
linkid_lb.position = [0.05, 0.9, 0.20, 0.05];
linkid_lb.text = 'Link ID';
linkid_lb.lb = ui_make_label(linkid_lb);

linkid_dd.parent_panel = leg_config_panel.panel;
linkid_dd.position = [0.25, 0.9, 0.25, 0.05];
linkid_dd.valuechange_callback = @linkid_dd_callback;
linkid_dd.dd = ui_make_dropdown(linkid_dd);

% component id
component_lb.parent_panel = leg_config_panel.panel;
component_lb.position = [0.55, 0.9, 0.20, 0.05];
component_lb.text = 'Part ID';
component_lb.lb = ui_make_label(component_lb);

component_dd.parent_panel = leg_config_panel.panel;
component_dd.position = [0.75, 0.9, 0.25, 0.05];
component_dd.items = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'};
component_dd.itemsdata = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
component_dd.valuechange_callback = @component_dd_callback;
component_dd.dd = ui_make_dropdown(component_dd);

% link length
linklengeth_lb.parent_panel = leg_config_panel.panel;
linklengeth_lb.position = [0.05, 0.85, 0.4, 0.05];
linklengeth_lb.text = 'Link Scale';
linklengeth_lb.lb = ui_make_label(linklengeth_lb);

linklengeth_fd.parent_panel = leg_config_panel.panel;
linklengeth_fd.position = [0.45, 0.85, 0.25, 0.05];
linklengeth_fd.valuechange_callback = @linklength_fd_callback;
linklengeth_fd.fd = ui_make_field(linklengeth_fd);

% % body length
legpos_lb.parent_panel = leg_config_panel.panel;
legpos_lb.position = [0.05, 0.8, 0.4, 0.05];
legpos_lb.text = 'Leg Position';
legpos_lb.lb = ui_make_label(legpos_lb);

legpos_fd.parent_panel = leg_config_panel.panel;
legpos_fd.position = [0.45, 0.8, 0.25, 0.05];
legpos_fd.lb = ui_make_label(legpos_fd);

%% Buttons
% write button
write_btn.parent_panel = leg_config_panel.panel;
write_btn.position = [0.25, 0.1, 0.5, 0.05];
write_btn.label = 'Write';
write_btn.push_callback = @write_btn_callback;
write_btn.btn = ui_make_button(write_btn);

% test button
test_btn.parent_panel = leg_config_panel.panel;
test_btn.position = [0.25, 0.05, 0.5, 0.05];
test_btn.label = 'Test Run';
test_btn.push_callback = @test_btn_callback;
test_btn.btn = ui_make_button(test_btn);

simulator_basename = 'Genotype_Visualizer';
if (ispc)
    simulator_name = strcat(simulator_basename, '.exe');
else
    simulator_name = simulator_basename;
end
simulator_exe = fullfile(evogen_exe_path, simulator_name);
simulator_param = fullfile(evogen_params_path, "sim_params.xml");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                          Data Containers                          %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mouse data
mousedata.position      = [0 0];
mousedata.position_last = [0 0];
mousedata.pressed       = false;
mousedata.mouse_button  = '';

% parts library
parts_lib.bodies.names = [
    "BodyBasic",
    "BodyCylinder",
    "BodyHex",
    "BodyShoe",
    "BodyTrain"
]';
parts_lib.legs.names = [
    "BeamBasic",
    "BeamConcave",
    "BeamHeart",
    "BeamHex",
    "BeamRhex",
    "BeamSlanted",
    "BeamStar",
    "BeamTriangle",
    "SingleBeam",
    "DoubleBeam",
    "TripleBeam"
]';

%% Robot Representation
robot.name = 'Robogami_Temp';
robot.body_dv = [1, 0.6, 0.4, 0.05]; % [body_id, length_x, length_y, length_z]
% Leg order: FL FR ML MR BL BR
robot.num_legs = 4;
robot.leg_dv = ones(6,8); % [leg_pos, num_links, link_1_id, link_1_scale, ... , link_6_id, link_6_scale]
robot_phen = '';

% data
env_mesh = '';

robotLinks = struct('mesh', {}, 'origin', {}, 'childjoints', {}, 'text', {});
robotJoints = struct('parent', {}, 'child', {}, 'origin', {}, 'rpy', {},  'axis', {}, 'text', {});

selected = struct('type', 'none', 'id', [], 'handle', []);

fixed_pos = [0.01, 0.25, 0.49];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                          Start Function                           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% update drawings
% redrawEnv;
load_robogami_library;
% display_mesh(parts_lib.bodies.meshes(1));
init_leg_dv;
update_dropdowns;
draw_robot;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                           Subfunctions                            %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%
%% Callbacks %%
%%%%%%%%%%%%%%%

function bodyid_dd_callback(src, event)
    robot.body_dv(1) = bodyid_dd.dd.Value;
    display_mesh(parts_lib.bodies.meshes(bodyid_dd.dd.Value));
    % update_dropdowns;
    draw_robot;
end

function numleg_dd_callback(src, event)
    robot.num_legs = numleg_dd.dd.Value;
    update_dropdowns;
    draw_robot;
end

function legid_dd_callback(src, event)
    update_dropdowns;
end

function numlink_dd_callback(src, event)
    robot.leg_dv(legid_dd.dd.Value, 2) = numlink_dd.dd.Value;
    update_dropdowns;
    draw_robot;
end

function linkid_dd_callback(src, event)
    update_dropdowns;
end

function component_dd_callback(src, event)
    robot.leg_dv(legid_dd.dd.Value, 3 + 2 * (linkid_dd.dd.Value - 1)) = component_dd.dd.Value;
    update_dropdowns;
    draw_robot;
end

function linklength_fd_callback(src, event)
    tmp_linklen = str2double(linklengeth_fd.fd.Value);
    tmp_linklen = max(0.5, min(1.5, tmp_linklen));
    robot.leg_dv(legid_dd.dd.Value, 3 + 2 * (linkid_dd.dd.Value - 1) + 1) = tmp_linklen;
    linklengeth_fd.fd.Value = num2str(tmp_linklen);
    draw_robot;
end

function write_btn_callback(~,~)
    convert_gen;
end

function test_btn_callback(~,~)
    convert_phen;
    cmd_str = fullfile(evogen_exe_path, simulator_name) + " mesh " + simulator_param + " " + num2str(robot_phen);
    system(cmd_str);
end

%%%%%%%%%%%%
%% Others %%
%%%%%%%%%%%%

function init_leg_dv
    % default robot: 4 legs with 1 link per leg
    % Leg order: FL FR BL BR ML MR - this is a little different to evogen, need to be adjusted
    % leg_dv [leg_pos, num_links, link_1_id, link_1_scale, ... , link_6_id, link_6_scale]
    robot.num_legs = 4;
    robot.leg_dv(1, 1) = fixed_pos(1);
    % robot.leg_dv(1, 2) = 1;
    % robot.leg_dv(1, 3) = 1;
    % robot.leg_dv(1, 4) = 1;
    % robot.leg_dv(1, 5) = 1;
    % robot.leg_dv(1, 6) = 1;
    % robot.leg_dv(1, 7) = 1;
    % robot.leg_dv(1, 8) = 1;

    robot.leg_dv(3, 1) = fixed_pos(3);
    % robot.leg_dv(3, 2) = 1;
    % robot.leg_dv(3, 3) = 1;
    % robot.leg_dv(3, 4) = 1;
    % robot.leg_dv(3, 5) = 1;
    % robot.leg_dv(3, 6) = 1;
    % robot.leg_dv(3, 7) = 1;
    % robot.leg_dv(3, 8) = 1;

    % pre-init unused legs
    robot.leg_dv(5, 1) = fixed_pos(2);
    % robot.leg_dv(5, 2) = 1;
    % robot.leg_dv(5, 3) = 1;
    % robot.leg_dv(5, 4) = 1;
    % robot.leg_dv(5, 5) = 1;
    % robot.leg_dv(5, 6) = 1;
    % robot.leg_dv(5, 7) = 1;
    % robot.leg_dv(5, 8) = 1;

    % mirror the legs
    robot.leg_dv(2, :) = robot.leg_dv(1, :);
    robot.leg_dv(2, 1) = 1 - robot.leg_dv(1, 1);
    robot.leg_dv(4, :) = robot.leg_dv(3, :);
    robot.leg_dv(4, 1) = 1 - robot.leg_dv(3, 1);
    robot.leg_dv(6, :) = robot.leg_dv(5, :);
    robot.leg_dv(6, 1) = 1 - robot.leg_dv(5, 1);
end

function update_dropdowns
    % TODO finish this function
    if numleg_dd.dd.Value ~= robot.num_legs
        numleg_dd.dd.Value = robot.num_legs;
    end

    % leg id
    items = {};
    itemsdata = [];
    for i = 1 : robot.num_legs
        items{end + 1} = num2str(i);
        itemsdata = [itemsdata, i];
    end
    legid_dd.dd.Items = items;
    legid_dd.dd.ItemsData = itemsdata;

    legid = legid_dd.dd.Value;
    if legid < 1 || legid > robot.num_legs
        legid = 1;
        legid_dd.dd.Value = 1;
    end

    % num link
    num_links = robot.leg_dv(legid,2);
    numlink_dd.dd.Value = num_links;

    % link id
    items = {};
    itemsdata = [];
    for i = 1 : num_links
        items{end + 1} = num2str(i);
        itemsdata = [itemsdata, i];
    end
    linkid_dd.dd.Items = items;
    linkid_dd.dd.ItemsData = itemsdata;

    linkid = linkid_dd.dd.Value;
    if linkid < 1 || linkid > num_links
        linkid = 1;
        linkid_dd.dd.Value = 1;
    end

    % component id
    component_dd.dd.Value = robot.leg_dv(legid, 3 + 2 * (linkid - 1));

    % link length
    linklengeth_fd.fd.Value = num2str(robot.leg_dv(legid, 3 + 2 * (linkid - 1) + 1));

    % leg pos
    legpos_fd.lb.Text = num2str(robot.leg_dv(legid, 1));
end

function display_mesh(obj)
    env_mesh = triangulation(obj.f.v, obj.v);
    cla(robot_ax.ax)
    trisurf(env_mesh, 'Parent', robot_ax.ax, ...
            'FaceColor', [.8, .8, .8], 'EdgeColor', 'none', ...
            'SpecularStrength', .5, 'AmbientStrength', .5);
    updateCamera(robot_ax.ax)
    updateLight(robot_ax.ax);
end

function load_robogami_library
    disp('Loading Robogami Library');
    parts_lib.bodies.meshes = [];
    parts_lib.legs.meshes = [];
    for i = 1 : parts_lib.bodies.names.size(2)
        parts_lib.bodies.meshes = [parts_lib.bodies.meshes, readObj(fullfile(evogen_tmp_parts_dir, 'bodies', strcat(num2str(i - 1), '.obj')))];
    end
    for i = 1 : parts_lib.legs.names.size(2)
        parts_lib.legs.meshes = [parts_lib.legs.meshes, readObj(fullfile(evogen_tmp_parts_dir, 'legs', strcat(num2str(i - 1), '.obj')))];
    end
end

function mousedata_update(~, ~)
    mousedata.pressed      = true;
    mousedata.mouse_button = get(main_fig.fig, 'SelectionType');
    mousedata.position     = get(0, 'PointerLocation');
    switch (mousedata.mouse_button)
        case 'alt'    % right click
            mousedata.mouse_button = 'rotate';
            main_fig.fig.Pointer = 'circle';
        case 'normal' % left click
            main_fig.fig.Pointer = 'arrow';
    end
end

%% DRAWING ROBOT
% convert the design_vector representation to robot_assembly
function compile_robot
    body_default_scale = ones(1, 3) * 0.01;
    link_default_scale = ones(1, 3) * 0.01;
    % robotLinks = struct('mesh', {}, 'origin', {}, 'childjoints', {}, 'text', {});
    % robotJoints = struct('parent', {}, 'child', {}, 'origin', {}, 'rpy', {},  'axis', {}, 'text', {});
    % what I need to do is to fill the above three vectors as loadURDF

    robotLinks(1).origin = zeros(1, 3);
    obj_tmp = parts_lib.bodies.meshes(robot.body_dv(1));
    mesh_tmp = triangulation(obj_tmp.f.v, obj_tmp.v);
    robotLinks(1).mesh = triangulation(mesh_tmp.ConnectivityList, bsxfun(@times, mesh_tmp.Points, body_default_scale));

    joint_counter = 1;
    link_counter = 2;
    for leg_idx = 1 : robot.num_legs
        % first link of each leg
        robotLinks(link_counter).origin = zeros(1, 3);
        obj_tmp = parts_lib.legs.meshes(robot.leg_dv(leg_idx, 3));
        mesh_tmp = triangulation(obj_tmp.f.v, obj_tmp.v);
        link_scale = link_default_scale * robot.leg_dv(leg_idx, 4);
        robotLinks(link_counter).mesh = triangulation(mesh_tmp.ConnectivityList, bsxfun(@times, mesh_tmp.Points, link_scale));

        robotJoints(joint_counter).parent = 1;
        robotJoints(joint_counter).child = link_counter;
        leg_pos_tmp = robot.leg_dv(leg_idx, 1);
        chassis_x = 2;
        chassis_y = 1.8;
        if leg_pos_tmp < 0.5
            leg_pos_x_tmp = (0.25 - leg_pos_tmp) * 4 * (chassis_x);
            leg_pos_y_tmp = chassis_y + 0.05;
        else
            leg_pos_x_tmp = (leg_pos_tmp - 0.75) * 4 * (chassis_x);
            leg_pos_y_tmp = -(chassis_y + 0.05);
        end
        robotJoints(joint_counter).origin = [leg_pos_x_tmp, leg_pos_y_tmp, 0];
        robotJoints(joint_counter).rpy = zeros(1, 3);
        robotJoints(joint_counter).axis = [0, 1, 0];

        robotLinks(1).childjoints(end + 1) = joint_counter;
        joint_counter = joint_counter + 1;
        link_counter = link_counter + 1;

        % additional links
        for link_idx = 2 : robot.leg_dv(leg_idx, 2)
            robotLinks(link_counter).origin = zeros(1, 3);
            obj_tmp = parts_lib.legs.meshes(robot.leg_dv(leg_idx, 3 + 2 * (link_idx - 2) + 1));
            mesh_tmp = triangulation(obj_tmp.f.v, obj_tmp.v);
            link_scale = link_default_scale * robot.leg_dv(leg_idx, 4 + 2 * (link_idx - 2) + 1);
            robotLinks(link_counter).mesh = triangulation(mesh_tmp.ConnectivityList, bsxfun(@times, mesh_tmp.Points, link_scale));
            robotJoints(joint_counter).parent = link_counter - 1;
            robotJoints(joint_counter).child = link_counter;
            robotJoints(joint_counter).origin = [leg_pos_x_tmp, leg_pos_y_tmp, -1.05 * (link_idx - 1)]; % TODO: how to get the mesh length
            robotJoints(joint_counter).rpy = zeros(1, 3);
            robotJoints(joint_counter).axis = [0, 1, 0];

            joint_counter = joint_counter + 1;
            link_counter = link_counter + 1;
        end
    end

end

function draw_robot
    compile_robot;
    cla(robot_ax.ax);
    if ~isempty(robotLinks)
        link_queue = [1; 0]; % assume link 1 is the root
        while ~isempty(link_queue)
            i = link_queue(:, 1);
            link_queue(:, 1) = [];

            % transform mesh according to joint
            mesh = robotLinks(i(1)).mesh;
            pts = mesh.Points;
            if i(2)>0
                % FIXME: won't work with tree depth > 1
                o = robotJoints(i(2)).origin;
                rpy = robotJoints(i(2)).rpy;
                rotm = eul2rotm(rpy, 'XYZ');

                % draw link
                pts = (rotm * pts')';
                pts = bsxfun(@plus, pts, o + robotLinks(i(1)).origin);
                mesh = triangulation(mesh.ConnectivityList, pts);

                % draw joint
                a = robotJoints(i(2)).axis;
                a = (rotm * a')';
                plot3([o(1) + .25 * a(1) o(1) - .25 * a(1)], [o(2) + .25 * a(2) o(2) - .25 * a(2)], [o(3) + .25 * a(3) o(3) - .25 * a(3)], ...
                        '-', 'Color', [0, 0, .5], 'LineWidth', 3, 'Parent', robot_ax.ax);
            end

            % draw link
            [edges, grp_assign] = reduceEdges(mesh, pi / 8);
            for igroup = unique(grp_assign(:)')
                patch('Faces', mesh.ConnectivityList(grp_assign==igroup, :), ...
                      'Vertices', mesh.Points, ...
                      'Parent', robot_ax.ax, ...
                      'FaceColor', [0.8, 0.8, 0.8], ...
                      'EdgeColor', 'none', ...
                      'SpecularStrength', .5, 'AmbientStrength', .5);
            end
            robotLinks(i(1)).face_groups = grp_assign;

            % get children
            childjoints = robotLinks(i(1)).childjoints;
            children    = [robotJoints(childjoints).child];
            link_queue(:, end + 1:end + length(childjoints)) = [children; childjoints];
        end
    end
    updateCamera(robot_ax.ax);
    updateLight(robot_ax.ax);
end

%% GENERAL DRAWING
% centralize camera
function updateCamera(ax)
    xlim = get(ax, 'xlim');
    ylim = get(ax, 'ylim');
    zlim = get(ax, 'zlim');
    view(ax, 127.5, 30);
    ax.CameraTarget = [(xlim(1) + xlim(2)) / 2, (ylim(1) + ylim(2)) / 2, (zlim(1) + zlim(2)) / 2];
end

% update light location so that it is always behind the camera
function updateLight(ax)
    % if ~exist('ax', 'var')
        % ax = gca;
    % end
    c = ax.Children;
    for i = 1:length(c)
        if isa(c(i), 'matlab.graphics.primitive.Light')
            delete(c(i));
        end
    end
    camlight(ax);
end

function convert_phen
    % phen format: [body_id, body_x, body_y, body_z, num_legs, leg_1, leg_2, ...]
    %     for each leg: [leg_pos, num_links, link_1_id, link_1_scale]
    robot_phen = [];
    robot_phen(1) = robot.body_dv(1) - 1;
    robot_phen(2:4) = robot.body_dv(2:4);
    robot_phen(5) = robot.num_legs;
    % note leg 5, 6 are the middle legs which need to show up in the middle
    if robot.num_legs == 4
        leg_orders = [1, 2, 3, 4];
    else % num_legs == 6
        leg_orders = [1, 2, 5, 6, 3, 4];
    end

    for i = 1 : length(leg_orders)
        leg_id = leg_orders(i);
        robot_phen(end + 1 : end + 2) = robot.leg_dv(leg_id, 1 : 2);
        num_links = robot.leg_dv(leg_id, 2);
        for j = 1 : num_links
            robot_phen(end + 1) = robot.leg_dv(leg_id, 2 + 2 * (j - 1) + 1) - 1; % part id
            robot_phen(end + 1) = robot.leg_dv(leg_id, 2 + 2 * (j - 1) + 2);
        end
    end
end

function convert_gen
    % dv format: [body_x, body_y, body_z, num_legs, leg_1, leg_2, ...]
    %     for each leg: [num_links, link_1_id, link_1_scale, ...]
    % Note: num_legs here corresponds to one side only
    design_vector = [];
    design_vector(1:4) = robot.body_dv(1:4);
    design_vector(5) = robot.num_legs;
    % only exporting leg 1, 3, 5
    % note leg 5 is the middle leg
    if robot.num_legs == 4
        for i = 1 : robot.num_legs / 2
            num_links = robot.leg_dv(2 * (i - 1) + 1, 2);
            design_vector = [design_vector, robot.leg_dv(2 * (i - 1) + 1, 2 : 2 + 2 * num_links)];
        end
    else % num_legs == 6
        % TODO: dirty here
        i = 1;
        num_links = robot.leg_dv(2 * (i - 1) + 1, 2);
        design_vector = [design_vector, robot.leg_dv(2 * (i - 1) + 1, 2 : 2 + 2 * num_links)];
        i = 5;
        num_links = robot.leg_dv(2 * (i - 1) + 1, 2);
        design_vector = [design_vector, robot.leg_dv(2 * (i - 1) + 1, 2 : 2 + 2 * num_links)];
        i = 3;
        num_links = robot.leg_dv(2 * (i - 1) + 1, 2);
        design_vector = [design_vector, robot.leg_dv(2 * (i - 1) + 1, 2 : 2 + 2 * num_links)];
    end
    design_vector
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                          Infrastructure                           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% FIGURE SETUP
function fig = ui_make_figure(fig_config)
    old_fig = findall(0, 'Type', 'figure', 'Name', fig_config.ui_title);
    if size(old_fig, 1) > 0
        disp(strcat("Previous ", main_fig.ui_title, ' instance detected, closing it'));
        close(old_fig);
    end
    fig = uifigure('NumberTitle', 'off', ...
                   'Name', fig_config.ui_title, ...
                   'Position', [fig_config.init_pos, fig_config.init_pos + fig_config.canvas_size], ...
                   'MenuBar', 'none', 'Toolbar', 'none', ...
                   'WindowButtonMotionFcn', @mainFigureWindowButtonMoveCallback, ...
                   'WindowButtonUpFcn', @mainFigureWindowButtonUpCallback, ...
                   'WindowButtonDownFcn', @mousedata_update, ...
                   'DeleteFcn', @mainFigureQuitCallback);
end

% panel_config: a dictionary containing name and layout of panel
function panel = ui_make_panel(panel_config)
    panel = uipanel(main_fig.fig, 'Units', 'Normalized', 'Position', panel_config.position, ...
                    'Title', panel_config.title, 'FontSize', 12, 'BackgroundColor', [1 1 1]);
end

function ax = ui_make_axes(ax_config)
    % add axes to a panel
    ax = axes(ax_config.parent.panel, 'Tag', ax_config.tag, 'FontSize', 10, ...
              'Units', 'Normalized', 'Position', ax_config.position, ...
              'XColor', 'none', 'YColor', 'none', 'ZColor', 'none');

    % update axes: square, 3d rotate on, camera light
    axis(ax, 'equal');
    axis(ax, 'tight');
    view(ax, 3);
    set(ax, 'NextPlot', 'add');
    updateLight(ax);
end

function dd = ui_make_dropdown(dd_config)
    p_width = dd_config.parent_panel.InnerPosition(3) * main_fig.canvas_size(1); % parent width
    p_height = dd_config.parent_panel.InnerPosition(4) * main_fig.canvas_size(2); % parent height
    dd = uidropdown(dd_config.parent_panel, ...
                    'Position', [dd_config.position(1) * p_width, dd_config.position(2) * p_height, dd_config.position(3) * p_width, dd_config.position(4) * p_height]);
    if isfield(dd_config, 'items')
        dd.Items = dd_config.items;
    end
    if isfield(dd_config, 'itemsdata')
        dd.ItemsData = dd_config.itemsdata;
    end
    if isfield(dd_config, 'value')
        dd.Value = dd_config.value;
    end
    if isfield(dd_config, 'valuechange_callback')
        dd.ValueChangedFcn = dd_config.valuechange_callback;
    end
end

function lb = ui_make_label(lb_config)
    p_width = lb_config.parent_panel.InnerPosition(3) * main_fig.canvas_size(1); % parent width
    p_height = lb_config.parent_panel.InnerPosition(4) * main_fig.canvas_size(2); % parent height
    lb = uilabel(lb_config.parent_panel, ...
                 'Position', [lb_config.position(1) * p_width, lb_config.position(2) * p_height, lb_config.position(3) * p_width, lb_config.position(4) * p_height]);
    if isfield(lb_config, 'text')
        lb.Text = lb_config.text;
    end
end

function fd = ui_make_field(fd_config)
    p_width = fd_config.parent_panel.InnerPosition(3) * main_fig.canvas_size(1); % parent width
    p_height = fd_config.parent_panel.InnerPosition(4) * main_fig.canvas_size(2); % parent height
    fd = uieditfield(fd_config.parent_panel, ...
                     'Position', [fd_config.position(1) * p_width, fd_config.position(2) * p_height, fd_config.position(3) * p_width, fd_config.position(4) * p_height]);
    if isfield(fd_config, 'value')
        fd.Value = fd_config.value;
    end
    if isfield(fd_config, 'valuechange_callback')
        fd.ValueChangedFcn = fd_config.valuechange_callback;
    end
end

function btn = ui_make_button(btn_config)
    p_width = btn_config.parent_panel.InnerPosition(3) * main_fig.canvas_size(1); % parent width
    p_height = btn_config.parent_panel.InnerPosition(4) * main_fig.canvas_size(2); % parent height
    btn = uibutton(btn_config.parent_panel, ...
                   'Position', [btn_config.position(1) * p_width, btn_config.position(2) * p_height, btn_config.position(3) * p_width, btn_config.position(4) * p_height], ...
                   'Text', btn_config.label);
    if isfield(btn_config, 'push_callback')
        btn.ButtonPushedFcn = btn_config.push_callback;
    end
end

%% Callbacks
% Determine the rotation matrix (View matrix) for rotation angles xyz ...
function R = rotationMatrix(r)
    Rx = [1 0 0; 0 cosd(r(1)) -sind(r(1)); 0 sind(r(1)) cosd(r(1))];
    Ry = [cosd(r(2)) 0 sind(r(2)); 0 1 0; -sind(r(2)) 0 cosd(r(2))];
    Rz = [cosd(r(3)) -sind(r(3)) 0; sind(r(3)) cosd(r(3)) 0; 0 0 1];
    R  = Rx * Ry * Rz;
end

function mainFigureWindowButtonMoveCallback(~, ~)
    mousedata.position_last = mousedata.position;
    mousedata.position = get(0, 'PointerLocation');
    if mousedata.pressed
        dp = mousedata.position_last - mousedata.position;
        switch mousedata.mouse_button
            case 'rotate'
                UpVector  = get(robot_ax.ax, 'CameraUpVector');
                XYZ       = get(robot_ax.ax, 'CameraPosition');
                Camtar    = get(robot_ax.ax, 'CameraTarget');
                Forward   = (Camtar - XYZ) / norm(Camtar - XYZ);
                ViewAngle = get(robot_ax.ax, 'CameraViewAngle');

                Mview     = [UpVector; Forward; cross(UpVector, Forward)];
                R         = rotationMatrix([dp(1) 0 dp(2)]);
                Mview     = R' * Mview;

                UpVector  = Mview(1, 1:3);
                XYZ       = Camtar - norm(Camtar - XYZ) * Mview(2, 1:3);

                set(robot_ax.ax, 'CameraUpVector', UpVector);
                set(robot_ax.ax, 'CameraPosition', XYZ);
                set(robot_ax.ax, 'CameraTarget', Camtar);
                set(robot_ax.ax, 'CameraViewAngle', ViewAngle);
            case 'normal'
        end
    end
end

function mainFigureWindowButtonUpCallback(~, ~)
    mousedata.pressed = false;
    main_fig.fig.Pointer = 'arrow';
    mousedata.mouse_button = '';
end

function mainFigureQuitCallback(~, ~)
    disp(strcat(main_fig.ui_title, ' Exited'))
end

end % main ui function
