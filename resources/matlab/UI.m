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
        GenLabel             matlab.ui.control.Label
        ResultInfoLabel      matlab.ui.control.Label
        ResultNameLabel      matlab.ui.control.Label
        ResultInfoTextLabel  matlab.ui.control.Label
        GenInfoLabel         matlab.ui.control.Label
        ExtPlotButton        matlab.ui.control.Button
    end

    
    properties (Access = private)
        evo_params % parameters of an evolutionary generation process
        evogen_results_path
        evogen_exe_path
        current_gen = -1
        current_gen_archive
        params_filename = 'params.csv'
        archive_prefix = '/archives/archive_'
        archive_subfix = '.csv'
    end
    
    % private helper functions
    methods (Access = private)

        function show_testinfo(app)
            [~, app.ResultNameLabel.Text, ~] = fileparts(app.evo_params.result_path);
            app.ResultInfoTextLabel.Text =...
                sprintf('Env: %s\n# of Gen: %d\nPop size: %d\nMap size: %dx%d\n',...
                        app.evo_params.env_name, app.evo_params.nb_gen, app.evo_params.gen_size,...
                        app.evo_params.griddim_0, app.evo_params.griddim_1);
        end
        
        function plot_heatmap(app)
            map = zeros(app.evo_params.griddim_0, app.evo_params.griddim_1);
            x = app.current_gen_archive(:, 2);
            y = app.current_gen_archive(:, 3);
            fitness = app.current_gen_archive(:, 4);
            x = round(x * double(app.evo_params.griddim_0 - 1)) + 1;
            y = round(y * double(app.evo_params.griddim_1 - 1)) + 1;
            map(sub2ind(size(map), x, y)) = fitness;
            surf(app.MapViewerAxes, map);
            app.GenInfoLabel.Text =...
                sprintf('Gen: %d/%d, Archive size: %d/%d',...
                app.current_gen, app.evo_params.nb_gen, size(x, 1),...
                app.evo_params.griddim_0 * app.evo_params.griddim_1);

        end
         
        function plot_heatmapext(app)
            map = zeros(app.evo_params.griddim_0, app.evo_params.griddim_1);
            x = app.current_gen_archive(:, 2);
            y = app.current_gen_archive(:, 3);
            fitness = app.current_gen_archive(:, 4);
            x = round(x * double(app.evo_params.griddim_0 - 1)) + 1;
            y = round(y * double(app.evo_params.griddim_1 - 1)) + 1;
            map(sub2ind(size(map), x, y)) = fitness;
            figure();
            surf(map);
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

            app.evogen_results_path = evogen_results_path;
            app.evogen_exe_path = evogen_exe_path;
        end

        % Button pushed function: LoadResultButton
        function LoadResultButtonPushed(app, event)
            result_path = uigetdir(app.evogen_results_path, 'EvoGen Result Dir');
            fid = fopen(fullfile(result_path, app.params_filename));
            textout = textscan(fid, '%d%d%d%d%d%d%d%d%s%f', 'Delimiter', ',');

            app.evo_params.result_path = result_path;
            app.evo_params.nb_gen = textout{1};
            app.evo_params.initial_aleat = textout{2};
            app.evo_params.init_size = textout{3};
            app.evo_params.gen_size = textout{4};
            app.evo_params.evogen_dump_period = textout{5};
            app.evo_params.behav_dim = textout{6};
            app.evo_params.griddim_0 = textout{7};
            app.evo_params.griddim_1 = textout{8};
            % app.evo_params.total_time = textout{10} / 1000;
            
            [~, filename, extname] = fileparts(char(textout{9}));
            app.evo_params.env_name = strcat(filename, extname);
            
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
                return;
            end
            plot_heatmapext(app);
        end

        % Value changed function: GenIDField
        function GenIDFieldValueChanged(app, event)
            load_gen(app, str2double(app.GenIDField.Value));
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create EvolutionaryRobogamiResultViewerUIFigure and hide until all components are created
            app.EvolutionaryRobogamiResultViewerUIFigure = uifigure('Visible', 'off');
            app.EvolutionaryRobogamiResultViewerUIFigure.Position = [100 100 646 542];
            app.EvolutionaryRobogamiResultViewerUIFigure.Name = 'Evolutionary Robogami Result Viewer';

            % Create MapViewerAxes
            app.MapViewerAxes = uiaxes(app.EvolutionaryRobogamiResultViewerUIFigure);
            title(app.MapViewerAxes, '')
            xlabel(app.MapViewerAxes, '')
            ylabel(app.MapViewerAxes, '')
            app.MapViewerAxes.XTick = [];
            app.MapViewerAxes.YTick = [];
            app.MapViewerAxes.Tag = 'MapViewer';
            app.MapViewerAxes.Position = [191 14 450 450];

            % Create LoadResultButton
            app.LoadResultButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.LoadResultButton.ButtonPushedFcn = createCallbackFcn(app, @LoadResultButtonPushed, true);
            app.LoadResultButton.Tag = 'loadresult';
            app.LoadResultButton.Position = [39 472 100 22];
            app.LoadResultButton.Text = 'Load Result';

            % Create GenIDField
            app.GenIDField = uieditfield(app.EvolutionaryRobogamiResultViewerUIFigure, 'text');
            app.GenIDField.ValueChangedFcn = createCallbackFcn(app, @GenIDFieldValueChanged, true);
            app.GenIDField.HorizontalAlignment = 'center';
            app.GenIDField.Position = [68 442 39 22];

            % Create LoadNextButton
            app.LoadNextButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.LoadNextButton.ButtonPushedFcn = createCallbackFcn(app, @LoadNextButtonPushed, true);
            app.LoadNextButton.Position = [86 413 26 22];
            app.LoadNextButton.Text = '>';

            % Create LoadPrevButton
            app.LoadPrevButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.LoadPrevButton.ButtonPushedFcn = createCallbackFcn(app, @LoadPrevButtonPushed, true);
            app.LoadPrevButton.Position = [61 413 26 22];
            app.LoadPrevButton.Text = '<';

            % Create LoadNext10Button
            app.LoadNext10Button = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.LoadNext10Button.ButtonPushedFcn = createCallbackFcn(app, @LoadNext10ButtonPushed, true);
            app.LoadNext10Button.Position = [111 413 36 22];
            app.LoadNext10Button.Text = '+10';

            % Create LoadPrev10Button
            app.LoadPrev10Button = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.LoadPrev10Button.ButtonPushedFcn = createCallbackFcn(app, @LoadPrev10ButtonPushed, true);
            app.LoadPrev10Button.Position = [28 413 33 22];
            app.LoadPrev10Button.Text = '-10';

            % Create GenLabel
            app.GenLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.GenLabel.FontSize = 13;
            app.GenLabel.FontWeight = 'bold';
            app.GenLabel.Position = [35 442 35 22];
            app.GenLabel.Text = 'Gen:';

            % Create ResultInfoLabel
            app.ResultInfoLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.ResultInfoLabel.FontSize = 13;
            app.ResultInfoLabel.FontWeight = 'bold';
            app.ResultInfoLabel.Position = [6 342 77 22];
            app.ResultInfoLabel.Text = 'Result Info:';

            % Create ResultNameLabel
            app.ResultNameLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.ResultNameLabel.HorizontalAlignment = 'center';
            app.ResultNameLabel.FontSize = 16;
            app.ResultNameLabel.FontWeight = 'bold';
            app.ResultNameLabel.Position = [23 513 596 30];
            app.ResultNameLabel.Text = 'Load a result to view';

            % Create ResultInfoTextLabel
            app.ResultInfoTextLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.ResultInfoTextLabel.VerticalAlignment = 'top';
            app.ResultInfoTextLabel.Position = [23 87 185 256];
            app.ResultInfoTextLabel.Text = '';

            % Create GenInfoLabel
            app.GenInfoLabel = uilabel(app.EvolutionaryRobogamiResultViewerUIFigure);
            app.GenInfoLabel.HorizontalAlignment = 'center';
            app.GenInfoLabel.FontSize = 13;
            app.GenInfoLabel.FontWeight = 'bold';
            app.GenInfoLabel.Position = [207 472 434 22];
            app.GenInfoLabel.Text = '';

            % Create ExtPlotButton
            app.ExtPlotButton = uibutton(app.EvolutionaryRobogamiResultViewerUIFigure, 'push');
            app.ExtPlotButton.ButtonPushedFcn = createCallbackFcn(app, @ExtPlotButtonPushed, true);
            app.ExtPlotButton.Position = [38 384 100 22];
            app.ExtPlotButton.Text = 'ExtPlot';

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
