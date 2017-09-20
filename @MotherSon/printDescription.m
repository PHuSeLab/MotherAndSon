function printDescription(ms)
  disp('Starting experiment');
  disp('-----------------------');
  fprintf('Mother\nLandmark mode:\tCK\n');
  fprintf('Source:');
  for i = 1:ms.motherCount
    fprintf('\t%s\n', ms.motherSession{i});
  end
  fprintf('Son\nLandmark mode:\t%s\n', ms.landmarkModeSon);
  
  switch(ms.sonModality)
    case 0
        fprintf('Source:\t%s\n', ms.sessionSon);
    case 1
        fprintf('Source:\tWebcam\n');
    case 2
        fprintf('Source:\t%s\n', ms.imgSonName);
  end
  
  if (ms.BW)
      disp('Modality: BW');
  else
      disp('Modality: Color');
  end
  
  disp('-----------------------');