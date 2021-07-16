classdef UI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        EvolutionaryRobogamiResultViewerUIFigure  matlab.ui.Figure
        MapViewerAxes        matlab.ui.control.UIAxes
        LoadResultButton     matlab.ui.control.Button
        GenIDField           matlab.ui.control.EditField
        LoadNextButton       matlab.ui.control.Button
        LoadPrevButton       matlab.ui.control.Button
        LoadNext10Button     matlab.ui.control.Button
        LoadPrev10Button     matlab.ui.control.Button
        SimulateRobotButton  matlab.ui.control.Button
        GenLabel             matlab.ui.control.Label
        ResultInfoLabel      matlab.ui.control.Label
        ResultNameLabel      matlab.ui.control.Label
        ResultInfoTextLabel  matlab.ui.control.Label
        GenInfoLabel         matlab.ui.control.Label
        ExtPlotButton        matlab.ui.control.Button
        RobotIDXField        matlab.ui.control.EditField
        RobotIDYField        matlab.ui.control.EditField
        RobotInfoLabel       matlab.ui.control.Label
    end

    properties (Access = private)
        evo_params % parameters of an evolutionary generation process
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
        archive_map
    end

    % private helper functions
    methods (Access = private)

        function show_testinfo(app)
            [~, app.ResultNameLabel.Text, ~] = fileparts(app.evo_params.result_path);
            app.ResultInfoTextLabel.Text =...
                sprintf('# of Gen: %d\nInit size: %d\nPop size: %d\nMap size: %dx%d\n',...
                        app.evo_params.nb_gen, app.evo_params.init_size, app.evo_params.gen_size,...
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
            % Force single instance
            figures = findall(groot, '-depth', 1, 'Type', 'Figure');
            % Shutdown all other instances of this app.
            for k = 1:numel(figures)
                fig = figures(k);
                % Only consider valid figures with a 'RunningAppInstance'
                % property, because this is the sign that the figure is
                % from an AppDesigner app.
                if isvalid(fig) && isprop(fig, 'RunningAppInstance')
                    other = fig.RunningAppInstance;
                    % Make sure the figure's app as the same class as us,
                    % and also make sure we don't delete ourself.
                    if isa(other, class(app)) && ~isequal(app, other)
                        % Delete the other instance. This automatically
                        % closes the associated figure as well.
                        delete(fig.RunningAppInstance);
                    end
                end
            end

            if (ispc)
                app.simulator_name = strcat(app.simulator_basename, '.exe');
            else
                app.simulator_name = app.simulator_basename;
            end

            app.evogen_results_path = evogen_results_path;
            app.evogen_exe_path = evogen_exe_path;
        end

        % Button pushed function: LoadResultButton
        function LoadResultButtonPushed(app, event)
            result_path = uigetdir(app.evogen_results_path, 'EvoGen Result Dir');
            evo_xml = xml2struct(fullfile(result_path, app.params_filename));

            app.evo_params.result_path = result_path;
            app.evo_params.nb_gen = str2double(evo_xml.boost_serialization{2}.EvoParams.nb_gen_.Text);
            app.evo_params.init_size = str2double(evo_xml.boost_serialization{2}.EvoParams.init_size_.Text);
            app.evo_params.gen_size = str2double(evo_xml.boost_serialization{2}.EvoParams.pop_size_.Text);
            app.evo_params.griddim_0 = str2double(evo_xml.boost_serialization{2}.EvoParams.grid_shape_.item{1}.Text);
            app.evo_params.griddim_1 = str2double(evo_xml.boost_serialization{2}.EvoParams.grid_shape_.item{2}.Text);
            app.evo_params.feature_description1 = evo_xml.boost_serialization{2}.EvoParams.feature_description_.item{1}.Text;
            app.evo_params.feature_description2= evo_xml.boost_serialization{2}.EvoParams.feature_description_.item{2}.Text;

            show_testinfo(app);
            load_gen(app, 0);
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

        % Button pushed function: ExtPlotButton
        function ExtPlotButtonPushed(app, event)
            % make sure there is something loaded
            if (app.current_gen == -1)
                msgbox('Load a result first');
                return;
            end
            figure();
            surf(app.archive_map);
        end

        % Value changed function: GenIDField
        function GenIDFieldValueChanged(app, event)
            load_gen(app, str2double(app.GenIDField.Value));
        end

        % Button pushed function: SimulateRobotButton
        function SimulateRobotButtonPushed(app, event)
            % make sure there is something loaded
            if (app.current_gen == -1)
                msgbox('Load a result first');
                return;
            end
            % Note here in CG, x goes from left to right and y goes from
            % top to bottom -- x is column index, y is row index
            idx = robot_idx_in_archive(app, str2double(app.RobotIDYField.Value), str2double(app.RobotIDXField.Value));
            if (idx == -1)
                app.RobotInfoLabel.Text = "Error: Cell (" + app.RobotIDXField.Value + ", " + app.RobotIDYField.Value + ") of Gen " + num2str(app.current_gen) + " empty";
            end
            app.RobotInfoLabel.Text = "Fitness: " + num2str(app.current_gen_archive(idx, 4));
            dv = app.current_gen_archive(idx, 5:end);
            dv = dv(~isnan(dv));
            cmd_str = fullfile(app.evogen_exe_path, app.simulator_name) + " " +...
                      fullfile(app.evo_params.result_path, app.sim_params_filename) + " " +...
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
            title(app.MapViewerAxes, '')
            xlabel(app.MapViewerAxes, '')
            ylabel(app.MapViewerAxes, '')
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
            app.LoadNext10Button.Position = [111 448 36 22];
            app.LoadNext10Button.Text = '+10';

            % Create LoadPrev10Button
            app.LoadPrev10Button = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.LoadPrev10Button.ButtonPushedFcn = createCallbackFcn(app, @LoadPrev10ButtonPushed, true);
            app.LoadPrev10Button.Position = [28 448 33 22];
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
            app.ResultInfoLabel.Position = [6 377 77 22];
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
            app.ResultInfoTextLabel.Position = [23 122 185 256];
            app.ResultInfoTextLabel.Text = '';

            % Create GenInfoLabel
            app.GenInfoLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.GenInfoLabel.HorizontalAlignment = 'center';
            app.GenInfoLabel.FontSize = 13;
            app.GenInfoLabel.FontWeight = 'bold';
            app.GenInfoLabel.Position = [207 507 434 22];
            app.GenInfoLabel.Text = '';

            % Create ExtPlotButton
            app.ExtPlotButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.ExtPlotButton.ButtonPushedFcn = createCallbackFcn(app, @ExtPlotButtonPushed, true);
            app.ExtPlotButton.Position = [38 419 100 22];
            app.ExtPlotButton.Text = 'ExtPlot';

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

            % Show the figure after all components are created
            app.EvolutionaryRobogamiResultViewerUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = UI(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.EvolutionaryRobogamiResultViewerUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

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
