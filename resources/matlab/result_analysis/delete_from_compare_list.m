function delete_from_compare_list(app)
    if isempty(app.CompareListBox.Value)
        return;
    end
    app.result_to_compare(app.CompareListBox.Value) = [];
    app.CompareListBox.Items(app.CompareListBox.Value) = [];
end