classdef result_analysis_ui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MainFigure                     matlab.ui.Figure
        SingleResultsPanel             matlab.ui.container.Panel
        SelectResultButton             matlab.ui.control.Button
        GenerateAllSingleResultPlotsButton  matlab.ui.control.Button
        NickNameField                  matlab.ui.control.EditField
        NicknameLabel                  matlab.ui.control.Label
        NickNameSaveButton             matlab.ui.control.Button
        OpenFolderButton               matlab.ui.control.Button
        ParentageTreeButton            matlab.ui.control.Button
        RobotIDYField                  matlab.ui.control.EditField
        RobotIDXField                  matlab.ui.control.EditField
        SimulateRobotButton            matlab.ui.control.Button
        LongevityofGenButton           matlab.ui.control.Button
        ParentagePlotsButton           matlab.ui.control.Button
        ParentageStatButton            matlab.ui.control.Button
        AvgAgeofMapButton              matlab.ui.control.Button
        BinUpdatesButton               matlab.ui.control.Button
        StatPlotButton                 matlab.ui.control.Button
        ToLabel                        matlab.ui.control.Label
        StatEndGenField                matlab.ui.control.EditField
        FromLabel                      matlab.ui.control.Label
        StatStartGenField              matlab.ui.control.EditField
        GenLabel                       matlab.ui.control.Label
        GenIDField                     matlab.ui.control.EditField
        ResultInfoTextLabel            matlab.ui.control.Label
        ResultInfoLabel                matlab.ui.control.Label
        PlotGenButton                  matlab.ui.control.Button
        GenStepField                   matlab.ui.control.EditField
        LoadFirstButton                matlab.ui.control.Button
        LoadLastButton                 matlab.ui.control.Button
        LoadPrevStepButton             matlab.ui.control.Button
        LoadNextStepButton             matlab.ui.control.Button
        LoadPrevButton                 matlab.ui.control.Button
        LoadNextButton                 matlab.ui.control.Button
        ResultNameLabel                matlab.ui.control.Label
        AddResultToCompareButton       matlab.ui.control.Button
        LoadResultGroupButton          matlab.ui.control.Button
        PatchResultStatButton          matlab.ui.control.Button
        BuildSelectedResultStatButton  matlab.ui.control.Button
        BuildAllResultStatButton       matlab.ui.control.Button
        RefreshResultListButton        matlab.ui.control.Button
        ResultGroupLabel               matlab.ui.control.Label
        ResultsListBox                 matlab.ui.control.ListBox
        VirtualResultsPanel            matlab.ui.container.Panel
        MannWhitneyTestCoverageAllButton  matlab.ui.control.Button
        mwwPercentEditField            matlab.ui.control.NumericEditField
        mwwLabel                       matlab.ui.control.Label
        MannWhitneyTestPercentAllButton  matlab.ui.control.Button
        MannWhitneyTestAllButton       matlab.ui.control.Button
        mwwGenEditField                matlab.ui.control.NumericEditField
        mwwGenEditFieldLabel           matlab.ui.control.Label
        QQPlotForVirtualButton         matlab.ui.control.Button
        VirtualResultNameField         matlab.ui.control.EditField
        GroupNameLabel                 matlab.ui.control.Label
        AddVirtualToCompareButton      matlab.ui.control.Button
        DeleteVirtualResultButton      matlab.ui.control.Button
        AddVirtualResultButton         matlab.ui.control.Button
        VirtualResultsListBox          matlab.ui.control.ListBox
        GroupStatButton                matlab.ui.control.Button
        GenerateAllVirtualResultPlotsButton  matlab.ui.control.Button
        ComparePanel                   matlab.ui.container.Panel
        MannWhitneyTestButton          matlab.ui.control.Button
        QQPlotForCompareButton         matlab.ui.control.Button
        TTestOptionDropDown            matlab.ui.control.DropDown
        TTestOptionDropDownLabel       matlab.ui.control.Label
        TTestAllButton                 matlab.ui.control.Button
        VarTestButton                  matlab.ui.control.Button
        ANOVAButton                    matlab.ui.control.Button
        TTestButton                    matlab.ui.control.Button
        CompPlotNameField              matlab.ui.control.EditField
        PlotNameLabel                  matlab.ui.control.Label
        CleanCompareButton             matlab.ui.control.Button
        ComparePlotButton              matlab.ui.control.Button
        MoveCompareDownButton          matlab.ui.control.Button
        MoveCompareUpButton            matlab.ui.control.Button
        RemoveAllCompareButton         matlab.ui.control.Button
        RemoveCompareButton            matlab.ui.control.Button
        CompareListBox                 matlab.ui.control.ListBox
        GenerateAllComparePlotsButton  matlab.ui.control.Button
        DebugPanel                     matlab.ui.container.Panel
        CLCButton                      matlab.ui.control.Button
        RehashButton                   matlab.ui.control.Button
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
        results = {} % array containing the cache of the loaded results
        virtual_results = {} % array containing the cache of virtual results
        targets_to_compare = {} % cell array containing the targets (raw result/virtual result) to compare
        current_result = {} % reference to the currently seleceted result
        current_virtual_result = {} % reference to the currently seleceted virtual result
        current_gen = -1
        gen_plot % containing handles to gen_plot
        compare_plot_config % struct containing the config for compare plots

        % TODO: need to remove the following
        robots_buffer
        robots_gen = -1
        archive_ids
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, evogen_exe_path, evogen_results_path)
            app.evogen_exe_path = evogen_exe_path;
            app.evogen_results_path = evogen_results_path;
            result_analysis_init(app);
        end

        % Button pushed function: SelectResultButton
        function SelectResultButtonPushed(app, event)
            select_result(app);
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
            load_gen(app, app.current_result.evo_params.nb_gen);
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

        % Button pushed function: AddVirtualResultButton
        function AddVirtualResultButtonPushed(app, event)
            add_virtual_result(app);
        end

        % Button pushed function: DeleteVirtualResultButton
        function DeleteVirtualResultButtonPushed(app, event)
            delete_virtual_result(app);
        end

        % Button pushed function: AddResultToCompareButton
        function AddResultToCompareButtonPushed(app, event)
            add_target_to_compare(app, false);
        end

        % Button pushed function: AddVirtualToCompareButton
        function AddVirtualToCompareButtonPushed(app, event)
            add_target_to_compare(app, true);
        end

        % Button pushed function: RemoveCompareButton
        function RemoveCompareButtonPushed(app, event)
            delete_from_compare_list(app, false);
        end

        % Button pushed function: RemoveAllCompareButton
        function RemoveAllCompareButtonPushed(app, event)
            delete_from_compare_list(app, true);
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

        % Value changed function: GenStepField
        function GenStepFieldValueChanged(app, event)
            app.gen_step = max(str2double(app.GenStepField.Value), 0);
        end

        % Button pushed function: ParentageTreeButton
        function ParentageTreeButtonPushed(app, event)
            plot_parentage_trace(app);
        end

        % Button pushed function: BinUpdatesButton
        function BinUpdatesButtonPushed(app, event)
            plot_bin_updates(app);
        end

        % Button pushed function: AvgAgeofMapButton
        function AvgAgeofMapButtonPushed(app, event)
            plot_avg_age_of_map(app);
        end

        % Button pushed function: LongevityofGenButton
        function LongevityofGenButtonPushed(app, event)
            plot_avg_longevity_of_gen(app);
        end

        % Button pushed function: RefreshResultListButton
        function RefreshResultListButtonPushed(app, event)
            refresh_result_list(app, 'ForceUpdate', true);
        end

        % Button pushed function: BuildAllResultStatButton
        function BuildAllResultStatButtonPushed(app, event)
            build_all_stat(app);
        end

        % Button pushed function: ParentageStatButton
        function ParentageStatButtonPushed(app, event)
            plot_parentage_stat(app);
        end

        % Button pushed function: BuildSelectedResultStatButton
        function BuildSelectedResultStatButtonPushed(app, event)
            build_selected_stat(app);
        end

        % Button pushed function: PatchResultStatButton
        function PatchResultStatButtonPushed(app, event)
            patch_selected_stat(app);
        end

        % Button pushed function: PlotGenButton
        function PlotGenButtonPushed(app, event)
            open_gen_all_plot(app);
            plot_gen_all(app);
        end

        % Button pushed function: LoadResultGroupButton
        function LoadResultGroupButtonPushed(app, event)
            load_group(app);
        end

        % Button pushed function: MoveCompareUpButton
        function MoveCompareUpButtonPushed(app, event)
            move_target_in_compare_list(app, true);
        end

        % Button pushed function: MoveCompareDownButton
        function MoveCompareDownButtonPushed(app, event)
            move_target_in_compare_list(app, false);
        end

        % Button pushed function: ParentagePlotsButton
        function ParentagePlotsButtonPushed(app, event)
            plot_parentage_related(app);
        end

        % Button pushed function: GroupStatButton
        function GroupStatButtonPushed(app, event)
            plot_group_stat(app);
        end

        % Button pushed function: QQPlotForVirtualButton
        function QQPlotForVirtualButtonPushed(app, event)
            plot_qq_for_virtual_result(app);
        end

        % Button pushed function: GenerateAllSingleResultPlotsButton
        function GenerateAllSingleResultPlotsButtonPushed(app, event)
            generate_all_single_result_plots(app);
        end

        % Button pushed function: GenerateAllVirtualResultPlotsButton
        function GenerateAllVirtualResultPlotsButtonPushed(app, event)
            generate_all_virtual_result_plots(app);
        end

        % Button pushed function: GenerateAllComparePlotsButton
        function GenerateAllComparePlotsButtonPushed(app, event)
            generate_all_compare_plots(app);
        end

        % Button pushed function: RehashButton
        function RehashButtonPushed(app, event)
            rehash;
        end

        % Button pushed function: CLCButton
        function CLCButtonPushed(app, event)
            clc;
        end

        % Button pushed function: TTestButton
        function TTestButtonPushed(app, event)
            run_ttest(app);
        end

        % Button pushed function: ANOVAButton
        function ANOVAButtonPushed(app, event)
            run_anova(app);
        end

        % Button pushed function: VarTestButton
        function VarTestButtonPushed(app, event)
            run_vartest(app);
        end

        % Button pushed function: TTestAllButton
        function TTestAllButtonPushed(app, event)
            run_ttest_all(app);
        end

        % Button pushed function: QQPlotForCompareButton
        function QQPlotForCompareButtonPushed(app, event)
            plot_qq_for_compare(app);
        end

        % Button pushed function: MannWhitneyTestButton
        function MannWhitneyTestButtonPushed(app, event)
            run_mwwtest(app);
        end

        % Button pushed function: MannWhitneyTestAllButton
        function MannWhitneyTestAllButtonPushed(app, event)
            run_mwwtest_all(app);
        end

        % Button pushed function: MannWhitneyTestPercentAllButton
        function MannWhitneyTestPercentAllButtonPushed(app, event)
            run_mwwtest_percent_all(app);
        end

        % Button pushed function: MannWhitneyTestCoverageAllButton
        function MannWhitneyTestCoverageAllButtonPushed(app, event)
            run_mwwtest_coverage_all(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MainFigure and hide until all components are created
            app.MainFigure = uifigure('Visible', 'off');
            app.MainFigure.Position = [100 100 1228 580];
            app.MainFigure.Name = 'Evolutionary Robogami Result Viewer';

            % Create DebugPanel
            app.DebugPanel = uipanel(app.MainFigure);
            app.DebugPanel.Title = 'Debug';
            app.DebugPanel.FontWeight = 'bold';
            app.DebugPanel.Position = [1131 1 100 580];

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

            % Create ComparePanel
            app.ComparePanel = uipanel(app.MainFigure);
            app.ComparePanel.Title = 'Compare';
            app.ComparePanel.FontWeight = 'bold';
            app.ComparePanel.Position = [852 1 280 580];

            % Create GenerateAllComparePlotsButton
            app.GenerateAllComparePlotsButton = uibutton(app.ComparePanel, 'push');
            app.GenerateAllComparePlotsButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateAllComparePlotsButtonPushed, true);
            app.GenerateAllComparePlotsButton.WordWrap = 'on';
            app.GenerateAllComparePlotsButton.FontSize = 11;
            app.GenerateAllComparePlotsButton.Position = [185 10 65 45];
            app.GenerateAllComparePlotsButton.Text = 'Generate All Plots';

            % Create CompareListBox
            app.CompareListBox = uilistbox(app.ComparePanel);
            app.CompareListBox.Items = {};
            app.CompareListBox.Multiselect = 'on';
            app.CompareListBox.Position = [1 1 176 524];
            app.CompareListBox.Value = {};

            % Create RemoveCompareButton
            app.RemoveCompareButton = uibutton(app.ComparePanel, 'push');
            app.RemoveCompareButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveCompareButtonPushed, true);
            app.RemoveCompareButton.Position = [185 446 60 22];
            app.RemoveCompareButton.Text = 'Remove';

            % Create RemoveAllCompareButton
            app.RemoveAllCompareButton = uibutton(app.ComparePanel, 'push');
            app.RemoveAllCompareButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveAllCompareButtonPushed, true);
            app.RemoveAllCompareButton.Position = [185 531 60 22];
            app.RemoveAllCompareButton.Text = 'Clear All';

            % Create MoveCompareUpButton
            app.MoveCompareUpButton = uibutton(app.ComparePanel, 'push');
            app.MoveCompareUpButton.ButtonPushedFcn = createCallbackFcn(app, @MoveCompareUpButtonPushed, true);
            app.MoveCompareUpButton.Position = [185 499 60 22];
            app.MoveCompareUpButton.Text = 'Up';

            % Create MoveCompareDownButton
            app.MoveCompareDownButton = uibutton(app.ComparePanel, 'push');
            app.MoveCompareDownButton.ButtonPushedFcn = createCallbackFcn(app, @MoveCompareDownButtonPushed, true);
            app.MoveCompareDownButton.Position = [185 474 60 22];
            app.MoveCompareDownButton.Text = 'Down';

            % Create ComparePlotButton
            app.ComparePlotButton = uibutton(app.ComparePanel, 'push');
            app.ComparePlotButton.ButtonPushedFcn = createCallbackFcn(app, @ComparePlotButtonPushed, true);
            app.ComparePlotButton.WordWrap = 'on';
            app.ComparePlotButton.Position = [185 390 63 36];
            app.ComparePlotButton.Text = 'Compare Plot';

            % Create CleanCompareButton
            app.CleanCompareButton = uibutton(app.ComparePanel, 'push');
            app.CleanCompareButton.ButtonPushedFcn = createCallbackFcn(app, @CleanCompareButtonPushed, true);
            app.CleanCompareButton.WordWrap = 'on';
            app.CleanCompareButton.Position = [185 342 63 43];
            app.CleanCompareButton.Text = 'Clean Compare';

            % Create PlotNameLabel
            app.PlotNameLabel = uilabel(app.ComparePanel);
            app.PlotNameLabel.Position = [4 531 65 22];
            app.PlotNameLabel.Text = 'Plot Name:';

            % Create CompPlotNameField
            app.CompPlotNameField = uieditfield(app.ComparePanel, 'text');
            app.CompPlotNameField.Position = [68 532 109 22];

            % Create TTestButton
            app.TTestButton = uibutton(app.ComparePanel, 'push');
            app.TTestButton.ButtonPushedFcn = createCallbackFcn(app, @TTestButtonPushed, true);
            app.TTestButton.WordWrap = 'on';
            app.TTestButton.Position = [188 258 57 22];
            app.TTestButton.Text = 'T-Test';

            % Create ANOVAButton
            app.ANOVAButton = uibutton(app.ComparePanel, 'push');
            app.ANOVAButton.ButtonPushedFcn = createCallbackFcn(app, @ANOVAButtonPushed, true);
            app.ANOVAButton.WordWrap = 'on';
            app.ANOVAButton.Position = [188 234 57 22];
            app.ANOVAButton.Text = 'ANOVA';

            % Create VarTestButton
            app.VarTestButton = uibutton(app.ComparePanel, 'push');
            app.VarTestButton.ButtonPushedFcn = createCallbackFcn(app, @VarTestButtonPushed, true);
            app.VarTestButton.WordWrap = 'on';
            app.VarTestButton.Position = [188 211 57 22];
            app.VarTestButton.Text = 'VarTest';

            % Create TTestAllButton
            app.TTestAllButton = uibutton(app.ComparePanel, 'push');
            app.TTestAllButton.ButtonPushedFcn = createCallbackFcn(app, @TTestAllButtonPushed, true);
            app.TTestAllButton.Position = [185 187 65 22];
            app.TTestAllButton.Text = 'T-Test All';

            % Create TTestOptionDropDownLabel
            app.TTestOptionDropDownLabel = uilabel(app.ComparePanel);
            app.TTestOptionDropDownLabel.Position = [181 309 73 22];
            app.TTestOptionDropDownLabel.Text = 'T-Test Option';

            % Create TTestOptionDropDown
            app.TTestOptionDropDown = uidropdown(app.ComparePanel);
            app.TTestOptionDropDown.Items = {};
            app.TTestOptionDropDown.Position = [181 282 92 22];
            app.TTestOptionDropDown.Value = {};

            % Create QQPlotForCompareButton
            app.QQPlotForCompareButton = uibutton(app.ComparePanel, 'push');
            app.QQPlotForCompareButton.ButtonPushedFcn = createCallbackFcn(app, @QQPlotForCompareButtonPushed, true);
            app.QQPlotForCompareButton.WordWrap = 'on';
            app.QQPlotForCompareButton.Position = [190 164 57 22];
            app.QQPlotForCompareButton.Text = 'QQ Plot';

            % Create MannWhitneyTestButton
            app.MannWhitneyTestButton = uibutton(app.ComparePanel, 'push');
            app.MannWhitneyTestButton.ButtonPushedFcn = createCallbackFcn(app, @MannWhitneyTestButtonPushed, true);
            app.MannWhitneyTestButton.WordWrap = 'on';
            app.MannWhitneyTestButton.Position = [187 83 57 22];
            app.MannWhitneyTestButton.Text = 'mwwtest';

            % Create VirtualResultsPanel
            app.VirtualResultsPanel = uipanel(app.MainFigure);
            app.VirtualResultsPanel.Title = 'Virtual Results';
            app.VirtualResultsPanel.FontWeight = 'bold';
            app.VirtualResultsPanel.Position = [598 1 255 580];

            % Create GenerateAllVirtualResultPlotsButton
            app.GenerateAllVirtualResultPlotsButton = uibutton(app.VirtualResultsPanel, 'push');
            app.GenerateAllVirtualResultPlotsButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateAllVirtualResultPlotsButtonPushed, true);
            app.GenerateAllVirtualResultPlotsButton.WordWrap = 'on';
            app.GenerateAllVirtualResultPlotsButton.FontSize = 11;
            app.GenerateAllVirtualResultPlotsButton.Position = [182 10 65 45];
            app.GenerateAllVirtualResultPlotsButton.Text = 'Generate All Plots';

            % Create GroupStatButton
            app.GroupStatButton = uibutton(app.VirtualResultsPanel, 'push');
            app.GroupStatButton.ButtonPushedFcn = createCallbackFcn(app, @GroupStatButtonPushed, true);
            app.GroupStatButton.WordWrap = 'on';
            app.GroupStatButton.Position = [182 346 57 36];
            app.GroupStatButton.Text = 'Group Stat';

            % Create VirtualResultsListBox
            app.VirtualResultsListBox = uilistbox(app.VirtualResultsPanel);
            app.VirtualResultsListBox.Items = {};
            app.VirtualResultsListBox.Multiselect = 'on';
            app.VirtualResultsListBox.Position = [1 1 176 524];
            app.VirtualResultsListBox.Value = {};

            % Create AddVirtualResultButton
            app.AddVirtualResultButton = uibutton(app.VirtualResultsPanel, 'push');
            app.AddVirtualResultButton.ButtonPushedFcn = createCallbackFcn(app, @AddVirtualResultButtonPushed, true);
            app.AddVirtualResultButton.Position = [182 533 57 22];
            app.AddVirtualResultButton.Text = 'Create';

            % Create DeleteVirtualResultButton
            app.DeleteVirtualResultButton = uibutton(app.VirtualResultsPanel, 'push');
            app.DeleteVirtualResultButton.ButtonPushedFcn = createCallbackFcn(app, @DeleteVirtualResultButtonPushed, true);
            app.DeleteVirtualResultButton.Position = [182 509 57 22];
            app.DeleteVirtualResultButton.Text = 'Remove';

            % Create AddVirtualToCompareButton
            app.AddVirtualToCompareButton = uibutton(app.VirtualResultsPanel, 'push');
            app.AddVirtualToCompareButton.ButtonPushedFcn = createCallbackFcn(app, @AddVirtualToCompareButtonPushed, true);
            app.AddVirtualToCompareButton.WordWrap = 'on';
            app.AddVirtualToCompareButton.FontSize = 11;
            app.AddVirtualToCompareButton.Position = [182 420 65 45];
            app.AddVirtualToCompareButton.Text = 'Add to Compare';

            % Create GroupNameLabel
            app.GroupNameLabel = uilabel(app.VirtualResultsPanel);
            app.GroupNameLabel.Position = [4 531 68 22];
            app.GroupNameLabel.Text = 'New Name:';

            % Create VirtualResultNameField
            app.VirtualResultNameField = uieditfield(app.VirtualResultsPanel, 'text');
            app.VirtualResultNameField.Position = [72 532 105 22];

            % Create QQPlotForVirtualButton
            app.QQPlotForVirtualButton = uibutton(app.VirtualResultsPanel, 'push');
            app.QQPlotForVirtualButton.ButtonPushedFcn = createCallbackFcn(app, @QQPlotForVirtualButtonPushed, true);
            app.QQPlotForVirtualButton.WordWrap = 'on';
            app.QQPlotForVirtualButton.Position = [182 309 57 22];
            app.QQPlotForVirtualButton.Text = 'QQ Plot';

            % Create mwwGenEditFieldLabel
            app.mwwGenEditFieldLabel = uilabel(app.VirtualResultsPanel);
            app.mwwGenEditFieldLabel.WordWrap = 'on';
            app.mwwGenEditFieldLabel.Position = [182 279 57 17];
            app.mwwGenEditFieldLabel.Text = 'mww Gen:';

            % Create mwwGenEditField
            app.mwwGenEditField = uieditfield(app.VirtualResultsPanel, 'numeric');
            app.mwwGenEditField.Position = [182 252 65 22];

            % Create MannWhitneyTestAllButton
            app.MannWhitneyTestAllButton = uibutton(app.VirtualResultsPanel, 'push');
            app.MannWhitneyTestAllButton.ButtonPushedFcn = createCallbackFcn(app, @MannWhitneyTestAllButtonPushed, true);
            app.MannWhitneyTestAllButton.WordWrap = 'on';
            app.MannWhitneyTestAllButton.Position = [184 213 60 36];
            app.MannWhitneyTestAllButton.Text = 'mwwtest all';

            % Create MannWhitneyTestPercentAllButton
            app.MannWhitneyTestPercentAllButton = uibutton(app.VirtualResultsPanel, 'push');
            app.MannWhitneyTestPercentAllButton.ButtonPushedFcn = createCallbackFcn(app, @MannWhitneyTestPercentAllButtonPushed, true);
            app.MannWhitneyTestPercentAllButton.WordWrap = 'on';
            app.MannWhitneyTestPercentAllButton.Position = [186 108 60 50];
            app.MannWhitneyTestPercentAllButton.Text = 'mwwtest percent all';

            % Create mwwLabel
            app.mwwLabel = uilabel(app.VirtualResultsPanel);
            app.mwwLabel.WordWrap = 'on';
            app.mwwLabel.Position = [184 183 57 22];
            app.mwwLabel.Text = 'mww %:';

            % Create mwwPercentEditField
            app.mwwPercentEditField = uieditfield(app.VirtualResultsPanel, 'numeric');
            app.mwwPercentEditField.Position = [184 161 65 22];

            % Create MannWhitneyTestCoverageAllButton
            app.MannWhitneyTestCoverageAllButton = uibutton(app.VirtualResultsPanel, 'push');
            app.MannWhitneyTestCoverageAllButton.ButtonPushedFcn = createCallbackFcn(app, @MannWhitneyTestCoverageAllButtonPushed, true);
            app.MannWhitneyTestCoverageAllButton.WordWrap = 'on';
            app.MannWhitneyTestCoverageAllButton.Position = [186 58 60 50];
            app.MannWhitneyTestCoverageAllButton.Text = 'mwwtest coverage all';

            % Create SingleResultsPanel
            app.SingleResultsPanel = uipanel(app.MainFigure);
            app.SingleResultsPanel.Title = 'Single Results';
            app.SingleResultsPanel.FontWeight = 'bold';
            app.SingleResultsPanel.Position = [1 1 598 580];

            % Create ResultsListBox
            app.ResultsListBox = uilistbox(app.SingleResultsPanel);
            app.ResultsListBox.Items = {};
            app.ResultsListBox.Multiselect = 'on';
            app.ResultsListBox.Position = [2 1 274 532];
            app.ResultsListBox.Value = {};

            % Create ResultGroupLabel
            app.ResultGroupLabel = uilabel(app.SingleResultsPanel);
            app.ResultGroupLabel.HorizontalAlignment = 'center';
            app.ResultGroupLabel.FontSize = 14;
            app.ResultGroupLabel.FontWeight = 'bold';
            app.ResultGroupLabel.Position = [2 537 271 22];
            app.ResultGroupLabel.Text = 'Group';

            % Create RefreshResultListButton
            app.RefreshResultListButton = uibutton(app.SingleResultsPanel, 'push');
            app.RefreshResultListButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshResultListButtonPushed, true);
            app.RefreshResultListButton.Tag = 'loadresult';
            app.RefreshResultListButton.Position = [280 497 62 22];
            app.RefreshResultListButton.Text = 'Refresh';

            % Create BuildAllResultStatButton
            app.BuildAllResultStatButton = uibutton(app.SingleResultsPanel, 'push');
            app.BuildAllResultStatButton.ButtonPushedFcn = createCallbackFcn(app, @BuildAllResultStatButtonPushed, true);
            app.BuildAllResultStatButton.Tag = 'loadresult';
            app.BuildAllResultStatButton.Position = [280 474 62 22];
            app.BuildAllResultStatButton.Text = 'Build All';

            % Create BuildSelectedResultStatButton
            app.BuildSelectedResultStatButton = uibutton(app.SingleResultsPanel, 'push');
            app.BuildSelectedResultStatButton.ButtonPushedFcn = createCallbackFcn(app, @BuildSelectedResultStatButtonPushed, true);
            app.BuildSelectedResultStatButton.Tag = 'loadresult';
            app.BuildSelectedResultStatButton.Position = [280 450 62 22];
            app.BuildSelectedResultStatButton.Text = 'Build';

            % Create PatchResultStatButton
            app.PatchResultStatButton = uibutton(app.SingleResultsPanel, 'push');
            app.PatchResultStatButton.ButtonPushedFcn = createCallbackFcn(app, @PatchResultStatButtonPushed, true);
            app.PatchResultStatButton.Tag = 'loadresult';
            app.PatchResultStatButton.Position = [280 427 62 22];
            app.PatchResultStatButton.Text = 'Patch';

            % Create LoadResultGroupButton
            app.LoadResultGroupButton = uibutton(app.SingleResultsPanel, 'push');
            app.LoadResultGroupButton.ButtonPushedFcn = createCallbackFcn(app, @LoadResultGroupButtonPushed, true);
            app.LoadResultGroupButton.Tag = 'loadresult';
            app.LoadResultGroupButton.WordWrap = 'on';
            app.LoadResultGroupButton.Position = [280 521 62 35];
            app.LoadResultGroupButton.Text = 'Load Group';

            % Create AddResultToCompareButton
            app.AddResultToCompareButton = uibutton(app.SingleResultsPanel, 'push');
            app.AddResultToCompareButton.ButtonPushedFcn = createCallbackFcn(app, @AddResultToCompareButtonPushed, true);
            app.AddResultToCompareButton.WordWrap = 'on';
            app.AddResultToCompareButton.FontSize = 11;
            app.AddResultToCompareButton.Position = [280 372 65 45];
            app.AddResultToCompareButton.Text = 'Add to Compare';

            % Create ResultNameLabel
            app.ResultNameLabel = uilabel(app.SingleResultsPanel);
            app.ResultNameLabel.HorizontalAlignment = 'center';
            app.ResultNameLabel.FontSize = 16;
            app.ResultNameLabel.FontWeight = 'bold';
            app.ResultNameLabel.Position = [384 499 196 30];
            app.ResultNameLabel.Text = 'Load a result to view';

            % Create LoadNextButton
            app.LoadNextButton = uibutton(app.SingleResultsPanel, 'push');
            app.LoadNextButton.ButtonPushedFcn = createCallbackFcn(app, @LoadNextButtonPushed, true);
            app.LoadNextButton.Position = [472 302 25 22];
            app.LoadNextButton.Text = '>';

            % Create LoadPrevButton
            app.LoadPrevButton = uibutton(app.SingleResultsPanel, 'push');
            app.LoadPrevButton.ButtonPushedFcn = createCallbackFcn(app, @LoadPrevButtonPushed, true);
            app.LoadPrevButton.Position = [447 302 25 22];
            app.LoadPrevButton.Text = '<';

            % Create LoadNextStepButton
            app.LoadNextStepButton = uibutton(app.SingleResultsPanel, 'push');
            app.LoadNextStepButton.ButtonPushedFcn = createCallbackFcn(app, @LoadNextStepButtonPushed, true);
            app.LoadNextStepButton.Position = [494 281 30 22];
            app.LoadNextStepButton.Text = '+';

            % Create LoadPrevStepButton
            app.LoadPrevStepButton = uibutton(app.SingleResultsPanel, 'push');
            app.LoadPrevStepButton.ButtonPushedFcn = createCallbackFcn(app, @LoadPrevStepButtonPushed, true);
            app.LoadPrevStepButton.Position = [423 281 30 22];
            app.LoadPrevStepButton.Text = '-';

            % Create LoadLastButton
            app.LoadLastButton = uibutton(app.SingleResultsPanel, 'push');
            app.LoadLastButton.ButtonPushedFcn = createCallbackFcn(app, @LoadLastButtonPushed, true);
            app.LoadLastButton.Position = [497 302 25 22];
            app.LoadLastButton.Text = '>>';

            % Create LoadFirstButton
            app.LoadFirstButton = uibutton(app.SingleResultsPanel, 'push');
            app.LoadFirstButton.ButtonPushedFcn = createCallbackFcn(app, @LoadFirstButtonPushed, true);
            app.LoadFirstButton.Position = [422 302 25 22];
            app.LoadFirstButton.Text = '<<';

            % Create GenStepField
            app.GenStepField = uieditfield(app.SingleResultsPanel, 'text');
            app.GenStepField.ValueChangedFcn = createCallbackFcn(app, @GenStepFieldValueChanged, true);
            app.GenStepField.HorizontalAlignment = 'center';
            app.GenStepField.Position = [454 281 39 22];

            % Create PlotGenButton
            app.PlotGenButton = uibutton(app.SingleResultsPanel, 'push');
            app.PlotGenButton.ButtonPushedFcn = createCallbackFcn(app, @PlotGenButtonPushed, true);
            app.PlotGenButton.Position = [506 331 64 22];
            app.PlotGenButton.Text = 'Plot Gen';

            % Create ResultInfoLabel
            app.ResultInfoLabel = uilabel(app.SingleResultsPanel);
            app.ResultInfoLabel.FontSize = 13;
            app.ResultInfoLabel.FontWeight = 'bold';
            app.ResultInfoLabel.Position = [388 468 77 22];
            app.ResultInfoLabel.Text = 'Result Info:';

            % Create ResultInfoTextLabel
            app.ResultInfoTextLabel = uilabel(app.SingleResultsPanel);
            app.ResultInfoTextLabel.VerticalAlignment = 'top';
            app.ResultInfoTextLabel.Position = [400 363 191 105];
            app.ResultInfoTextLabel.Text = '';

            % Create GenIDField
            app.GenIDField = uieditfield(app.SingleResultsPanel, 'text');
            app.GenIDField.ValueChangedFcn = createCallbackFcn(app, @GenIDFieldValueChanged, true);
            app.GenIDField.HorizontalAlignment = 'center';
            app.GenIDField.Position = [440 331 58 22];

            % Create GenLabel
            app.GenLabel = uilabel(app.SingleResultsPanel);
            app.GenLabel.FontSize = 13;
            app.GenLabel.FontWeight = 'bold';
            app.GenLabel.Position = [407 331 35 22];
            app.GenLabel.Text = 'Gen:';

            % Create StatStartGenField
            app.StatStartGenField = uieditfield(app.SingleResultsPanel, 'text');
            app.StatStartGenField.HorizontalAlignment = 'center';
            app.StatStartGenField.Position = [427 249 41 22];

            % Create FromLabel
            app.FromLabel = uilabel(app.SingleResultsPanel);
            app.FromLabel.FontSize = 13;
            app.FromLabel.FontWeight = 'bold';
            app.FromLabel.Position = [387 249 41 22];
            app.FromLabel.Text = 'From:';

            % Create StatEndGenField
            app.StatEndGenField = uieditfield(app.SingleResultsPanel, 'text');
            app.StatEndGenField.HorizontalAlignment = 'center';
            app.StatEndGenField.Position = [494 249 62 22];

            % Create ToLabel
            app.ToLabel = uilabel(app.SingleResultsPanel);
            app.ToLabel.FontSize = 13;
            app.ToLabel.FontWeight = 'bold';
            app.ToLabel.Position = [473 249 25 22];
            app.ToLabel.Text = 'To:';

            % Create StatPlotButton
            app.StatPlotButton = uibutton(app.SingleResultsPanel, 'push');
            app.StatPlotButton.ButtonPushedFcn = createCallbackFcn(app, @StatPlotButtonPushed, true);
            app.StatPlotButton.Position = [403 219 64 22];
            app.StatPlotButton.Text = 'Statistics';

            % Create BinUpdatesButton
            app.BinUpdatesButton = uibutton(app.SingleResultsPanel, 'push');
            app.BinUpdatesButton.ButtonPushedFcn = createCallbackFcn(app, @BinUpdatesButtonPushed, true);
            app.BinUpdatesButton.Tag = 'loadresult';
            app.BinUpdatesButton.Position = [398 173 76 22];
            app.BinUpdatesButton.Text = 'Bin Updates';

            % Create AvgAgeofMapButton
            app.AvgAgeofMapButton = uibutton(app.SingleResultsPanel, 'push');
            app.AvgAgeofMapButton.ButtonPushedFcn = createCallbackFcn(app, @AvgAgeofMapButtonPushed, true);
            app.AvgAgeofMapButton.Tag = 'loadresult';
            app.AvgAgeofMapButton.Position = [388 196 100 22];
            app.AvgAgeofMapButton.Text = 'Avg Age of Map';

            % Create ParentageStatButton
            app.ParentageStatButton = uibutton(app.SingleResultsPanel, 'push');
            app.ParentageStatButton.ButtonPushedFcn = createCallbackFcn(app, @ParentageStatButtonPushed, true);
            app.ParentageStatButton.Tag = 'loadresult';
            app.ParentageStatButton.Position = [493 219 89 22];
            app.ParentageStatButton.Text = 'Parentage Stat';

            % Create ParentagePlotsButton
            app.ParentagePlotsButton = uibutton(app.SingleResultsPanel, 'push');
            app.ParentagePlotsButton.ButtonPushedFcn = createCallbackFcn(app, @ParentagePlotsButtonPushed, true);
            app.ParentagePlotsButton.Tag = 'loadresult';
            app.ParentagePlotsButton.WordWrap = 'on';
            app.ParentagePlotsButton.Position = [491 182 95 32];
            app.ParentagePlotsButton.Text = 'Parentage Plots';

            % Create LongevityofGenButton
            app.LongevityofGenButton = uibutton(app.SingleResultsPanel, 'push');
            app.LongevityofGenButton.ButtonPushedFcn = createCallbackFcn(app, @LongevityofGenButtonPushed, true);
            app.LongevityofGenButton.Tag = 'loadresult';
            app.LongevityofGenButton.WordWrap = 'on';
            app.LongevityofGenButton.Position = [396 134 82 36];
            app.LongevityofGenButton.Text = 'Longevity of Gen';

            % Create SimulateRobotButton
            app.SimulateRobotButton = uibutton(app.SingleResultsPanel, 'push');
            app.SimulateRobotButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateRobotButtonPushed, true);
            app.SimulateRobotButton.Tag = 'loadresult';
            app.SimulateRobotButton.Position = [412 6 55 22];
            app.SimulateRobotButton.Text = 'Simulate';

            % Create RobotIDXField
            app.RobotIDXField = uieditfield(app.SingleResultsPanel, 'text');
            app.RobotIDXField.HorizontalAlignment = 'center';
            app.RobotIDXField.Position = [534 20 39 22];

            % Create RobotIDYField
            app.RobotIDYField = uieditfield(app.SingleResultsPanel, 'text');
            app.RobotIDYField.HorizontalAlignment = 'center';
            app.RobotIDYField.Position = [492 20 39 22];

            % Create ParentageTreeButton
            app.ParentageTreeButton = uibutton(app.SingleResultsPanel, 'push');
            app.ParentageTreeButton.ButtonPushedFcn = createCallbackFcn(app, @ParentageTreeButtonPushed, true);
            app.ParentageTreeButton.Tag = 'loadresult';
            app.ParentageTreeButton.WordWrap = 'on';
            app.ParentageTreeButton.Position = [400 30 78 32];
            app.ParentageTreeButton.Text = 'Parentage Tree';

            % Create OpenFolderButton
            app.OpenFolderButton = uibutton(app.SingleResultsPanel, 'push');
            app.OpenFolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFolderButtonPushed, true);
            app.OpenFolderButton.Tag = 'loadresult';
            app.OpenFolderButton.Position = [288 67 82 22];
            app.OpenFolderButton.Text = 'Open Folder';

            % Create NickNameSaveButton
            app.NickNameSaveButton = uibutton(app.SingleResultsPanel, 'push');
            app.NickNameSaveButton.ButtonPushedFcn = createCallbackFcn(app, @NickNameSaveButtonPushed, true);
            app.NickNameSaveButton.Tag = 'loadresult';
            app.NickNameSaveButton.Position = [285 111 90 22];
            app.NickNameSaveButton.Text = 'Set Nickname';

            % Create NicknameLabel
            app.NicknameLabel = uilabel(app.SingleResultsPanel);
            app.NicknameLabel.HorizontalAlignment = 'right';
            app.NicknameLabel.Position = [282 161 62 22];
            app.NicknameLabel.Text = 'Nickname:';

            % Create NickNameField
            app.NickNameField = uieditfield(app.SingleResultsPanel, 'text');
            app.NickNameField.Position = [287 140 86 22];

            % Create GenerateAllSingleResultPlotsButton
            app.GenerateAllSingleResultPlotsButton = uibutton(app.SingleResultsPanel, 'push');
            app.GenerateAllSingleResultPlotsButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateAllSingleResultPlotsButtonPushed, true);
            app.GenerateAllSingleResultPlotsButton.WordWrap = 'on';
            app.GenerateAllSingleResultPlotsButton.FontSize = 11;
            app.GenerateAllSingleResultPlotsButton.Position = [280 10 65 45];
            app.GenerateAllSingleResultPlotsButton.Text = 'Generate All Plots';

            % Create SelectResultButton
            app.SelectResultButton = uibutton(app.SingleResultsPanel, 'push');
            app.SelectResultButton.ButtonPushedFcn = createCallbackFcn(app, @SelectResultButtonPushed, true);
            app.SelectResultButton.Tag = 'loadresult';
            app.SelectResultButton.Position = [460 532 71 22];
            app.SelectResultButton.Text = 'Select';

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
