classdef result_analysis_ui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MainFigure           matlab.ui.Figure
        NickNameField        matlab.ui.control.EditField
        NickNameSaveButton   matlab.ui.control.Button
        RemoveCompareButton  matlab.ui.control.Button
        AddCompareButton     matlab.ui.control.Button
        ComparePlotButton    matlab.ui.control.Button
        CompareListBox       matlab.ui.control.ListBox
        GenStepField         matlab.ui.control.EditField
        LoadFirstButton      matlab.ui.control.Button
        LoadLastButton       matlab.ui.control.Button
        ResumeButton         matlab.ui.control.Button
        OpenFolderButton     matlab.ui.control.Button
        ToLabel              matlab.ui.control.Label
        FromLabel            matlab.ui.control.Label
        StatEndGenField      matlab.ui.control.EditField
        StatStartGenField    matlab.ui.control.EditField
        StatPlotButton       matlab.ui.control.Button
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
        LoadPrevStepButton   matlab.ui.control.Button
        LoadNextStepButton   matlab.ui.control.Button
        LoadPrevButton       matlab.ui.control.Button
        LoadNextButton       matlab.ui.control.Button
        GenIDField           matlab.ui.control.EditField
        LoadResultButton     matlab.ui.control.Button
        MapViewerAxes        matlab.ui.control.UIAxes
    end

    properties (Access = public)
        result_loaded = false
        result_path = ""
        result_basename = ""
        result_displayname
        evo_params % parameters of an evolutionary generation process
        stat % variables containing the stats of the result
        stat_loaded = false
        evogen_results_path
        evogen_exe_path
        current_gen = -1
        current_gen_archive
        current_gen_x_idx
        current_gen_y_idx
        gen_step = 500
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
        result_to_compare string
    end

    % private helper functions
    methods (Access = private)
        function bring_figure_back(app)
            figure(app.MainFigure);
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

            % init ui assets
            app.GenStepField.Value = num2str(app.gen_step);

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

        % Button pushed function: LoadNextStepButton
        function LoadNextStepButtonPushed(app, event)
            load_gen(app, app.current_gen + app.gen_step);
        end

        % Button pushed function: LoadPrevStepButton
        function LoadPrevStepButtonPushed(app, event)
            load_gen(app, app.current_gen - app.gen_step);
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
            [app.stat, app.stat_loaded] = build_stat(app.result_path, app.evo_params, app.stat, app.stat_loaded);
            app.BuildStatButton.Text = 'RebuildStat';
        end

        % Button pushed function: StatPlotButton
        function StatPlotButtonPushed(app, event)
            if (~app.stat_loaded)
                msgbox('Build Stat first');
                return;
            end
            stat_plot(app.stat, app.result_displayname, str2double(app.StatStartGenField.Value), str2double(app.StatEndGenField.Value));
        end

        % Button pushed function: ComparePlotButton
        function ComparePlotButtonPushed(app, event)
            if (app.result_to_compare.length > 1)
                compare_plot(app.result_to_compare, app.evogen_results_path);
            end
        end

        % Button pushed function: AddCompareButton
        function AddCompareButtonPushed(app, event)
            add_new_to_compare(app);
        end

        % Button pushed function: RemoveCompareButton
        function RemoveCompareButtonPushed(app, event)
            if isempty(app.CompareListBox.Value)
                return;
            end
            tmp_value = app.CompareListBox.Value;
            app.CompareListBox.Items(app.result_to_compare == tmp_value) = [];
            app.result_to_compare(app.result_to_compare == tmp_value) = [];
        end

        % Button pushed function: NickNameSaveButton
        function NickNameSaveButtonPushed(app, event)
            name = app.NickNameField.Value;
            if isempty(name)
                return;
            end
            save_nickname(app, name);
            app.NickNameSaveButton.Text = 'ReSave';
            app.result_displayname = [name, ' - (', app.result_basename, ')'];
            app.ResultNameLabel.Text = app.result_displayname;
        end

        % Button pushed function: OpenFolderButton
        function OpenFolderButtonPushed(app, event)
            winopen(app.result_path);
        end

        % Button pushed function: ResumeButton
        function ResumeButtonPushed(app, event)
            cmd_str = fullfile(app.evogen_exe_path, app.generator_name) + ...
                      " resume " + app.result_basename;
            system(cmd_str);
        end

        % Button pushed function: SimulateRobotButton
        function SimulateRobotButtonPushed(app, event)
            run_simulation(app);
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

        % Value changed function: GenStepField
        function GenStepFieldValueChanged(app, event)
            app.gen_step = max(str2double(app.GenStepField.Value), 0);
        end

        % Value changed function: StatStartGenField
        function StatStartGenFieldValueChanged(app, event)
            if (str2double(app.StatStartGenField.Value) < 0)
                app.StatStartGenField.Value = num2str(0);
            end
        end

        % Value changed function: StatEndGenField
        function StatEndGenFieldValueChanged(app, event)
            if (app.result_loaded && str2double(app.StatEndGenField.Value) > app.evo_params.nb_gen)
                app.StatEndGenField.Value = num2str(app.evo_params.nb_gen);
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MainFigure and hide until all components are created
            app.MainFigure = uifigure('Visible', 'off');
            app.MainFigure.Position = [100 100 642 577];
            app.MainFigure.Name = 'Evolutionary Robogami Result Viewer';

            % Create MapViewerAxes
            app.MapViewerAxes = uiaxes(app.MainFigure);
            app.MapViewerAxes.XTick = [];
            app.MapViewerAxes.YTick = [];
            app.MapViewerAxes.Tag = 'MapViewer';
            app.MapViewerAxes.Position = [191 49 450 450];

            % Create LoadResultButton
            app.LoadResultButton = uibutton(app.MainFigure, 'push');
            app.LoadResultButton.ButtonPushedFcn = createCallbackFcn(app, @LoadResultButtonPushed, true);
            app.LoadResultButton.Tag = 'loadresult';
            app.LoadResultButton.Position = [39 507 100 22];
            app.LoadResultButton.Text = 'Load Result';

            % Create GenIDField
            app.GenIDField = uieditfield(app.MainFigure, 'text');
            app.GenIDField.ValueChangedFcn = createCallbackFcn(app, @GenIDFieldValueChanged, true);
            app.GenIDField.HorizontalAlignment = 'center';
            app.GenIDField.Position = [68 477 58 22];

            % Create LoadNextButton
            app.LoadNextButton = uibutton(app.MainFigure, 'push');
            app.LoadNextButton.ButtonPushedFcn = createCallbackFcn(app, @LoadNextButtonPushed, true);
            app.LoadNextButton.Position = [86 448 25 22];
            app.LoadNextButton.Text = '>';

            % Create LoadPrevButton
            app.LoadPrevButton = uibutton(app.MainFigure, 'push');
            app.LoadPrevButton.ButtonPushedFcn = createCallbackFcn(app, @LoadPrevButtonPushed, true);
            app.LoadPrevButton.Position = [61 448 25 22];
            app.LoadPrevButton.Text = '<';

            % Create LoadNextStepButton
            app.LoadNextStepButton = uibutton(app.MainFigure, 'push');
            app.LoadNextStepButton.ButtonPushedFcn = createCallbackFcn(app, @LoadNextStepButtonPushed, true);
            app.LoadNextStepButton.Position = [108 427 30 22];
            app.LoadNextStepButton.Text = '+';

            % Create LoadPrevStepButton
            app.LoadPrevStepButton = uibutton(app.MainFigure, 'push');
            app.LoadPrevStepButton.ButtonPushedFcn = createCallbackFcn(app, @LoadPrevStepButtonPushed, true);
            app.LoadPrevStepButton.Position = [37 427 30 22];
            app.LoadPrevStepButton.Text = '-';

            % Create SimulateRobotButton
            app.SimulateRobotButton = uibutton(app.MainFigure, 'push');
            app.SimulateRobotButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateRobotButtonPushed, true);
            app.SimulateRobotButton.Tag = 'loadresult';
            app.SimulateRobotButton.Position = [326 11 72 22];
            app.SimulateRobotButton.Text = 'Simulate';

            % Create GenLabel
            app.GenLabel = uilabel(app.MainFigure);
            app.GenLabel.FontSize = 13;
            app.GenLabel.FontWeight = 'bold';
            app.GenLabel.Position = [35 477 35 22];
            app.GenLabel.Text = 'Gen:';

            % Create ResultInfoLabel
            app.ResultInfoLabel = uilabel(app.MainFigure);
            app.ResultInfoLabel.FontSize = 13;
            app.ResultInfoLabel.FontWeight = 'bold';
            app.ResultInfoLabel.Position = [4 237 77 22];
            app.ResultInfoLabel.Text = 'Result Info:';

            % Create ResultNameLabel
            app.ResultNameLabel = uilabel(app.MainFigure);
            app.ResultNameLabel.HorizontalAlignment = 'center';
            app.ResultNameLabel.FontSize = 16;
            app.ResultNameLabel.FontWeight = 'bold';
            app.ResultNameLabel.Position = [23 548 596 30];
            app.ResultNameLabel.Text = 'Load a result to view';

            % Create ResultInfoTextLabel
            app.ResultInfoTextLabel = uilabel(app.MainFigure);
            app.ResultInfoTextLabel.VerticalAlignment = 'top';
            app.ResultInfoTextLabel.Position = [23 118 185 120];
            app.ResultInfoTextLabel.Text = '';

            % Create GenInfoLabel
            app.GenInfoLabel = uilabel(app.MainFigure);
            app.GenInfoLabel.HorizontalAlignment = 'center';
            app.GenInfoLabel.FontSize = 13;
            app.GenInfoLabel.FontWeight = 'bold';
            app.GenInfoLabel.Position = [207 507 434 22];
            app.GenInfoLabel.Text = '';

            % Create BuildStatButton
            app.BuildStatButton = uibutton(app.MainFigure, 'push');
            app.BuildStatButton.ButtonPushedFcn = createCallbackFcn(app, @BuildStatButtonPushed, true);
            app.BuildStatButton.Position = [558 12 73 22];
            app.BuildStatButton.Text = 'BuildStat';

            % Create RobotIDXField
            app.RobotIDXField = uieditfield(app.MainFigure, 'text');
            app.RobotIDXField.ValueChangedFcn = createCallbackFcn(app, @RobotIDXFieldValueChanged, true);
            app.RobotIDXField.HorizontalAlignment = 'center';
            app.RobotIDXField.Position = [239 11 39 22];

            % Create RobotIDYField
            app.RobotIDYField = uieditfield(app.MainFigure, 'text');
            app.RobotIDYField.ValueChangedFcn = createCallbackFcn(app, @RobotIDYFieldValueChanged, true);
            app.RobotIDYField.HorizontalAlignment = 'center';
            app.RobotIDYField.Position = [283 11 39 22];

            % Create RobotInfoLabel
            app.RobotInfoLabel = uilabel(app.MainFigure);
            app.RobotInfoLabel.Position = [14 11 217 22];
            app.RobotInfoLabel.Text = '';

            % Create StatPlotButton
            app.StatPlotButton = uibutton(app.MainFigure, 'push');
            app.StatPlotButton.ButtonPushedFcn = createCallbackFcn(app, @StatPlotButtonPushed, true);
            app.StatPlotButton.Position = [39 366 57 22];
            app.StatPlotButton.Text = 'StatPlot';

            % Create StatStartGenField
            app.StatStartGenField = uieditfield(app.MainFigure, 'text');
            app.StatStartGenField.ValueChangedFcn = createCallbackFcn(app, @StatStartGenFieldValueChanged, true);
            app.StatStartGenField.HorizontalAlignment = 'center';
            app.StatStartGenField.Position = [55 391 41 22];

            % Create StatEndGenField
            app.StatEndGenField = uieditfield(app.MainFigure, 'text');
            app.StatEndGenField.ValueChangedFcn = createCallbackFcn(app, @StatEndGenFieldValueChanged, true);
            app.StatEndGenField.HorizontalAlignment = 'center';
            app.StatEndGenField.Position = [122 391 62 22];

            % Create FromLabel
            app.FromLabel = uilabel(app.MainFigure);
            app.FromLabel.FontSize = 13;
            app.FromLabel.FontWeight = 'bold';
            app.FromLabel.Position = [15 391 41 22];
            app.FromLabel.Text = 'From:';

            % Create ToLabel
            app.ToLabel = uilabel(app.MainFigure);
            app.ToLabel.FontSize = 13;
            app.ToLabel.FontWeight = 'bold';
            app.ToLabel.Position = [101 391 25 22];
            app.ToLabel.Text = 'To:';

            % Create OpenFolderButton
            app.OpenFolderButton = uibutton(app.MainFigure, 'push');
            app.OpenFolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFolderButtonPushed, true);
            app.OpenFolderButton.Tag = 'loadresult';
            app.OpenFolderButton.Position = [476 12 82 22];
            app.OpenFolderButton.Text = 'Open Folder';

            % Create ResumeButton
            app.ResumeButton = uibutton(app.MainFigure, 'push');
            app.ResumeButton.ButtonPushedFcn = createCallbackFcn(app, @ResumeButtonPushed, true);
            app.ResumeButton.Position = [402 12 73 22];
            app.ResumeButton.Text = 'Resume';

            % Create LoadLastButton
            app.LoadLastButton = uibutton(app.MainFigure, 'push');
            app.LoadLastButton.ButtonPushedFcn = createCallbackFcn(app, @LoadLastButtonPushed, true);
            app.LoadLastButton.Position = [111 448 25 22];
            app.LoadLastButton.Text = '>>';

            % Create LoadFirstButton
            app.LoadFirstButton = uibutton(app.MainFigure, 'push');
            app.LoadFirstButton.ButtonPushedFcn = createCallbackFcn(app, @LoadFirstButtonPushed, true);
            app.LoadFirstButton.Position = [36 448 25 22];
            app.LoadFirstButton.Text = '<<';

            % Create GenStepField
            app.GenStepField = uieditfield(app.MainFigure, 'text');
            app.GenStepField.ValueChangedFcn = createCallbackFcn(app, @GenStepFieldValueChanged, true);
            app.GenStepField.HorizontalAlignment = 'center';
            app.GenStepField.Position = [68 427 39 22];

            % Create CompareListBox
            app.CompareListBox = uilistbox(app.MainFigure);
            app.CompareListBox.Items = {};
            app.CompareListBox.Position = [47 261 146 98];
            app.CompareListBox.Value = {};

            % Create ComparePlotButton
            app.ComparePlotButton = uibutton(app.MainFigure, 'push');
            app.ComparePlotButton.ButtonPushedFcn = createCallbackFcn(app, @ComparePlotButtonPushed, true);
            app.ComparePlotButton.Position = [98 366 86 22];
            app.ComparePlotButton.Text = 'ComparePlot';

            % Create AddCompareButton
            app.AddCompareButton = uibutton(app.MainFigure, 'push');
            app.AddCompareButton.ButtonPushedFcn = createCallbackFcn(app, @AddCompareButtonPushed, true);
            app.AddCompareButton.Position = [5 337 37 22];
            app.AddCompareButton.Text = 'Add';

            % Create RemoveCompareButton
            app.RemoveCompareButton = uibutton(app.MainFigure, 'push');
            app.RemoveCompareButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveCompareButtonPushed, true);
            app.RemoveCompareButton.Position = [5 315 37 22];
            app.RemoveCompareButton.Text = 'Del';

            % Create NickNameSaveButton
            app.NickNameSaveButton = uibutton(app.MainFigure, 'push');
            app.NickNameSaveButton.ButtonPushedFcn = createCallbackFcn(app, @NickNameSaveButtonPushed, true);
            app.NickNameSaveButton.Tag = 'loadresult';
            app.NickNameSaveButton.Position = [138 88 50 22];
            app.NickNameSaveButton.Text = 'Save';

            % Create NickNameField
            app.NickNameField = uieditfield(app.MainFigure, 'text');
            app.NickNameField.HorizontalAlignment = 'center';
            app.NickNameField.Position = [5 88 134 22];

            % Show the figure after all components are created
            app.MainFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = result_analysis_ui(varargin)

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