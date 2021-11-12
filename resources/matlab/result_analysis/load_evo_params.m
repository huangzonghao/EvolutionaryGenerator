function evo_params = load_evo_params(result_path)
    evo_xml = xml2struct(fullfile(result_path, 'evo_params.xml'));
    evo_params.nb_gen_planned = str2double(evo_xml.boost_serialization{2}.EvoParams.nb_gen_.Text);
    evo_params.init_size = str2double(evo_xml.boost_serialization{2}.EvoParams.init_size_.Text);
    evo_params.gen_size = str2double(evo_xml.boost_serialization{2}.EvoParams.pop_size_.Text);
    evo_params.griddim_0 = str2double(evo_xml.boost_serialization{2}.EvoParams.grid_shape_.item{1}.Text);
    evo_params.griddim_1 = str2double(evo_xml.boost_serialization{2}.EvoParams.grid_shape_.item{2}.Text);
    evo_params.feature_description1 = evo_xml.boost_serialization{2}.EvoParams.feature_description_.item{1}.Text;
    evo_params.feature_description2 = evo_xml.boost_serialization{2}.EvoParams.feature_description_.item{2}.Text;

    statusfile_id = fopen(fullfile(result_path, 'status.txt'));
    status_info = cell2mat(textscan(statusfile_id, '%d/%d%*[^\n]'));
    fclose(statusfile_id);
    evo_params.nb_gen = status_info(1);
end
