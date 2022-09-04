classdef task_scheduler < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MainFigure                    matlab.ui.Figure
        MiscellaneousPanel            matlab.ui.container.Panel
        CLCButton                     matlab.ui.control.Button
        RehashButton                  matlab.ui.control.Button
        JobFIleLauncherPanel          matlab.ui.container.Panel
        OpenJobFolderButton           matlab.ui.control.Button
        OpenResultFolderButton        matlab.ui.control.Button
        JobFileStatusLabel            matlab.ui.control.Label
        JobFileInfoLabel              matlab.ui.control.Label
        RefreshJobFileListButton      matlab.ui.control.Button
        LaunchJobFileButton           matlab.ui.control.Button
        JobFilesListBox               matlab.ui.control.ListBox
        AvailableJobFilesLabel        matlab.ui.control.Label
        JobFileEditorPanel            matlab.ui.container.Panel
        SaveJobEditButton             matlab.ui.control.Button
        SessionTimeEditField          matlab.ui.control.NumericEditField
        SessionTimeminEditFieldLabel  matlab.ui.control.Label
        GroupCommentsTextArea         matlab.ui.control.TextArea
        GroupCommentsTextAreaLabel    matlab.ui.control.Label
        GroupNameEditField            matlab.ui.control.EditField
        GroupNameLabel                matlab.ui.control.Label
        OutputFileNameEditField       matlab.ui.control.EditField
        OutputFileNameLabel           matlab.ui.control.Label
        JobsListBox                   matlab.ui.control.ListBox
        CreatedJobsListBoxLabel       matlab.ui.control.Label
        LoadJobButton                 matlab.ui.control.Button
        OpenJobFileFolderButton       matlab.ui.control.Button
        JobCountLabel                 matlab.ui.control.Label
        SaveButton                    matlab.ui.control.Button
        RemoveButton                  matlab.ui.control.Button
        JobEditorPanel                matlab.ui.container.Panel
        JobTypeDropDown               matlab.ui.control.DropDown
        JobTypeLabel                  matlab.ui.control.Label
        LoadedResultDetailLabel       matlab.ui.control.Label
        LoadExistingResultButton      matlab.ui.control.Button
        GridDimensionEditField        matlab.ui.control.EditField
        BinsEditFieldLabel            matlab.ui.control.Label
        NumDimEditField               matlab.ui.control.NumericEditField
        DimensionsEditFieldLabel      matlab.ui.control.Label
        StartIndexEditField           matlab.ui.control.NumericEditField
        StartIndexEditFieldLabel      matlab.ui.control.Label
        NicknameEditField             matlab.ui.control.EditField
        NicknameEditFieldLabel        matlab.ui.control.Label
        NumRepsEditField              matlab.ui.control.NumericEditField
        RepsLabel                     matlab.ui.control.Label
        JobCommentsTextArea           matlab.ui.control.TextArea
        JobCommentsTextAreaLabel      matlab.ui.control.Label
        SimTimeEditField              matlab.ui.control.NumericEditField
        SimTimeLabel                  matlab.ui.control.Label
        PopSizeEditField              matlab.ui.control.NumericEditField
        PopSizeLabel                  matlab.ui.control.Label
        NumGenEditField               matlab.ui.control.NumericEditField
        GenEditFieldLabel             matlab.ui.control.Label
        EnvironmentDropDown           matlab.ui.control.DropDown
        EnvLabel                      matlab.ui.control.Label
        BagFilesListBox               matlab.ui.control.ListBox
        BagFilesLabel                 matlab.ui.control.Label
        ClearBagSelectionButton       matlab.ui.control.Button
        IgnoreRandomPopInBagCheckBox  matlab.ui.control.CheckBox
        RefreshBagFileListButton      matlab.ui.control.Button
        CreateJobButton               matlab.ui.control.Button
    end

    properties (Access = public)
        workspace_dir
        bagfile_dir
        jobfile_dir
        trainer_exe_path
        task_launcher_path

        jobs % cell array of job struct containing the jobs created
             % fields of job struct:
             % bag_file, env, num_gen, pop_size, sim_time,
             % nickname, comment, in_scheduler(bool), job_id(int)
        result_loaded % a struct holding the informaiton of the loaded existing
                      % result
    end

    methods (Access = private)
        job = format_job(app, job_config)
        add_job(app)
        edit_job(app)
        clear_bag_selection(app)
        launch_job_file(app)
        load_selected_job(app)
        refresh_bag_list(app)
        refresh_job_files_list(app)
        refresh_jobs_list(app)
        remove_job(app)
        save_schedule_file(app)
        task_scheduler_init(app, evogen_workspace_path, evogen_exe_path, evogen_task_launcher_path)
        update_job_file_info_label(app)
        grid_dimension_update(app)
        load_existing_result(app);
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, evogen_workspace_path, evogen_exe_path, evogen_task_launcher_path)
            task_scheduler_init(app, evogen_workspace_path, evogen_exe_path, evogen_task_launcher_path);
        end

        % Button pushed function: CreateJobButton
        function CreateJobButtonPushed(app, event)
            add_job(app);
        end

        % Button pushed function: SaveJobEditButton
        function SaveJobEditButtonPushed(app, event)
            edit_job(app);
        end

        % Button pushed function: RemoveButton
        function RemoveButtonPushed(app, event)
            remove_job(app);
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            save_schedule_file(app);
        end

        % Button pushed function: OpenJobFileFolderButton
        function OpenJobFileFolderButtonPushed(app, event)
            winopen(app.jobfile_dir);
        end

        % Button pushed function: OpenResultFolderButton
        function OpenResultFolderButtonPushed(app, event)
            winopen(fullfile(app.workspace_dir, 'Results'));
        end

        % Button pushed function: OpenJobFolderButton
        function OpenJobFolderButtonPushed(app, event)
            winopen(fullfile(app.workspace_dir, 'Jobs'));
        end

        % Button pushed function: LoadJobButton
        function LoadJobButtonPushed(app, event)
            load_selected_job(app);
        end

        % Button pushed function: ClearBagSelectionButton
        function ClearBagSelectionButtonPushed(app, event)
            clear_bag_selection(app);
        end

        % Value changed function: JobFilesListBox
        function JobFilesListBoxValueChanged(app, event)
            update_job_file_info_label(app);
        end

        % Button pushed function: RefreshJobFileListButton
        function RefreshJobFileListButtonPushed(app, event)
            refresh_job_files_list(app);
        end

        % Button pushed function: LaunchJobFileButton
        function LaunchJobFileButtonPushed(app, event)
            launch_job_file(app);
        end

        % Button pushed function: RehashButton
        function RehashButtonPushed(app, event)
            rehash;
        end

        % Button pushed function: CLCButton
        function CLCButtonPushed(app, event)
            clc;
        end

        % Value changed function: NumDimEditField
        function NumDimEditFieldValueChanged(app, event)
            grid_dimension_update(app);
        end

        % Button pushed function: LoadExistingResultButton
        function LoadExistingResultButtonPushed(app, event)
            load_existing_result(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MainFigure and hide until all components are created
            app.MainFigure = uifigure('Visible', 'off');
            app.MainFigure.Position = [100 100 1160 505];
            app.MainFigure.Name = 'EvoGen Task Scheduler';

            % Create JobEditorPanel
            app.JobEditorPanel = uipanel(app.MainFigure);
            app.JobEditorPanel.Title = 'Job Editor';
            app.JobEditorPanel.Position = [1 1 330 505];

            % Create CreateJobButton
            app.CreateJobButton = uibutton(app.JobEditorPanel, 'push');
            app.CreateJobButton.ButtonPushedFcn = createCallbackFcn(app, @CreateJobButtonPushed, true);
            app.CreateJobButton.Position = [229 5 74 23];
            app.CreateJobButton.Text = 'Create Job';

            % Create RefreshBagFileListButton
            app.RefreshBagFileListButton = uibutton(app.JobEditorPanel, 'push');
            app.RefreshBagFileListButton.Position = [156 409 50 20];
            app.RefreshBagFileListButton.Text = 'Refresh';

            % Create IgnoreRandomPopInBagCheckBox
            app.IgnoreRandomPopInBagCheckBox = uicheckbox(app.JobEditorPanel);
            app.IgnoreRandomPopInBagCheckBox.Text = 'Ignore Random Pop In Bag';
            app.IgnoreRandomPopInBagCheckBox.WordWrap = 'on';
            app.IgnoreRandomPopInBagCheckBox.Position = [219 316 103 36];
            app.IgnoreRandomPopInBagCheckBox.Value = true;

            % Create ClearBagSelectionButton
            app.ClearBagSelectionButton = uibutton(app.JobEditorPanel, 'push');
            app.ClearBagSelectionButton.ButtonPushedFcn = createCallbackFcn(app, @ClearBagSelectionButtonPushed, true);
            app.ClearBagSelectionButton.Position = [104 409 50 20];
            app.ClearBagSelectionButton.Text = 'Clear';

            % Create BagFilesLabel
            app.BagFilesLabel = uilabel(app.JobEditorPanel);
            app.BagFilesLabel.FontWeight = 'bold';
            app.BagFilesLabel.Position = [8 407 63 22];
            app.BagFilesLabel.Text = 'Bag Files:';

            % Create BagFilesListBox
            app.BagFilesListBox = uilistbox(app.JobEditorPanel);
            app.BagFilesListBox.Items = {};
            app.BagFilesListBox.Position = [1 176 208 233];
            app.BagFilesListBox.Value = {};

            % Create EnvLabel
            app.EnvLabel = uilabel(app.JobEditorPanel);
            app.EnvLabel.HorizontalAlignment = 'right';
            app.EnvLabel.Position = [211 460 76 22];
            app.EnvLabel.Text = 'Environment:';

            % Create EnvironmentDropDown
            app.EnvironmentDropDown = uidropdown(app.JobEditorPanel);
            app.EnvironmentDropDown.Items = {};
            app.EnvironmentDropDown.Position = [233 436 91 26];
            app.EnvironmentDropDown.Value = {};

            % Create GenEditFieldLabel
            app.GenEditFieldLabel = uilabel(app.JobEditorPanel);
            app.GenEditFieldLabel.HorizontalAlignment = 'right';
            app.GenEditFieldLabel.Position = [221 408 42 22];
            app.GenEditFieldLabel.Text = '# Gen:';

            % Create NumGenEditField
            app.NumGenEditField = uieditfield(app.JobEditorPanel, 'numeric');
            app.NumGenEditField.Limits = [0 Inf];
            app.NumGenEditField.RoundFractionalValues = 'on';
            app.NumGenEditField.ValueDisplayFormat = '%.0f';
            app.NumGenEditField.HorizontalAlignment = 'center';
            app.NumGenEditField.Position = [273 408 50 20];

            % Create PopSizeLabel
            app.PopSizeLabel = uilabel(app.JobEditorPanel);
            app.PopSizeLabel.HorizontalAlignment = 'right';
            app.PopSizeLabel.Position = [212 381 57 22];
            app.PopSizeLabel.Text = 'Pop Size:';

            % Create PopSizeEditField
            app.PopSizeEditField = uieditfield(app.JobEditorPanel, 'numeric');
            app.PopSizeEditField.HorizontalAlignment = 'center';
            app.PopSizeEditField.Position = [273 383 50 20];

            % Create SimTimeLabel
            app.SimTimeLabel = uilabel(app.JobEditorPanel);
            app.SimTimeLabel.HorizontalAlignment = 'right';
            app.SimTimeLabel.Position = [210 357 59 22];
            app.SimTimeLabel.Text = 'Sim Time:';

            % Create SimTimeEditField
            app.SimTimeEditField = uieditfield(app.JobEditorPanel, 'numeric');
            app.SimTimeEditField.HorizontalAlignment = 'center';
            app.SimTimeEditField.Position = [273 358 50 20];

            % Create JobCommentsTextAreaLabel
            app.JobCommentsTextAreaLabel = uilabel(app.JobEditorPanel);
            app.JobCommentsTextAreaLabel.HorizontalAlignment = 'right';
            app.JobCommentsTextAreaLabel.Position = [205 229 90 22];
            app.JobCommentsTextAreaLabel.Text = 'Job Comments:';

            % Create JobCommentsTextArea
            app.JobCommentsTextArea = uitextarea(app.JobEditorPanel);
            app.JobCommentsTextArea.Position = [215 127 108 92];

            % Create RepsLabel
            app.RepsLabel = uilabel(app.JobEditorPanel);
            app.RepsLabel.HorizontalAlignment = 'right';
            app.RepsLabel.Position = [215 33 47 22];
            app.RepsLabel.Text = '# Reps:';

            % Create NumRepsEditField
            app.NumRepsEditField = uieditfield(app.JobEditorPanel, 'numeric');
            app.NumRepsEditField.Limits = [1 Inf];
            app.NumRepsEditField.RoundFractionalValues = 'on';
            app.NumRepsEditField.ValueDisplayFormat = '%.0f';
            app.NumRepsEditField.HorizontalAlignment = 'center';
            app.NumRepsEditField.Position = [272 33 50 20];
            app.NumRepsEditField.Value = 1;

            % Create NicknameEditFieldLabel
            app.NicknameEditFieldLabel = uilabel(app.JobEditorPanel);
            app.NicknameEditFieldLabel.HorizontalAlignment = 'right';
            app.NicknameEditFieldLabel.Position = [213 105 62 22];
            app.NicknameEditFieldLabel.Text = 'Nickname:';

            % Create NicknameEditField
            app.NicknameEditField = uieditfield(app.JobEditorPanel, 'text');
            app.NicknameEditField.HorizontalAlignment = 'center';
            app.NicknameEditField.Position = [231 82 89 20];

            % Create StartIndexEditFieldLabel
            app.StartIndexEditFieldLabel = uilabel(app.JobEditorPanel);
            app.StartIndexEditFieldLabel.HorizontalAlignment = 'right';
            app.StartIndexEditFieldLabel.Position = [216 54 67 22];
            app.StartIndexEditFieldLabel.Text = 'Start Index:';

            % Create StartIndexEditField
            app.StartIndexEditField = uieditfield(app.JobEditorPanel, 'numeric');
            app.StartIndexEditField.Limits = [0 Inf];
            app.StartIndexEditField.Position = [291 54 28 22];

            % Create DimensionsEditFieldLabel
            app.DimensionsEditFieldLabel = uilabel(app.JobEditorPanel);
            app.DimensionsEditFieldLabel.HorizontalAlignment = 'right';
            app.DimensionsEditFieldLabel.Position = [212 295 80 22];
            app.DimensionsEditFieldLabel.Text = '# Dimensions:';

            % Create NumDimEditField
            app.NumDimEditField = uieditfield(app.JobEditorPanel, 'numeric');
            app.NumDimEditField.Limits = [0 6];
            app.NumDimEditField.RoundFractionalValues = 'on';
            app.NumDimEditField.ValueChangedFcn = createCallbackFcn(app, @NumDimEditFieldValueChanged, true);
            app.NumDimEditField.HorizontalAlignment = 'center';
            app.NumDimEditField.Position = [295 294 29 22];

            % Create BinsEditFieldLabel
            app.BinsEditFieldLabel = uilabel(app.JobEditorPanel);
            app.BinsEditFieldLabel.HorizontalAlignment = 'right';
            app.BinsEditFieldLabel.Position = [210 280 42 22];
            app.BinsEditFieldLabel.Text = '# Bins:';

            % Create GridDimensionEditField
            app.GridDimensionEditField = uieditfield(app.JobEditorPanel, 'text');
            app.GridDimensionEditField.Position = [213 258 109 22];

            % Create LoadExistingResultButton
            app.LoadExistingResultButton = uibutton(app.JobEditorPanel, 'push');
            app.LoadExistingResultButton.ButtonPushedFcn = createCallbackFcn(app, @LoadExistingResultButtonPushed, true);
            app.LoadExistingResultButton.Position = [28 144 125 22];
            app.LoadExistingResultButton.Text = 'Load Existing Result';

            % Create LoadedResultDetailLabel
            app.LoadedResultDetailLabel = uilabel(app.JobEditorPanel);
            app.LoadedResultDetailLabel.VerticalAlignment = 'top';
            app.LoadedResultDetailLabel.WordWrap = 'on';
            app.LoadedResultDetailLabel.Position = [8 7 198 130];
            app.LoadedResultDetailLabel.Text = '';

            % Create JobTypeLabel
            app.JobTypeLabel = uilabel(app.JobEditorPanel);
            app.JobTypeLabel.HorizontalAlignment = 'right';
            app.JobTypeLabel.FontWeight = 'bold';
            app.JobTypeLabel.Position = [4 451 61 22];
            app.JobTypeLabel.Text = 'Job Type:';

            % Create JobTypeDropDown
            app.JobTypeDropDown = uidropdown(app.JobEditorPanel);
            app.JobTypeDropDown.Items = {};
            app.JobTypeDropDown.Position = [71 451 117 22];
            app.JobTypeDropDown.Value = {};

            % Create JobFileEditorPanel
            app.JobFileEditorPanel = uipanel(app.MainFigure);
            app.JobFileEditorPanel.Title = 'Job File Editor';
            app.JobFileEditorPanel.Position = [330 1 353 505];

            % Create RemoveButton
            app.RemoveButton = uibutton(app.JobFileEditorPanel, 'push');
            app.RemoveButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveButtonPushed, true);
            app.RemoveButton.Position = [227 412 71 23];
            app.RemoveButton.Text = 'Remove';

            % Create SaveButton
            app.SaveButton = uibutton(app.JobFileEditorPanel, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [252 60 71 23];
            app.SaveButton.Text = 'Save';

            % Create JobCountLabel
            app.JobCountLabel = uilabel(app.JobFileEditorPanel);
            app.JobCountLabel.Position = [224 113 51 22];
            app.JobCountLabel.Text = '';

            % Create OpenJobFileFolderButton
            app.OpenJobFileFolderButton = uibutton(app.JobFileEditorPanel, 'push');
            app.OpenJobFileFolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenJobFileFolderButtonPushed, true);
            app.OpenJobFileFolderButton.WordWrap = 'on';
            app.OpenJobFileFolderButton.Position = [252 14 71 38];
            app.OpenJobFileFolderButton.Text = 'Open Job File Folder';

            % Create LoadJobButton
            app.LoadJobButton = uibutton(app.JobFileEditorPanel, 'push');
            app.LoadJobButton.ButtonPushedFcn = createCallbackFcn(app, @LoadJobButtonPushed, true);
            app.LoadJobButton.Position = [226 443 49 23];
            app.LoadJobButton.Text = 'Load';

            % Create CreatedJobsListBoxLabel
            app.CreatedJobsListBoxLabel = uilabel(app.JobFileEditorPanel);
            app.CreatedJobsListBoxLabel.Position = [6 461 82 22];
            app.CreatedJobsListBoxLabel.Text = 'Created Jobs:';

            % Create JobsListBox
            app.JobsListBox = uilistbox(app.JobFileEditorPanel);
            app.JobsListBox.Items = {};
            app.JobsListBox.Multiselect = 'on';
            app.JobsListBox.Position = [1 0 213 463];
            app.JobsListBox.Value = {};

            % Create OutputFileNameLabel
            app.OutputFileNameLabel = uilabel(app.JobFileEditorPanel);
            app.OutputFileNameLabel.HorizontalAlignment = 'right';
            app.OutputFileNameLabel.Position = [219 168 103 22];
            app.OutputFileNameLabel.Text = 'Output File Name:';

            % Create OutputFileNameEditField
            app.OutputFileNameEditField = uieditfield(app.JobFileEditorPanel, 'text');
            app.OutputFileNameEditField.HorizontalAlignment = 'center';
            app.OutputFileNameEditField.Position = [231 142 116 20];

            % Create GroupNameLabel
            app.GroupNameLabel = uilabel(app.JobFileEditorPanel);
            app.GroupNameLabel.HorizontalAlignment = 'right';
            app.GroupNameLabel.Position = [211 386 78 22];
            app.GroupNameLabel.Text = 'Group Name:';

            % Create GroupNameEditField
            app.GroupNameEditField = uieditfield(app.JobFileEditorPanel, 'text');
            app.GroupNameEditField.HorizontalAlignment = 'center';
            app.GroupNameEditField.Position = [229 363 116 20];

            % Create GroupCommentsTextAreaLabel
            app.GroupCommentsTextAreaLabel = uilabel(app.JobFileEditorPanel);
            app.GroupCommentsTextAreaLabel.HorizontalAlignment = 'right';
            app.GroupCommentsTextAreaLabel.Position = [212 333 104 22];
            app.GroupCommentsTextAreaLabel.Text = 'Group Comments:';

            % Create GroupCommentsTextArea
            app.GroupCommentsTextArea = uitextarea(app.JobFileEditorPanel);
            app.GroupCommentsTextArea.Position = [224 197 123 132];

            % Create SessionTimeminEditFieldLabel
            app.SessionTimeminEditFieldLabel = uilabel(app.JobFileEditorPanel);
            app.SessionTimeminEditFieldLabel.HorizontalAlignment = 'right';
            app.SessionTimeminEditFieldLabel.Position = [220 112 108 22];
            app.SessionTimeminEditFieldLabel.Text = 'Session Time (min)';

            % Create SessionTimeEditField
            app.SessionTimeEditField = uieditfield(app.JobFileEditorPanel, 'numeric');
            app.SessionTimeEditField.Limits = [0 180];
            app.SessionTimeEditField.RoundFractionalValues = 'on';
            app.SessionTimeEditField.ValueDisplayFormat = '%.0f';
            app.SessionTimeEditField.Position = [311 91 36 22];

            % Create SaveJobEditButton
            app.SaveJobEditButton = uibutton(app.JobFileEditorPanel, 'push');
            app.SaveJobEditButton.ButtonPushedFcn = createCallbackFcn(app, @SaveJobEditButtonPushed, true);
            app.SaveJobEditButton.Position = [279 443 67 23];
            app.SaveJobEditButton.Text = 'Save Edit';

            % Create JobFIleLauncherPanel
            app.JobFIleLauncherPanel = uipanel(app.MainFigure);
            app.JobFIleLauncherPanel.Title = 'Job FIle Launcher';
            app.JobFIleLauncherPanel.Position = [682 1 368 505];

            % Create AvailableJobFilesLabel
            app.AvailableJobFilesLabel = uilabel(app.JobFIleLauncherPanel);
            app.AvailableJobFilesLabel.Position = [4 460 109 22];
            app.AvailableJobFilesLabel.Text = 'Available Job Files:';

            % Create JobFilesListBox
            app.JobFilesListBox = uilistbox(app.JobFIleLauncherPanel);
            app.JobFilesListBox.Items = {};
            app.JobFilesListBox.ValueChangedFcn = createCallbackFcn(app, @JobFilesListBoxValueChanged, true);
            app.JobFilesListBox.Position = [1 0 215 461];
            app.JobFilesListBox.Value = {};

            % Create LaunchJobFileButton
            app.LaunchJobFileButton = uibutton(app.JobFIleLauncherPanel, 'push');
            app.LaunchJobFileButton.ButtonPushedFcn = createCallbackFcn(app, @LaunchJobFileButtonPushed, true);
            app.LaunchJobFileButton.WordWrap = 'on';
            app.LaunchJobFileButton.FontWeight = 'bold';
            app.LaunchJobFileButton.Position = [222 386 68 52];
            app.LaunchJobFileButton.Text = 'Launch Job File';

            % Create RefreshJobFileListButton
            app.RefreshJobFileListButton = uibutton(app.JobFIleLauncherPanel, 'push');
            app.RefreshJobFileListButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshJobFileListButtonPushed, true);
            app.RefreshJobFileListButton.WordWrap = 'on';
            app.RefreshJobFileListButton.Position = [222 443 68 38];
            app.RefreshJobFileListButton.Text = 'Refresh';

            % Create JobFileInfoLabel
            app.JobFileInfoLabel = uilabel(app.JobFIleLauncherPanel);
            app.JobFileInfoLabel.VerticalAlignment = 'top';
            app.JobFileInfoLabel.WordWrap = 'on';
            app.JobFileInfoLabel.Position = [219 180 144 172];
            app.JobFileInfoLabel.Text = '';

            % Create JobFileStatusLabel
            app.JobFileStatusLabel = uilabel(app.JobFIleLauncherPanel);
            app.JobFileStatusLabel.FontSize = 14;
            app.JobFileStatusLabel.FontWeight = 'bold';
            app.JobFileStatusLabel.Position = [220 356 110 22];
            app.JobFileStatusLabel.Text = 'Job File Status:';

            % Create OpenResultFolderButton
            app.OpenResultFolderButton = uibutton(app.JobFIleLauncherPanel, 'push');
            app.OpenResultFolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenResultFolderButtonPushed, true);
            app.OpenResultFolderButton.WordWrap = 'on';
            app.OpenResultFolderButton.Position = [227 8 50 50];
            app.OpenResultFolderButton.Text = 'Open Result Folder';

            % Create OpenJobFolderButton
            app.OpenJobFolderButton = uibutton(app.JobFIleLauncherPanel, 'push');
            app.OpenJobFolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenJobFolderButtonPushed, true);
            app.OpenJobFolderButton.WordWrap = 'on';
            app.OpenJobFolderButton.Position = [289 8 50 50];
            app.OpenJobFolderButton.Text = 'Open Job Folder';

            % Create MiscellaneousPanel
            app.MiscellaneousPanel = uipanel(app.MainFigure);
            app.MiscellaneousPanel.Title = 'Miscellaneous';
            app.MiscellaneousPanel.Position = [1048 1 111 505];

            % Create RehashButton
            app.RehashButton = uibutton(app.MiscellaneousPanel, 'push');
            app.RehashButton.ButtonPushedFcn = createCallbackFcn(app, @RehashButtonPushed, true);
            app.RehashButton.Position = [14 451 80 22];
            app.RehashButton.Text = 'Rehash';

            % Create CLCButton
            app.CLCButton = uibutton(app.MiscellaneousPanel, 'push');
            app.CLCButton.ButtonPushedFcn = createCallbackFcn(app, @CLCButtonPushed, true);
            app.CLCButton.Position = [14 425 80 22];
            app.CLCButton.Text = 'CLC';

            % Show the figure after all components are created
            app.MainFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = task_scheduler(varargin)

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
