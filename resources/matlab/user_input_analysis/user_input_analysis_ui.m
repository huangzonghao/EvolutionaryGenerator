classdef user_input_analysis_ui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MainFigure                     matlab.ui.Figure
        SavePaperPlotButton            matlab.ui.control.Button
        RehashButton                   matlab.ui.control.Button
        PaperPlotButton                matlab.ui.control.Button
        AddRandomtoAddedButton         matlab.ui.control.Button
        NumRandomField                 matlab.ui.control.EditField
        NumEditFieldLabel              matlab.ui.control.Label
        SortAddedFitnessButton         matlab.ui.control.Button
        SortSelectedFitnessButton      matlab.ui.control.Button
        TotalAddedCountLabel           matlab.ui.control.Label
        ScreenshotNameField            matlab.ui.control.EditField
        PicFileLabel                   matlab.ui.control.Label
        ClearAllButton                 matlab.ui.control.Button
        CommentTextArea                matlab.ui.control.TextArea
        CommentsLabel                  matlab.ui.control.Label
        OutputBagNameField             matlab.ui.control.EditField
        BagNameLabel                   matlab.ui.control.Label
        ClearAddedListBoxButton        matlab.ui.control.Button
        SaveButton                     matlab.ui.control.Button
        RemoveButton                   matlab.ui.control.Button
        AddFromSelectedtoAddedButton   matlab.ui.control.Button
        RefreshRobotsListButton        matlab.ui.control.Button
        AddedRobotsListBox             matlab.ui.control.ListBox
        SelectedRobotsListBox          matlab.ui.control.ListBox
        CloseFigButton                 matlab.ui.control.Button
        OpenFigButton                  matlab.ui.control.Button
        ScreenShotButton               matlab.ui.control.Button
        RefRightButton                 matlab.ui.control.Button
        RefLeftButton                  matlab.ui.control.Button
        VerOrderCheckBox               matlab.ui.control.CheckBox
        AllButton                      matlab.ui.control.Button
        ClearButton                    matlab.ui.control.Button
        valleyButton                   matlab.ui.control.Button
        sineButton                     matlab.ui.control.Button
        groundButton                   matlab.ui.control.Button
        RefreshRawUserInputListButton  matlab.ui.control.Button
        VerPlotButton                  matlab.ui.control.Button
        RefreshPlotButton              matlab.ui.control.Button
        PopVarButton                   matlab.ui.control.Button
        ClearPlotButton                matlab.ui.control.Button
        ListBox                        matlab.ui.control.ListBox
        OpenFolderButton               matlab.ui.control.Button
        RobotIDYField                  matlab.ui.control.EditField
        RobotIDXField                  matlab.ui.control.EditField
        SimulateRobotButton            matlab.ui.control.Button
    end

    properties (Access = public)
        paper_fig
        plot_fig
        heat_axes
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
        fitness_range = [Inf, -Inf];
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
        user_inputs_selected = [] % a n x 3 matrix storing the n selected user inputs to be saved to output bag, one for each row
                                  % format: [user_internal_id, env_id, ver_id]
        user_inputs_added = [] % same as above
        random_robots = [] % a [n x max_gene_length] matrix containing gene for randomly generated robots
        default_env_order = ["ground", "Sine2.obj", "Valley5.obj"]
        auto_refresh_selected_list_on_next_enabled_update = true % controls if next update on results_enabled matrix would trigger an automatic update of the selected_robots_list
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

        % Button pushed function: RefreshRawUserInputListButton
        function RefreshRawUserInputListButtonPushed(app, event)
            refresh_raw_user_input_list(app);
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

        % Button pushed function: ClearAllButton
        function ClearAllButtonPushed(app, event)
            update_results_enabled(app, -2);
        end

        % Button pushed function: RefLeftButton
        function RefLeftButtonPushed(app, event)
            load_and_plot_ref(app, 'left');
        end

        % Button pushed function: RefRightButton
        function RefRightButtonPushed(app, event)
            load_and_plot_ref(app, 'right');
        end

        % Button pushed function: ScreenShotButton
        function ScreenShotButtonPushed(app, event)
            take_screenshot(app);
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

        % Button pushed function: RefreshRobotsListButton
        function RefreshRobotsListButtonPushed(app, event)
            refresh_selected_robots_list(app);
        end

        % Button pushed function: SortSelectedFitnessButton
        function SortSelectedFitnessButtonPushed(app, event)
            sort_selected_robots_list_by_fitness(app);
        end

        % Button pushed function: AddFromSelectedtoAddedButton
        function AddFromSelectedtoAddedButtonPushed(app, event)
            refresh_added_robots_list(app);
        end

        % Button pushed function: ClearAddedListBoxButton
        function ClearAddedListBoxButtonPushed(app, event)
            clear_added_robots_list(app);
        end

        % Button pushed function: RemoveButton
        function RemoveButtonPushed(app, event)
            remove_added(app);
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            save_bag(app);
        end

        % Button pushed function: SortAddedFitnessButton
        function SortAddedFitnessButtonPushed(app, event)
            sort_added_robots_list_by_fitness(app);
        end

        % Button pushed function: AddRandomtoAddedButton
        function AddRandomtoAddedButtonPushed(app, event)
            add_random_robots_to_bag(app);
        end

        % Button pushed function: PaperPlotButton
        function PaperPlotButtonPushed(app, event)
            generate_paper_plot(app);
        end

        % Button pushed function: SavePaperPlotButton
        function SavePaperPlotButtonPushed(app, event)
            save_paper_plot(app);
        end

        % Button pushed function: RehashButton
        function RehashButtonPushed(app, event)
            rehash;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MainFigure and hide until all components are created
            app.MainFigure = uifigure('Visible', 'off');
            app.MainFigure.Position = [250 20 767 660];
            app.MainFigure.Name = 'Evolutionary Robogami User Input Viewer';
            app.MainFigure.CloseRequestFcn = createCallbackFcn(app, @MainFigureCloseRequest, true);

            % Create SimulateRobotButton
            app.SimulateRobotButton = uibutton(app.MainFigure, 'push');
            app.SimulateRobotButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateRobotButtonPushed, true);
            app.SimulateRobotButton.Tag = 'loadresult';
            app.SimulateRobotButton.Position = [22 81 72 22];
            app.SimulateRobotButton.Text = 'Simulate';

            % Create RobotIDXField
            app.RobotIDXField = uieditfield(app.MainFigure, 'text');
            app.RobotIDXField.ValueChangedFcn = createCallbackFcn(app, @RobotIDXFieldValueChanged, true);
            app.RobotIDXField.HorizontalAlignment = 'center';
            app.RobotIDXField.Position = [18 108 39 22];

            % Create RobotIDYField
            app.RobotIDYField = uieditfield(app.MainFigure, 'text');
            app.RobotIDYField.ValueChangedFcn = createCallbackFcn(app, @RobotIDYFieldValueChanged, true);
            app.RobotIDYField.HorizontalAlignment = 'center';
            app.RobotIDYField.Position = [58 108 39 22];

            % Create OpenFolderButton
            app.OpenFolderButton = uibutton(app.MainFigure, 'push');
            app.OpenFolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFolderButtonPushed, true);
            app.OpenFolderButton.Tag = 'loadresult';
            app.OpenFolderButton.Position = [18 19 82 22];
            app.OpenFolderButton.Text = 'Open Folder';

            % Create ListBox
            app.ListBox = uilistbox(app.MainFigure);
            app.ListBox.Items = {};
            app.ListBox.Multiselect = 'on';
            app.ListBox.Position = [151 16 112 631];
            app.ListBox.Value = {};

            % Create ClearPlotButton
            app.ClearPlotButton = uibutton(app.MainFigure, 'push');
            app.ClearPlotButton.ButtonPushedFcn = createCallbackFcn(app, @ClearPlotButtonPushed, true);
            app.ClearPlotButton.Position = [30 347 73 22];
            app.ClearPlotButton.Text = 'ClearPlot';

            % Create PopVarButton
            app.PopVarButton = uibutton(app.MainFigure, 'push');
            app.PopVarButton.ButtonPushedFcn = createCallbackFcn(app, @PopVarButtonPushed, true);
            app.PopVarButton.Position = [18 48 73 22];
            app.PopVarButton.Text = 'Pop Var';

            % Create RefreshPlotButton
            app.RefreshPlotButton = uibutton(app.MainFigure, 'push');
            app.RefreshPlotButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshPlotButtonPushed, true);
            app.RefreshPlotButton.Position = [22 374 85 40];
            app.RefreshPlotButton.Text = 'RefreshPlot';

            % Create VerPlotButton
            app.VerPlotButton = uibutton(app.MainFigure, 'push');
            app.VerPlotButton.ButtonPushedFcn = createCallbackFcn(app, @VerPlotButtonPushed, true);
            app.VerPlotButton.Position = [23 157 104 33];
            app.VerPlotButton.Text = 'VerPlot';

            % Create RefreshRawUserInputListButton
            app.RefreshRawUserInputListButton = uibutton(app.MainFigure, 'push');
            app.RefreshRawUserInputListButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshRawUserInputListButtonPushed, true);
            app.RefreshRawUserInputListButton.Position = [22 611 86 36];
            app.RefreshRawUserInputListButton.Text = 'RefreshList';

            % Create groundButton
            app.groundButton = uibutton(app.MainFigure, 'push');
            app.groundButton.ButtonPushedFcn = createCallbackFcn(app, @groundButtonPushed, true);
            app.groundButton.Position = [38 529 57 22];
            app.groundButton.Text = 'ground';

            % Create sineButton
            app.sineButton = uibutton(app.MainFigure, 'push');
            app.sineButton.ButtonPushedFcn = createCallbackFcn(app, @sineButtonPushed, true);
            app.sineButton.Position = [38 505 57 22];
            app.sineButton.Text = 'sine';

            % Create valleyButton
            app.valleyButton = uibutton(app.MainFigure, 'push');
            app.valleyButton.ButtonPushedFcn = createCallbackFcn(app, @valleyButtonPushed, true);
            app.valleyButton.Position = [38 481 57 22];
            app.valleyButton.Text = 'valley';

            % Create ClearButton
            app.ClearButton = uibutton(app.MainFigure, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Position = [38 427 57 22];
            app.ClearButton.Text = 'Clear';

            % Create AllButton
            app.AllButton = uibutton(app.MainFigure, 'push');
            app.AllButton.ButtonPushedFcn = createCallbackFcn(app, @AllButtonPushed, true);
            app.AllButton.Position = [38 450 57 22];
            app.AllButton.Text = 'All';

            % Create VerOrderCheckBox
            app.VerOrderCheckBox = uicheckbox(app.MainFigure);
            app.VerOrderCheckBox.Text = 'default order';
            app.VerOrderCheckBox.Position = [27 135 89 22];
            app.VerOrderCheckBox.Value = true;

            % Create RefLeftButton
            app.RefLeftButton = uibutton(app.MainFigure, 'push');
            app.RefLeftButton.ButtonPushedFcn = createCallbackFcn(app, @RefLeftButtonPushed, true);
            app.RefLeftButton.Position = [12 291 50 40];
            app.RefLeftButton.Text = 'RefLeft';

            % Create RefRightButton
            app.RefRightButton = uibutton(app.MainFigure, 'push');
            app.RefRightButton.ButtonPushedFcn = createCallbackFcn(app, @RefRightButtonPushed, true);
            app.RefRightButton.Position = [70 291 57 40];
            app.RefRightButton.Text = 'RefRight';

            % Create ScreenShotButton
            app.ScreenShotButton = uibutton(app.MainFigure, 'push');
            app.ScreenShotButton.ButtonPushedFcn = createCallbackFcn(app, @ScreenShotButtonPushed, true);
            app.ScreenShotButton.Position = [34 263 78 22];
            app.ScreenShotButton.Text = 'ScreenShot';

            % Create OpenFigButton
            app.OpenFigButton = uibutton(app.MainFigure, 'push');
            app.OpenFigButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFigButtonPushed, true);
            app.OpenFigButton.Position = [18 205 54 22];
            app.OpenFigButton.Text = 'OpenFig';

            % Create CloseFigButton
            app.CloseFigButton = uibutton(app.MainFigure, 'push');
            app.CloseFigButton.ButtonPushedFcn = createCallbackFcn(app, @CloseFigButtonPushed, true);
            app.CloseFigButton.Position = [80 205 56 22];
            app.CloseFigButton.Text = 'CloseFig';

            % Create SelectedRobotsListBox
            app.SelectedRobotsListBox = uilistbox(app.MainFigure);
            app.SelectedRobotsListBox.Items = {};
            app.SelectedRobotsListBox.Multiselect = 'on';
            app.SelectedRobotsListBox.Position = [338 16 152 631];
            app.SelectedRobotsListBox.Value = {};

            % Create AddedRobotsListBox
            app.AddedRobotsListBox = uilistbox(app.MainFigure);
            app.AddedRobotsListBox.Items = {};
            app.AddedRobotsListBox.Multiselect = 'on';
            app.AddedRobotsListBox.Position = [498 16 152 631];
            app.AddedRobotsListBox.Value = {};

            % Create RefreshRobotsListButton
            app.RefreshRobotsListButton = uibutton(app.MainFigure, 'push');
            app.RefreshRobotsListButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshRobotsListButtonPushed, true);
            app.RefreshRobotsListButton.Position = [271 618 58 22];
            app.RefreshRobotsListButton.Text = 'Refresh';

            % Create AddFromSelectedtoAddedButton
            app.AddFromSelectedtoAddedButton = uibutton(app.MainFigure, 'push');
            app.AddFromSelectedtoAddedButton.ButtonPushedFcn = createCallbackFcn(app, @AddFromSelectedtoAddedButtonPushed, true);
            app.AddFromSelectedtoAddedButton.Position = [272 427 58 22];
            app.AddFromSelectedtoAddedButton.Text = 'Add';

            % Create RemoveButton
            app.RemoveButton = uibutton(app.MainFigure, 'push');
            app.RemoveButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveButtonPushed, true);
            app.RemoveButton.Position = [676 618 60 22];
            app.RemoveButton.Text = 'Remove';

            % Create SaveButton
            app.SaveButton = uibutton(app.MainFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [676 319 60 22];
            app.SaveButton.Text = 'Save';

            % Create ClearAddedListBoxButton
            app.ClearAddedListBoxButton = uibutton(app.MainFigure, 'push');
            app.ClearAddedListBoxButton.ButtonPushedFcn = createCallbackFcn(app, @ClearAddedListBoxButtonPushed, true);
            app.ClearAddedListBoxButton.Position = [677 40 60 22];
            app.ClearAddedListBoxButton.Text = 'Clear';

            % Create BagNameLabel
            app.BagNameLabel = uilabel(app.MainFigure);
            app.BagNameLabel.HorizontalAlignment = 'right';
            app.BagNameLabel.Position = [651 567 66 22];
            app.BagNameLabel.Text = 'Bag Name:';

            % Create OutputBagNameField
            app.OutputBagNameField = uieditfield(app.MainFigure, 'text');
            app.OutputBagNameField.Position = [666 541 95 23];

            % Create CommentsLabel
            app.CommentsLabel = uilabel(app.MainFigure);
            app.CommentsLabel.Position = [654 513 67 22];
            app.CommentsLabel.Text = 'Comments:';

            % Create CommentTextArea
            app.CommentTextArea = uitextarea(app.MainFigure);
            app.CommentTextArea.Position = [661 347 107 166];

            % Create ClearAllButton
            app.ClearAllButton = uibutton(app.MainFigure, 'push');
            app.ClearAllButton.ButtonPushedFcn = createCallbackFcn(app, @ClearAllButtonPushed, true);
            app.ClearAllButton.Position = [32 558 72 31];
            app.ClearAllButton.Text = 'ClearAll';

            % Create PicFileLabel
            app.PicFileLabel = uilabel(app.MainFigure);
            app.PicFileLabel.HorizontalAlignment = 'right';
            app.PicFileLabel.Position = [2 232 46 22];
            app.PicFileLabel.Text = 'Pic File';

            % Create ScreenshotNameField
            app.ScreenshotNameField = uieditfield(app.MainFigure, 'text');
            app.ScreenshotNameField.Position = [55 232 95 23];

            % Create TotalAddedCountLabel
            app.TotalAddedCountLabel = uilabel(app.MainFigure);
            app.TotalAddedCountLabel.Position = [661 81 100 22];
            app.TotalAddedCountLabel.Text = '';

            % Create SortSelectedFitnessButton
            app.SortSelectedFitnessButton = uibutton(app.MainFigure, 'push');
            app.SortSelectedFitnessButton.ButtonPushedFcn = createCallbackFcn(app, @SortSelectedFitnessButtonPushed, true);
            app.SortSelectedFitnessButton.Position = [279 590 44 22];
            app.SortSelectedFitnessButton.Text = 'SortFit';

            % Create SortAddedFitnessButton
            app.SortAddedFitnessButton = uibutton(app.MainFigure, 'push');
            app.SortAddedFitnessButton.ButtonPushedFcn = createCallbackFcn(app, @SortAddedFitnessButtonPushed, true);
            app.SortAddedFitnessButton.Position = [684 592 44 22];
            app.SortAddedFitnessButton.Text = 'SortFit';

            % Create NumEditFieldLabel
            app.NumEditFieldLabel = uilabel(app.MainFigure);
            app.NumEditFieldLabel.Position = [278 392 34 22];
            app.NumEditFieldLabel.Text = 'Num:';

            % Create NumRandomField
            app.NumRandomField = uieditfield(app.MainFigure, 'text');
            app.NumRandomField.Position = [283 365 41 22];

            % Create AddRandomtoAddedButton
            app.AddRandomtoAddedButton = uibutton(app.MainFigure, 'push');
            app.AddRandomtoAddedButton.ButtonPushedFcn = createCallbackFcn(app, @AddRandomtoAddedButtonPushed, true);
            app.AddRandomtoAddedButton.WordWrap = 'on';
            app.AddRandomtoAddedButton.Position = [268 310 65 49];
            app.AddRandomtoAddedButton.Text = 'Add Random';

            % Create PaperPlotButton
            app.PaperPlotButton = uibutton(app.MainFigure, 'push');
            app.PaperPlotButton.ButtonPushedFcn = createCallbackFcn(app, @PaperPlotButtonPushed, true);
            app.PaperPlotButton.Position = [670 242 84 22];
            app.PaperPlotButton.Text = 'Paper Plot';

            % Create RehashButton
            app.RehashButton = uibutton(app.MainFigure, 'push');
            app.RehashButton.ButtonPushedFcn = createCallbackFcn(app, @RehashButtonPushed, true);
            app.RehashButton.Position = [671 87 84 22];
            app.RehashButton.Text = 'Rehash';

            % Create SavePaperPlotButton
            app.SavePaperPlotButton = uibutton(app.MainFigure, 'push');
            app.SavePaperPlotButton.ButtonPushedFcn = createCallbackFcn(app, @SavePaperPlotButtonPushed, true);
            app.SavePaperPlotButton.WordWrap = 'on';
            app.SavePaperPlotButton.Position = [674 199 75 34];
            app.SavePaperPlotButton.Text = 'Save Paper Plot';

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
