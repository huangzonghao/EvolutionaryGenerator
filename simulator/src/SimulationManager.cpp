#include <chrono>
#include <filesystem>
#include <chrono/core/ChRealtimeStep.h>
#include <chrono/physics/ChBodyEasy.h>
#include <chrono_irrlicht/ChIrrApp.h>
#include <chrono_vehicle/terrain/RigidTerrain.h>
// #include <chrono_opengl/ChOpenGLWindow.h>

#include "SimulationManager.h"
#include "ChUrdfDoc.h"
#include "ChIrrEvoGenCamera.h"
// #include "ChRobogami.h"

using namespace chrono;

SimulationManager::SimulationManager(double step_size,
                                     double timeout,
                                     double system_friction_k,
                                     double system_friction_s,
                                     SystemType system_type)
    : step_size_(step_size), timeout_(timeout), k_friction_(system_friction_k),
    s_friction_(system_friction_s), system_type_(system_type)
{
    payloads_.clear();
    motors_.clear();
    ch_waypoints_.clear();
    SetChronoDataPath(CHRONO_DATA_DIR);
    auxrefs_ = std::make_shared<std::unordered_set<std::string>>();
}

void SimulationManager::LoadUrdfFile(const std::string& filename){
    robot_doc_ = std::make_shared<ChUrdfDoc>(filename);
}

void SimulationManager::LoadUrdfString(const std::string& urdfstring){
    robot_doc_ = std::make_shared<ChUrdfDoc>(urdfstring, true);
}

// void SimulationManager::LoadRobogamiProtoFile(const std::string& filename) {
    // robot_doc_ = std::make_shared<ChRobogami>(filename);
// }

// void SimulationManager::LoadRobogamiRobot() {
    // robot_doc_ = std::make_shared<ChRobogami>();
// }

void SimulationManager::SetEnv(const std::string& filename, double env_x, double env_y, double env_z){
    env_file_ = filename;
    env_x_ = env_x;
    env_y_ = env_y;
    env_z_ = env_z;
    load_map_ = true;
}

void SimulationManager::SetEigenHeightmap(const std::shared_ptr<const Eigen::MatrixXd>& heightmap){
    heightmap_ = heightmap;
}

const std::string& SimulationManager::GetUrdfFileName(){
    if(!robot_doc_){
        std::cerr << "Error: URDF file not set yet, call LoadUrdfFile() first" << std::endl;
        exit(EXIT_FAILURE);
    }
    return robot_doc_->GetRobotFileName();
}

void SimulationManager::AddComponent(const std::string& type_name, const std::string& body_name,
                                     double mass, double size_x, double size_y, double size_z,
                                     double pos_x, double pos_y, double pos_z){

    payloads_.push_back(std::make_shared<SimPayload>(type_name, body_name, mass,
                                                     size_x, size_y, size_z,
                                                     pos_x, pos_y, pos_z));
    auxrefs_->insert(body_name);
}

void SimulationManager::AddMotor(const std::string& type_name, const std::string& body_name,
                                 const std::string& link_name, double mass,
                                 double size_x, double size_y, double size_z,
                                 double pos_x, double pos_y, double pos_z) {

    motors_.push_back(std::make_shared<SimMotor>(type_name, body_name, link_name,
                                                 mass, size_x, size_y, size_z,
                                                 pos_x, pos_y, pos_z));
    auxrefs_->insert(body_name);
}

void SimulationManager::AddEvoGenMotor(const std::string& link_name,
                                       size_t leg_id, size_t link_id){
    // Use light motor in EvoGen
    auto motor_tmp = std::make_shared<SimMotor>(link_name);
    motors_.push_back(motor_tmp);
    if (leg_id >= leg_motors_.size())
        leg_motors_.resize(leg_id + 1);
    if (link_id >= leg_motors_[leg_id].size())
        leg_motors_[leg_id].resize(link_id + 1);
    leg_motors_[leg_id][link_id] = motor_tmp;
}

void SimulationManager::RemoveLastMotor(){
    if (!motors_.empty())
        motors_.pop_back();
    // TODO: also need to check & remove useless entries in auxrefs_
}

