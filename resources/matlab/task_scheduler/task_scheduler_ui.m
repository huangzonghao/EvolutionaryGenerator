classdef task_scheduler_ui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MainFigure                    matlab.ui.Figure
        IgnoreRandomPopInBagCheckBox  matlab.ui.control.CheckBox
        LoadJobButton                 matlab.ui.control.Button
        OpenFolderButton              matlab.ui.control.Button
        RefreshButton                 matlab.ui.control.Button
        JobCountLabel                 matlab.ui.control.Label
        GroupCommentsTextArea         matlab.ui.control.TextArea
        GroupCommentsTextAreaLabel    matlab.ui.control.Label
        JobCommentsTextArea           matlab.ui.control.TextArea
        JobCommentsTextAreaLabel      matlab.ui.control.Label
        GroupNameEditField            matlab.ui.control.EditField
        GroupNameLabel                matlab.ui.control.Label
        NicknameEditField             matlab.ui.control.EditField
        NicknameEditFieldLabel        matlab.ui.control.Label
        SaveButton                    matlab.ui.control.Button
        RemoveButton                  matlab.ui.control.Button
        SimTimeEditField              matlab.ui.control.NumericEditField
        SimTimeLabel                  matlab.ui.control.Label
        PopSizeEditField              matlab.ui.control.NumericEditField
        PopSizeLabel                  matlab.ui.control.Label
        NumGenEditField               matlab.ui.control.NumericEditField
        GenEditFieldLabel             matlab.ui.control.Label
        EnvDropDown                   matlab.ui.control.DropDown
        EnvLabel                      matlab.ui.control.Label
        CreateJobButton               matlab.ui.control.Button
        OutputFileNameEditField       matlab.ui.control.EditField
        OutputFileNameLabel           matlab.ui.control.Label
        JobsListBox                   matlab.ui.control.ListBox
        CreatedJobsListBoxLabel       matlab.ui.control.Label
        BagFilesListBox               matlab.ui.control.ListBox
        BagFilesLabel                 matlab.ui.control.Label
    end

    properties (Access = public)
        workspace_dir
        bagfile_dir
        jobfile_dir

        jobs % cell array of job struct containing the jobs created
             % fields of job struct:
             % bag_file, env, num_gen, pop_size, sim_time,
             % nickname, comment, in_scheduler(bool), job_id(int)
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, evogen_workspace_path)
            task_scheduler_init(app, evogen_workspace_path);
        end

        % Button pushed function: CreateJobButton
        function CreateJobButtonPushed(app, event)
            add_job(app);
        end

        % Button pushed function: RemoveButton
        function RemoveButtonPushed(app, event)
            remove_job(app);
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            save_schedule_file(app);
        end

        % Button pushed function: OpenFolderButton
        function OpenFolderButtonPushed(app, event)
            winopen(app.jobfile_dir);
        end

        % Button pushed function: LoadJobButton
        function LoadJobButtonPushed(app, event)
            load_selected_job(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MainFigure and hide until all components are created
            app.MainFigure = uifigure('Visible', 'off');
            app.MainFigure.Position = [100 100 671 480];
            app.MainFigure.Name = 'MATLAB App';

            % Create BagFilesLabel
            app.BagFilesLabel = uilabel(app.MainFigure);
            app.BagFilesLabel.Position = [4 457 59 22];
            app.BagFilesLabel.Text = 'Bag Files:';

            % Create BagFilesListBox
            app.BagFilesListBox = uilistbox(app.MainFigure);
            app.BagFilesListBox.Items = {};
            app.BagFilesListBox.Position = [1 1 203 456];
            app.BagFilesListBox.Value = {};

            % Create CreatedJobsListBoxLabel
            app.CreatedJobsListBoxLabel = uilabel(app.MainFigure);
            app.CreatedJobsListBoxLabel.Position = [323 456 82 22];
            app.CreatedJobsListBoxLabel.Text = 'Created Jobs:';

            % Create JobsListBox
            app.JobsListBox = uilistbox(app.MainFigure);
            app.JobsListBox.Items = {};
            app.JobsListBox.Multiselect = 'on';
            app.JobsListBox.Position = [327 1 203 456];
            app.JobsListBox.Value = {};

            % Create OutputFileNameLabel
            app.OutputFileNameLabel = uilabel(app.MainFigure);
            app.OutputFileNameLabel.HorizontalAlignment = 'right';
            app.OutputFileNameLabel.Position = [526 329 103 22];
            app.OutputFileNameLabel.Text = 'Output File Name:';

            % Create OutputFileNameEditField
            app.OutputFileNameEditField = uieditfield(app.MainFigure, 'text');
            app.OutputFileNameEditField.HorizontalAlignment = 'center';
            app.OutputFileNameEditField.Position = [548 303 116 20];

            % Create CreateJobButton
            app.CreateJobButton = uibutton(app.MainFigure, 'push');
            app.CreateJobButton.ButtonPushedFcn = createCallbackFcn(app, @CreateJobButtonPushed, true);
            app.CreateJobButton.Position = [224 61 74 23];
            app.CreateJobButton.Text = 'Create Job';

            % Create EnvLabel
            app.EnvLabel = uilabel(app.MainFigure);
            app.EnvLabel.HorizontalAlignment = 'right';
            app.EnvLabel.Position = [210 439 30 22];
            app.EnvLabel.Text = 'Env:';

            % Create EnvDropDown
            app.EnvDropDown = uidropdown(app.MainFigure);
            app.EnvDropDown.Items = {};
            app.EnvDropDown.Position = [228 415 91 26];
            app.EnvDropDown.Value = {};

            % Create GenEditFieldLabel
            app.GenEditFieldLabel = uilabel(app.MainFigure);
            app.GenEditFieldLabel.HorizontalAlignment = 'right';
            app.GenEditFieldLabel.Position = [216 387 42 22];
            app.GenEditFieldLabel.Text = '# Gen:';

            % Create NumGenEditField
            app.NumGenEditField = uieditfield(app.MainFigure, 'numeric');
            app.NumGenEditField.Limits = [0 Inf];
            app.NumGenEditField.RoundFractionalValues = 'on';
            app.NumGenEditField.ValueDisplayFormat = '%.0f';
            app.NumGenEditField.HorizontalAlignment = 'center';
            app.NumGenEditField.Position = [268 387 50 20];

            % Create PopSizeLabel
            app.PopSizeLabel = uilabel(app.MainFigure);
            app.PopSizeLabel.HorizontalAlignment = 'right';
            app.PopSizeLabel.Position = [207 360 57 22];
            app.PopSizeLabel.Text = 'Pop Size:';

            % Create PopSizeEditField
            app.PopSizeEditField = uieditfield(app.MainFigure, 'numeric');
            app.PopSizeEditField.HorizontalAlignment = 'center';
            app.PopSizeEditField.Position = [268 362 50 20];

            % Create SimTimeLabel
            app.SimTimeLabel = uilabel(app.MainFigure);
            app.SimTimeLabel.HorizontalAlignment = 'right';
            app.SimTimeLabel.Position = [205 336 59 22];
            app.SimTimeLabel.Text = 'Sim Time:';

            % Create SimTimeEditField
            app.SimTimeEditField = uieditfield(app.MainFigure, 'numeric');
            app.SimTimeEditField.HorizontalAlignment = 'center';
            app.SimTimeEditField.Position = [268 337 50 20];

            % Create RemoveButton
            app.RemoveButton = uibutton(app.MainFigure, 'push');
            app.RemoveButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveButtonPushed, true);
            app.RemoveButton.Position = [544 407 71 23];
            app.RemoveButton.Text = 'Remove';

            % Create SaveButton
            app.SaveButton = uibutton(app.MainFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [569 71 71 23];
            app.SaveButton.Text = 'Save';

            % Create NicknameEditFieldLabel
            app.NicknameEditFieldLabel = uilabel(app.MainFigure);
            app.NicknameEditFieldLabel.HorizontalAlignment = 'right';
            app.NicknameEditFieldLabel.Position = [203 269 62 22];
            app.NicknameEditFieldLabel.Text = 'Nickname:';

            % Create NicknameEditField
            app.NicknameEditField = uieditfield(app.MainFigure, 'text');
            app.NicknameEditField.HorizontalAlignment = 'center';
            app.NicknameEditField.Position = [224 250 95 20];

            % Create GroupNameLabel
            app.GroupNameLabel = uilabel(app.MainFigure);
            app.GroupNameLabel.HorizontalAlignment = 'right';
            app.GroupNameLabel.Position = [528 381 78 22];
            app.GroupNameLabel.Text = 'Group Name:';

            % Create GroupNameEditField
            app.GroupNameEditField = uieditfield(app.MainFigure, 'text');
            app.GroupNameEditField.HorizontalAlignment = 'center';
            app.GroupNameEditField.Position = [546 358 116 20];

            % Create JobCommentsTextAreaLabel
            app.JobCommentsTextAreaLabel = uilabel(app.MainFigure);
            app.JobCommentsTextAreaLabel.HorizontalAlignment = 'right';
            app.JobCommentsTextAreaLabel.Position = [201 225 90 22];
            app.JobCommentsTextAreaLabel.Text = 'Job Comments:';

            % Create JobCommentsTextArea
            app.JobCommentsTextArea = uitextarea(app.MainFigure);
            app.JobCommentsTextArea.Position = [211 103 108 116];

            % Create GroupCommentsTextAreaLabel
            app.GroupCommentsTextAreaLabel = uilabel(app.MainFigure);
            app.GroupCommentsTextAreaLabel.HorizontalAlignment = 'right';
            app.GroupCommentsTextAreaLabel.Position = [529 271 104 22];
            app.GroupCommentsTextAreaLabel.Text = 'Group Comments:';

            % Create GroupCommentsTextArea
            app.GroupCommentsTextArea = uitextarea(app.MainFigure);
            app.GroupCommentsTextArea.Position = [541 135 123 132];

            % Create JobCountLabel
            app.JobCountLabel = uilabel(app.MainFigure);
            app.JobCountLabel.Position = [541 85 51 22];
            app.JobCountLabel.Text = '';

            % Create RefreshButton
            app.RefreshButton = uibutton(app.MainFigure, 'push');
            app.RefreshButton.Position = [152 459 50 20];
            app.RefreshButton.Text = 'Refresh';

            % Create OpenFolderButton
            app.OpenFolderButton = uibutton(app.MainFigure, 'push');
            app.OpenFolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFolderButtonPushed, true);
            app.OpenFolderButton.Position = [567 35 82 23];
            app.OpenFolderButton.Text = 'Open Folder';

            % Create LoadJobButton
            app.LoadJobButton = uibutton(app.MainFigure, 'push');
            app.LoadJobButton.ButtonPushedFcn = createCallbackFcn(app, @LoadJobButtonPushed, true);
            app.LoadJobButton.Position = [543 438 71 23];
            app.LoadJobButton.Text = 'Load';

            % Create IgnoreRandomPopInBagCheckBox
            app.IgnoreRandomPopInBagCheckBox = uicheckbox(app.MainFigure);
            app.IgnoreRandomPopInBagCheckBox.Text = 'Ignore Random Pop In Bag';
            app.IgnoreRandomPopInBagCheckBox.WordWrap = 'on';
            app.IgnoreRandomPopInBagCheckBox.Position = [214 295 103 36];
            app.IgnoreRandomPopInBagCheckBox.Value = true;

            % Show the figure after all components are created
            app.MainFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = task_scheduler_ui(varargin)

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
