classdef RadexSolver
    
    methods(Static=true)
        
        function [ Result , RuntimeMessage ] = SolveLevelsPopulation( DvDr, Density, Temperature, MoleculeToCollisionPartnerDensityRatio, Molecule, CollisionPartners, CollisionPartnerWeights, BackgroundTemperature)
            
            CollisionPartnerDensities = Density*(MoleculeToCollisionPartnerDensityRatio^-1)*CollisionPartnerWeights/(sum(CollisionPartnerWeights));
            DensityToDvdrRatio = Density / DvDr;
            
            if (1e5 <= DensityToDvdrRatio) && (DensityToDvdrRatio <= 1e25)
                InputDensity = DensityToDvdrRatio;
                InputDvDr = 1;
            elseif (DensityToDvdrRatio > 1e25) && (DensityToDvdrRatio * 1e-3 <= 1e25)
                InputDensity = DensityToDvdrRatio * 1e-3;
                InputDvDr = 1e-3;
            elseif (DensityToDvdrRatio < 1e5) && (DensityToDvdrRatio * 1e3 >= 1e5)
                InputDensity = DensityToDvdrRatio * 1e3;
                InputDvDr = 1e3;
            else
                ME = MException('VerifyInput:DensityToDvdrRatioOutOfRange','Error in input. Density To Dvdr Ratio should be between 1e2 and 1e28. Input: [%g]', DensityToDvdrRatio);
                throw(ME);
            end
            
            RadexSolver.buildRadexInputFile('radex.inp', Molecule.MoleculeFileName, 'radex.out', 0, 0, Temperature, CollisionPartners, CollisionPartnerDensities, BackgroundTemperature, InputDensity, InputDvDr);
            
            radexPath = fullfile('.','radexLVG.exe');
            
            RuntimeMessage = evalc(sprintf('!%s < radex.inp',radexPath));
            
            Result = RadexResult.ReadFromFile('radex.out');
            
        end
        
    end
    
    methods(Access=private, Static=true)
        
        function buildRadexInputFile (FileName, InputFile, OutputFile, LowerFreq, UpperFreq, KineticTemp, CollisionParters, CollisionPartnerDensities, BackgroundTemperature, ColumnDensity, LineWidth)
            
            if ~(0.1 <= KineticTemp && KineticTemp <= 1e4)
                ME = MException('VerifyInput:TemperatureOutOfRange','Error in input. Kinetic temperature [K] should be between 0.1 and 1e4. Input: [%g]', KineticTemp);
                throw(ME);
            elseif numel(CollisionParters) > 7
                ME = MException('VerifyInput:CollisionPartersOutOfRange','Error in input. Collision Parters should should contain no more than 7 elements. Input: [%g]', numel(CollisionParters));
                throw(ME);
            elseif any(~(1e-3 <= CollisionPartnerDensities & CollisionPartnerDensities <= 1e13))
                ME = MException('VerifyInput:CollisionPartnerDensitiesOutOfRange','Error in input. Collision Parters density should be between 1e-3 and 1e13. Input: [%s]', num2str(CollisionPartnerDensities,'%g '));
                throw(ME);
            elseif ~(-1e4 <= BackgroundTemperature && BackgroundTemperature <= 1e4)
                ME = MException('VerifyInput:BackgroundTemperatureOutOfRange','Error in input. Background Temperature [K] should be between -1e4 and 1e4. Input: [%g]', BackgroundTemperature);
                throw(ME);
            elseif ~(1e5 <= ColumnDensity && ColumnDensity <= 1e25)
                ME = MException('VerifyInput:ColumnDensityOutOfRange','Error in input. Column Density [cm^-2] should be between 1e5 and 1e25. Input: [%g]', ColumnDensity);
                throw(ME);
            elseif ~(1e-3 <= LineWidth && LineWidth <= 1e3)
                ME = MException('VerifyInput:LineWidthOutOfRange','Error in input. Line Width [km/s] should be between 1e-3 and 1e3. Input: [%g]', LineWidth);
                throw(ME);
            end
            
            fid = fopen(FileName,'wt');
            
            try
                
                fprintf(fid,'%s\n',InputFile);
                fprintf(fid,'%s\n',OutputFile);
                fprintf(fid,'%g %g\n',LowerFreq,UpperFreq);
                fprintf(fid,'%g\n',KineticTemp);
                fprintf(fid,'%u\n',numel(CollisionParters));
                
                for i=1:numel(CollisionParters)
                    fprintf(fid,'%s\n',CollisionPartnersCodes.ToStringRadexFormat(CollisionParters(i).CollisionPartnerCode));
                    fprintf(fid,'%g\n',CollisionPartnerDensities(i));
                end
                
                fprintf(fid,'%g\n',BackgroundTemperature);
                fprintf(fid,'%g\n',ColumnDensity);
                fprintf(fid,'%g\n',LineWidth);
                fprintf(fid,'0\n');
                
            catch
                fclose(fid);
                rethrow(lasterror);
            end
            
            fclose(fid);
            
        end
        
    end
    
end