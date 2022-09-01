classdef result_analyzer < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MainFigure                     matlab.ui.Figure
        DebugPanel                     matlab.ui.container.Panel
        CLCButton                      matlab.ui.control.Button
        RehashButton                   matlab.ui.control.Button
        SingleResultsPanel             matlab.ui.container.Panel
        PlotGenButton                  matlab.ui.control.Button
        Feature2DropDown               matlab.ui.control.DropDown
        Feature2DropDownLabel          matlab.ui.control.Label
        Feature1DropDown               matlab.ui.control.DropDown
        Feature1DropDownLabel          matlab.ui.control.Label
        GenLabel                       matlab.ui.control.Label
        GenIDField                     matlab.ui.control.EditField
        GenStepField                   matlab.ui.control.EditField
        LoadFirstButton                matlab.ui.control.Button
        LoadLastButton                 matlab.ui.control.Button
        LoadPrevStepButton             matlab.ui.control.Button
        LoadNextStepButton             matlab.ui.control.Button
        LoadPrevButton                 matlab.ui.control.Button
        LoadNextButton                 matlab.ui.control.Button
        UpdateFitAfterSim              matlab.ui.control.CheckBox
        RegenerateArchiveButton        matlab.ui.control.Button
        EnableResultEditCheckBox       matlab.ui.control.CheckBox
        CompareFitnessButton           matlab.ui.control.Button
        NextResultButton               matlab.ui.control.Button
        PrevResultButton               matlab.ui.control.Button
        ExportforPublishingButton      matlab.ui.control.Button
        ExportPickleButton             matlab.ui.control.Button
        DumpRobotsCheckBox             matlab.ui.control.CheckBox
        PackSelectedResultsButton      matlab.ui.control.Button
        ExportArchiveMapButton         matlab.ui.control.Button
        SanitizeArchiveCheckBox        matlab.ui.control.CheckBox
        ExportRobotButton              matlab.ui.control.Button
        ExportforPlottingButton        matlab.ui.control.Button
        SimTimeEditField               matlab.ui.control.NumericEditField
        SimTimeEditFieldLabel          matlab.ui.control.Label
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
        ResultInfoTextLabel            matlab.ui.control.Label
        ResultInfoLabel                matlab.ui.control.Label
        ResultNameLabel                matlab.ui.control.Label
        AddResultToCompareButton       matlab.ui.control.Button
        LoadResultGroupButton          matlab.ui.control.Button
        PatchResultStatButton          matlab.ui.control.Button
        BuildSelectedResultStatButton  matlab.ui.control.Button
        BuildPackExportAllButton       matlab.ui.control.Button
        RefreshResultListButton        matlab.ui.control.Button
        ResultGroupLabel               matlab.ui.control.Label
        ResultsListBox                 matlab.ui.control.ListBox
        VirtualResultsPanel            matlab.ui.container.Panel
        ComputeBenchmarkButton         matlab.ui.control.Button
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
        ComparisonPlotsTestsPanel      matlab.ui.container.Panel
        CalibrateForVideoButton        matlab.ui.control.Button
        ReEvalTypeDropDown             matlab.ui.control.DropDown
        ReEvalTypeDropDownLabel        matlab.ui.control.Label
        WithVisualizationCheckBox      matlab.ui.control.CheckBox
        ReevaluateFitnessButton        matlab.ui.control.Button
        CombinedArchiveMapButton       matlab.ui.control.Button
        VideoGenFitnessButton          matlab.ui.control.Button
        VideoGenIDField                matlab.ui.control.NumericEditField
        GenEditFieldLabel              matlab.ui.control.Label
        SimulateforVideoButton         matlab.ui.control.Button
        PaperPlot3Button               matlab.ui.control.Button
        PaperPlot2Button               matlab.ui.control.Button
        PaperPlot1Button               matlab.ui.control.Button
        ExportComparePlotDataButton    matlab.ui.control.Button
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
    end

    properties (Access = public)
        % Constants
        evogen_python_path
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
        meta_info % fields: results_path
        result_group_path = string.empty
        results = {} % array containing the cache of the loaded results
        virtual_results = {} % array containing the cache of virtual results
        targets_to_compare = {} % cell array containing the targets (raw result/virtual result) to compare
        current_result = {} % reference to the currently seleceted result
        current_virtual_result = {} % reference to the currently seleceted virtual result
        current_gen = -1
        plot_handles % containing handles to plots
        compare_plot_config % struct containing the config for compare plots

        % TODO: need to remove the following
        archive_ids
    end

    methods (Static)
        pack_result(result_path)
        [stat, stat_loaded] = build_stat(result, dump_robots, orig_stat, orig_stat_loaded)
        export_result(result, dest_path)
        sim_configs = video_simulation_configs(env)
    end

    methods (Access = private)
        %% System tools
        result_analyzer_init(app)
        open_folder(app)

        %% File System
        refresh_result_list(app, varargin)
        select_result(app, mode)
        load_gen(app, gen_to_load)
        load_group(app)
        load_result(app, result_idx_to_load)
        load_result_robots(app, result_idx_to_load)
        result = load_target_result(app, is_virtual, id)
        load_virtual_results(app)
        save_nickname(app)
        add_target_to_compare(app, adding_virtual)
        add_virtual_result(app)
        move_target_in_compare_list(app, move_up)
        delete_from_compare_list(app, do_remove_all)
        delete_virtual_result(app)

        %% File navigation and manipulation
        build_pack_export_all_results(app)
        build_selected_stat(app)
        export_archive_map(app)
        export_compare_plot_data(app)
        export_group(app)
        export_pickle_for_group(app)
        export_robot(app)
        patch_selected_stat(app)
        pack_selected_results(app)

        %% Evaluation
        compute_benchmark(app)
        compare_different_version_fitness(app)
        reevaluate_fitness(app)
        regenerate_archive_map(app)
        regenerate_archive_map_kernel(app, result_id)

        %% Plotting
        open_gen_all_plot(app)
        generate_all_compare_plots(app)
        generate_all_single_result_plots(app)
        generate_all_virtual_result_plots(app)
        generate_combined_archive_map(app)
        generate_paper_plot1(app)
        generate_paper_plot2(app)
        generate_paper_plot3(app)
        generate_video_fitness_plot(app)
        plot_avg_age_of_map(app)
        plot_avg_longevity_of_gen(app)
        plot_bin_updates(app)
        plot_gen_all(app)
        plot_group_stat(app)
        plot_parentage_related(app)
        plot_parentage_stat(app)
        plot_parentage_trace(app)
        plot_qq_for_compare(app)
        plot_qq_for_virtual_result(app)
        plot_result_compares(app, do_clean_plot)
        plot_result_stat(app)

        %% Statistical Tests
        report = mwwtest_fitness_percentage(app, v_result_1, v_result_2, avg_fitness_percentage)
        report = mwwtest_result_coverage(app, result1, result2, coverage_percentage)
        report = mwwtest_result_fitness(app, v_result_1, v_result_2, gen)
        report = ttest_all_archived(app, result1, result2, gen)
        report = ttest_result_stats(app, result1, result2, gen)
        run_anova(app)
        run_mwwtest(app)
        run_mwwtest_all(app)
        run_mwwtest_coverage_all(app)
        run_mwwtest_percent_all(app)
        run_ttest(app)
        run_ttest_all(app)
        run_vartest(app)

        %% Simulation & Video
        calibrate_for_video(app)
        simulate_for_video(app)
        simulate_from_archive_map(app)
        sim_report = simulate_robot(app, sim_configs)
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, evogen_python_path, evogen_exe_path, evogen_results_path)
            app.evogen_python_path = evogen_python_path;
            app.evogen_exe_path = evogen_exe_path;
            app.evogen_results_path = evogen_results_path;
            result_analyzer_init(app);
        end

        % Button pushed function: PrevResultButton
        function PrevResultButtonPushed(app, event)
            select_result(app, 'prev');
        end

        % Button pushed function: SelectResultButton
        function SelectResultButtonPushed(app, event)
            select_result(app, 'user');
        end

        % Button pushed function: NextResultButton
        function NextResultButtonPushed(app, event)
            select_result(app, 'next');
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

        % Button pushed function: ExportArchiveMapButton
        function ExportArchiveMapButtonPushed(app, event)
            export_archive_map(app);
        end

        % Button pushed function: CompareFitnessButton
        function CompareFitnessButtonPushed(app, event)
            compare_different_version_fitness(app);
        end

        % Value changed function: SanitizeArchiveCheckBox
        function SanitizeArchiveCheckBoxValueChanged(app, event)
            plot_gen_all(app);
        end

        % Button pushed function: ComparePlotButton
        function ComparePlotButtonPushed(app, event)
            plot_result_compares(app, false);
        end

        % Button pushed function: ExportComparePlotDataButton
        function ExportComparePlotDataButtonPushed(app, event)
            export_compare_plot_data(app);
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

        % Button pushed function: ComputeBenchmarkButton
        function ComputeBenchmarkButtonPushed(app, event)
            compute_benchmark(app);
        end

        % Button pushed function: ExportforPlottingButton
        function ExportforPlottingButtonPushed(app, event)
            export_group(app);
        end

        % Button pushed function: ExportPickleButton
        function ExportPickleButtonPushed(app, event)
            export_pickle_for_group(app);
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

        % Button pushed function: RegenerateArchiveButton
        function RegenerateArchiveButtonPushed(app, event)
            regenerate_archive_map(app);
        end

        % Button pushed function: ExportRobotButton
        function ExportRobotButtonPushed(app, event)
            export_robot(app);
        end

        % Button pushed function: SimulateRobotButton
        function SimulateRobotButtonPushed(app, event)
            simulate_from_archive_map(app);
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

        % Button pushed function: ParentageStatButton
        function ParentageStatButtonPushed(app, event)
            plot_parentage_stat(app);
        end

        % Button pushed function: BuildSelectedResultStatButton
        function BuildSelectedResultStatButtonPushed(app, event)
            build_selected_stat(app);
        end

        % Button pushed function: PackSelectedResultsButton
        function PackSelectedResultsButtonPushed(app, event)
            pack_selected_results(app);
        end

        % Button pushed function: BuildPackExportAllButton
        function BuildPackExportAllButtonPushed(app, event)
            build_pack_export_all_results(app);
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

        % Button pushed function: PaperPlot1Button
        function PaperPlot1ButtonPushed(app, event)
            generate_paper_plot1(app);
        end

        % Button pushed function: PaperPlot2Button
        function PaperPlot2ButtonPushed(app, event)
            generate_paper_plot2(app);
        end

        % Button pushed function: PaperPlot3Button
        function PaperPlot3ButtonPushed(app, event)
            generate_paper_plot3(app);
        end

        % Button pushed function: SimulateforVideoButton
        function SimulateforVideoButtonPushed(app, event)
            simulate_for_video(app);
        end

        % Button pushed function: VideoGenFitnessButton
        function VideoGenFitnessButtonPushed(app, event)
            generate_video_fitness_plot(app);
        end

        % Button pushed function: CombinedArchiveMapButton
        function CombinedArchiveMapButtonPushed(app, event)
            generate_combined_archive_map(app);
        end

        % Button pushed function: ReevaluateFitnessButton
        function ReevaluateFitnessButtonPushed(app, event)
            reevaluate_fitness(app);
        end

        % Button pushed function: CalibrateForVideoButton
        function CalibrateForVideoButtonPushed(app, event)
            calibrate_for_video(app);
        end

        % Value changed function: Feature1DropDown
        function Feature1DropDownValueChanged(app, event)
            plot_gen_all(app);
        end

        % Value changed function: Feature2DropDown
        function Feature2DropDownValueChanged(app, event)
            plot_gen_all(app);
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

            % Create ComparisonPlotsTestsPanel
            app.ComparisonPlotsTestsPanel = uipanel(app.MainFigure);
            app.ComparisonPlotsTestsPanel.Title = 'Comparison Plots & Tests';
            app.ComparisonPlotsTestsPanel.FontWeight = 'bold';
            app.ComparisonPlotsTestsPanel.Position = [852 1 379 580];

            % Create GenerateAllComparePlotsButton
            app.GenerateAllComparePlotsButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.GenerateAllComparePlotsButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateAllComparePlotsButtonPushed, true);
            app.GenerateAllComparePlotsButton.WordWrap = 'on';
            app.GenerateAllComparePlotsButton.FontSize = 11;
            app.GenerateAllComparePlotsButton.Position = [185 10 65 45];
            app.GenerateAllComparePlotsButton.Text = 'Generate All Plots';

            % Create CompareListBox
            app.CompareListBox = uilistbox(app.ComparisonPlotsTestsPanel);
            app.CompareListBox.Items = {};
            app.CompareListBox.Multiselect = 'on';
            app.CompareListBox.Position = [1 1 176 524];
            app.CompareListBox.Value = {};

            % Create RemoveCompareButton
            app.RemoveCompareButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.RemoveCompareButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveCompareButtonPushed, true);
            app.RemoveCompareButton.Position = [185 446 60 22];
            app.RemoveCompareButton.Text = 'Remove';

            % Create RemoveAllCompareButton
            app.RemoveAllCompareButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.RemoveAllCompareButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveAllCompareButtonPushed, true);
            app.RemoveAllCompareButton.Position = [185 531 60 22];
            app.RemoveAllCompareButton.Text = 'Clear All';

            % Create MoveCompareUpButton
            app.MoveCompareUpButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.MoveCompareUpButton.ButtonPushedFcn = createCallbackFcn(app, @MoveCompareUpButtonPushed, true);
            app.MoveCompareUpButton.Position = [185 499 60 22];
            app.MoveCompareUpButton.Text = 'Up';

            % Create MoveCompareDownButton
            app.MoveCompareDownButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.MoveCompareDownButton.ButtonPushedFcn = createCallbackFcn(app, @MoveCompareDownButtonPushed, true);
            app.MoveCompareDownButton.Position = [185 474 60 22];
            app.MoveCompareDownButton.Text = 'Down';

            % Create ComparePlotButton
            app.ComparePlotButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.ComparePlotButton.ButtonPushedFcn = createCallbackFcn(app, @ComparePlotButtonPushed, true);
            app.ComparePlotButton.WordWrap = 'on';
            app.ComparePlotButton.Position = [185 397 63 36];
            app.ComparePlotButton.Text = 'Compare Plot';

            % Create CleanCompareButton
            app.CleanCompareButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.CleanCompareButton.ButtonPushedFcn = createCallbackFcn(app, @CleanCompareButtonPushed, true);
            app.CleanCompareButton.WordWrap = 'on';
            app.CleanCompareButton.Position = [185 303 63 43];
            app.CleanCompareButton.Text = 'Clean Compare';

            % Create PlotNameLabel
            app.PlotNameLabel = uilabel(app.ComparisonPlotsTestsPanel);
            app.PlotNameLabel.Position = [4 531 65 22];
            app.PlotNameLabel.Text = 'Plot Name:';

            % Create CompPlotNameField
            app.CompPlotNameField = uieditfield(app.ComparisonPlotsTestsPanel, 'text');
            app.CompPlotNameField.Position = [68 532 109 22];

            % Create TTestButton
            app.TTestButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.TTestButton.ButtonPushedFcn = createCallbackFcn(app, @TTestButtonPushed, true);
            app.TTestButton.WordWrap = 'on';
            app.TTestButton.Position = [188 219 57 22];
            app.TTestButton.Text = 'T-Test';

            % Create ANOVAButton
            app.ANOVAButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.ANOVAButton.ButtonPushedFcn = createCallbackFcn(app, @ANOVAButtonPushed, true);
            app.ANOVAButton.WordWrap = 'on';
            app.ANOVAButton.Position = [188 195 57 22];
            app.ANOVAButton.Text = 'ANOVA';

            % Create VarTestButton
            app.VarTestButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.VarTestButton.ButtonPushedFcn = createCallbackFcn(app, @VarTestButtonPushed, true);
            app.VarTestButton.WordWrap = 'on';
            app.VarTestButton.Position = [188 172 57 22];
            app.VarTestButton.Text = 'VarTest';

            % Create TTestAllButton
            app.TTestAllButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.TTestAllButton.ButtonPushedFcn = createCallbackFcn(app, @TTestAllButtonPushed, true);
            app.TTestAllButton.Position = [185 148 65 22];
            app.TTestAllButton.Text = 'T-Test All';

            % Create TTestOptionDropDownLabel
            app.TTestOptionDropDownLabel = uilabel(app.ComparisonPlotsTestsPanel);
            app.TTestOptionDropDownLabel.Position = [181 270 73 22];
            app.TTestOptionDropDownLabel.Text = 'T-Test Option';

            % Create TTestOptionDropDown
            app.TTestOptionDropDown = uidropdown(app.ComparisonPlotsTestsPanel);
            app.TTestOptionDropDown.Items = {};
            app.TTestOptionDropDown.Position = [181 243 92 22];
            app.TTestOptionDropDown.Value = {};

            % Create QQPlotForCompareButton
            app.QQPlotForCompareButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.QQPlotForCompareButton.ButtonPushedFcn = createCallbackFcn(app, @QQPlotForCompareButtonPushed, true);
            app.QQPlotForCompareButton.WordWrap = 'on';
            app.QQPlotForCompareButton.Position = [190 125 57 22];
            app.QQPlotForCompareButton.Text = 'QQ Plot';

            % Create MannWhitneyTestButton
            app.MannWhitneyTestButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.MannWhitneyTestButton.ButtonPushedFcn = createCallbackFcn(app, @MannWhitneyTestButtonPushed, true);
            app.MannWhitneyTestButton.WordWrap = 'on';
            app.MannWhitneyTestButton.Position = [187 83 57 22];
            app.MannWhitneyTestButton.Text = 'mwwtest';

            % Create ExportComparePlotDataButton
            app.ExportComparePlotDataButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.ExportComparePlotDataButton.ButtonPushedFcn = createCallbackFcn(app, @ExportComparePlotDataButtonPushed, true);
            app.ExportComparePlotDataButton.WordWrap = 'on';
            app.ExportComparePlotDataButton.Position = [186 359 63 36];
            app.ExportComparePlotDataButton.Text = 'Compare Plot Data';

            % Create PaperPlot1Button
            app.PaperPlot1Button = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.PaperPlot1Button.ButtonPushedFcn = createCallbackFcn(app, @PaperPlot1ButtonPushed, true);
            app.PaperPlot1Button.Tag = 'loadresult';
            app.PaperPlot1Button.Position = [279 424 86 22];
            app.PaperPlot1Button.Text = 'stat v. iteration';

            % Create PaperPlot2Button
            app.PaperPlot2Button = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.PaperPlot2Button.ButtonPushedFcn = createCallbackFcn(app, @PaperPlot2ButtonPushed, true);
            app.PaperPlot2Button.Tag = 'loadresult';
            app.PaperPlot2Button.Position = [279 397 83 22];
            app.PaperPlot2Button.Text = 'box plots';

            % Create PaperPlot3Button
            app.PaperPlot3Button = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.PaperPlot3Button.ButtonPushedFcn = createCallbackFcn(app, @PaperPlot3ButtonPushed, true);
            app.PaperPlot3Button.Tag = 'loadresult';
            app.PaperPlot3Button.WordWrap = 'on';
            app.PaperPlot3Button.Position = [279 351 84 41];
            app.PaperPlot3Button.Text = 'archive comparison';

            % Create SimulateforVideoButton
            app.SimulateforVideoButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.SimulateforVideoButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateforVideoButtonPushed, true);
            app.SimulateforVideoButton.Tag = 'loadresult';
            app.SimulateforVideoButton.WordWrap = 'on';
            app.SimulateforVideoButton.Position = [283 255 82 39];
            app.SimulateforVideoButton.Text = 'Simulate for Video';

            % Create GenEditFieldLabel
            app.GenEditFieldLabel = uilabel(app.ComparisonPlotsTestsPanel);
            app.GenEditFieldLabel.HorizontalAlignment = 'right';
            app.GenEditFieldLabel.FontWeight = 'bold';
            app.GenEditFieldLabel.Position = [283 303 33 22];
            app.GenEditFieldLabel.Text = 'Gen:';

            % Create VideoGenIDField
            app.VideoGenIDField = uieditfield(app.ComparisonPlotsTestsPanel, 'numeric');
            app.VideoGenIDField.Position = [321 303 44 22];

            % Create VideoGenFitnessButton
            app.VideoGenFitnessButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.VideoGenFitnessButton.ButtonPushedFcn = createCallbackFcn(app, @VideoGenFitnessButtonPushed, true);
            app.VideoGenFitnessButton.WordWrap = 'on';
            app.VideoGenFitnessButton.Position = [283 213 86 35];
            app.VideoGenFitnessButton.Text = 'Video Gen Fitness';

            % Create CombinedArchiveMapButton
            app.CombinedArchiveMapButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.CombinedArchiveMapButton.ButtonPushedFcn = createCallbackFcn(app, @CombinedArchiveMapButtonPushed, true);
            app.CombinedArchiveMapButton.WordWrap = 'on';
            app.CombinedArchiveMapButton.Position = [283 174 86 36];
            app.CombinedArchiveMapButton.Text = 'Combined Archive Map';

            % Create ReevaluateFitnessButton
            app.ReevaluateFitnessButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.ReevaluateFitnessButton.ButtonPushedFcn = createCallbackFcn(app, @ReevaluateFitnessButtonPushed, true);
            app.ReevaluateFitnessButton.Tag = 'loadresult';
            app.ReevaluateFitnessButton.WordWrap = 'on';
            app.ReevaluateFitnessButton.Position = [283 125 82 39];
            app.ReevaluateFitnessButton.Text = 'Re-evaluate Fitness';

            % Create WithVisualizationCheckBox
            app.WithVisualizationCheckBox = uicheckbox(app.ComparisonPlotsTestsPanel);
            app.WithVisualizationCheckBox.Text = 'w/ Visualization';
            app.WithVisualizationCheckBox.Position = [273 104 105 22];

            % Create ReEvalTypeDropDownLabel
            app.ReEvalTypeDropDownLabel = uilabel(app.ComparisonPlotsTestsPanel);
            app.ReEvalTypeDropDownLabel.FontWeight = 'bold';
            app.ReEvalTypeDropDownLabel.Position = [273 80 87 22];
            app.ReEvalTypeDropDownLabel.Text = 'Re - Eval Type';

            % Create ReEvalTypeDropDown
            app.ReEvalTypeDropDown = uidropdown(app.ComparisonPlotsTestsPanel);
            app.ReEvalTypeDropDown.Items = {};
            app.ReEvalTypeDropDown.Position = [272 58 101 22];
            app.ReEvalTypeDropDown.Value = {};

            % Create CalibrateForVideoButton
            app.CalibrateForVideoButton = uibutton(app.ComparisonPlotsTestsPanel, 'push');
            app.CalibrateForVideoButton.ButtonPushedFcn = createCallbackFcn(app, @CalibrateForVideoButtonPushed, true);
            app.CalibrateForVideoButton.Tag = 'loadresult';
            app.CalibrateForVideoButton.WordWrap = 'on';
            app.CalibrateForVideoButton.Position = [283 10 82 39];
            app.CalibrateForVideoButton.Text = 'Calibrate For Video';

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
            app.AddVirtualToCompareButton.FontSize = 14;
            app.AddVirtualToCompareButton.FontWeight = 'bold';
            app.AddVirtualToCompareButton.Position = [182 407 65 40];
            app.AddVirtualToCompareButton.Text = 'Add to Plot';

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

            % Create ComputeBenchmarkButton
            app.ComputeBenchmarkButton = uibutton(app.VirtualResultsPanel, 'push');
            app.ComputeBenchmarkButton.ButtonPushedFcn = createCallbackFcn(app, @ComputeBenchmarkButtonPushed, true);
            app.ComputeBenchmarkButton.Tag = 'loadresult';
            app.ComputeBenchmarkButton.WordWrap = 'on';
            app.ComputeBenchmarkButton.Position = [179 454 74 51];
            app.ComputeBenchmarkButton.Text = 'Compute Benchmark';

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

            % Create BuildPackExportAllButton
            app.BuildPackExportAllButton = uibutton(app.SingleResultsPanel, 'push');
            app.BuildPackExportAllButton.ButtonPushedFcn = createCallbackFcn(app, @BuildPackExportAllButtonPushed, true);
            app.BuildPackExportAllButton.Tag = 'loadresult';
            app.BuildPackExportAllButton.WordWrap = 'on';
            app.BuildPackExportAllButton.Position = [280 259 62 50];
            app.BuildPackExportAllButton.Text = 'Build Pack Export All';

            % Create BuildSelectedResultStatButton
            app.BuildSelectedResultStatButton = uibutton(app.SingleResultsPanel, 'push');
            app.BuildSelectedResultStatButton.ButtonPushedFcn = createCallbackFcn(app, @BuildSelectedResultStatButtonPushed, true);
            app.BuildSelectedResultStatButton.Tag = 'loadresult';
            app.BuildSelectedResultStatButton.Position = [280 445 62 22];
            app.BuildSelectedResultStatButton.Text = 'Build';

            % Create PatchResultStatButton
            app.PatchResultStatButton = uibutton(app.SingleResultsPanel, 'push');
            app.PatchResultStatButton.ButtonPushedFcn = createCallbackFcn(app, @PatchResultStatButtonPushed, true);
            app.PatchResultStatButton.Tag = 'loadresult';
            app.PatchResultStatButton.Position = [280 234 62 22];
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
            app.AddResultToCompareButton.FontSize = 14;
            app.AddResultToCompareButton.FontWeight = 'bold';
            app.AddResultToCompareButton.Position = [280 170 61 45];
            app.AddResultToCompareButton.Text = 'Add to Plot';

            % Create ResultNameLabel
            app.ResultNameLabel = uilabel(app.SingleResultsPanel);
            app.ResultNameLabel.HorizontalAlignment = 'center';
            app.ResultNameLabel.FontSize = 16;
            app.ResultNameLabel.FontWeight = 'bold';
            app.ResultNameLabel.Position = [384 499 196 30];
            app.ResultNameLabel.Text = 'Load a result to view';

            % Create ResultInfoLabel
            app.ResultInfoLabel = uilabel(app.SingleResultsPanel);
            app.ResultInfoLabel.FontSize = 13;
            app.ResultInfoLabel.FontWeight = 'bold';
            app.ResultInfoLabel.Position = [348 488 77 22];
            app.ResultInfoLabel.Text = 'Result Info:';

            % Create ResultInfoTextLabel
            app.ResultInfoTextLabel = uilabel(app.SingleResultsPanel);
            app.ResultInfoTextLabel.VerticalAlignment = 'top';
            app.ResultInfoTextLabel.Position = [350 359 137 129];
            app.ResultInfoTextLabel.Text = '';

            % Create StatStartGenField
            app.StatStartGenField = uieditfield(app.SingleResultsPanel, 'text');
            app.StatStartGenField.HorizontalAlignment = 'center';
            app.StatStartGenField.Position = [545 394 41 22];

            % Create FromLabel
            app.FromLabel = uilabel(app.SingleResultsPanel);
            app.FromLabel.FontSize = 13;
            app.FromLabel.FontWeight = 'bold';
            app.FromLabel.Position = [505 394 41 22];
            app.FromLabel.Text = 'From:';

            % Create StatEndGenField
            app.StatEndGenField = uieditfield(app.SingleResultsPanel, 'text');
            app.StatEndGenField.HorizontalAlignment = 'center';
            app.StatEndGenField.Position = [544 370 42 22];

            % Create ToLabel
            app.ToLabel = uilabel(app.SingleResultsPanel);
            app.ToLabel.FontSize = 13;
            app.ToLabel.FontWeight = 'bold';
            app.ToLabel.Position = [523 370 25 22];
            app.ToLabel.Text = 'To:';

            % Create StatPlotButton
            app.StatPlotButton = uibutton(app.SingleResultsPanel, 'push');
            app.StatPlotButton.ButtonPushedFcn = createCallbackFcn(app, @StatPlotButtonPushed, true);
            app.StatPlotButton.Position = [403 236 64 22];
            app.StatPlotButton.Text = 'Statistics';

            % Create BinUpdatesButton
            app.BinUpdatesButton = uibutton(app.SingleResultsPanel, 'push');
            app.BinUpdatesButton.ButtonPushedFcn = createCallbackFcn(app, @BinUpdatesButtonPushed, true);
            app.BinUpdatesButton.Tag = 'loadresult';
            app.BinUpdatesButton.Position = [398 190 76 22];
            app.BinUpdatesButton.Text = 'Bin Updates';

            % Create AvgAgeofMapButton
            app.AvgAgeofMapButton = uibutton(app.SingleResultsPanel, 'push');
            app.AvgAgeofMapButton.ButtonPushedFcn = createCallbackFcn(app, @AvgAgeofMapButtonPushed, true);
            app.AvgAgeofMapButton.Tag = 'loadresult';
            app.AvgAgeofMapButton.Position = [388 213 100 22];
            app.AvgAgeofMapButton.Text = 'Avg Age of Map';

            % Create ParentageStatButton
            app.ParentageStatButton = uibutton(app.SingleResultsPanel, 'push');
            app.ParentageStatButton.ButtonPushedFcn = createCallbackFcn(app, @ParentageStatButtonPushed, true);
            app.ParentageStatButton.Tag = 'loadresult';
            app.ParentageStatButton.Position = [493 236 89 22];
            app.ParentageStatButton.Text = 'Parentage Stat';

            % Create ParentagePlotsButton
            app.ParentagePlotsButton = uibutton(app.SingleResultsPanel, 'push');
            app.ParentagePlotsButton.ButtonPushedFcn = createCallbackFcn(app, @ParentagePlotsButtonPushed, true);
            app.ParentagePlotsButton.Tag = 'loadresult';
            app.ParentagePlotsButton.WordWrap = 'on';
            app.ParentagePlotsButton.Position = [491 202 95 32];
            app.ParentagePlotsButton.Text = 'Parentage Plots';

            % Create LongevityofGenButton
            app.LongevityofGenButton = uibutton(app.SingleResultsPanel, 'push');
            app.LongevityofGenButton.ButtonPushedFcn = createCallbackFcn(app, @LongevityofGenButtonPushed, true);
            app.LongevityofGenButton.Tag = 'loadresult';
            app.LongevityofGenButton.WordWrap = 'on';
            app.LongevityofGenButton.Position = [396 151 82 36];
            app.LongevityofGenButton.Text = 'Longevity of Gen';

            % Create SimulateRobotButton
            app.SimulateRobotButton = uibutton(app.SingleResultsPanel, 'push');
            app.SimulateRobotButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateRobotButtonPushed, true);
            app.SimulateRobotButton.Tag = 'loadresult';
            app.SimulateRobotButton.FontSize = 14;
            app.SimulateRobotButton.Position = [405 2 70 35];
            app.SimulateRobotButton.Text = 'Simulate';

            % Create RobotIDXField
            app.RobotIDXField = uieditfield(app.SingleResultsPanel, 'text');
            app.RobotIDXField.HorizontalAlignment = 'center';
            app.RobotIDXField.Position = [534 7 39 22];

            % Create RobotIDYField
            app.RobotIDYField = uieditfield(app.SingleResultsPanel, 'text');
            app.RobotIDYField.HorizontalAlignment = 'center';
            app.RobotIDYField.Position = [492 7 39 22];

            % Create ParentageTreeButton
            app.ParentageTreeButton = uibutton(app.SingleResultsPanel, 'push');
            app.ParentageTreeButton.ButtonPushedFcn = createCallbackFcn(app, @ParentageTreeButtonPushed, true);
            app.ParentageTreeButton.Tag = 'loadresult';
            app.ParentageTreeButton.WordWrap = 'on';
            app.ParentageTreeButton.Position = [399 115 78 34];
            app.ParentageTreeButton.Text = 'Parentage Tree';

            % Create OpenFolderButton
            app.OpenFolderButton = uibutton(app.SingleResultsPanel, 'push');
            app.OpenFolderButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFolderButtonPushed, true);
            app.OpenFolderButton.Tag = 'loadresult';
            app.OpenFolderButton.Position = [288 59 82 22];
            app.OpenFolderButton.Text = 'Open Folder';

            % Create NickNameSaveButton
            app.NickNameSaveButton = uibutton(app.SingleResultsPanel, 'push');
            app.NickNameSaveButton.ButtonPushedFcn = createCallbackFcn(app, @NickNameSaveButtonPushed, true);
            app.NickNameSaveButton.Tag = 'loadresult';
            app.NickNameSaveButton.Position = [285 86 90 22];
            app.NickNameSaveButton.Text = 'Set Nickname';

            % Create NicknameLabel
            app.NicknameLabel = uilabel(app.SingleResultsPanel);
            app.NicknameLabel.HorizontalAlignment = 'right';
            app.NicknameLabel.Position = [282 136 62 22];
            app.NicknameLabel.Text = 'Nickname:';

            % Create NickNameField
            app.NickNameField = uieditfield(app.SingleResultsPanel, 'text');
            app.NickNameField.Position = [287 115 86 22];

            % Create GenerateAllSingleResultPlotsButton
            app.GenerateAllSingleResultPlotsButton = uibutton(app.SingleResultsPanel, 'push');
            app.GenerateAllSingleResultPlotsButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateAllSingleResultPlotsButtonPushed, true);
            app.GenerateAllSingleResultPlotsButton.WordWrap = 'on';
            app.GenerateAllSingleResultPlotsButton.FontSize = 11;
            app.GenerateAllSingleResultPlotsButton.Position = [288 10 65 45];
            app.GenerateAllSingleResultPlotsButton.Text = 'Generate All Plots';

            % Create SelectResultButton
            app.SelectResultButton = uibutton(app.SingleResultsPanel, 'push');
            app.SelectResultButton.ButtonPushedFcn = createCallbackFcn(app, @SelectResultButtonPushed, true);
            app.SelectResultButton.Tag = 'loadresult';
            app.SelectResultButton.Position = [450 525 56 29];
            app.SelectResultButton.Text = 'Select';

            % Create SimTimeEditFieldLabel
            app.SimTimeEditFieldLabel = uilabel(app.SingleResultsPanel);
            app.SimTimeEditFieldLabel.HorizontalAlignment = 'right';
            app.SimTimeEditFieldLabel.Position = [484 36 55 22];
            app.SimTimeEditFieldLabel.Text = 'Sim Time:';

            % Create SimTimeEditField
            app.SimTimeEditField = uieditfield(app.SingleResultsPanel, 'numeric');
            app.SimTimeEditField.Position = [542 36 40 22];

            % Create ExportforPlottingButton
            app.ExportforPlottingButton = uibutton(app.SingleResultsPanel, 'push');
            app.ExportforPlottingButton.ButtonPushedFcn = createCallbackFcn(app, @ExportforPlottingButtonPushed, true);
            app.ExportforPlottingButton.WordWrap = 'on';
            app.ExportforPlottingButton.FontSize = 11;
            app.ExportforPlottingButton.Position = [280 384 62 33];
            app.ExportforPlottingButton.Text = 'Export for Plotting';

            % Create ExportRobotButton
            app.ExportRobotButton = uibutton(app.SingleResultsPanel, 'push');
            app.ExportRobotButton.ButtonPushedFcn = createCallbackFcn(app, @ExportRobotButtonPushed, true);
            app.ExportRobotButton.WordWrap = 'on';
            app.ExportRobotButton.FontSize = 11;
            app.ExportRobotButton.Position = [404 38 65 33];
            app.ExportRobotButton.Text = 'Export Robot';

            % Create SanitizeArchiveCheckBox
            app.SanitizeArchiveCheckBox = uicheckbox(app.SingleResultsPanel);
            app.SanitizeArchiveCheckBox.ValueChangedFcn = createCallbackFcn(app, @SanitizeArchiveCheckBoxValueChanged, true);
            app.SanitizeArchiveCheckBox.Text = 'Sanitize Archive';
            app.SanitizeArchiveCheckBox.Position = [487 182 107 22];

            % Create ExportArchiveMapButton
            app.ExportArchiveMapButton = uibutton(app.SingleResultsPanel, 'push');
            app.ExportArchiveMapButton.ButtonPushedFcn = createCallbackFcn(app, @ExportArchiveMapButtonPushed, true);
            app.ExportArchiveMapButton.Tag = 'loadresult';
            app.ExportArchiveMapButton.WordWrap = 'on';
            app.ExportArchiveMapButton.Position = [494 147 82 36];
            app.ExportArchiveMapButton.Text = 'Export Archive Map';

            % Create PackSelectedResultsButton
            app.PackSelectedResultsButton = uibutton(app.SingleResultsPanel, 'push');
            app.PackSelectedResultsButton.ButtonPushedFcn = createCallbackFcn(app, @PackSelectedResultsButtonPushed, true);
            app.PackSelectedResultsButton.Tag = 'loadresult';
            app.PackSelectedResultsButton.WordWrap = 'on';
            app.PackSelectedResultsButton.Position = [280 420 62 22];
            app.PackSelectedResultsButton.Text = 'Pack';

            % Create DumpRobotsCheckBox
            app.DumpRobotsCheckBox = uicheckbox(app.SingleResultsPanel);
            app.DumpRobotsCheckBox.Text = 'Dump Robots';
            app.DumpRobotsCheckBox.WordWrap = 'on';
            app.DumpRobotsCheckBox.Position = [282 466 67 30];

            % Create ExportPickleButton
            app.ExportPickleButton = uibutton(app.SingleResultsPanel, 'push');
            app.ExportPickleButton.ButtonPushedFcn = createCallbackFcn(app, @ExportPickleButtonPushed, true);
            app.ExportPickleButton.WordWrap = 'on';
            app.ExportPickleButton.FontSize = 11;
            app.ExportPickleButton.Position = [280 311 62 33];
            app.ExportPickleButton.Text = 'Export Pickle';

            % Create ExportforPublishingButton
            app.ExportforPublishingButton = uibutton(app.SingleResultsPanel, 'push');
            app.ExportforPublishingButton.WordWrap = 'on';
            app.ExportforPublishingButton.FontSize = 11;
            app.ExportforPublishingButton.Position = [280 348 62 33];
            app.ExportforPublishingButton.Text = 'Export for Publishing';

            % Create PrevResultButton
            app.PrevResultButton = uibutton(app.SingleResultsPanel, 'push');
            app.PrevResultButton.ButtonPushedFcn = createCallbackFcn(app, @PrevResultButtonPushed, true);
            app.PrevResultButton.Tag = 'loadresult';
            app.PrevResultButton.Position = [388 525 56 29];
            app.PrevResultButton.Text = 'Up';

            % Create NextResultButton
            app.NextResultButton = uibutton(app.SingleResultsPanel, 'push');
            app.NextResultButton.ButtonPushedFcn = createCallbackFcn(app, @NextResultButtonPushed, true);
            app.NextResultButton.Tag = 'loadresult';
            app.NextResultButton.Position = [512 525 56 29];
            app.NextResultButton.Text = 'Dn';

            % Create CompareFitnessButton
            app.CompareFitnessButton = uibutton(app.SingleResultsPanel, 'push');
            app.CompareFitnessButton.ButtonPushedFcn = createCallbackFcn(app, @CompareFitnessButtonPushed, true);
            app.CompareFitnessButton.Tag = 'loadresult';
            app.CompareFitnessButton.WordWrap = 'on';
            app.CompareFitnessButton.Position = [503 111 63 35];
            app.CompareFitnessButton.Text = 'Compare Fitness';

            % Create EnableResultEditCheckBox
            app.EnableResultEditCheckBox = uicheckbox(app.SingleResultsPanel);
            app.EnableResultEditCheckBox.Text = 'Enable Result  Edit';
            app.EnableResultEditCheckBox.WordWrap = 'on';
            app.EnableResultEditCheckBox.FontSize = 10;
            app.EnableResultEditCheckBox.Position = [547 70 52 33];

            % Create RegenerateArchiveButton
            app.RegenerateArchiveButton = uibutton(app.SingleResultsPanel, 'push');
            app.RegenerateArchiveButton.ButtonPushedFcn = createCallbackFcn(app, @RegenerateArchiveButtonPushed, true);
            app.RegenerateArchiveButton.Tag = 'loadresult';
            app.RegenerateArchiveButton.WordWrap = 'on';
            app.RegenerateArchiveButton.Position = [401 75 78 36];
            app.RegenerateArchiveButton.Text = 'Regenerate Archive';

            % Create UpdateFitAfterSim
            app.UpdateFitAfterSim = uicheckbox(app.SingleResultsPanel);
            app.UpdateFitAfterSim.Text = 'Update Fitness After Simulation';
            app.UpdateFitAfterSim.WordWrap = 'on';
            app.UpdateFitAfterSim.FontSize = 10;
            app.UpdateFitAfterSim.Position = [490 61 66 47];

            % Create LoadNextButton
            app.LoadNextButton = uibutton(app.SingleResultsPanel, 'push');
            app.LoadNextButton.ButtonPushedFcn = createCallbackFcn(app, @LoadNextButtonPushed, true);
            app.LoadNextButton.Position = [544 444 25 22];
            app.LoadNextButton.Text = '>';

            % Create LoadPrevButton
            app.LoadPrevButton = uibutton(app.SingleResultsPanel, 'push');
            app.LoadPrevButton.ButtonPushedFcn = createCallbackFcn(app, @LoadPrevButtonPushed, true);
            app.LoadPrevButton.Position = [519 444 25 22];
            app.LoadPrevButton.Text = '<';

            % Create LoadNextStepButton
            app.LoadNextStepButton = uibutton(app.SingleResultsPanel, 'push');
            app.LoadNextStepButton.ButtonPushedFcn = createCallbackFcn(app, @LoadNextStepButtonPushed, true);
            app.LoadNextStepButton.Position = [566 423 30 22];
            app.LoadNextStepButton.Text = '+';

            % Create LoadPrevStepButton
            app.LoadPrevStepButton = uibutton(app.SingleResultsPanel, 'push');
            app.LoadPrevStepButton.ButtonPushedFcn = createCallbackFcn(app, @LoadPrevStepButtonPushed, true);
            app.LoadPrevStepButton.Position = [495 423 30 22];
            app.LoadPrevStepButton.Text = '-';

            % Create LoadLastButton
            app.LoadLastButton = uibutton(app.SingleResultsPanel, 'push');
            app.LoadLastButton.ButtonPushedFcn = createCallbackFcn(app, @LoadLastButtonPushed, true);
            app.LoadLastButton.Position = [569 444 25 22];
            app.LoadLastButton.Text = '>>';

            % Create LoadFirstButton
            app.LoadFirstButton = uibutton(app.SingleResultsPanel, 'push');
            app.LoadFirstButton.ButtonPushedFcn = createCallbackFcn(app, @LoadFirstButtonPushed, true);
            app.LoadFirstButton.Position = [494 444 25 22];
            app.LoadFirstButton.Text = '<<';

            % Create GenStepField
            app.GenStepField = uieditfield(app.SingleResultsPanel, 'text');
            app.GenStepField.ValueChangedFcn = createCallbackFcn(app, @GenStepFieldValueChanged, true);
            app.GenStepField.HorizontalAlignment = 'center';
            app.GenStepField.Position = [526 423 39 22];

            % Create GenIDField
            app.GenIDField = uieditfield(app.SingleResultsPanel, 'text');
            app.GenIDField.ValueChangedFcn = createCallbackFcn(app, @GenIDFieldValueChanged, true);
            app.GenIDField.HorizontalAlignment = 'center';
            app.GenIDField.Position = [528 468 58 22];

            % Create GenLabel
            app.GenLabel = uilabel(app.SingleResultsPanel);
            app.GenLabel.FontSize = 13;
            app.GenLabel.FontWeight = 'bold';
            app.GenLabel.Position = [495 468 35 22];
            app.GenLabel.Text = 'Gen:';

            % Create Feature1DropDownLabel
            app.Feature1DropDownLabel = uilabel(app.SingleResultsPanel);
            app.Feature1DropDownLabel.HorizontalAlignment = 'right';
            app.Feature1DropDownLabel.Position = [350 337 54 22];
            app.Feature1DropDownLabel.Text = 'Feature 1';

            % Create Feature1DropDown
            app.Feature1DropDown = uidropdown(app.SingleResultsPanel);
            app.Feature1DropDown.Items = {};
            app.Feature1DropDown.ValueChangedFcn = createCallbackFcn(app, @Feature1DropDownValueChanged, true);
            app.Feature1DropDown.Position = [355 317 158 22];
            app.Feature1DropDown.Value = {};

            % Create Feature2DropDownLabel
            app.Feature2DropDownLabel = uilabel(app.SingleResultsPanel);
            app.Feature2DropDownLabel.HorizontalAlignment = 'right';
            app.Feature2DropDownLabel.Position = [347 296 57 22];
            app.Feature2DropDownLabel.Text = 'Feature 2';

            % Create Feature2DropDown
            app.Feature2DropDown = uidropdown(app.SingleResultsPanel);
            app.Feature2DropDown.Items = {};
            app.Feature2DropDown.ValueChangedFcn = createCallbackFcn(app, @Feature2DropDownValueChanged, true);
            app.Feature2DropDown.Position = [355 276 158 22];
            app.Feature2DropDown.Value = {};

            % Create PlotGenButton
            app.PlotGenButton = uibutton(app.SingleResultsPanel, 'push');
            app.PlotGenButton.ButtonPushedFcn = createCallbackFcn(app, @PlotGenButtonPushed, true);
            app.PlotGenButton.WordWrap = 'on';
            app.PlotGenButton.Position = [529 289 51 54];
            app.PlotGenButton.Text = 'Plot Gen';

            % Create DebugPanel
            app.DebugPanel = uipanel(app.MainFigure);
            app.DebugPanel.Title = 'Debug';
            app.DebugPanel.FontWeight = 'bold';
            app.DebugPanel.Position = [1131 467 100 114];

            % Create RehashButton
            app.RehashButton = uibutton(app.DebugPanel, 'push');
            app.RehashButton.ButtonPushedFcn = createCallbackFcn(app, @RehashButtonPushed, true);
            app.RehashButton.Tag = 'loadresult';
            app.RehashButton.Position = [21 56 57 22];
            app.RehashButton.Text = 'Rehash';

            % Create CLCButton
            app.CLCButton = uibutton(app.DebugPanel, 'push');
            app.CLCButton.ButtonPushedFcn = createCallbackFcn(app, @CLCButtonPushed, true);
            app.CLCButton.Tag = 'loadresult';
            app.CLCButton.Position = [21 30 57 22];
            app.CLCButton.Text = 'CLC';

            % Show the figure after all components are created
            app.MainFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = result_analyzer(varargin)

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
