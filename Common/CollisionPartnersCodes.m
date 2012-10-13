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

classdef (Sealed) CollisionPartnersCodes
    % Enum of collision partners
    
    properties  (Constant)
        H2 = 1;
        H2para = 2;
        H2ortho = 3;
        electrons = 4;
        H = 5;
        He = 6;
        HPlus = 7;
    end

    methods (Access = private)
        %private so that you can't instatiate.
        function out = CollisionPartnersCodes
        end
    end
    
    methods (Access = public, Static=true)

        function Result = ToString (CollisionPartnerCode)
            switch CollisionPartnerCode
                case CollisionPartnersCodes.H2
                    Result = 'H2';
                case CollisionPartnersCodes.H2para
                    Result = 'H2 para';
                case CollisionPartnersCodes.H2ortho
                    Result = 'H2 ortho';
                case CollisionPartnersCodes.electrons
                    Result = 'Electron';
                case CollisionPartnersCodes.H
                    Result = 'H';
                case CollisionPartnersCodes.He
                    Result = 'He';
                case CollisionPartnersCodes.HPlus
                    Result = 'H+';
                otherwise
                    ME = MException('VerifyInput:unknownCollisionPartnerCode','Error in input. Collision partner code [%d] is unknown', CollisionPartnerCode);
                    throw(ME);
            end            
        end
        
        function Result = ToStringRadexFormat (CollisionPartnerCode)            
            switch CollisionPartnerCode
                case CollisionPartnersCodes.H2
                    Result = 'H2';
                case CollisionPartnersCodes.H2para
                    Result = 'p';
                case CollisionPartnersCodes.H2ortho
                    Result = 'o';
                case CollisionPartnersCodes.electrons
                    Result = 'e';
                case CollisionPartnersCodes.H
                    Result = 'h';
                case CollisionPartnersCodes.He
                    Result = 'he';
                case CollisionPartnersCodes.HPlus
                    Result = 'h+';
                otherwise
                    ME = MException('VerifyInput:unknownCollisionPartnerCode','Error in input. Collision partner code [%d] is unknown', CollisionPartnerCode);
                    throw(ME);
            end            
        end
        
        function Result = ToCodeFromRadexFormat (CollisionPartnerString)
            switch CollisionPartnerString
                case 'H2'
                    Result = CollisionPartnersCodes.H2;
                case 'p'
                    Result = CollisionPartnersCodes.H2para;
                case 'o'
                    Result = CollisionPartnersCodes.H2ortho;
                case 'e'
                    Result = CollisionPartnersCodes.electrons;
                case 'h'
                    Result = CollisionPartnersCodes.H;
                case 'he'
                    Result = CollisionPartnersCodes.He;
                case 'h+'
                    Result = CollisionPartnersCodes.HPlus;
                otherwise
                    ME = MException('VerifyInput:unknownCollisionPartnerCode','Error in input. Collision partner code [%d] is unknown', CollisionPartnerCode);
                    throw(ME);
            end            
        end
        
    end
    
end
