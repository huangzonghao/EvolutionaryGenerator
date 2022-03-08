classdef user_input_analysis_ui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MainFigure                     matlab.ui.Figure
        MiscellaneousPanel             matlab.ui.container.Panel
        CLCButton                      matlab.ui.control.Button
        PopVarButton                   matlab.ui.control.Button
        OpenFolderButton               matlab.ui.control.Button
        RobotIDYField                  matlab.ui.control.EditField
        RobotIDXField                  matlab.ui.control.EditField
        SimulateRobotButton            matlab.ui.control.Button
        SavePaperPlotButton            matlab.ui.control.Button
        RehashButton                   matlab.ui.control.Button
        PaperPlotButton                matlab.ui.control.Button
        UserDesignBagCreatorPanel      matlab.ui.container.Panel
        NumRandomField                 matlab.ui.control.EditField
        NumEditFieldLabel              matlab.ui.control.Label
        AddRandomtoAddedButton         matlab.ui.control.Button
        ClearAddedListBoxButton        matlab.ui.control.Button
        TotalAddedCountLabel           matlab.ui.control.Label
        CommentTextArea                matlab.ui.control.TextArea
        CommentsLabel                  matlab.ui.control.Label
        OutputBagNameField             matlab.ui.control.EditField
        BagNameLabel                   matlab.ui.control.Label
        SortAddedFitnessButton         matlab.ui.control.Button
        SaveButton                     matlab.ui.control.Button
        RemoveButton                   matlab.ui.control.Button
        AddedRobotsListBox             matlab.ui.control.ListBox
        UserDesignExplorerPanel        matlab.ui.container.Panel
        SortSelectedFitnessButton      matlab.ui.control.Button
        AddFromSelectedtoAddedButton   matlab.ui.control.Button
        RefreshRobotsListButton        matlab.ui.control.Button
        SelectedRobotsListBox          matlab.ui.control.ListBox
        UserInputFileExplorerPanel     matlab.ui.container.Panel
        UserInputGroupNameLabel        matlab.ui.control.Label
        LoadUserInputGroupButton       matlab.ui.control.Button
        UserRelatedPlotsPanel          matlab.ui.container.Panel
        FeaturePlotPrevUserButton      matlab.ui.control.Button
        FeaturePlotNextUserButton      matlab.ui.control.Button
        FeaturePlotButton              matlab.ui.control.Button
        VerOrderCheckBox               matlab.ui.control.CheckBox
        VerPlotButton                  matlab.ui.control.Button
        ResetCompareGroupButton        matlab.ui.control.Button
        LoadCompareGroupButton         matlab.ui.control.Button
        CompareUsertoTrainingPanel     matlab.ui.container.Panel
        ScreenshotNameField            matlab.ui.control.EditField
        PicFileLabel                   matlab.ui.control.Label
        CloseFigButton                 matlab.ui.control.Button
        OpenFigButton                  matlab.ui.control.Button
        ScreenShotButton               matlab.ui.control.Button
        RefRightButton                 matlab.ui.control.Button
        RefLeftButton                  matlab.ui.control.Button
        RefreshPlotButton              matlab.ui.control.Button
        ClearPlotButton                matlab.ui.control.Button
        UserDesignFilterPanel          matlab.ui.container.Panel
        ClearAllButton                 matlab.ui.control.Button
        AllButton                      matlab.ui.control.Button
        ClearButton                    matlab.ui.control.Button
        valleyButton                   matlab.ui.control.Button
        sineButton                     matlab.ui.control.Button
        groundButton                   matlab.ui.control.Button
        RefreshRawUserInputListButton  matlab.ui.control.Button
        UserInputFileListBox           matlab.ui.control.ListBox
    end

    properties (Access = public)
        % User Input ref plot
        % TODO: merge the following into a structure
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
        archive_map

        paper_fig
        feature_plot_fig
        results = {}
        fitness_range = [Inf, -Inf];
        evo_params % parameters of an evolutionary generation process
        user_input_group
        compare_group = false

        % Constants
        user_input_dir
        training_results_dir
        evogen_exe_path
        simulator_basename = 'Genotype_Visualizer'
        simulator_name
        map_dim_0 = 20
        map_dim_1 = 20
        default_feature_description string

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

        % Button pushed function: FeaturePlotButton
        function FeaturePlotButtonPushed(app, event)
            plot_ver_features(app);
        end

        % Button pushed function: FeaturePlotNextUserButton
        function FeaturePlotNextUserButtonPushed(app, event)
            feature_plot_next_user(app);
        end

        % Button pushed function: FeaturePlotPrevUserButton
        function FeaturePlotPrevUserButtonPushed(app, event)
            feature_plot_prev_user(app);
        end

        % Button pushed function: LoadUserInputGroupButton
        function LoadUserInputGroupButtonPushed(app, event)
            load_user_input_group(app);
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

        % Button pushed function: LoadCompareGroupButton
        function LoadCompareGroupButtonPushed(app, event)
            load_compare_group(app);
        end

        % Button pushed function: ResetCompareGroupButton
        function ResetCompareGroupButtonPushed(app, event)
            reset_compare_group(app);
        end

        % Button pushed function: CLCButton
        function CLCButtonPushed(app, event)
            clc;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MainFigure and hide until all components are created
            app.MainFigure = uifigure('Visible', 'off');
            app.MainFigure.Position = [250 20 1150 660];
            app.MainFigure.Name = 'Evolutionary Robogami User Input Viewer';
            app.MainFigure.CloseRequestFcn = createCallbackFcn(app, @MainFigureCloseRequest, true);

            % Create UserInputFileExplorerPanel
            app.UserInputFileExplorerPanel = uipanel(app.MainFigure);
            app.UserInputFileExplorerPanel.Title = 'User Input File Explorer';
            app.UserInputFileExplorerPanel.Position = [1 1 405 660];

            % Create UserInputFileListBox
            app.UserInputFileListBox = uilistbox(app.UserInputFileExplorerPanel);
            app.UserInputFileListBox.Items = {};
            app.UserInputFileListBox.Multiselect = 'on';
            app.UserInputFileListBox.Position = [2 0 112 614];
            app.UserInputFileListBox.Value = {};

            % Create RefreshRawUserInputListButton
            app.RefreshRawUserInputListButton = uibutton(app.UserInputFileExplorerPanel, 'push');
            app.RefreshRawUserInputListButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshRawUserInputListButtonPushed, true);
            app.RefreshRawUserInputListButton.Position = [122 527 86 36];
            app.RefreshRawUserInputListButton.Text = 'RefreshList';

            % Create UserDesignFilterPanel
            app.UserDesignFilterPanel = uipanel(app.UserInputFileExplorerPanel);
            app.UserDesignFilterPanel.Title = 'User Design Filter';
            app.UserDesignFilterPanel.Position = [114 0 115 521];

            % Create groundButton
            app.groundButton = uibutton(app.UserDesignFilterPanel, 'push');
            app.groundButton.ButtonPushedFcn = createCallbackFcn(app, @groundButtonPushed, true);
            app.groundButton.Position = [27 430 57 22];
            app.groundButton.Text = 'ground';

            % Create sineButton
            app.sineButton = uibutton(app.UserDesignFilterPanel, 'push');
            app.sineButton.ButtonPushedFcn = createCallbackFcn(app, @sineButtonPushed, true);
            app.sineButton.Position = [27 406 57 22];
            app.sineButton.Text = 'sine';

            % Create valleyButton
            app.valleyButton = uibutton(app.UserDesignFilterPanel, 'push');
            app.valleyButton.ButtonPushedFcn = createCallbackFcn(app, @valleyButtonPushed, true);
            app.valleyButton.Position = [27 382 57 22];
            app.valleyButton.Text = 'valley';

            % Create ClearButton
            app.ClearButton = uibutton(app.UserDesignFilterPanel, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Position = [27 328 57 22];
            app.ClearButton.Text = 'Clear';

            % Create AllButton
            app.AllButton = uibutton(app.UserDesignFilterPanel, 'push');
            app.AllButton.ButtonPushedFcn = createCallbackFcn(app, @AllButtonPushed, true);
            app.AllButton.Position = [27 351 57 22];
            app.AllButton.Text = 'All';

            % Create ClearAllButton
            app.ClearAllButton = uibutton(app.UserDesignFilterPanel, 'push');
            app.ClearAllButton.ButtonPushedFcn = createCallbackFcn(app, @ClearAllButtonPushed, true);
            app.ClearAllButton.Position = [21 459 72 31];
            app.ClearAllButton.Text = 'ClearAll';

            % Create CompareUsertoTrainingPanel
            app.CompareUsertoTrainingPanel = uipanel(app.UserInputFileExplorerPanel);
            app.CompareUsertoTrainingPanel.Title = 'Compare User to Training';
            app.CompareUsertoTrainingPanel.Position = [229 388 176 252];

            % Create ClearPlotButton
            app.ClearPlotButton = uibutton(app.CompareUsertoTrainingPanel, 'push');
            app.ClearPlotButton.ButtonPushedFcn = createCallbackFcn(app, @ClearPlotButtonPushed, true);
            app.ClearPlotButton.Position = [6 155 73 22];
            app.ClearPlotButton.Text = 'ClearPlot';

            % Create RefreshPlotButton
            app.RefreshPlotButton = uibutton(app.CompareUsertoTrainingPanel, 'push');
            app.RefreshPlotButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshPlotButtonPushed, true);
            app.RefreshPlotButton.Position = [6 186 85 40];
            app.RefreshPlotButton.Text = 'RefreshPlot';

            % Create RefLeftButton
            app.RefLeftButton = uibutton(app.CompareUsertoTrainingPanel, 'push');
            app.RefLeftButton.ButtonPushedFcn = createCallbackFcn(app, @RefLeftButtonPushed, true);
            app.RefLeftButton.Position = [107 188 50 40];
            app.RefLeftButton.Text = 'RefLeft';

            % Create RefRightButton
            app.RefRightButton = uibutton(app.CompareUsertoTrainingPanel, 'push');
            app.RefRightButton.ButtonPushedFcn = createCallbackFcn(app, @RefRightButtonPushed, true);
            app.RefRightButton.Position = [103 145 57 40];
            app.RefRightButton.Text = 'RefRight';

            % Create ScreenShotButton
            app.ScreenShotButton = uibutton(app.CompareUsertoTrainingPanel, 'push');
            app.ScreenShotButton.ButtonPushedFcn = createCallbackFcn(app, @ScreenShotButtonPushed, true);
            app.ScreenShotButton.Position = [13 78 78 22];
            app.ScreenShotButton.Text = 'ScreenShot';

            % Create OpenFigButton
            app.OpenFigButton = uibutton(app.CompareUsertoTrainingPanel, 'push');
            app.OpenFigButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFigButtonPushed, true);
            app.OpenFigButton.Position = [13 42 54 22];
            app.OpenFigButton.Text = 'OpenFig';

            % Create CloseFigButton
            app.CloseFigButton = uibutton(app.CompareUsertoTrainingPanel, 'push');
            app.CloseFigButton.ButtonPushedFcn = createCallbackFcn(app, @CloseFigButtonPushed, true);
            app.CloseFigButton.Position = [101 42 56 22];
            app.CloseFigButton.Text = 'CloseFig';

            % Create PicFileLabel
            app.PicFileLabel = uilabel(app.CompareUsertoTrainingPanel);
            app.PicFileLabel.HorizontalAlignment = 'right';
            app.PicFileLabel.Position = [13 110 46 22];
            app.PicFileLabel.Text = 'Pic File';

            % Create ScreenshotNameField
            app.ScreenshotNameField = uieditfield(app.CompareUsertoTrainingPanel, 'text');
            app.ScreenshotNameField.Position = [66 110 95 23];

            % Create UserRelatedPlotsPanel
            app.UserRelatedPlotsPanel = uipanel(app.UserInputFileExplorerPanel);
            app.UserRelatedPlotsPanel.Title = 'User Related Plots';
            app.UserRelatedPlotsPanel.Position = [229 0 176 389];

            % Create LoadCompareGroupButton
            app.LoadCompareGroupButton = uibutton(app.UserRelatedPlotsPanel, 'push');
            app.LoadCompareGroupButton.ButtonPushedFcn = createCallbackFcn(app, @LoadCompareGroupButtonPushed, true);
            app.LoadCompareGroupButton.WordWrap = 'on';
            app.LoadCompareGroupButton.Position = [8 305 61 50];
            app.LoadCompareGroupButton.Text = 'Load Compare Group';

            % Create ResetCompareGroupButton
            app.ResetCompareGroupButton = uibutton(app.UserRelatedPlotsPanel, 'push');
            app.ResetCompareGroupButton.ButtonPushedFcn = createCallbackFcn(app, @ResetCompareGroupButtonPushed, true);
            app.ResetCompareGroupButton.WordWrap = 'on';
            app.ResetCompareGroupButton.Position = [79 305 61 50];
            app.ResetCompareGroupButton.Text = 'Reset Compare Group';

            % Create VerPlotButton
            app.VerPlotButton = uibutton(app.UserRelatedPlotsPanel, 'push');
            app.VerPlotButton.ButtonPushedFcn = createCallbackFcn(app, @VerPlotButtonPushed, true);
            app.VerPlotButton.Position = [32 274 47 20];
            app.VerPlotButton.Text = 'VerPlot';

            % Create VerOrderCheckBox
            app.VerOrderCheckBox = uicheckbox(app.UserRelatedPlotsPanel);
            app.VerOrderCheckBox.Text = 'default order';
            app.VerOrderCheckBox.Position = [35 248 89 22];
            app.VerOrderCheckBox.Value = true;

            % Create FeaturePlotButton
            app.FeaturePlotButton = uibutton(app.UserRelatedPlotsPanel, 'push');
            app.FeaturePlotButton.ButtonPushedFcn = createCallbackFcn(app, @FeaturePlotButtonPushed, true);
            app.FeaturePlotButton.Position = [32 225 72 22];
            app.FeaturePlotButton.Text = 'FeaturePlot';

            % Create FeaturePlotNextUserButton
            app.FeaturePlotNextUserButton = uibutton(app.UserRelatedPlotsPanel, 'push');
            app.FeaturePlotNextUserButton.ButtonPushedFcn = createCallbackFcn(app, @FeaturePlotNextUserButtonPushed, true);
            app.FeaturePlotNextUserButton.Position = [79 197 42 25];
            app.FeaturePlotNextUserButton.Text = 'Next';

            % Create FeaturePlotPrevUserButton
            app.FeaturePlotPrevUserButton = uibutton(app.UserRelatedPlotsPanel, 'push');
            app.FeaturePlotPrevUserButton.ButtonPushedFcn = createCallbackFcn(app, @FeaturePlotPrevUserButtonPushed, true);
            app.FeaturePlotPrevUserButton.Position = [15 197 46 25];
            app.FeaturePlotPrevUserButton.Text = 'Prev';

            % Create LoadUserInputGroupButton
            app.LoadUserInputGroupButton = uibutton(app.UserInputFileExplorerPanel, 'push');
            app.LoadUserInputGroupButton.ButtonPushedFcn = createCallbackFcn(app, @LoadUserInputGroupButtonPushed, true);
            app.LoadUserInputGroupButton.Position = [122 575 86 36];
            app.LoadUserInputGroupButton.Text = 'LoadGroup';

            % Create UserInputGroupNameLabel
            app.UserInputGroupNameLabel = uilabel(app.UserInputFileExplorerPanel);
            app.UserInputGroupNameLabel.HorizontalAlignment = 'center';
            app.UserInputGroupNameLabel.FontSize = 14;
            app.UserInputGroupNameLabel.FontWeight = 'bold';
            app.UserInputGroupNameLabel.Position = [7 615 214 22];
            app.UserInputGroupNameLabel.Text = '';

            % Create UserDesignExplorerPanel
            app.UserDesignExplorerPanel = uipanel(app.MainFigure);
            app.UserDesignExplorerPanel.Title = 'User Design Explorer';
            app.UserDesignExplorerPanel.Position = [405 1 260 660];

            % Create SelectedRobotsListBox
            app.SelectedRobotsListBox = uilistbox(app.UserDesignExplorerPanel);
            app.SelectedRobotsListBox.Items = {};
            app.SelectedRobotsListBox.Multiselect = 'on';
            app.SelectedRobotsListBox.Position = [1 0 152 638];
            app.SelectedRobotsListBox.Value = {};

            % Create RefreshRobotsListButton
            app.RefreshRobotsListButton = uibutton(app.UserDesignExplorerPanel, 'push');
            app.RefreshRobotsListButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshRobotsListButtonPushed, true);
            app.RefreshRobotsListButton.Position = [176 609 58 22];
            app.RefreshRobotsListButton.Text = 'Refresh';

            % Create AddFromSelectedtoAddedButton
            app.AddFromSelectedtoAddedButton = uibutton(app.UserDesignExplorerPanel, 'push');
            app.AddFromSelectedtoAddedButton.ButtonPushedFcn = createCallbackFcn(app, @AddFromSelectedtoAddedButtonPushed, true);
            app.AddFromSelectedtoAddedButton.Position = [176 509 58 39];
            app.AddFromSelectedtoAddedButton.Text = '=>';

            % Create SortSelectedFitnessButton
            app.SortSelectedFitnessButton = uibutton(app.UserDesignExplorerPanel, 'push');
            app.SortSelectedFitnessButton.ButtonPushedFcn = createCallbackFcn(app, @SortSelectedFitnessButtonPushed, true);
            app.SortSelectedFitnessButton.Position = [184 581 44 22];
            app.SortSelectedFitnessButton.Text = 'SortFit';

            % Create UserDesignBagCreatorPanel
            app.UserDesignBagCreatorPanel = uipanel(app.MainFigure);
            app.UserDesignBagCreatorPanel.Title = 'User Design Bag Creator';
            app.UserDesignBagCreatorPanel.Position = [664 1 312 660];

            % Create AddedRobotsListBox
            app.AddedRobotsListBox = uilistbox(app.UserDesignBagCreatorPanel);
            app.AddedRobotsListBox.Items = {};
            app.AddedRobotsListBox.Multiselect = 'on';
            app.AddedRobotsListBox.Position = [1 0 152 638];
            app.AddedRobotsListBox.Value = {};

            % Create RemoveButton
            app.RemoveButton = uibutton(app.UserDesignBagCreatorPanel, 'push');
            app.RemoveButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveButtonPushed, true);
            app.RemoveButton.Position = [194 609 60 22];
            app.RemoveButton.Text = 'Remove';

            % Create SaveButton
            app.SaveButton = uibutton(app.UserDesignBagCreatorPanel, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [194 157 60 22];
            app.SaveButton.Text = 'Save';

            % Create SortAddedFitnessButton
            app.SortAddedFitnessButton = uibutton(app.UserDesignBagCreatorPanel, 'push');
            app.SortAddedFitnessButton.ButtonPushedFcn = createCallbackFcn(app, @SortAddedFitnessButtonPushed, true);
            app.SortAddedFitnessButton.Position = [202 583 44 22];
            app.SortAddedFitnessButton.Text = 'SortFit';

            % Create BagNameLabel
            app.BagNameLabel = uilabel(app.UserDesignBagCreatorPanel);
            app.BagNameLabel.HorizontalAlignment = 'right';
            app.BagNameLabel.Position = [169 405 66 22];
            app.BagNameLabel.Text = 'Bag Name:';

            % Create OutputBagNameField
            app.OutputBagNameField = uieditfield(app.UserDesignBagCreatorPanel, 'text');
            app.OutputBagNameField.Position = [184 379 95 23];

            % Create CommentsLabel
            app.CommentsLabel = uilabel(app.UserDesignBagCreatorPanel);
            app.CommentsLabel.Position = [172 351 67 22];
            app.CommentsLabel.Text = 'Comments:';

            % Create CommentTextArea
            app.CommentTextArea = uitextarea(app.UserDesignBagCreatorPanel);
            app.CommentTextArea.Position = [179 185 107 166];

            % Create TotalAddedCountLabel
            app.TotalAddedCountLabel = uilabel(app.UserDesignBagCreatorPanel);
            app.TotalAddedCountLabel.Position = [179 46 100 22];
            app.TotalAddedCountLabel.Text = '';

            % Create ClearAddedListBoxButton
            app.ClearAddedListBoxButton = uibutton(app.UserDesignBagCreatorPanel, 'push');
            app.ClearAddedListBoxButton.ButtonPushedFcn = createCallbackFcn(app, @ClearAddedListBoxButtonPushed, true);
            app.ClearAddedListBoxButton.Position = [202 23 60 22];
            app.ClearAddedListBoxButton.Text = 'Clear';

            % Create AddRandomtoAddedButton
            app.AddRandomtoAddedButton = uibutton(app.UserDesignBagCreatorPanel, 'push');
            app.AddRandomtoAddedButton.ButtonPushedFcn = createCallbackFcn(app, @AddRandomtoAddedButtonPushed, true);
            app.AddRandomtoAddedButton.WordWrap = 'on';
            app.AddRandomtoAddedButton.Position = [228 509 65 49];
            app.AddRandomtoAddedButton.Text = 'Add Random';

            % Create NumEditFieldLabel
            app.NumEditFieldLabel = uilabel(app.UserDesignBagCreatorPanel);
            app.NumEditFieldLabel.Position = [169 536 34 22];
            app.NumEditFieldLabel.Text = 'Num:';

            % Create NumRandomField
            app.NumRandomField = uieditfield(app.UserDesignBagCreatorPanel, 'text');
            app.NumRandomField.Position = [174 509 41 22];

            % Create MiscellaneousPanel
            app.MiscellaneousPanel = uipanel(app.MainFigure);
            app.MiscellaneousPanel.Title = 'Miscellaneous';
            app.MiscellaneousPanel.Position = [975 1 176 660];

            % Create PaperPlotButton
            app.PaperPlotButton = uibutton(app.MiscellaneousPanel, 'push');
            app.PaperPlotButton.ButtonPushedFcn = createCallbackFcn(app, @PaperPlotButtonPushed, true);
            app.PaperPlotButton.Position = [35 439 84 22];
            app.PaperPlotButton.Text = 'Paper Plot';

            % Create RehashButton
            app.RehashButton = uibutton(app.MiscellaneousPanel, 'push');
            app.RehashButton.ButtonPushedFcn = createCallbackFcn(app, @RehashButtonPushed, true);
            app.RehashButton.Position = [35 609 84 22];
            app.RehashButton.Text = 'Rehash';

            % Create SavePaperPlotButton
            app.SavePaperPlotButton = uibutton(app.MiscellaneousPanel, 'push');
            app.SavePaperPlotButton.ButtonPushedFcn = createCallbackFcn(app, @SavePaperPlotButtonPushed, true);
            app.SavePaperPlotButton.WordWrap = 'on';
            app.SavePaperPlotButton.Position = [39 396 75 34];
            app.SavePaperPlotButton.Text = 'Save Paper Plot';

            % Create SimulateRobotButton
            app.SimulateRobotButton = uibutton(app.MiscellaneousPanel, 'push');
            app.SimulateRobotButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateRobotButtonPushed, true);
            app.SimulateRobotButton.Tag = 'loadresult';
            app.SimulateRobotButton.Position = [36 524 72 22];
            app.SimulateRobotButton.Text = 'Simulate';

            % Create RobotIDXField
            app.RobotIDXField = uieditfield(app.MiscellaneousPanel, 'text');
            app.RobotIDXField.ValueChangedFcn = createCallbackFcn(app, @RobotIDXFieldValueChanged, true);
            app.RobotIDXField.HorizontalAlignment = 'center';
            app.RobotIDXField.Position = [35 549 39 22];

            % Create RobotIDYField
            app.RobotIDYField = uieditfield(app.MiscellaneousPanel, 'text');
            app.RobotIDYField.ValueChangedFcn = createCallbackFcn(app, @RobotIDYFieldValueChanged, true);
            app.RobotIDYField.HorizontalAlignment = 'center';
            app.RobotIDYField.Position = [75 549 39 22];

            % Create OpenFolderButton
            app.OpenFolderButton = uibutton(app.MiscellaneousPanel, 'push');
            app.OpenFolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFolderButtonPushed, true);
            app.OpenFolderButton.Tag = 'loadresult';
            app.OpenFolderButton.Position = [35 473 82 22];
            app.OpenFolderButton.Text = 'Open Folder';

            % Create PopVarButton
            app.PopVarButton = uibutton(app.MiscellaneousPanel, 'push');
            app.PopVarButton.ButtonPushedFcn = createCallbackFcn(app, @PopVarButtonPushed, true);
            app.PopVarButton.Position = [35 499 73 22];
            app.PopVarButton.Text = 'Pop Var';

            % Create CLCButton
            app.CLCButton = uibutton(app.MiscellaneousPanel, 'push');
            app.CLCButton.ButtonPushedFcn = createCallbackFcn(app, @CLCButtonPushed, true);
            app.CLCButton.Position = [35 583 84 22];
            app.CLCButton.Text = 'CLC';

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
