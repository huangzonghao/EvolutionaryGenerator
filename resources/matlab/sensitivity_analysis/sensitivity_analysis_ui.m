classdef sensitivity_analysis_ui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MainFigure               matlab.ui.Figure
        DebugPanel               matlab.ui.container.Panel
        CLCButton                matlab.ui.control.Button
        RehashButton             matlab.ui.control.Button
        ResultsPanel             matlab.ui.container.Panel
        ResultGroupLabel         matlab.ui.control.Label
        RefreshResultListButton  matlab.ui.control.Button
        LoadResultGroupButton    matlab.ui.control.Button
        VirtualResultsListBox    matlab.ui.control.ListBox
        ResultsListBox           matlab.ui.control.ListBox
        SensitivityPanel         matlab.ui.container.Panel
        BodyWidthButton          matlab.ui.control.Button
        MaxLegLengthButton       matlab.ui.control.Button
        AverageLegLengthButton   matlab.ui.control.Button
        SanitizeArchiveCheckBox  matlab.ui.control.CheckBox
        BodyLengthButton         matlab.ui.control.Button
    end

    properties (Access = public)
        % Constants
        evogen_python_path
        evogen_exe_path
        evogen_results_path
        simulator_basename = 'Genotype_Visualizer'
        simulator_name
        generator_basename = 'Evolutionary_Generator'
        generator_name

        % Containers
        result_group_path = string.empty
        results = {} % array containing the cache of the loaded results
        current_result = {}
        virtual_results = {} % array containing the cache of virtual results
        plot_handles % containing handles to plots
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, evogen_python_path, evogen_exe_path, evogen_results_path)
            app.evogen_python_path = evogen_python_path;
            app.evogen_exe_path = evogen_exe_path;
            app.evogen_results_path = evogen_results_path;
            sensitivity_analysis_init(app);
        end

        % Button pushed function: LoadResultGroupButton
        function LoadResultGroupButtonPushed(app, event)
            load_group(app);
        end

        % Button pushed function: RefreshResultListButton
        function RefreshResultListButtonPushed(app, event)
            refresh_result_list(app, 'ForceUpdate', true);
        end

        % Button pushed function: RehashButton
        function RehashButtonPushed(app, event)
            rehash;
        end

        % Button pushed function: CLCButton
        function CLCButtonPushed(app, event)
            clc;
        end

        % Button pushed function: BodyLengthButton
        function BodyLengthButtonPushed(app, event)
            analyze_body_length(app);
        end

        % Button pushed function: BodyWidthButton
        function BodyWidthButtonPushed(app, event)
            
        end

        % Button pushed function: AverageLegLengthButton
        function AverageLegLengthButtonPushed(app, event)
            
        end

        % Button pushed function: MaxLegLengthButton
        function MaxLegLengthButtonPushed(app, event)
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MainFigure and hide until all components are created
            app.MainFigure = uifigure('Visible', 'off');
            app.MainFigure.Position = [100 100 931 580];
            app.MainFigure.Name = 'Evolutionary Robogami Result Viewer';

            % Create SensitivityPanel
            app.SensitivityPanel = uipanel(app.MainFigure);
            app.SensitivityPanel.Title = 'Sensitivity';
            app.SensitivityPanel.FontWeight = 'bold';
            app.SensitivityPanel.Position = [578 1 255 580];

            % Create BodyLengthButton
            app.BodyLengthButton = uibutton(app.SensitivityPanel, 'push');
            app.BodyLengthButton.ButtonPushedFcn = createCallbackFcn(app, @BodyLengthButtonPushed, true);
            app.BodyLengthButton.Position = [11 495 83 22];
            app.BodyLengthButton.Text = 'Body Length';

            % Create SanitizeArchiveCheckBox
            app.SanitizeArchiveCheckBox = uicheckbox(app.SensitivityPanel);
            app.SanitizeArchiveCheckBox.Text = 'Sanitize Archive';
            app.SanitizeArchiveCheckBox.Position = [10 522 107 22];

            % Create AverageLegLengthButton
            app.AverageLegLengthButton = uibutton(app.SensitivityPanel, 'push');
            app.AverageLegLengthButton.ButtonPushedFcn = createCallbackFcn(app, @AverageLegLengthButtonPushed, true);
            app.AverageLegLengthButton.Position = [10 427 123 22];
            app.AverageLegLengthButton.Text = 'Average Leg Length';

            % Create MaxLegLengthButton
            app.MaxLegLengthButton = uibutton(app.SensitivityPanel, 'push');
            app.MaxLegLengthButton.ButtonPushedFcn = createCallbackFcn(app, @MaxLegLengthButtonPushed, true);
            app.MaxLegLengthButton.Position = [10 396 102 22];
            app.MaxLegLengthButton.Text = 'Max Leg Length';

            % Create BodyWidthButton
            app.BodyWidthButton = uibutton(app.SensitivityPanel, 'push');
            app.BodyWidthButton.ButtonPushedFcn = createCallbackFcn(app, @BodyWidthButtonPushed, true);
            app.BodyWidthButton.Position = [11 462 83 22];
            app.BodyWidthButton.Text = 'Body Width';

            % Create ResultsPanel
            app.ResultsPanel = uipanel(app.MainFigure);
            app.ResultsPanel.Title = 'Results';
            app.ResultsPanel.FontWeight = 'bold';
            app.ResultsPanel.Position = [1 1 578 580];

            % Create ResultsListBox
            app.ResultsListBox = uilistbox(app.ResultsPanel);
            app.ResultsListBox.Items = {};
            app.ResultsListBox.Multiselect = 'on';
            app.ResultsListBox.Position = [87 2 274 532];
            app.ResultsListBox.Value = {};

            % Create VirtualResultsListBox
            app.VirtualResultsListBox = uilistbox(app.ResultsPanel);
            app.VirtualResultsListBox.Items = {};
            app.VirtualResultsListBox.Multiselect = 'on';
            app.VirtualResultsListBox.Position = [376 2 176 532];
            app.VirtualResultsListBox.Value = {};

            % Create LoadResultGroupButton
            app.LoadResultGroupButton = uibutton(app.ResultsPanel, 'push');
            app.LoadResultGroupButton.ButtonPushedFcn = createCallbackFcn(app, @LoadResultGroupButtonPushed, true);
            app.LoadResultGroupButton.Tag = 'loadresult';
            app.LoadResultGroupButton.WordWrap = 'on';
            app.LoadResultGroupButton.Position = [10 516 62 35];
            app.LoadResultGroupButton.Text = 'Load Group';

            % Create RefreshResultListButton
            app.RefreshResultListButton = uibutton(app.ResultsPanel, 'push');
            app.RefreshResultListButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshResultListButtonPushed, true);
            app.RefreshResultListButton.Tag = 'loadresult';
            app.RefreshResultListButton.Position = [10 483 62 22];
            app.RefreshResultListButton.Text = 'Refresh';

            % Create ResultGroupLabel
            app.ResultGroupLabel = uilabel(app.ResultsPanel);
            app.ResultGroupLabel.HorizontalAlignment = 'center';
            app.ResultGroupLabel.FontSize = 14;
            app.ResultGroupLabel.FontWeight = 'bold';
            app.ResultGroupLabel.Position = [89 536 271 22];
            app.ResultGroupLabel.Text = 'Group';

            % Create DebugPanel
            app.DebugPanel = uipanel(app.MainFigure);
            app.DebugPanel.Title = 'Debug';
            app.DebugPanel.FontWeight = 'bold';
            app.DebugPanel.Position = [832 1 100 580];

            % Create RehashButton
            app.RehashButton = uibutton(app.DebugPanel, 'push');
            app.RehashButton.ButtonPushedFcn = createCallbackFcn(app, @RehashButtonPushed, true);
            app.RehashButton.Tag = 'loadresult';
            app.RehashButton.Position = [21 522 57 22];
            app.RehashButton.Text = 'Rehash';

            % Create CLCButton
            app.CLCButton = uibutton(app.DebugPanel, 'push');
            app.CLCButton.ButtonPushedFcn = createCallbackFcn(app, @CLCButtonPushed, true);
            app.CLCButton.Tag = 'loadresult';
            app.CLCButton.Position = [21 496 57 22];
            app.CLCButton.Text = 'CLC';

            % Show the figure after all components are created
            app.MainFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = sensitivity_analysis_ui(varargin)

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