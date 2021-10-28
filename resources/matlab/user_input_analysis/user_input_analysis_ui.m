classdef user_input_analysis_ui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MainFigure           matlab.ui.Figure
        CloseFigButton       matlab.ui.control.Button
        OpenFigButton        matlab.ui.control.Button
        RefRightButton       matlab.ui.control.Button
        RefLeftButton        matlab.ui.control.Button
        VerOrderCheckBox     matlab.ui.control.CheckBox
        AllButton            matlab.ui.control.Button
        ClearButton          matlab.ui.control.Button
        valleyButton         matlab.ui.control.Button
        sineButton           matlab.ui.control.Button
        groundButton         matlab.ui.control.Button
        RefreshListButton    matlab.ui.control.Button
        VerPlotButton        matlab.ui.control.Button
        RefreshPlotButton    matlab.ui.control.Button
        PopVarButton         matlab.ui.control.Button
        ClearPlotButton      matlab.ui.control.Button
        ListBox              matlab.ui.control.ListBox
        OpenFolderButton     matlab.ui.control.Button
        RobotIDYField        matlab.ui.control.EditField
        RobotIDXField        matlab.ui.control.EditField
        SimulateRobotButton  matlab.ui.control.Button
    end

    properties (Access = public)
        plot_fig
        panel
        map_surf
        map_heat
        stat_bar
        stat_heat
        left_surf
        left_heat
        right_surf
        right_heat
        results = {}
        evo_params % parameters of an evolutionary generation process
        user_input_dir
        training_results_dir
        evogen_exe_path
        simulator_basename = 'Genotype_Visualizer'
        simulator_name
        map_dim_0 = 20
        map_dim_1 = 20
        default_feature_description string
        archive_map
        map_stat % one archive_map stat per env
        results_enabled = [] % a num_user x num_env matrix representing which result is enabled to show
        default_env_order = ["ground", "Sine2.obj", "Valley5.obj"]
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, evogen_exe_path, evogen_user_input_path, evogen_results_path)
            user_input_analysis_init(app, evogen_exe_path, evogen_user_input_path, evogen_results_path);
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

        % Button pushed function: RefLeftButton
        function RefLeftButtonPushed(app, event)
            load_and_plot_ref(app, 'left');
        end

        % Button pushed function: RefRightButton
        function RefRightButtonPushed(app, event)
            load_and_plot_ref(app, 'right');
        end

        % Button pushed function: OpenFigButton
        function OpenFigButtonPushed(app, event)
            open_plot(app);
        end

        % Button pushed function: CloseFigButton
        function CloseFigButtonPushed(app, event)
            close_plot(app);
        end

        % Close request function: MainFigure
        function MainFigureCloseRequest(app, event)
            close_plot(app);
            delete(app)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MainFigure and hide until all components are created
            app.MainFigure = uifigure('Visible', 'off');
            app.MainFigure.Position = [250 20 269 655];
            app.MainFigure.Name = 'Evolutionary Robogami User Input Viewer';
            app.MainFigure.CloseRequestFcn = createCallbackFcn(app, @MainFigureCloseRequest, true);

            % Create SimulateRobotButton
            app.SimulateRobotButton = uibutton(app.MainFigure, 'push');
            app.SimulateRobotButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateRobotButtonPushed, true);
            app.SimulateRobotButton.Tag = 'loadresult';
            app.SimulateRobotButton.Position = [22 76 72 22];
            app.SimulateRobotButton.Text = 'Simulate';

            % Create RobotIDXField
            app.RobotIDXField = uieditfield(app.MainFigure, 'text');
            app.RobotIDXField.ValueChangedFcn = createCallbackFcn(app, @RobotIDXFieldValueChanged, true);
            app.RobotIDXField.HorizontalAlignment = 'center';
            app.RobotIDXField.Position = [18 103 39 22];

            % Create RobotIDYField
            app.RobotIDYField = uieditfield(app.MainFigure, 'text');
            app.RobotIDYField.ValueChangedFcn = createCallbackFcn(app, @RobotIDYFieldValueChanged, true);
            app.RobotIDYField.HorizontalAlignment = 'center';
            app.RobotIDYField.Position = [58 103 39 22];

            % Create OpenFolderButton
            app.OpenFolderButton = uibutton(app.MainFigure, 'push');
            app.OpenFolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFolderButtonPushed, true);
            app.OpenFolderButton.Tag = 'loadresult';
            app.OpenFolderButton.Position = [18 14 82 22];
            app.OpenFolderButton.Text = 'Open Folder';

            % Create ListBox
            app.ListBox = uilistbox(app.MainFigure);
            app.ListBox.Items = {};
            app.ListBox.Multiselect = 'on';
            app.ListBox.Position = [151 11 112 631];
            app.ListBox.Value = {};

            % Create ClearPlotButton
            app.ClearPlotButton = uibutton(app.MainFigure, 'push');
            app.ClearPlotButton.ButtonPushedFcn = createCallbackFcn(app, @ClearPlotButtonPushed, true);
            app.ClearPlotButton.Position = [30 387 73 22];
            app.ClearPlotButton.Text = 'ClearPlot';

            % Create PopVarButton
            app.PopVarButton = uibutton(app.MainFigure, 'push');
            app.PopVarButton.ButtonPushedFcn = createCallbackFcn(app, @PopVarButtonPushed, true);
            app.PopVarButton.Position = [18 43 73 22];
            app.PopVarButton.Text = 'Pop Var';

            % Create RefreshPlotButton
            app.RefreshPlotButton = uibutton(app.MainFigure, 'push');
            app.RefreshPlotButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshPlotButtonPushed, true);
            app.RefreshPlotButton.Position = [22 414 85 40];
            app.RefreshPlotButton.Text = 'RefreshPlot';

            % Create VerPlotButton
            app.VerPlotButton = uibutton(app.MainFigure, 'push');
            app.VerPlotButton.ButtonPushedFcn = createCallbackFcn(app, @VerPlotButtonPushed, true);
            app.VerPlotButton.Position = [23 177 58 22];
            app.VerPlotButton.Text = 'VerPlot';

            % Create RefreshListButton
            app.RefreshListButton = uibutton(app.MainFigure, 'push');
            app.RefreshListButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshListButtonPushed, true);
            app.RefreshListButton.Position = [22 606 86 36];
            app.RefreshListButton.Text = 'RefreshList';

            % Create groundButton
            app.groundButton = uibutton(app.MainFigure, 'push');
            app.groundButton.ButtonPushedFcn = createCallbackFcn(app, @groundButtonPushed, true);
            app.groundButton.Position = [38 573 57 22];
            app.groundButton.Text = 'ground';

            % Create sineButton
            app.sineButton = uibutton(app.MainFigure, 'push');
            app.sineButton.ButtonPushedFcn = createCallbackFcn(app, @sineButtonPushed, true);
            app.sineButton.Position = [38 549 57 22];
            app.sineButton.Text = 'sine';

            % Create valleyButton
            app.valleyButton = uibutton(app.MainFigure, 'push');
            app.valleyButton.ButtonPushedFcn = createCallbackFcn(app, @valleyButtonPushed, true);
            app.valleyButton.Position = [38 525 57 22];
            app.valleyButton.Text = 'valley';

            % Create ClearButton
            app.ClearButton = uibutton(app.MainFigure, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Position = [38 471 57 22];
            app.ClearButton.Text = 'Clear';

            % Create AllButton
            app.AllButton = uibutton(app.MainFigure, 'push');
            app.AllButton.ButtonPushedFcn = createCallbackFcn(app, @AllButtonPushed, true);
            app.AllButton.Position = [38 494 57 22];
            app.AllButton.Text = 'All';

            % Create VerOrderCheckBox
            app.VerOrderCheckBox = uicheckbox(app.MainFigure);
            app.VerOrderCheckBox.Text = 'default order';
            app.VerOrderCheckBox.Position = [27 155 89 22];
            app.VerOrderCheckBox.Value = true;

            % Create RefLeftButton
            app.RefLeftButton = uibutton(app.MainFigure, 'push');
            app.RefLeftButton.ButtonPushedFcn = createCallbackFcn(app, @RefLeftButtonPushed, true);
            app.RefLeftButton.Position = [12 331 50 40];
            app.RefLeftButton.Text = 'RefLeft';

            % Create RefRightButton
            app.RefRightButton = uibutton(app.MainFigure, 'push');
            app.RefRightButton.ButtonPushedFcn = createCallbackFcn(app, @RefRightButtonPushed, true);
            app.RefRightButton.Position = [70 331 57 40];
            app.RefRightButton.Text = 'RefRight';

            % Create OpenFigButton
            app.OpenFigButton = uibutton(app.MainFigure, 'push');
            app.OpenFigButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFigButtonPushed, true);
            app.OpenFigButton.Position = [18 211 54 22];
            app.OpenFigButton.Text = 'OpenFig';

            % Create CloseFigButton
            app.CloseFigButton = uibutton(app.MainFigure, 'push');
            app.CloseFigButton.ButtonPushedFcn = createCallbackFcn(app, @CloseFigButtonPushed, true);
            app.CloseFigButton.Position = [80 211 56 22];
            app.CloseFigButton.Text = 'CloseFig';

            % Show the figure after all components are created
            app.MainFigure.Visible = 'on';
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
                registerApp(app, app.MainFigure)

                % Execute the startup function
                runStartupFcn(app, @(app)startupFcn(app, varargin{:}))
            else

                % Focus the running singleton app
                figure(runningApp.MainFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.MainFigure)
        end
    end
end
