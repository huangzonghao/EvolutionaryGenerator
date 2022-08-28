function grid_dimension_update(app)
    new_dim = app.NumDimEditField.Value;
    curr_array = str2num(app.GridDimensionEditField.Value);
    curr_dim = length(curr_array);
    if new_dim == curr_dim
        return
    end
    if new_dim < curr_dim
        new_array = curr_array(1:new_dim);
    else
        new_array = curr_array;
        for i = 1 : new_dim - curr_dim
            new_array(end + 1) = curr_array(end);
        end
    end
    grid_dim_string = num2str(new_array, '%d,');
    app.GridDimensionEditField.Value = grid_dim_string(1:end-1);
end