void SimulationManager::RemoveAllMotors(){
    motors_.clear();
    leg_motors_.clear();
    // TODO: also need to check & remove useless entries in auxrefs_
}

void SimulationManager::AddWaypoint(double x, double y, double z){
    ch_waypoints_.push_back(chrono::ChVector<>(x,y,z));
}

void SimulationManager::AddWaypoints(const std::shared_ptr<const Eigen::MatrixXd>& waypoints_ptr){
    eigen_waypoints_ = waypoints_ptr;
    auto& waypoints_mat = *waypoints_ptr;
    if (waypoints_mat.rows() != 3){
        std::cerr << "Error: waypoint matrix passed to SimulationManager::AddWaypoints should be 3xN matrix" << std::endl;
        exit(EXIT_FAILURE);
    }
    for (int i = 0; i < waypoints_mat.cols(); ++i){
        AddWaypoint(waypoints_mat(0,i), waypoints_mat(1,i), waypoints_mat(2,i));
    }
}

void SimulationManager::SetCamera(std::vector<double> camera_pos) {
    if (camera_pos.size() != 6)
        return;

    SetCamera(camera_pos[0], camera_pos[1], camera_pos[2],
              camera_pos[3], camera_pos[4], camera_pos[5]);
}

void SimulationManager::SetCamera(double from_x, double from_y, double from_z,
                                  double to_x, double to_y, double to_z) {
    camera_pos_[0] = from_x;
    camera_pos_[1] = from_y;
    camera_pos_[2] = from_z;
    camera_pos_[3] = to_x;
    camera_pos_[4] = to_y;
    camera_pos_[5] = to_z;
}

void SimulationManager::SetLight(std::vector<double> light_pos) {
    if (light_pos.size() != 3)
        return;

    SetLight(light_pos[0], light_pos[1], light_pos[2]);
}

void SimulationManager::SetLight(double x, double y, double z) {
    light_pos_[0] = x;
    light_pos_[1] = y;
    light_pos_[2] = z;
}

void SimulationManager::SetFOV(double fov) {
    fov_ = fov;
}

void SimulationManager::SetRobotColor(std::vector<double> robot_color) {
    if (robot_color.size() != 3)
        return;

    robot_color_[0] = 1;
    robot_color_[1] = robot_color[0];
    robot_color_[2] = robot_color[1];
    robot_color_[3] = robot_color[2];
}

void SimulationManager::SetEnvColor(std::vector<double> env_color) {
    if (env_color.size() != 3)
        return;

    env_color_[0] = env_color[0];
    env_color_[1] = env_color[1];
    env_color_[2] = env_color[2];
}

void SimulationManager::RecordVideoFrames(int frame_interval, const std::string& output_name) {
    std::cout << "frame interval " << frame_interval << ", outputname  " << output_name << std::endl;
    if(frame_interval < 1) {
        save_video_frames_ = false;
        return;
    }

    save_video_frames_ = true;
    video_frame_interval_ = frame_interval;
    video_frame_output_name_ = output_name;
}

