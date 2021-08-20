classdef UI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        EvolutionaryRobogamiResultViewerUIFigure  matlab.ui.Figure
        LoadFirstButton      matlab.ui.control.Button
        LoadLastButton       matlab.ui.control.Button
        ResumeButton         matlab.ui.control.Button
        OpenFolderButton     matlab.ui.control.Button
        ToLabel              matlab.ui.control.Label
        FromLabel            matlab.ui.control.Label
        StatEndGenField      matlab.ui.control.EditField
        StatStartGenField    matlab.ui.control.EditField
        StatPlotButton       matlab.ui.control.Button
        RobotIDYLabel        matlab.ui.control.Label
        RobotIDXLabel        matlab.ui.control.Label
        RobotInfoLabel       matlab.ui.control.Label
        RobotIDYField        matlab.ui.control.EditField
        RobotIDXField        matlab.ui.control.EditField
        BuildStatButton      matlab.ui.control.Button
        GenInfoLabel         matlab.ui.control.Label
        ResultInfoTextLabel  matlab.ui.control.Label
        ResultNameLabel      matlab.ui.control.Label
        ResultInfoLabel      matlab.ui.control.Label
        GenLabel             matlab.ui.control.Label
        SimulateRobotButton  matlab.ui.control.Button
        LoadPrev10Button     matlab.ui.control.Button
        LoadNext10Button     matlab.ui.control.Button
        LoadPrevButton       matlab.ui.control.Button
        LoadNextButton       matlab.ui.control.Button
        GenIDField           matlab.ui.control.EditField
        LoadResultButton     matlab.ui.control.Button
        MapViewerAxes        matlab.ui.control.UIAxes
    end

    properties (Access = private)
        evo_params % parameters of an evolutionary generation process
        stat % variables containing the stats of the result
        stat_loaded = false
        evogen_results_path
        evogen_exe_path
        current_gen = -1
        current_gen_archive
        current_gen_x_idx
        current_gen_y_idx
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
        archive_map
    end

    % private helper functions
    methods (Access = private)

        function show_testinfo(app)
            [~, app.ResultNameLabel.Text, ~] = fileparts(app.evo_params.result_path);
            app.evo_params.result_basename = app.ResultNameLabel.Text;
            app.ResultInfoTextLabel.Text =...
                sprintf(['# of Gen Finished: %d/%d\n', ...
                         'Progress: %.2f%%\n', ...
                         'Init size: %d\n', ...
                         'Pop size: %d\n', ...
                         'Map size: %dx%d\n'],...
                        app.evo_params.nb_gen, app.evo_params.nb_gen_planned, ...
                        double(app.evo_params.nb_gen) / app.evo_params.nb_gen_planned * 100, ...
                        app.evo_params.init_size, ...
                        app.evo_params.gen_size, ...
                        app.evo_params.griddim_0, app.evo_params.griddim_1);
        end

        function plot_heatmap(app)
            app.archive_map = zeros(app.evo_params.griddim_0, app.evo_params.griddim_1);
            x = app.current_gen_archive(:, 2);
            y = app.current_gen_archive(:, 3);
            fitness = app.current_gen_archive(:, 4);
            x = round(x * double(app.evo_params.griddim_0 - 1)) + 1;
            y = round(y * double(app.evo_params.griddim_1 - 1)) + 1;
            app.archive_map(sub2ind(size(app.archive_map), x, y)) = fitness;
            surf(app.MapViewerAxes, app.archive_map);
            xlabel(app.MapViewerAxes, app.evo_params.feature_description2); % x, y flipped in plot
            ylabel(app.MapViewerAxes, app.evo_params.feature_description1);
            app.GenInfoLabel.Text =...
                sprintf('Gen: %d/%d, Archive size: %d/%d',...
                app.current_gen, app.evo_params.nb_gen, size(x, 1),...
                app.evo_params.griddim_0 * app.evo_params.griddim_1);

            app.current_gen_x_idx = x;
            app.current_gen_y_idx = y;
            % Note the swapping of x, y here
            app.RobotIDXField.Value = num2str(y(1));
            app.RobotIDYField.Value = num2str(x(1));
            idx = robot_idx_in_archive(app, x(1), y(1));
            app.RobotInfoLabel.Text = "Fitness: " + num2str(app.current_gen_archive(idx, 4));
        end

        function load_gen(app, gen_to_load)
            gen_to_load = min(max(gen_to_load, 0), app.evo_params.nb_gen);
            if (gen_to_load == app.current_gen)
                return
            end
            app.current_gen = gen_to_load;
            app.current_gen_archive = readmatrix(fullfile(app.evo_params.result_path, strcat(app.archive_prefix, num2str(app.current_gen), app.archive_subfix)));
            app.GenIDField.Value = num2str(app.current_gen);
            plot_heatmap(app);
        end

        function load_result(app)
            result_path = uigetdir(app.evogen_results_path, 'EvoGen Result Dir');
            figure(app.EvolutionaryRobogamiResultViewerUIFigure);
            evo_xml = xml2struct(fullfile(result_path, app.params_filename));

            app.evo_params.result_path = result_path;
            app.evo_params.nb_gen_planned = str2double(evo_xml.boost_serialization{2}.EvoParams.nb_gen_.Text);
            app.evo_params.init_size = str2double(evo_xml.boost_serialization{2}.EvoParams.init_size_.Text);
            app.evo_params.gen_size = str2double(evo_xml.boost_serialization{2}.EvoParams.pop_size_.Text);
            app.evo_params.griddim_0 = str2double(evo_xml.boost_serialization{2}.EvoParams.grid_shape_.item{1}.Text);
            app.evo_params.griddim_1 = str2double(evo_xml.boost_serialization{2}.EvoParams.grid_shape_.item{2}.Text);
            app.evo_params.feature_description1 = evo_xml.boost_serialization{2}.EvoParams.feature_description_.item{1}.Text;
            app.evo_params.feature_description2 = evo_xml.boost_serialization{2}.EvoParams.feature_description_.item{2}.Text;
            app.RobotIDXLabel.Text = app.evo_params.feature_description2(1:5);
            app.RobotIDYLabel.Text = app.evo_params.feature_description1(1:5);

            statusfile_id = fopen(fullfile(result_path, 'status.txt'));
            status_info = cell2mat(textscan(statusfile_id, '%d/%d%*[^\n]'));
            app.evo_params.nb_gen = status_info(1);
            [app.stat, app.stat_loaded] = load_stat(result_path);
            if app.stat_loaded
                app.BuildStatButton.Text = 'RebuildStat';
            else
                app.BuildStatButton.Text = 'BuildStat';
            end
            app.StatStartGenField.Value = num2str(0);
            app.StatEndGenField.Value = num2str(app.evo_params.nb_gen);
            app.current_gen = -1;
            show_testinfo(app);
            load_gen(app, 0);
        end

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
        function startupFcn(app, evogen_exe_path, evogen_results_path)
            if (ispc)
                app.simulator_name = strcat(app.simulator_basename, '.exe');
                app.generator_name = strcat(app.generator_basename, '.exe');
            else
                app.simulator_name = app.simulator_basename;
                app.generator_name = app.generator_basename;
            end

            app.evogen_results_path = evogen_results_path;
            app.evogen_exe_path = evogen_exe_path;

            load_result(app);
        end

        % Button pushed function: LoadResultButton
        function LoadResultButtonPushed(app, event)
            load_result(app);
        end

        % Button pushed function: LoadNextButton
        function LoadNextButtonPushed(app, event)
            load_gen(app, app.current_gen + 1);
        end

        % Button pushed function: LoadPrevButton
        function LoadPrevButtonPushed(app, event)
            load_gen(app, app.current_gen - 1);
        end

        % Button pushed function: LoadNext10Button
        function LoadNext10ButtonPushed(app, event)
            load_gen(app, app.current_gen + 10);
        end

        % Button pushed function: LoadPrev10Button
        function LoadPrev10ButtonPushed(app, event)
            load_gen(app, app.current_gen - 10);
        end

        % Button pushed function: LoadFirstButton
        function LoadFirstButtonPushed(app, event)
            load_gen(app, 0);
        end

        % Button pushed function: LoadLastButton
        function LoadLastButtonPushed(app, event)
            load_gen(app, app.evo_params.nb_gen);
        end

        % Button pushed function: BuildStatButton
        function BuildStatButtonPushed(app, event)
            app.BuildStatButton.Text = 'Building ...';
            [app.stat, app.stat_loaded] = build_stat(app.evo_params);
            app.BuildStatButton.Text = 'RebuildStat';
        end

        % Button pushed function: StatPlotButton
        function StatPlotButtonPushed(app, event)
            if (~app.stat_loaded)
                msgbox('Build Stat first');
                return;
            end
            stat_plot(app.stat, app.evo_params, str2double(app.StatStartGenField.Value), str2double(app.StatEndGenField.Value));
        end

        % Button pushed function: OpenFolderButton
        function OpenFolderButtonPushed(app, event)
            winopen(app.evo_params.result_path);
        end

        % Button pushed function: ResumeButton
        function ResumeButtonPushed(app, event)
            cmd_str = fullfile(app.evogen_exe_path, app.generator_name) + ...
                      " resume " + app.evo_params.result_basename;
            system(cmd_str);
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
                      fullfile(app.evo_params.result_path, app.sim_params_filename) + " " + ...
                      num2str(dv);
            system(cmd_str);
        end

        % Value changed function: GenIDField
        function GenIDFieldValueChanged(app, event)
            load_gen(app, str2double(app.GenIDField.Value));
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
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create EvolutionaryRobogamiResultViewerUIFigure and hide until all components are created
            app.EvolutionaryRobogamiResultViewerUIFigure = uifigure('Visible', 'off');
            app.EvolutionaryRobogamiResultViewerUIFigure.Position = [100 100 642 577];
            app.EvolutionaryRobogamiResultViewerUIFigure.Name = 'Evolutionary Robogami Result Viewer';

            % Create MapViewerAxes
            app.MapViewerAxes = uiaxes(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.MapViewerAxes.XTick = [];
            app.MapViewerAxes.YTick = [];
            app.MapViewerAxes.Tag = 'MapViewer';
            app.MapViewerAxes.Position = [191 49 450 450];

            % Create LoadResultButton
            app.LoadResultButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.LoadResultButton.ButtonPushedFcn = createCallbackFcn(app, @LoadResultButtonPushed, true);
            app.LoadResultButton.Tag = 'loadresult';
            app.LoadResultButton.Position = [39 507 100 22];
            app.LoadResultButton.Text = 'Load Result';

            % Create GenIDField
            app.GenIDField = uieditfield(app.EvolutionaryRobogamiResultViewerUIFigure, 'text');
            app.GenIDField.ValueChangedFcn = createCallbackFcn(app, @GenIDFieldValueChanged, true);
            app.GenIDField.HorizontalAlignment = 'center';
            app.GenIDField.Position = [68 477 39 22];

            % Create LoadNextButton
            app.LoadNextButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.LoadNextButton.ButtonPushedFcn = createCallbackFcn(app, @LoadNextButtonPushed, true);
            app.LoadNextButton.Position = [86 448 26 22];
            app.LoadNextButton.Text = '>';

            % Create LoadPrevButton
            app.LoadPrevButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.LoadPrevButton.ButtonPushedFcn = createCallbackFcn(app, @LoadPrevButtonPushed, true);
            app.LoadPrevButton.Position = [61 448 26 22];
            app.LoadPrevButton.Text = '<';

            % Create LoadNext10Button
            app.LoadNext10Button = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.LoadNext10Button.ButtonPushedFcn = createCallbackFcn(app, @LoadNext10ButtonPushed, true);
            app.LoadNext10Button.Position = [111 448 30 22];
            app.LoadNext10Button.Text = '+10';

            % Create LoadPrev10Button
            app.LoadPrev10Button = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.LoadPrev10Button.ButtonPushedFcn = createCallbackFcn(app, @LoadPrev10ButtonPushed, true);
            app.LoadPrev10Button.Position = [31 448 30 22];
            app.LoadPrev10Button.Text = '-10';

            % Create SimulateRobotButton
            app.SimulateRobotButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.SimulateRobotButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateRobotButtonPushed, true);
            app.SimulateRobotButton.Tag = 'loadresult';
            app.SimulateRobotButton.Position = [120 49 72 22];
            app.SimulateRobotButton.Text = 'Simulate';

            % Create GenLabel
            app.GenLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.GenLabel.FontSize = 13;
            app.GenLabel.FontWeight = 'bold';
            app.GenLabel.Position = [35 477 35 22];
            app.GenLabel.Text = 'Gen:';

            % Create ResultInfoLabel
            app.ResultInfoLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.ResultInfoLabel.FontSize = 13;
            app.ResultInfoLabel.FontWeight = 'bold';
            app.ResultInfoLabel.Position = [4 333 77 22];
            app.ResultInfoLabel.Text = 'Result Info:';

            % Create ResultNameLabel
            app.ResultNameLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.ResultNameLabel.HorizontalAlignment = 'center';
            app.ResultNameLabel.FontSize = 16;
            app.ResultNameLabel.FontWeight = 'bold';
            app.ResultNameLabel.Position = [23 548 596 30];
            app.ResultNameLabel.Text = 'Load a result to view';

            % Create ResultInfoTextLabel
            app.ResultInfoTextLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.ResultInfoTextLabel.VerticalAlignment = 'top';
            app.ResultInfoTextLabel.Position = [23 214 185 120];
            app.ResultInfoTextLabel.Text = '';

            % Create GenInfoLabel
            app.GenInfoLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.GenInfoLabel.HorizontalAlignment = 'center';
            app.GenInfoLabel.FontSize = 13;
            app.GenInfoLabel.FontWeight = 'bold';
            app.GenInfoLabel.Position = [207 507 434 22];
            app.GenInfoLabel.Text = '';

            % Create BuildStatButton
            app.BuildStatButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.BuildStatButton.ButtonPushedFcn = createCallbackFcn(app, @BuildStatButtonPushed, true);
            app.BuildStatButton.Position = [12 180 73 22];
            app.BuildStatButton.Text = 'BuildStat';

            % Create RobotIDXField
            app.RobotIDXField = uieditfield(app.EvolutionaryRobogamiResultViewerUIFigure, 'text');
            app.RobotIDXField.ValueChangedFcn = createCallbackFcn(app, @RobotIDXFieldValueChanged, true);
            app.RobotIDXField.HorizontalAlignment = 'center';
            app.RobotIDXField.Position = [25 49 39 22];

            % Create RobotIDYField
            app.RobotIDYField = uieditfield(app.EvolutionaryRobogamiResultViewerUIFigure, 'text');
            app.RobotIDYField.ValueChangedFcn = createCallbackFcn(app, @RobotIDYFieldValueChanged, true);
            app.RobotIDYField.HorizontalAlignment = 'center';
            app.RobotIDYField.Position = [68 49 39 22];

            % Create RobotInfoLabel
            app.RobotInfoLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.RobotInfoLabel.Position = [28 16 604 22];
            app.RobotInfoLabel.Text = '';

            % Create RobotIDXLabel
            app.RobotIDXLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.RobotIDXLabel.Position = [24 71 37 20];
            app.RobotIDXLabel.Text = '';

            % Create RobotIDYLabel
            app.RobotIDYLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.RobotIDYLabel.Position = [69 70 38 22];
            app.RobotIDYLabel.Text = '';

            % Create StatPlotButton
            app.StatPlotButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.StatPlotButton.ButtonPushedFcn = createCallbackFcn(app, @StatPlotButtonPushed, true);
            app.StatPlotButton.Position = [39 366 100 22];
            app.StatPlotButton.Text = 'StatPlot';

            % Create StatStartGenField
            app.StatStartGenField = uieditfield(app.EvolutionaryRobogamiResultViewerUIFigure, 'text');
            app.StatStartGenField.HorizontalAlignment = 'center';
            app.StatStartGenField.Position = [55 391 41 22];

            % Create StatEndGenField
            app.StatEndGenField = uieditfield(app.EvolutionaryRobogamiResultViewerUIFigure, 'text');
            app.StatEndGenField.HorizontalAlignment = 'center';
            app.StatEndGenField.Position = [122 391 40 22];

            % Create FromLabel
            app.FromLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.FromLabel.FontSize = 13;
            app.FromLabel.FontWeight = 'bold';
            app.FromLabel.Position = [15 391 41 22];
            app.FromLabel.Text = 'From:';

            % Create ToLabel
            app.ToLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.ToLabel.FontSize = 13;
            app.ToLabel.FontWeight = 'bold';
            app.ToLabel.Position = [101 391 25 22];
            app.ToLabel.Text = 'To:';

            % Create OpenFolderButton
            app.OpenFolderButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.OpenFolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFolderButtonPushed, true);
            app.OpenFolderButton.Tag = 'loadresult';
            app.OpenFolderButton.Position = [90 180 82 22];
            app.OpenFolderButton.Text = 'Open Folder';

            % Create ResumeButton
            app.ResumeButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.ResumeButton.ButtonPushedFcn = createCallbackFcn(app, @ResumeButtonPushed, true);
            app.ResumeButton.Position = [12 156 73 22];
            app.ResumeButton.Text = 'Resume';

            % Create LoadLastButton
            app.LoadLastButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.LoadLastButton.ButtonPushedFcn = createCallbackFcn(app, @LoadLastButtonPushed, true);
            app.LoadLastButton.Position = [87 427 30 22];
            app.LoadLastButton.Text = '>>';

            % Create LoadFirstButton
            app.LoadFirstButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.LoadFirstButton.ButtonPushedFcn = createCallbackFcn(app, @LoadFirstButtonPushed, true);
            app.LoadFirstButton.Position = [57 427 30 22];
            app.LoadFirstButton.Text = '<<';

            % Show the figure after all components are created
            app.EvolutionaryRobogamiResultViewerUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = UI(varargin)

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.EvolutionaryRobogamiResultViewerUIFigure)

                % Execute the startup function
                runStartupFcn(app, @(app)startupFcn(app, varargin{:}))
            else

                % Focus the running singleton app
                figure(runningApp.EvolutionaryRobogamiResultViewerUIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.EvolutionaryRobogamiResultViewerUIFigure)
        end
    end
end
