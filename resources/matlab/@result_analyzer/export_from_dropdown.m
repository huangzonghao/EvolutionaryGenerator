function export_from_dropdown(app)
    switch app.ResultExportOptionDropDown.Value
    case 1 % Clean Build Pack
        build_pack_export_all_results(app);
    case 2 % Plotting Only
        export_group(app);
    case 3 % Publishing
        msgbox('Not implemented yet');
    case 4 % Pickle
        export_pickle_for_group(app);
    end
end