bool SimulationManager::RunSimulation() {
    if(!robot_doc_){
        std::cerr << "Error: No Robot loaded." << std::endl;
        exit(EXIT_FAILURE);
    }

    task_done_ = false;

    switch(system_type_){
    case NSC:
        ch_system_ = chrono_types::make_shared<ChSystemNSC>();
        break;
    case SMC:
        ch_system_ = chrono_types::make_shared<ChSystemSMC>();
        break;
    default:
        std::cerr << "Wrong system type: " << system_type_ << std::endl;
        exit(EXIT_FAILURE);
    }

    ch_system_->Set_G_acc(ChVector<>(0, 0, -9.81));
    ch_system_->SetSolverMaxIterations(20);  // the higher, the easier to keep the constraints satisifed.

    if (!auxrefs_->empty()) robot_doc_->SetAuxRef(auxrefs_);

    robot_self_collided_ = false;

    if (robot_color_[0])
        robot_doc_->SetRobotColor(robot_color_[1], robot_color_[2], robot_color_[3]);
    bool add_ok = false;
    if (!ch_waypoints_.empty())
        add_ok = robot_doc_->AddtoSystem(ch_system_, ch_waypoints_[0]);
    else
        add_ok = robot_doc_->AddtoSystem(ch_system_, ChVector<>(0,0,0));

    // check for robot's self collision
    ch_system_->ComputeCollisions();
    if (ch_system_->GetContactContainer()->GetNcontacts() > 0) {
        robot_self_collided_ = true;
        return false;
    }

    // Make sure env shows up under the robot
    double env_pos_z = 0;
    if (load_map_) {
        env_pos_z = load_map();
    }

    // add waypoint markers
    auto wp_color = chrono_types::make_shared<ChColorAsset>();
    wp_color->SetColor(ChColor(0.8f, 0.0f, 0.0f));
    if (!ch_waypoints_.empty()){
        // TODO: put first waypoint marker on the ground
        for(auto waypoint = ch_waypoints_.begin() + 1; waypoint != ch_waypoints_.end(); ++waypoint){
            auto wp_marker = chrono_types::make_shared<ChBodyEasyBox>(0.01, 0.01, 0.005, 1.0, true, false);
            wp_marker->SetPos(*waypoint);
            wp_marker->SetBodyFixed(true);
            wp_marker->AddAsset(wp_color);
            ch_system_->AddBody(wp_marker);
        }
    }

    // Add motors and extra weights to system
    for (const auto& payload : payloads_) payload->AddtoSystem(ch_system_);
    for (const auto& motor : motors_) motor->AddtoSystem(*robot_doc_);

    // Set up controller
    std::shared_ptr<RobotController> controller;
    if (controller_type_ == EvoGen) {
        controller = std::make_shared<EvoGenController>(&motors_);
        std::dynamic_pointer_cast<EvoGenController>(controller)->SetLegs(leg_motors_);
    } else if (controller_type_ == Wheel) {
        controller = std::make_shared<WheelController>(&motors_);
    } else if (controller_type_ == Dummy) {
        controller = std::make_shared<DummyController>();
    }

    const std::shared_ptr<ChBody>& camera_body = robot_doc_->GetCameraBody();

    std::chrono::steady_clock::time_point tik;
    std::chrono::steady_clock::time_point tok;

    // update fall down threshold
    fall_down_thresh = robot_doc_->GetMinPos().z() * 1.5 - 2;

    init_stats();
    if(do_viz_) {
        // // OpenGL Visualization Code
        // opengl::ChOpenGLWindow& gl_window = opengl::ChOpenGLWindow::getInstance();
        // gl_window.Initialize(1280, 720, "Inverted Pendulum", ch_system_.get());
        // gl_window.SetCamera(ChVector<>(camera_pos_[0], camera_pos_[1], camera_pos_[2]),
                            // ChVector<>(camera_pos_[3], camera_pos_[4], camera_pos_[5]), ChVector<>(0, 0, 1));
        // gl_window.SetRenderMode(opengl::WIREFRAME);
        // ChRealtimeStepTimer realtime_timer;

        // bool device_running = true;
        // while (ch_system_->GetChTime() < timeout_ && !task_done_ ) {
            // device_running = gl_window.Active(); // TODO: not sure what's the difference between Active() and Running()
            // if (early_termination_enabled_ && !device_running) {
                // std::cout << "User closed" << std::endl;
                // break;
            // }
            // if (gl_window.Running()) {
                // // Advance system and controller states
                // ch_system_->DoStepDynamics(step_size_);
                // task_done_ = controller->Update();
                // update_stats();

                // // Enforce soft real-time
                // if (do_realtime_) realtime_timer.Spin(step_size_);
                // if (check_termination()) {
                    // std::cout << "Simulation Cut: Early termination condition met"  << std::endl;
                    // break;
                // }
            // }

            // gl_window.Render();
        // }

        ChRealtimeStepTimer realtime_timer;
        using namespace chrono::irrlicht;
        using namespace irr::core;
        ChIrrApp vis_app(ch_system_.get(),
                         L"Evolutionary Algorithm Simulation",
                         dimension2d<irr::u32>(canvas_size_[0], canvas_size_[1]), false);

        auto device = vis_app.GetDevice();
        auto scene_mgr = device->getSceneManager();
        auto driver = device->getVideoDriver();

        // vis_app.AddTypicalLogo();
        // vis_app.AddTypicalSky();
        // Manually add a Z-up sky
        std::string mtexturedir = GetChronoDataFile("skybox/");
        std::string str_lf = mtexturedir + "sky_lf.jpg";
        std::string str_up = mtexturedir + "sky_up.jpg";
        std::string str_dn = mtexturedir + "sky_dn.jpg";
        irr::video::ITexture* map_skybox_side = driver->getTexture(str_lf.c_str());
        irr::scene::ISceneNode* skybox =
            scene_mgr->addSkyBoxSceneNode(driver->getTexture(str_up.c_str()),
                                          driver->getTexture(str_dn.c_str()),
                                          map_skybox_side, map_skybox_side,
                                          map_skybox_side, map_skybox_side);
        ChMatrix33<> A = ChMatrix33<>(Q_from_AngX(-CH_C_PI_2));
        auto sky_rot_angles = CH_C_RAD_TO_DEG * A.Get_A_Rxyz();
        skybox->setRotation(irr::core::vector3dfCH(sky_rot_angles));

        // vis_app.AddTypicalLights(vector3df(light_pos_[0], light_pos_[1], light_pos_[2]),
                                 // vector3df(light_pos_[3], light_pos_[4], light_pos_[5]));
        // Manually add a directional light
        irr::scene::ILightSceneNode* light = scene_mgr->addLightSceneNode(0); // Note: directional light doesn't care about position
        light->setLightType(irr::video::ELT_DIRECTIONAL);
        vector3df light_dir(light_pos_[0], light_pos_[1], light_pos_[2]);
        // std::cout << "Light direction: " << light_dir.X << ", " << light_dir.Y << ", " << light_dir.Z << std::endl;
        // auto rot_angles = light_dir.getHorizontalAngle();
        // std::cout << "Rotation angles: " << rot_angles.X << ", " << rot_angles.Y << ", " << rot_angles.Z << std::endl;
        light->setRotation(light_dir.getHorizontalAngle()); // for directional light, use the rotation from positive z to express its direction.

        // vis_app.AddTypicalCamera(vector3df(camera_pos_[0], camera_pos_[1], camera_pos_[2]),
                                 // vector3df(camera_pos_[3], camera_pos_[4], camera_pos_[5]));
        // Manually add camera here
        std::shared_ptr<EvoGenCamera> camera =
            std::make_shared<EvoGenCamera>(device, scene_mgr->getRootSceneNode(),
                                           scene_mgr, -1, -160.0f, 1.0f, 0.003f);
        camera->bindTargetAndRotation(false);
        camera->setUpVector(vector3df(0, 0, 1));
        camera->setPosition(vector3df(camera_pos_[0], camera_pos_[1], camera_pos_[2] + env_pos_z));
        camera->setTarget(vector3df(camera_pos_[3], camera_pos_[4], camera_pos_[5] + env_pos_z));
        camera->setFOV(fov_ * irr::core::DEGTORAD);
        camera->setNearValue(0.1f);
        camera->setMinZoom(0.6f);

        vis_app.AssetBindAll();
        vis_app.AssetUpdateAll();
        vis_app.SetTimestep(step_size_);

        tik = std::chrono::steady_clock::now();
        bool device_running = true;
        std::string video_frame_output_path;
        if (save_video_frames_) {
            video_frame_output_path = "video_capture/" + video_frame_output_name_;
            std::filesystem::create_directories(video_frame_output_path);
        }
        // while (ch_system_->GetChTime() < timeout_ && !task_done_ && vis_app.GetDevice()->run()) {
        while (ch_system_->GetChTime() < timeout_ && !task_done_ ) {
            device_running = vis_app.GetDevice()->run(); // this should have been checked as one of the
                                        // while loop conditions, but it starts to return
                                        // false since the second vis_app instance.
                                        // So I have to call it inside the loop and ignore
                                        // the return value in order to keep the UI interaction
            if (early_termination_enabled_ && !device_running) {
                std::cout << "User closed" << std::endl;
                break;
            }
            vis_app.BeginScene(true, true, irr::video::SColor(255, 140, 161, 192));
            // vis_app.GetSceneManager()->getActiveCamera()->setTarget(vector3dfCH(camera_body->GetPos()));
            vis_app.DrawAll();

            if (save_video_frames_) {
                if (video_frame_counter_ % video_frame_interval_ == 0 && video_frame_counter_ != 0) { // the first frame is always white
                    irr::video::IImage* image = driver->createScreenShot();
                    if (image) {
                        char filename[100];
                        sprintf(filename, "%s_%04d.png", video_frame_output_name_,  (video_frame_counter_ + 1) / video_frame_interval_);
                        driver->writeImageToFile(image, std::string(video_frame_output_path + "/" + filename).c_str());
                        image->drop();
                    }
                }
                video_frame_counter_++;
            }

            vis_app.DoStep();
            vis_app.EndScene();

            task_done_ = controller->Update();
            update_stats();

            if (do_realtime_) realtime_timer.Spin(step_size_);

            if (check_termination()) {
                std::cout << "Simulation Cut: Early termination condition met"  << std::endl;
                break;
            }
        }
        vis_app.GetDevice()->closeDevice(); // TODO: with this code is seems the irrlicht part didn't init the device status correctly
        tok = std::chrono::steady_clock::now();
    } else {
        tik = std::chrono::steady_clock::now();
        while(ch_system_->GetChTime() < timeout_ && !task_done_ && !check_termination()) {
            ch_system_->DoStepDynamics(step_size_);

            task_done_ = controller->Update();
            update_stats();
        }
        tok = std::chrono::steady_clock::now();
    }

    // TODO: potentially need to release some resources here

    last_sim_time_ = (tok - tik).count();
    return true;
}

