function delete_from_compare_list(app)
    if isempty(app.CompareListBox.Value)
        return;
    end
    app.results_to_compare(app.CompareListBox.Value) = [];
    app.CompareListBox.Items(app.CompareListBox.Value) = [];
end
