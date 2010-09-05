classdef RadexSolver < handle
    
    properties (Constant)
        
        RadexExpandingSphereFileName = 'radexExpandingSphere.exe';
        RadexUniformSphereFileName = 'radexUniformSphere.exe';
        RadexPlaneParallelSlabFileName = 'radexPlaneParallelSlab.exe';
        InputFileName = 'radex.inp';
        OutputFileName = 'radex.out';
    end
    
    
    methods(Static=true)
        
        function [ Result, Converged, RuntimeMessage ] = CalculateLVGPopulation(PopulationRequest)
            
            %we need to set the directory to the radex exe dir.
            RadexDirectory = RadexSolver.getRadexDirectory();
            userDir = cd;
            cd(RadexDirectory);

            radexFileName = RadexSolver.convertBetaTypeToFileName(PopulationRequest.BetaTypeCode);
            [inputDensity, inputDvDr] = RadexSolver.computeDensityAndDvDrParams(PopulationRequest);
            collisionPartnerDensities = PopulationRequest.CollisionPartnerDensities*PopulationRequest.Weights/(sum(PopulationRequest.Weights));
            
            RadexSolver.buildRadexInputFile(RadexSolver.InputFileName, PopulationRequest.MoleculeFileName, RadexSolver.OutputFileName, 0, 0, PopulationRequest.Temperature, ...
                PopulationRequest.CollisionPartners, collisionPartnerDensities, PopulationRequest.BackgroundTemperature, inputDensity, inputDvDr);
            
            RuntimeMessage = evalc(sprintf('!%s < %s',radexFileName, RadexSolver.InputFileName));
            
            Converged = RadexSolver.verifyThatRadexHasRun(RuntimeMessage);
            %parse results            
            Result = RadexResult.ReadFromFile(RadexSolver.OutputFileName);
            
            %set working dir back to normal
            cd(userDir);
            
        end
        
        function [ Result , RuntimeMessage ] = SolveLevelsPopulationOpticallyThin(CollisionPartnerDensity, Temperature, Molecule, CollisionPartners, CollisionPartnerWeights, BackgroundTemperature)
           
           [ Result , RuntimeMessage ] = RadexSolver.SolveLevelsPopulationLVG(RadexSolver.LVG, 1e3, CollisionPartnerDensity, Temperature, 1e5/CollisionPartnerDensity, Molecule, CollisionPartners, CollisionPartnerWeights, BackgroundTemperature);
            
        end
        
    end
    
    methods(Access=private, Static=true)
        
        function buildRadexInputFile (FileName, MoleculeFile, OutputFile, LowerFreq, UpperFreq, KineticTemp, CollisionParters, CollisionPartnerDensities, BackgroundTemperature, ColumnDensity, LineWidth)
            
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
                
                fprintf(fid,'%s\n',MoleculeFile);
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
        
        function FileName = convertBetaTypeToFileName (BetaType)
            
            switch BetaType
                case BetaTypeCodes.ExpandingSphere
                    FileName = RadexSolver.RadexLVGFileName;
                case BetaTypeCodes.UniformSphere
                    FileName = RadexSolver.RadexUniformSphereFileName;
                case BetaTypeCodes.HomogeneousSlab
                    FileName = RadexSolver.RadexPlaneParallelSlabFileName;
                otherwise
                    ME = MException('VerifyInput:BetaTypeUnkown','Error in input. BetaType is unknown. Input: [%g]', BetaType);
                    throw(ME);
            end
            
        end
        
        function [InputDensity,InputDvDr] = computeDensityAndDvDrParams (PopulationRequest)
            
            DensityToDvdrRatio = PopulationRequest.MoleculeDensity / ( PopulationRequest.VelocityDerivative * 1e-5); %Radex accepts dvdr in Km/sec, the 1e5 converts our cm's to km's
            
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
            
        end
        
        function Converged = verifyThatRadexHasRun (RuntimeMessage)
            %check if radex has run
            if ~isempty(regexp(RuntimeMessage,'Calculation did not converge', 'once'))
                Converged = 0;
            elseif isempty(regexp(RuntimeMessage,'Finished in.*iterations', 'once'))
                ME = MException('RuntimeError:RadexError','Radex did not run. Output message: %s', RuntimeMessage);
                throw(ME);
            else
                Converged = 1;
            end
        end
        
        function RadexDir = getRadexDirectory()
            
            persistent RadexDirectory;
            if isempty(RadexDirectory)
                classPath = mfilename('fullpath'); %returns path of current class. exe files are assumed to be in the same directory as the RadexSolver class.
                RadexDirectory = fileparts(classPath);
            end
            
            RadexDir = RadexDirectory;
            
        end
        
    end
    
end