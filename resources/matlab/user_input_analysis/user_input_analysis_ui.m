classdef user_input_analysis_ui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UserInputAnalysisUIFigure  matlab.ui.Figure
        VerOrderCheckBox           matlab.ui.control.CheckBox
        AllButton                  matlab.ui.control.Button
        ClearButton                matlab.ui.control.Button
        valleyButton               matlab.ui.control.Button
        sineButton                 matlab.ui.control.Button
        groundButton               matlab.ui.control.Button
        RefreshListButton          matlab.ui.control.Button
        VerPlotButton              matlab.ui.control.Button
        RefreshPlotButton          matlab.ui.control.Button
        PopVarButton               matlab.ui.control.Button
        ClearPlotButton            matlab.ui.control.Button
        ListBox                    matlab.ui.control.ListBox
        OpenFolderButton           matlab.ui.control.Button
        RobotIDYField              matlab.ui.control.EditField
        RobotIDXField              matlab.ui.control.EditField
        SimulateRobotButton        matlab.ui.control.Button
        MapStatViewerAxes          matlab.ui.control.UIAxes
        MapViewerAxes              matlab.ui.control.UIAxes
    end

    properties (Access = public)
        results = {}
        evo_params % parameters of an evolutionary generation process
        user_input_dir
        evogen_exe_path
        % TODO: should read the following constant values from somewhere
        %     especially the simulator name, which is system dependent
        params_filename = 'evo_params.xml'
        sim_params_filename = 'sim_params.xml'
        archive_prefix = '/archives/archive_'
        archive_subfix = '.csv'
        simulator_basename = 'Genotype_Visualizer'
        simulator_name
        generator_basename = 'Evolutionary_Generator'
        generator_name
        map_dim_0 = 20
        map_dim_1 = 20
        default_feature_description string
        archive_map
        map_stat % one archive_map stat per env
        results_enabled = [] % a num_user x num_env matrix representing which result is enabled to show
        result_to_compare string
        default_env_order = ["ground", "Sine2.obj", "Valley5.obj"]
    end

    % private helper functions
    methods (Access = private)
        function idx = robot_idx_in_archive(app, x ,y)
            for idx = 1 : size(app.current_gen_archive, 1)
                if (app.current_gen_x_idx(idx) == x)
                    if (app.current_gen_y_idx(idx) == y)
                        return;
                    end
                end
            end
            idx = -1;
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, evogen_exe_path, evogen_user_input_path)
            if (ispc)
                app.simulator_name = strcat(app.simulator_basename, '.exe');
                app.generator_name = strcat(app.generator_basename, '.exe');
            else
                app.simulator_name = app.simulator_basename;
                app.generator_name = app.generator_basename;
            end

            app.user_input_dir = evogen_user_input_path;
            app.evogen_exe_path = evogen_exe_path;

            % init params
            app.archive_map = zeros(app.map_dim_0, app.map_dim_1);
            app.map_stat = zeros(app.map_dim_0, app.map_dim_1, length(app.default_env_order));
        end

        % Button pushed function: OpenFolderButton
        function OpenFolderButtonPushed(app, event)
            winopen(app.user_input_dir);
        end

        % Button pushed function: SimulateRobotButton
        function SimulateRobotButtonPushed(app, event)
            % Note here in CG, x goes from left to right and y goes from
            % top to bottom -- x is column index, y is row index
            idx = robot_idx_in_archive(app, str2double(app.RobotIDYField.Value), str2double(app.RobotIDXField.Value));
            if (idx == -1)
                app.RobotInfoLabel.Text = "Error: Cell (" + app.RobotIDXField.Value + ", " + app.RobotIDYField.Value + ") of Gen " + num2str(app.current_gen) + " empty";
            end
            app.RobotInfoLabel.Text = "Fitness: " + num2str(app.current_gen_archive(idx, 4));
            dv = app.current_gen_archive(idx, 5:end);
            dv = dv(~isnan(dv));
            cmd_str = fullfile(app.evogen_exe_path, app.simulator_name) + " mesh " + ...
                      fullfile(app.result_path, app.sim_params_filename) + " " + ...
                      num2str(dv);
            system(cmd_str);
        end

        % Value changed function: RobotIDXField
        function RobotIDXFieldValueChanged(app, event)
            value = str2double(app.RobotIDXField.Value);
            value = min(max(value, 1), app.evo_params.griddim_1); % note X corresponds to column index of matrix here
            app.RobotIDXField.Value = num2str(value);
        end

        % Value changed function: RobotIDYField
        function RobotIDYFieldValueChanged(app, event)
            value = str2double(app.RobotIDYField.Value);
            value = min(max(value, 1), app.evo_params.griddim_0); % note y corresponds to row index of matrix here
            app.RobotIDYField.Value = num2str(value);
        end

        % Button pushed function: ClearPlotButton
        function ClearPlotButtonPushed(app, event)
            clear_plot(app);
        end

        % Button pushed function: PopVarButton
        function PopVarButtonPushed(app, event)
            user_analysis_pop_var(app);
        end

        % Button pushed function: RefreshPlotButton
        function RefreshPlotButtonPushed(app, event)
            plot_archive(app);
        end

        % Button pushed function: VerPlotButton
        function VerPlotButtonPushed(app, event)
            plot_ver_fitness(app);
        end

        % Button pushed function: RefreshListButton
        function RefreshListButtonPushed(app, event)
            load_all(app);
        end

        % Button pushed function: groundButton
        function groundButtonPushed(app, event)
            update_results_enabled(app, 1);
        end

        % Button pushed function: sineButton
        function sineButtonPushed(app, event)
            update_results_enabled(app, 2);
        end

        % Button pushed function: valleyButton
        function valleyButtonPushed(app, event)
            update_results_enabled(app, 3);
        end

        % Button pushed function: AllButton
        function AllButtonPushed(app, event)
            update_results_enabled(app, 0);
        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
            update_results_enabled(app, -1);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UserInputAnalysisUIFigure and hide until all components are created
            app.UserInputAnalysisUIFigure = uifigure('Visible', 'off');
            app.UserInputAnalysisUIFigure.Position = [100 100 1420 578];
            app.UserInputAnalysisUIFigure.Name = 'Evolutionary Robogami User Input Viewer';

            % Create MapViewerAxes
            app.MapViewerAxes = uiaxes(app.UserInputAnalysisUIFigure);
            app.MapViewerAxes.XTick = [];
            app.MapViewerAxes.YTick = [];
            app.MapViewerAxes.Tag = 'MapViewer';
            app.MapViewerAxes.Position = [269 20 550 550];

            % Create MapStatViewerAxes
            app.MapStatViewerAxes = uiaxes(app.UserInputAnalysisUIFigure);
            app.MapStatViewerAxes.XTick = [];
            app.MapStatViewerAxes.YTick = [];
            app.MapStatViewerAxes.Tag = 'MapViewer';
            app.MapStatViewerAxes.Position = [861 20 550 550];

            % Create SimulateRobotButton
            app.SimulateRobotButton = uibutton(app.UserInputAnalysisUIFigure, 'push');
            app.SimulateRobotButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateRobotButtonPushed, true);
            app.SimulateRobotButton.Tag = 'loadresult';
            app.SimulateRobotButton.Position = [24 90 72 22];
            app.SimulateRobotButton.Text = 'Simulate';

            % Create RobotIDXField
            app.RobotIDXField = uieditfield(app.UserInputAnalysisUIFigure, 'text');
            app.RobotIDXField.ValueChangedFcn = createCallbackFcn(app, @RobotIDXFieldValueChanged, true);
            app.RobotIDXField.HorizontalAlignment = 'center';
            app.RobotIDXField.Position = [20 117 39 22];

            % Create RobotIDYField
            app.RobotIDYField = uieditfield(app.UserInputAnalysisUIFigure, 'text');
            app.RobotIDYField.ValueChangedFcn = createCallbackFcn(app, @RobotIDYFieldValueChanged, true);
            app.RobotIDYField.HorizontalAlignment = 'center';
            app.RobotIDYField.Position = [60 117 39 22];

            % Create OpenFolderButton
            app.OpenFolderButton = uibutton(app.UserInputAnalysisUIFigure, 'push');
            app.OpenFolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFolderButtonPushed, true);
            app.OpenFolderButton.Tag = 'loadresult';
            app.OpenFolderButton.Position = [10 20 82 22];
            app.OpenFolderButton.Text = 'Open Folder';

            % Create ListBox
            app.ListBox = uilistbox(app.UserInputAnalysisUIFigure);
            app.ListBox.Items = {};
            app.ListBox.Multiselect = 'on';
            app.ListBox.Position = [133 20 112 543];
            app.ListBox.Value = {};

            % Create ClearPlotButton
            app.ClearPlotButton = uibutton(app.UserInputAnalysisUIFigure, 'push');
            app.ClearPlotButton.ButtonPushedFcn = createCallbackFcn(app, @ClearPlotButtonPushed, true);
            app.ClearPlotButton.Position = [28 307 73 22];
            app.ClearPlotButton.Text = 'ClearPlot';

            % Create PopVarButton
            app.PopVarButton = uibutton(app.UserInputAnalysisUIFigure, 'push');
            app.PopVarButton.ButtonPushedFcn = createCallbackFcn(app, @PopVarButtonPushed, true);
            app.PopVarButton.Position = [10 49 73 22];
            app.PopVarButton.Text = 'Pop Var';

            % Create RefreshPlotButton
            app.RefreshPlotButton = uibutton(app.UserInputAnalysisUIFigure, 'push');
            app.RefreshPlotButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshPlotButtonPushed, true);
            app.RefreshPlotButton.Position = [20 334 85 40];
            app.RefreshPlotButton.Text = 'RefreshPlot';

            % Create VerPlotButton
            app.VerPlotButton = uibutton(app.UserInputAnalysisUIFigure, 'push');
            app.VerPlotButton.ButtonPushedFcn = createCallbackFcn(app, @VerPlotButtonPushed, true);
            app.VerPlotButton.Position = [24 265 58 22];
            app.VerPlotButton.Text = 'VerPlot';

            % Create RefreshListButton
            app.RefreshListButton = uibutton(app.UserInputAnalysisUIFigure, 'push');
            app.RefreshListButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshListButtonPushed, true);
            app.RefreshListButton.Position = [20 526 86 36];
            app.RefreshListButton.Text = 'RefreshList';

            % Create groundButton
            app.groundButton = uibutton(app.UserInputAnalysisUIFigure, 'push');
            app.groundButton.ButtonPushedFcn = createCallbackFcn(app, @groundButtonPushed, true);
            app.groundButton.Position = [36 493 57 22];
            app.groundButton.Text = 'ground';

            % Create sineButton
            app.sineButton = uibutton(app.UserInputAnalysisUIFigure, 'push');
            app.sineButton.ButtonPushedFcn = createCallbackFcn(app, @sineButtonPushed, true);
            app.sineButton.Position = [36 469 57 22];
            app.sineButton.Text = 'sine';

            % Create valleyButton
            app.valleyButton = uibutton(app.UserInputAnalysisUIFigure, 'push');
            app.valleyButton.ButtonPushedFcn = createCallbackFcn(app, @valleyButtonPushed, true);
            app.valleyButton.Position = [36 445 57 22];
            app.valleyButton.Text = 'valley';

            % Create ClearButton
            app.ClearButton = uibutton(app.UserInputAnalysisUIFigure, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Position = [36 391 57 22];
            app.ClearButton.Text = 'Clear';

            % Create AllButton
            app.AllButton = uibutton(app.UserInputAnalysisUIFigure, 'push');
            app.AllButton.ButtonPushedFcn = createCallbackFcn(app, @AllButtonPushed, true);
            app.AllButton.Position = [36 414 57 22];
            app.AllButton.Text = 'All';

            % Create VerOrderCheckBox
            app.VerOrderCheckBox = uicheckbox(app.UserInputAnalysisUIFigure);
            app.VerOrderCheckBox.Text = 'default order';
            app.VerOrderCheckBox.Position = [28 243 89 22];
            app.VerOrderCheckBox.Value = true;

            % Show the figure after all components are created
            app.UserInputAnalysisUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = user_input_analysis_ui(varargin)

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.UserInputAnalysisUIFigure)

                % Execute the startup function
                runStartupFcn(app, @(app)startupFcn(app, varargin{:}))
            else

                % Focus the running singleton app
                figure(runningApp.UserInputAnalysisUIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UserInputAnalysisUIFigure)
        end
    end
end
