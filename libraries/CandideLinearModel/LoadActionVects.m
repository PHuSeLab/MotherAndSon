function action = LoadActionVects()
    action={};
    auv_files = dir('libraries/CandideLinearModel/Candide/Data/AUV*');    
    for i=1:length(auv_files)
        action{i} = load([auv_files(i).folder '/' auv_files(i).name]);
    end
%     curr_i = i+1;
%     fap_files = dir('libraries/CandideLinearModel/Candide/Data/FAP*');    
%     for i=1:length(fap_files)
%         action{curr_i} = load([fap_files(i).folder '/' fap_files(i).name]);
%         curr_i = curr_i + 1;
%     end    
end