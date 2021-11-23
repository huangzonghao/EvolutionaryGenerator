classdef result_analysis_ui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MainFigure                matlab.ui.Figure
        CompPlotNameField         matlab.ui.control.EditField
        PlotNameLabel             matlab.ui.control.Label
        AddGroupCompareButton     matlab.ui.control.Button
        GroupNameField            matlab.ui.control.EditField
        GroupNameLabel            matlab.ui.control.Label
        LoadResultGroupButton     matlab.ui.control.Button
        ResultGroupLabel          matlab.ui.control.Label
        PlotGenButton             matlab.ui.control.Button
        ResultsToCompareLabel     matlab.ui.control.Label
        RebuildResultStatButton   matlab.ui.control.Button
        ParentageStatButton       matlab.ui.control.Button
        BuildAllResultStatButton  matlab.ui.control.Button
        RefreshResultListButton   matlab.ui.control.Button
        ResultsListBox            matlab.ui.control.ListBox
        ResultsLabel              matlab.ui.control.Label
        AgeofBinsButton           matlab.ui.control.Button
        CleanCompareButton        matlab.ui.control.Button
        NickNameField             matlab.ui.control.EditField
        NicknameLabel             matlab.ui.control.Label
        BinUpdatesButton          matlab.ui.control.Button
        ParentageTreeButton       matlab.ui.control.Button
        NickNameSaveButton        matlab.ui.control.Button
        RemoveCompareButton       matlab.ui.control.Button
        AddCompareButton          matlab.ui.control.Button
        ComparePlotButton         matlab.ui.control.Button
        CompareListBox            matlab.ui.control.ListBox
        GenStepField              matlab.ui.control.EditField
        LoadFirstButton           matlab.ui.control.Button
        LoadLastButton            matlab.ui.control.Button
        OpenFolderButton          matlab.ui.control.Button
        ToLabel                   matlab.ui.control.Label
        FromLabel                 matlab.ui.control.Label
        StatEndGenField           matlab.ui.control.EditField
        StatStartGenField         matlab.ui.control.EditField
        StatPlotButton            matlab.ui.control.Button
        RobotIDYField             matlab.ui.control.EditField
        RobotIDXField             matlab.ui.control.EditField
        ResultInfoTextLabel       matlab.ui.control.Label
        ResultInfoLabel           matlab.ui.control.Label
        GenLabel                  matlab.ui.control.Label
        SimulateRobotButton       matlab.ui.control.Button
        LoadPrevStepButton        matlab.ui.control.Button
        LoadNextStepButton        matlab.ui.control.Button
        LoadPrevButton            matlab.ui.control.Button
        LoadNextButton            matlab.ui.control.Button
        GenIDField                matlab.ui.control.EditField
        LoadResultButton          matlab.ui.control.Button
        ResultNameLabel           matlab.ui.control.Label
    end

    properties (Access = public)
        % Constants
        evogen_exe_path
        evogen_results_path
        gen_step = 500
        % TODO: should read the following constant values from somewhere
        %     especially the simulator name, which is system dependent
        sim_params_filename = 'sim_params.xml'
        simulator_basename = 'Genotype_Visualizer'
        simulator_name
        generator_basename = 'Evolutionary_Generator'
        generator_name

        % Containers
        result_group_path = string.empty
        result_paths = string.empty % array containing the paths to the results
        results % array containing the cache of the loaded results
        results_to_compare % cell array containing the results to compare

        % Properties to cache for the currently loaded result
        result_loaded = false
        result_path = ""
        result_displayname string % the displayname of the result used accross different figs
        gen_plot % struct containing: handle, archive_surf_ax
        evo_params % parameters of an evolutionary generation process
        stat % variables containing the stats of the result
        stat_loaded = false
        current_gen = -1
        current_gen_archive
        robots_buffer
        robots_gen = -1
        archive_map
        archive_ids
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

            refresh_result_list(app);
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

        % Button pushed function: StatPlotButton
        function StatPlotButtonPushed(app, event)
            plot_result_stat(app);
        end

        % Button pushed function: ComparePlotButton
        function ComparePlotButtonPushed(app, event)
            plot_result_compares(app, false);
        end

        % Button pushed function: CleanCompareButton
        function CleanCompareButtonPushed(app, event)
            plot_result_compares(app, true);
        end

        % Button pushed function: AddCompareButton
        function AddCompareButtonPushed(app, event)
            add_new_to_compare(app, false);
        end

        % Button pushed function: AddGroupCompareButton
        function AddGroupCompareButtonPushed(app, event)
            add_new_to_compare(app, true);
        end

        % Button pushed function: RemoveCompareButton
        function RemoveCompareButtonPushed(app, event)
            delete_from_compare_list(app);
        end

        % Button pushed function: NickNameSaveButton
        function NickNameSaveButtonPushed(app, event)
            save_nickname(app);
        end

        % Button pushed function: OpenFolderButton
        function OpenFolderButtonPushed(app, event)
            open_folder(app);
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

        % Button pushed function: ParentageTreeButton
        function ParentageTreeButtonPushed(app, event)
            plot_parentage(app);
        end

        % Button pushed function: BinUpdatesButton
        function BinUpdatesButtonPushed(app, event)
            plot_bin_updates(app);
        end

        % Button pushed function: AgeofBinsButton
        function AgeofBinsButtonPushed(app, event)
            plot_age_of_bins(app);
        end

        % Button pushed function: RefreshResultListButton
        function RefreshResultListButtonPushed(app, event)
            refresh_result_list(app);
        end

        % Button pushed function: BuildAllResultStatButton
        function BuildAllResultStatButtonPushed(app, event)
            build_all_stat(app);
        end

        % Button pushed function: ParentageStatButton
        function ParentageStatButtonPushed(app, event)
            plot_parentage_stat(app);
        end

        % Button pushed function: RebuildResultStatButton
        function RebuildResultStatButtonPushed(app, event)
            build_selected_stat(app);
        end

        % Button pushed function: PlotGenButton
        function PlotGenButtonPushed(app, event)
            plot_gen_all(app);
        end

        % Button pushed function: LoadResultGroupButton
        function LoadResultGroupButtonPushed(app, event)
            load_group(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MainFigure and hide until all components are created
            app.MainFigure = uifigure('Visible', 'off');
            app.MainFigure.Position = [100 100 772 580];
            app.MainFigure.Name = 'Evolutionary Robogami Result Viewer';

            % Create ResultNameLabel
            app.ResultNameLabel = uilabel(app.MainFigure);
            app.ResultNameLabel.HorizontalAlignment = 'center';
            app.ResultNameLabel.FontSize = 16;
            app.ResultNameLabel.FontWeight = 'bold';
            app.ResultNameLabel.Position = [559 546 196 30];
            app.ResultNameLabel.Text = 'Load a result to view';

            % Create LoadResultButton
            app.LoadResultButton = uibutton(app.MainFigure, 'push');
            app.LoadResultButton.ButtonPushedFcn = createCallbackFcn(app, @LoadResultButtonPushed, true);
            app.LoadResultButton.Tag = 'loadresult';
            app.LoadResultButton.Position = [285 529 71 22];
            app.LoadResultButton.Text = 'Load';

            % Create GenIDField
            app.GenIDField = uieditfield(app.MainFigure, 'text');
            app.GenIDField.ValueChangedFcn = createCallbackFcn(app, @GenIDFieldValueChanged, true);
            app.GenIDField.HorizontalAlignment = 'center';
            app.GenIDField.Position = [615 378 58 22];

            % Create LoadNextButton
            app.LoadNextButton = uibutton(app.MainFigure, 'push');
            app.LoadNextButton.ButtonPushedFcn = createCallbackFcn(app, @LoadNextButtonPushed, true);
            app.LoadNextButton.Position = [647 349 25 22];
            app.LoadNextButton.Text = '>';

            % Create LoadPrevButton
            app.LoadPrevButton = uibutton(app.MainFigure, 'push');
            app.LoadPrevButton.ButtonPushedFcn = createCallbackFcn(app, @LoadPrevButtonPushed, true);
            app.LoadPrevButton.Position = [622 349 25 22];
            app.LoadPrevButton.Text = '<';

            % Create LoadNextStepButton
            app.LoadNextStepButton = uibutton(app.MainFigure, 'push');
            app.LoadNextStepButton.ButtonPushedFcn = createCallbackFcn(app, @LoadNextStepButtonPushed, true);
            app.LoadNextStepButton.Position = [669 328 30 22];
            app.LoadNextStepButton.Text = '+';

            % Create LoadPrevStepButton
            app.LoadPrevStepButton = uibutton(app.MainFigure, 'push');
            app.LoadPrevStepButton.ButtonPushedFcn = createCallbackFcn(app, @LoadPrevStepButtonPushed, true);
            app.LoadPrevStepButton.Position = [598 328 30 22];
            app.LoadPrevStepButton.Text = '-';

            % Create SimulateRobotButton
            app.SimulateRobotButton = uibutton(app.MainFigure, 'push');
            app.SimulateRobotButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateRobotButtonPushed, true);
            app.SimulateRobotButton.Tag = 'loadresult';
            app.SimulateRobotButton.Position = [567 13 55 22];
            app.SimulateRobotButton.Text = 'Simulate';

            % Create GenLabel
            app.GenLabel = uilabel(app.MainFigure);
            app.GenLabel.FontSize = 13;
            app.GenLabel.FontWeight = 'bold';
            app.GenLabel.Position = [582 378 35 22];
            app.GenLabel.Text = 'Gen:';

            % Create ResultInfoLabel
            app.ResultInfoLabel = uilabel(app.MainFigure);
            app.ResultInfoLabel.FontSize = 13;
            app.ResultInfoLabel.FontWeight = 'bold';
            app.ResultInfoLabel.Position = [563 515 77 22];
            app.ResultInfoLabel.Text = 'Result Info:';

            % Create ResultInfoTextLabel
            app.ResultInfoTextLabel = uilabel(app.MainFigure);
            app.ResultInfoTextLabel.VerticalAlignment = 'top';
            app.ResultInfoTextLabel.Position = [575 410 191 105];
            app.ResultInfoTextLabel.Text = '';

            % Create RobotIDXField
            app.RobotIDXField = uieditfield(app.MainFigure, 'text');
            app.RobotIDXField.ValueChangedFcn = createCallbackFcn(app, @RobotIDXFieldValueChanged, true);
            app.RobotIDXField.HorizontalAlignment = 'center';
            app.RobotIDXField.Position = [669 13 39 22];

            % Create RobotIDYField
            app.RobotIDYField = uieditfield(app.MainFigure, 'text');
            app.RobotIDYField.ValueChangedFcn = createCallbackFcn(app, @RobotIDYFieldValueChanged, true);
            app.RobotIDYField.HorizontalAlignment = 'center';
            app.RobotIDYField.Position = [627 13 39 22];

            % Create StatPlotButton
            app.StatPlotButton = uibutton(app.MainFigure, 'push');
            app.StatPlotButton.ButtonPushedFcn = createCallbackFcn(app, @StatPlotButtonPushed, true);
            app.StatPlotButton.Position = [566 258 64 22];
            app.StatPlotButton.Text = 'Statistics';

            % Create StatStartGenField
            app.StatStartGenField = uieditfield(app.MainFigure, 'text');
            app.StatStartGenField.ValueChangedFcn = createCallbackFcn(app, @StatStartGenFieldValueChanged, true);
            app.StatStartGenField.HorizontalAlignment = 'center';
            app.StatStartGenField.Position = [602 296 41 22];

            % Create StatEndGenField
            app.StatEndGenField = uieditfield(app.MainFigure, 'text');
            app.StatEndGenField.ValueChangedFcn = createCallbackFcn(app, @StatEndGenFieldValueChanged, true);
            app.StatEndGenField.HorizontalAlignment = 'center';
            app.StatEndGenField.Position = [669 296 62 22];

            % Create FromLabel
            app.FromLabel = uilabel(app.MainFigure);
            app.FromLabel.FontSize = 13;
            app.FromLabel.FontWeight = 'bold';
            app.FromLabel.Position = [562 296 41 22];
            app.FromLabel.Text = 'From:';

            % Create ToLabel
            app.ToLabel = uilabel(app.MainFigure);
            app.ToLabel.FontSize = 13;
            app.ToLabel.FontWeight = 'bold';
            app.ToLabel.Position = [648 296 25 22];
            app.ToLabel.Text = 'To:';

            % Create OpenFolderButton
            app.OpenFolderButton = uibutton(app.MainFigure, 'push');
            app.OpenFolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFolderButtonPushed, true);
            app.OpenFolderButton.Tag = 'loadresult';
            app.OpenFolderButton.Position = [281 13 82 22];
            app.OpenFolderButton.Text = 'Open Folder';

            % Create LoadLastButton
            app.LoadLastButton = uibutton(app.MainFigure, 'push');
            app.LoadLastButton.ButtonPushedFcn = createCallbackFcn(app, @LoadLastButtonPushed, true);
            app.LoadLastButton.Position = [672 349 25 22];
            app.LoadLastButton.Text = '>>';

            % Create LoadFirstButton
            app.LoadFirstButton = uibutton(app.MainFigure, 'push');
            app.LoadFirstButton.ButtonPushedFcn = createCallbackFcn(app, @LoadFirstButtonPushed, true);
            app.LoadFirstButton.Position = [597 349 25 22];
            app.LoadFirstButton.Text = '<<';

            % Create GenStepField
            app.GenStepField = uieditfield(app.MainFigure, 'text');
            app.GenStepField.ValueChangedFcn = createCallbackFcn(app, @GenStepFieldValueChanged, true);
            app.GenStepField.HorizontalAlignment = 'center';
            app.GenStepField.Position = [629 328 39 22];

            % Create CompareListBox
            app.CompareListBox = uilistbox(app.MainFigure);
            app.CompareListBox.Items = {};
            app.CompareListBox.Multiselect = 'on';
            app.CompareListBox.Position = [375 1 176 554];
            app.CompareListBox.Value = {};

            % Create ComparePlotButton
            app.ComparePlotButton = uibutton(app.MainFigure, 'push');
            app.ComparePlotButton.ButtonPushedFcn = createCallbackFcn(app, @ComparePlotButtonPushed, true);
            app.ComparePlotButton.Position = [293 280 63 22];
            app.ComparePlotButton.Text = 'Compare';

            % Create AddCompareButton
            app.AddCompareButton = uibutton(app.MainFigure, 'push');
            app.AddCompareButton.ButtonPushedFcn = createCallbackFcn(app, @AddCompareButtonPushed, true);
            app.AddCompareButton.Position = [303 490 37 22];
            app.AddCompareButton.Text = 'Add';

            % Create RemoveCompareButton
            app.RemoveCompareButton = uibutton(app.MainFigure, 'push');
            app.RemoveCompareButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveCompareButtonPushed, true);
            app.RemoveCompareButton.Position = [303 467 37 22];
            app.RemoveCompareButton.Text = 'Del';

            % Create NickNameSaveButton
            app.NickNameSaveButton = uibutton(app.MainFigure, 'push');
            app.NickNameSaveButton.ButtonPushedFcn = createCallbackFcn(app, @NickNameSaveButtonPushed, true);
            app.NickNameSaveButton.Tag = 'loadresult';
            app.NickNameSaveButton.Position = [278 57 90 22];
            app.NickNameSaveButton.Text = 'Set Nickname';

            % Create ParentageTreeButton
            app.ParentageTreeButton = uibutton(app.MainFigure, 'push');
            app.ParentageTreeButton.ButtonPushedFcn = createCallbackFcn(app, @ParentageTreeButtonPushed, true);
            app.ParentageTreeButton.Tag = 'loadresult';
            app.ParentageTreeButton.WordWrap = 'on';
            app.ParentageTreeButton.Position = [660 253 78 32];
            app.ParentageTreeButton.Text = 'Parentage Tree';

            % Create BinUpdatesButton
            app.BinUpdatesButton = uibutton(app.MainFigure, 'push');
            app.BinUpdatesButton.ButtonPushedFcn = createCallbackFcn(app, @BinUpdatesButtonPushed, true);
            app.BinUpdatesButton.Tag = 'loadresult';
            app.BinUpdatesButton.Position = [561 212 76 22];
            app.BinUpdatesButton.Text = 'Bin Updates';

            % Create NicknameLabel
            app.NicknameLabel = uilabel(app.MainFigure);
            app.NicknameLabel.HorizontalAlignment = 'right';
            app.NicknameLabel.Position = [275 107 62 22];
            app.NicknameLabel.Text = 'Nickname:';

            % Create NickNameField
            app.NickNameField = uieditfield(app.MainFigure, 'text');
            app.NickNameField.Position = [280 86 86 22];

            % Create CleanCompareButton
            app.CleanCompareButton = uibutton(app.MainFigure, 'push');
            app.CleanCompareButton.ButtonPushedFcn = createCallbackFcn(app, @CleanCompareButtonPushed, true);
            app.CleanCompareButton.WordWrap = 'on';
            app.CleanCompareButton.Position = [293 229 67 43];
            app.CleanCompareButton.Text = 'Clean Compare';

            % Create AgeofBinsButton
            app.AgeofBinsButton = uibutton(app.MainFigure, 'push');
            app.AgeofBinsButton.ButtonPushedFcn = createCallbackFcn(app, @AgeofBinsButtonPushed, true);
            app.AgeofBinsButton.Tag = 'loadresult';
            app.AgeofBinsButton.Position = [563 235 70 22];
            app.AgeofBinsButton.Text = 'Age of Bins';

            % Create ResultsLabel
            app.ResultsLabel = uilabel(app.MainFigure);
            app.ResultsLabel.FontWeight = 'bold';
            app.ResultsLabel.Position = [2 554 53 22];
            app.ResultsLabel.Text = 'Results:';

            % Create ResultsListBox
            app.ResultsListBox = uilistbox(app.MainFigure);
            app.ResultsListBox.Items = {};
            app.ResultsListBox.Multiselect = 'on';
            app.ResultsListBox.Position = [0 0 274 525];
            app.ResultsListBox.Value = {};

            % Create RefreshResultListButton
            app.RefreshResultListButton = uibutton(app.MainFigure, 'push');
            app.RefreshResultListButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshResultListButtonPushed, true);
            app.RefreshResultListButton.Tag = 'loadresult';
            app.RefreshResultListButton.Position = [54 556 60 22];
            app.RefreshResultListButton.Text = 'Refresh';

            % Create BuildAllResultStatButton
            app.BuildAllResultStatButton = uibutton(app.MainFigure, 'push');
            app.BuildAllResultStatButton.ButtonPushedFcn = createCallbackFcn(app, @BuildAllResultStatButtonPushed, true);
            app.BuildAllResultStatButton.Tag = 'loadresult';
            app.BuildAllResultStatButton.Position = [169 556 56 22];
            app.BuildAllResultStatButton.Text = 'BuildAll';

            % Create ParentageStatButton
            app.ParentageStatButton = uibutton(app.MainFigure, 'push');
            app.ParentageStatButton.ButtonPushedFcn = createCallbackFcn(app, @ParentageStatButtonPushed, true);
            app.ParentageStatButton.Tag = 'loadresult';
            app.ParentageStatButton.Position = [656 229 89 22];
            app.ParentageStatButton.Text = 'Parentage Stat';

            % Create RebuildResultStatButton
            app.RebuildResultStatButton = uibutton(app.MainFigure, 'push');
            app.RebuildResultStatButton.ButtonPushedFcn = createCallbackFcn(app, @RebuildResultStatButtonPushed, true);
            app.RebuildResultStatButton.Tag = 'loadresult';
            app.RebuildResultStatButton.Position = [112 556 58 22];
            app.RebuildResultStatButton.Text = 'ReBuild';

            % Create ResultsToCompareLabel
            app.ResultsToCompareLabel = uilabel(app.MainFigure);
            app.ResultsToCompareLabel.FontWeight = 'bold';
            app.ResultsToCompareLabel.Position = [375 556 119 22];
            app.ResultsToCompareLabel.Text = 'ResultsToCompare:';

            % Create PlotGenButton
            app.PlotGenButton = uibutton(app.MainFigure, 'push');
            app.PlotGenButton.ButtonPushedFcn = createCallbackFcn(app, @PlotGenButtonPushed, true);
            app.PlotGenButton.Position = [681 378 64 22];
            app.PlotGenButton.Text = 'Plot Gen';

            % Create ResultGroupLabel
            app.ResultGroupLabel = uilabel(app.MainFigure);
            app.ResultGroupLabel.HorizontalAlignment = 'center';
            app.ResultGroupLabel.FontSize = 14;
            app.ResultGroupLabel.FontWeight = 'bold';
            app.ResultGroupLabel.Position = [2 529 182 22];
            app.ResultGroupLabel.Text = 'Group';

            % Create LoadResultGroupButton
            app.LoadResultGroupButton = uibutton(app.MainFigure, 'push');
            app.LoadResultGroupButton.ButtonPushedFcn = createCallbackFcn(app, @LoadResultGroupButtonPushed, true);
            app.LoadResultGroupButton.Tag = 'loadresult';
            app.LoadResultGroupButton.Position = [204 529 70 22];
            app.LoadResultGroupButton.Text = 'LoadGroup';

            % Create GroupNameLabel
            app.GroupNameLabel = uilabel(app.MainFigure);
            app.GroupNameLabel.HorizontalAlignment = 'right';
            app.GroupNameLabel.Position = [272 439 78 22];
            app.GroupNameLabel.Text = 'Group Name:';

            % Create GroupNameField
            app.GroupNameField = uieditfield(app.MainFigure, 'text');
            app.GroupNameField.Position = [282 418 86 22];

            % Create AddGroupCompareButton
            app.AddGroupCompareButton = uibutton(app.MainFigure, 'push');
            app.AddGroupCompareButton.ButtonPushedFcn = createCallbackFcn(app, @AddGroupCompareButtonPushed, true);
            app.AddGroupCompareButton.Position = [287 387 74 22];
            app.AddGroupCompareButton.Text = 'Add Group';

            % Create PlotNameLabel
            app.PlotNameLabel = uilabel(app.MainFigure);
            app.PlotNameLabel.Position = [277 358 65 22];
            app.PlotNameLabel.Text = 'Plot Name:';

            % Create CompPlotNameField
            app.CompPlotNameField = uieditfield(app.MainFigure, 'text');
            app.CompPlotNameField.Position = [283 337 86 22];

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