void SimulationManager::
GetActuatorVels(std::vector<std::pair<double, double>> &vels_vec) const {
    if (vels_vec.empty()){
        vels_vec.resize(motors_.size());
    } else if (vels_vec.size() != motors_.size()) {
        std::cerr << "Error, simulation motor number is not equal to generation motor number" << std::endl;
        exit(EXIT_FAILURE);
    }
    for (int i = 0; i < motors_.size(); ++i) {
        vels_vec[i].second = motors_[i]->GetMaxVel();
    }
}

void SimulationManager::
GetActuatorTorques(std::vector<std::pair<double, double>> &torqs_vec) const {
    if (torqs_vec.empty()){
        torqs_vec.resize(motors_.size());
    }
    else if (torqs_vec.size() != motors_.size()){
        std::cerr << "Error, simulation motor number is not equal to generation motor number" << std::endl;
        exit(EXIT_FAILURE);
    }
    for (int i = 0; i < motors_.size(); ++i){
        torqs_vec[i].second = motors_[i]->GetMaxTorque();
    }
}

double SimulationManager::GetRootBodyDisplacement() const {
    return (ch_waypoints_[0] - robot_doc_->GetRootBody()->GetPos()).Length();
}

double SimulationManager::GetRootBodyDisplacementX() const {
    return  robot_doc_->GetRootBody()->GetPos().x() - ch_waypoints_[0].x();
}

