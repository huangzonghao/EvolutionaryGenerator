% Pop variables to the base workspace for debugging
function user_analysis_pop_var(app)
    assignin('base', 'user_analysis_app', app);
    assignin('base', 'app', app);
    disp('Var poped to base workspace');
end
