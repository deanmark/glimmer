function [ Result ] = RadexSolver( dvdrKmParsec, Density, Temperature, CollisionPartnerToMoleculeDensityRatio, Molecule, CollisionPartners, CollisionPartnerWeights, BackgroundTemperature)

CollisionPartnerDensities = Density*CollisionPartnerToMoleculeDensityRatio*CollisionPartnerWeights/(sum(CollisionPartnerWeights));
buildRadexInputFile('radex.inp', Molecule.MoleculeFileName, 'radex.out', 0, 0, Temperature, CollisionPartners, CollisionPartnerDensities, BackgroundTemperature, Density, dvdrKmParsec);

!radexLVG.exe < radex.inp

Result = RadexResult.ReadFromFile('radex.out');

end

function buildRadexInputFile (FileName, InputFile, OutputFile, LowerFreq, UpperFreq, KineticTemp, CollisionParters, CollisionPartnerDensities, BackgroundTemperature, ColumnDensity, LineWidth)

fid = fopen(FileName,'wt');

try
    
    fprintf(fid,'%s\n',InputFile);
    fprintf(fid,'%s\n',OutputFile);
    fprintf(fid,'%g %g\n',LowerFreq,UpperFreq);
    fprintf(fid,'%g\n',KineticTemp);
    fprintf(fid,'%u\n',numel(CollisionParters));
    
    for i=1:numel(CollisionParters)
        fprintf(fid,'%s\n',CollisionPartnersCodes.ToStringRadexFormat(CollisionParters(i).CollisionPartnerCode));
        fprintf(fid,'%e\n',CollisionPartnerDensities(i));
    end
    
    fprintf(fid,'%g\n',BackgroundTemperature);
    fprintf(fid,'%e\n',ColumnDensity);
    fprintf(fid,'%e\n',LineWidth);
    fprintf(fid,'0\n');
    
catch
    fclose(fid);
    rethrow(lasterror);
end

fclose(fid);

end