double SimulationManager::GetRootBodyDisplacementY() const {
    return  robot_doc_->GetRootBody()->GetPos().y() - ch_waypoints_[0].y();
}

double SimulationManager::GetRootBodyAccumulatedY() const {
    return  accumulated_y_;
}
/***********************
*  private functions  *
***********************/

bool SimulationManager::check_termination() {
    return  robot_doc_->GetRootBody()->GetPos().z() < fall_down_thresh ? true : false;
}

void SimulationManager::init_stats() {
    prev_y_ = robot_doc_->GetRootBody()->GetPos().y();
    accumulated_y_ = 0;
}

void SimulationManager::update_stats() {
    double current_y = robot_doc_->GetRootBody()->GetPos().y();
    accumulated_y_ += std::abs(current_y - prev_y_);
    prev_y_ = current_y;
}

// TODO: right now using greedy method to place the env under the robot, that the
// lowest point of the robot is higher than the highest point of the env, which may
// not be necessary. need to make it more accurate
// Return vertical position of the map, so that the camera could be adjusted correspondingly
double SimulationManager::load_map(){
    double pos_z = 0;

    auto ground_mat = chrono_types::make_shared<ChMaterialSurfaceNSC>();
    ground_mat->SetSfriction(s_friction_);
    ground_mat->SetKfriction(k_friction_);
    ground_mat->SetRestitution(0.01f);

    // the environment is placed in the way that (x,y) = (0,0) is placed at the
    // corner of the map - corresponds to the (0,0) index of a heightmap matrix
    if (env_file_.empty() || env_file_ == "ground"){
        // ground body
        auto flat_ground = chrono_types::make_shared<ChBodyEasyBox>(env_x_, env_y_, env_z_, 1.0, true, true, ground_mat);
        flat_ground->SetRot(env_rot_);
        pos_z = robot_doc_->GetMinPos().z() - env_z_ * 0.5 - 0.01;
        flat_ground->SetPos(ChVector<>(0, 0, pos_z));
        flat_ground->SetBodyFixed(true);
        auto ground_texture = chrono_types::make_shared<ChColorAsset>();
        ground_texture->SetColor(ChColor(env_color_[0], env_color_[1], env_color_[2]));
        flat_ground->AddAsset(ground_texture);
        ch_system_->AddBody(flat_ground);
    } else if (env_file_.find(".urdf") != std::string::npos){
        // chrono::ChUrdfDoc urdf_map_doc(env_file_);
        // urdf_map_doc.SetCollisionMaterial(ground_mat);
        // urdf_map_doc.AddtoSystem(ch_system_, 0, 0, env_z_ / 2, 0, 0, 0);
    } else if (env_file_.find(".bmp") != std::string::npos){
        vehicle::RigidTerrain terrain(ch_system_.get());
        pos_z = robot_doc_->GetMinPos().z() - env_z_ * 0.5 - 0.01;
        auto patch = terrain.AddPatch(ground_mat,
                                      ChCoordsys<>(ChVector<>(env_x_ / 2, env_y_ / 2, pos_z),
                                                   QUNIT),
                                      env_file_, "ground_mesh", env_x_, env_y_, 0, env_z_);
        patch->SetColor(ChColor(env_color_[0], env_color_[1], env_color_[2]));
        terrain.Initialize();
    } else if (env_file_.find(".obj") != std::string::npos){
        // TODO: the position and dimension set up doesn't seem to be right
        // Need to use trimesh or other method the get the height and width of
        // the mesh
        // set obj terrain as a mesh object
        auto ch_body = chrono_types::make_shared<ChBody>();
        ch_body->SetBodyFixed(true);
        pos_z = robot_doc_->GetMinPos().z() - 1;
        ch_body->SetCoord(ChCoordsys<>(ChVector<>(0, 0, pos_z), QUNIT));

        // first load mesh
        std::shared_ptr<geometry::ChTriangleMeshConnected> trimesh;
        trimesh = chrono_types::make_shared<geometry::ChTriangleMeshConnected>();
        // TODO: maybe use relative path in env_file_?
        trimesh->LoadWavefrontMesh(env_file_);
        // TODO: this doesnt' seem to be working, might need to use trimesh
        // Get the bounding box of mesh
        // double bbox_x_min = 0;
        // double bbox_x_max = 0;
        // double bbox_y_min = 0;
        // double bbox_y_max = 0;
        // double bbox_z_min = 0;
        // double bbox_z_max = 0;
        // trimesh->GetBoundingBox(bbox_x_min, bbox_x_max, bbox_y_min, bbox_y_max, bbox_z_min, bbox_z_max);
        // std::cout << std::endl << "Size of bounding box of the env:" << std::endl <<
                               // << "x min: " << bbox_x_min << ", x max: " << bbox_x_max << std::endl
                               // << "y min: " << bbox_y_min << ", y max: " << bbox_y_max << std::endl
                               // << "z min: " << bbox_z_min << ", z max: " << bbox_z_max << std::endl;

        // TODO: The mesh scale here and the mesh scale in ChUrdfDoc should be controlled
        //          by the same variable
        // Apply the scales to mesh
        trimesh->Transform(VNULL, ChMatrix33<>(ChVector<>(0.01, 0.01, 0.01)));
        // // Apply translation to mesh -- the vis_asset::pos doesn't seem to be applied to mesh objects
        // trimesh->Transform(vis_in_child, ChMatrix33<>(1));
        trimesh->RepairDuplicateVertexes(1e-9); // if meshes are not watertight

        // visual
        auto trimesh_shape = chrono_types::make_shared<ChTriangleMeshShape>();
        // trimesh_shape->Pos = vis_in_child;
        // trimesh_shape->Rot = ChMatrix33<>(ChQuaternion<>(u_visual->origin.rotation.w,
                                                       // u_visual->origin.rotation.x,
                                                       // u_visual->origin.rotation.y,
                                                       // u_visual->origin.rotation.z));

        trimesh_shape->SetMesh(trimesh);
        // trimesh_shape->SetName(trimesh_shape->GetNameString() + "_vis_mesh");
        trimesh_shape->SetBackfaceCull(true);
        trimesh_shape->SetStatic(true); // mesh object is considered static if it's non-deformable
        // for some reason this SetScale method doesn't work
        // trimesh_shape->SetScale(ChVector<>(tmp_urdf_mesh_ptr->scale.x,
                                           // tmp_urdf_mesh_ptr->scale.y,
                                           // tmp_urdf_mesh_ptr->scale.z));
        ch_body->AddAsset(trimesh_shape);
        ch_body->AddAsset(chrono_types::make_shared<ChColorAsset>(env_color_[0], env_color_[1], env_color_[2]));

        // colision
        auto collision_material_ = chrono_types::make_shared<ChMaterialSurfaceNSC>();
        ch_body->GetCollisionModel()->ClearModel();
        // TODO: enable translation and rotation of collision model
        ch_body->GetCollisionModel()->AddTriangleMesh(collision_material_,
                                                      trimesh,
                                                      true,   // is static
                                                      true,  // use convex hull
                                                      ChVector<>(),
                                                      ChMatrix33<>(),
                                                      0.1); // sphereswept_thickness

        ch_body->GetCollisionModel()->BuildModel();
        ch_body->SetCollide(true);
        ch_system_->AddBody(ch_body);

        // vehicle::RigidTerrain terrain(ch_system_.get());
        // TODO: how to get the highest point in obj env
        // auto patch = terrain.AddPatch(ground_mat,
                                      // ChCoordsys<>(ChVector<>(env_x_ / 2,
                                                              // env_y_ / 2,
                                                              // robot_doc_->GetMinPos().z() - 1),
                                                   // QUNIT),
                                      // env_file_, "ground_mesh");
        // patch->SetColor(ChColor(0.2, 0.2, 0.2));
        // terrain.Initialize();

        // // For debug purposes
        // auto x_box = chrono_types::make_shared<ChBodyEasyBox>(20, 1, 1, 1.0, true, true, ground_mat);
        // x_box->SetPos(ChVector<>(10, 0, 0.5));
        // x_box->SetBodyFixed(true);
        // auto x_text = chrono_types::make_shared<ChColorAsset>();
        // x_text->SetColor(ChColor(0.9f, 0.0f, 0.0f)); // red
        // x_box->AddAsset(x_text);
        // ch_system_->AddBody(x_box);

        // auto y_box = chrono_types::make_shared<ChBodyEasyBox>(1, 20, 1, 1.0, true, true, ground_mat);
        // y_box->SetPos(ChVector<>(0, 10, 0.5));
        // y_box->SetBodyFixed(true);
        // auto y_text = chrono_types::make_shared<ChColorAsset>();
        // y_text->SetColor(ChColor(0.0f, 0.9f, 0.0f)); // green
        // y_box->AddAsset(y_text);
        // ch_system_->AddBody(y_box);

        // auto z_box = chrono_types::make_shared<ChBodyEasyBox>(1, 1, 20, 1.0, true, true, ground_mat);
        // z_box->SetPos(ChVector<>(0, 0, 10));
        // z_box->SetBodyFixed(true);
        // auto z_text = chrono_types::make_shared<ChColorAsset>();
        // z_text->SetColor(ChColor(0.0f, 0.0f, 0.9f)); // blue
        // z_box->AddAsset(z_text);
        // ch_system_->AddBody(z_box);
    }
    else {
        std::cerr << "Map file " << env_file_ << " not recognized, exiting" << std::endl;
        exit(EXIT_FAILURE);
    }

    return pos_z;
}
