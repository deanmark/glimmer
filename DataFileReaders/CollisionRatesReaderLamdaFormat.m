%{
GLIMMER is a visual LVG (Large Velocity Gradient) analysis tool.

Copyright (C) 2012  Dean Mark <deanmark at gmail>, 
		Prof. Amiel Sternberg <amiel at wise.tau.ac.il>, 
		Department of Astrophysics, Tel-Aviv University

Documentation for the program is posted at http://deanmark.github.com/glimmer/

This file is part of GLIMMER.

GLIMMER is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GLIMMER is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%}

classdef CollisionRatesReaderLamdaFormat < CollisionRatesReader
    
    properties(Constant = true, Hidden=true)
        
        CollisionTemperatureString = 'COLL TEMPS';
        CollisionTransitionString = 'NUMBER OF COLL TRANS';
        CollisionPartnerString = 'COLLISIONS BETWEEN';
        NumberOfCollisionPartnerString = 'NUMBER OF COLL PARTNERS';
        
    end
    
    methods(Static=true)
        
        function Rates = CreateCollisionRatesFromFile (FileName, CollisionPartner, MoleculeData, CollisionFactor)
            
            if nargin < 4; CollisionFactor = 1; end
            
            collisionRates = CollisionRatesReaderLamdaFormat.readCollisionRatesFile (FileName, CollisionPartner);
            collisionRates(2:end, 3:end) = CollisionFactor*collisionRates(2:end, 3:end);
            Rates = CollisionRates(MoleculeData, CollisionPartner, collisionRates);
            
        end
    
        function CollisionPartners = ListAllCollisionPartners(FileName)
            
            fid = fopen(FileName);
            
            try
                
                CollisionRatesReaderLamdaFormat.getToNumberOfCollPartnersSection(fid);
                
                numColPartners = str2double(FileIOHelper.JumpLinesInFile(fid, 2));                
                CollisionPartners = CollisionRatesReaderLamdaFormat.readCollisionPartnerCodes(fid, numColPartners);          
                
            catch ME
                fclose(fid);
                rethrow(ME);
            end
            
            fclose(fid);
        end
        
    end
    
    methods(Static=true,Access = private, Hidden=true)
        
        function CollisionRates = readCollisionRatesFile (FileName, CollisionPartner)
            
            fid = fopen(FileName);
            
            try
                CollisionRatesReaderLamdaFormat.getToNumberOfCollPartnersSection(fid);
                numColPartners = str2double(FileIOHelper.JumpLinesInFile(fid, 2));
                
                foundPartner = CollisionRatesReaderLamdaFormat.getToCollisionPartnerSection(fid,CollisionPartner,numColPartners);
                
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
        
        function CollisionPartners = readCollisionPartnerCodes (fid, NumberOfCollisionPartners)
            
            CollisionPartners = zeros([1 NumberOfCollisionPartners]);
            
            for i=1:NumberOfCollisionPartners
                
                currentLine = FileIOHelper.JumpLinesInFile(fid, 2);
                CollisionPartners(i) = CollisionRatesReaderLamdaFormat.convertCollisionLineToCollisionCode(currentLine);
                
                collisionalTransitions = str2double(FileIOHelper.JumpLinesInFile(fid, 2));
                FileIOHelper.JumpLinesInFile(fid, collisionalTransitions+5);
                
            end

        end
        
        function getToNumberOfCollPartnersSection (fid)
            
            energyLevels = str2double(FileIOHelper.JumpLinesInFile(fid, 6));
            radiativeTransitions = str2double(FileIOHelper.JumpLinesInFile(fid, energyLevels + 3));
            FileIOHelper.JumpLinesInFile(fid, radiativeTransitions + 1);
            
        end
        
        function FoundSection = getToCollisionPartnerSection (fid, CollisionPartner, NumberOfCollisionPartners)
            
            FoundSection = 0;
            i = 0;
            
            while i < NumberOfCollisionPartners && ~FoundSection
               
                currentLine = FileIOHelper.JumpLinesInFile(fid, 2);
                currentCollPartner = CollisionRatesReaderLamdaFormat.convertCollisionLineToCollisionCode(currentLine);                
                
                if currentCollPartner == CollisionPartner
                    FoundSection = 1;
                    return;
                end
                
                collisionalTransitions = str2double(FileIOHelper.JumpLinesInFile(fid, 2));
                FileIOHelper.JumpLinesInFile(fid, collisionalTransitions+5);
                
                i=i+1;
                
            end
            
        end
        
        function CollisionRates = readCollisionRatesSection (fid)
            
            currentLine = fgetl(fid);
                        
%             if isempty(strfind(upper(currentLine), CollisionRatesReaderLamdaFormat.CollisionTransitionString))
%                 ME = MException('CollisionRatesReaderLamdaFormat:CollisionTransitionStringNotFound','Collision transition string was not found. Data file is not in the lamda format');
%                 throw(ME);
%             end
            
            currentLine = fgetl(fid);
            numCollisions = str2double(currentLine);
            
            %arrive to temperature row
            currentLine = FileIOHelper.JumpLinesInFile(fid, 3);
            
%             if isempty(strfind(upper(currentLine), CollisionRatesReaderLamdaFormat.CollisionTemperatureString))
%                 ME = MException('CollisionRatesReaderLamdaFormat:CollisionTemperatureStringNotFound','Collision temperature string was not found. Data file is not in the lamda format');
%                 throw(ME);
%             end
            
            currentLine = fgetl(fid);
            temperatures = str2num(currentLine);
            
            CollisionRates = zeros(numCollisions+1,size(temperatures,2)+2);
            
            %insert temperatures into array
            CollisionRates(1,3:end) = temperatures;
            
            fgetl(fid);
            
            %insert collision data into array
            for i=1:numCollisions
                
                currentLine = fgetl(fid);
                
                rowData = regexp(strtrim(currentLine),'\s+','split');
                
                for j=1:numel(rowData)-1
                    CollisionRates(i+1,j) = str2double(rowData{j+1});
                end
            end
        end
        
        function CollisionPartner = convertCollisionLineToCollisionCode (currentLine)
            
            parts = regexp(currentLine,'\s','split');
            CollisionPartner = str2double(parts{1});
            
            if isnan(CollisionPartner)
                innerParts = regexp(parts{1},'-','split');
                CollisionPartner = CollisionPartnersCodes.ToCodeFromRadexFormat(innerParts{2});
            end
            
        end
        
    end %methods
    
    
end %class
