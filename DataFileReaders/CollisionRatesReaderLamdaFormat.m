classdef CollisionRatesReaderLamdaFormat < CollisionRatesReader
    
    properties(Constant = true, Hidden=true)
        
        CollisionTemperatureString = '!COLL TEMPS';
        CollisionTransitionString = '!NUMBER OF COLL TRANS';
        CollisionPartnerString = '!COLLISIONS BETWEEN';
        
    end
    
    methods(Static=true)
        
        function Rates = CreateCollisionRatesFromFile (FileName, CollisionPartner, MoleculeData, CollisionFactor)
            
            if nargin < 4; CollisionFactor = 1; end
            
            collisionRates = CollisionRatesReaderLamdaFormat.readCollisionRatesFile (FileName, CollisionPartner);
            collisionRates(2:end, 3:end) = CollisionFactor*collisionRates(2:end, 3:end);
            Rates = CollisionRates(MoleculeData, CollisionPartner, collisionRates);
            
        end
        
    end
    
    methods(Static=true,Access = private, Hidden=true)
        
        function CollisionRates = readCollisionRatesFile (FileName, CollisionPartner)
            
            fid = fopen(FileName);
            
            try
                foundPartner = CollisionRatesReaderLamdaFormat.getToCollisionPartnerSection(fid,CollisionPartner);
                
                if foundPartner
                    CollisionRates = CollisionRatesReaderLamdaFormat.readCollisionRatesSection(fid);
                else
                    CollisionRates = 0;
                end
                
            catch
                fclose(fid);
                rethrow(lasterror);
            end
            
            fclose(fid);
            
            if CollisionRates == 0
                ME = MException('CollisionRatesReaderLamdaFormat:CollisionPartnerNotFound','Collision partner not found in data file');
                throw(ME);
            end
        end
        
        function FoundSection = getToCollisionPartnerSection (fid, CollisionPartner)
            
            FoundSection = 0;
            
            currentLine = fgetl(fid);
            
            while strcmp(currentLine,'-1') == false || feof(fid) ~= true
                
                if strcmp(currentLine, CollisionRatesReaderLamdaFormat.CollisionPartnerString)
                    currentLine = fgetl(fid);
                    if size (strmatch(num2str(CollisionPartner), currentLine), 1) == 1
                        FoundSection = 1;
                        return;
                    end
                end
                
                currentLine = fgetl(fid);
                
            end
            
        end
        
        function CollisionRates = readCollisionRatesSection (fid)
            
            currentLine = fgetl(fid);
            
            if strcmp(currentLine, CollisionRatesReaderLamdaFormat.CollisionTransitionString)==false
                ME = MException('CollisionRatesReaderLamdaFormat:CollisionTransitionStringNotFound','Collision transition string was not found. Data file is not in the lamda format');
                throw(ME);
            end
            
            currentLine = fgetl(fid);
            numCollisions = str2double(currentLine);
            
            %arrive to temperature row
            currentLine = FileIOHelper.JumpLinesInFile(fid, 3);
            
            if strcmp(currentLine, CollisionRatesReaderLamdaFormat.CollisionTemperatureString)==false
                ME = MException('CollisionRatesReaderLamdaFormat:CollisionTemperatureStringNotFound','Collision temperature string was not found. Data file is not in the lamda format');
                throw(ME);
            end
            
            currentLine = fgetl(fid);
            temperatures = str2num(currentLine);
            
            CollisionRates = zeros(numCollisions+1,size(temperatures,2)+2);
            
            %insert temperatures into array
            for i=1:size(temperatures,2)
                CollisionRates(1,i+2) = temperatures(i);
            end
            
            fgetl(fid);
            
            %insert collision data into array
            for i=1:numCollisions
                
                currentLine = fgetl(fid);
                
                rowData = regexp(strtrim(currentLine),' *','split');
                
                for j=1:size(rowData,2)-1
                    CollisionRates(i+1,j) = str2double(rowData(j+1));
                end
            end
        end
        
    end %methods
    
end %class