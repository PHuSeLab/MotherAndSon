classdef MotherSon < handle
   
    properties
        % paths
        CKimgPath
        CKlandmarksPath
        dataPath
        imagesPath
        landmarksPath
        % processes
        processMother
        modelGeneration
        dims
        % mother
        motherModality
        imgPathMother
        landmarksPathMother
        landmarkModeMother
        motherSession
        motherCount
        motherData
        % son
        sonModality
        BW
        landmarkSon
        landmarkModeSon
        sessionSon
        landmarkSonPath
        imgSonPath
        imgSonName
        imgSon
    end
    
    methods
        prepareData(obj)
        printDescription(obj)
        fiducialSon = processData(obj)
        genLatentSpaceMotherSon(obj)
        displayLatentSpaceMotherSon(obj, fiducialSon)
    end
end
