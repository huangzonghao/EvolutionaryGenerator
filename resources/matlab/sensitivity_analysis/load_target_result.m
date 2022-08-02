function result = load_target_result(app, is_virtual, id)
    if is_virtual
        result = app.virtual_results{id};
    else
        if ~app.results{id}.loaded
            load_result(app, id);
        end
        result = app.results{id};
    end
end
