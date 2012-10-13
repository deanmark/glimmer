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

classdef (Sealed) LVGParameterCodes
    
    properties  (Constant)
        Temperature = 1;
        CollisionPartnerDensity = 2;
        VelocityDerivative = 3;
        MoleculeAbundanceRatio = 4;
        ConstantNpartnerBydVdR = 5;
    end
    
    methods (Access = private)
        %private so that you can't instatiate.
        function out = LVGParameterCodes
        end
    end
    
    methods (Access = public, Static=true)
        
        function Result = ToStringGUIFormat (LVGParameterCode)
            switch LVGParameterCode
                case LVGParameterCodes.Temperature
                    Result = 'Temperature';
                case LVGParameterCodes.CollisionPartnerDensity
                    Result = 'n collision partner';
                case LVGParameterCodes.VelocityDerivative
                    Result = 'dV/dR';
                case LVGParameterCodes.MoleculeAbundanceRatio
                    Result = 'X mol';
                case LVGParameterCodes.ConstantNpartnerBydVdR
                    Result = 'N/dV';
                otherwise
                    ME = MException('VerifyInput:unknownLVGParameterCode','Error in input. LVG Parameter Code [%d] is unknown', LVGParameterCode);
                    throw(ME);
            end
        end
        
        function Result = ToCodeFromGUIFormat (LVGParameterCode)
            switch LVGParameterCode
                case 'Temperature'
                    Result = LVGParameterCodes.Temperature;
                case 'n collision partner'
                    Result = LVGParameterCodes.CollisionPartnerDensity;
                case 'dV/dR'
                    Result = LVGParameterCodes.VelocityDerivative;
                case 'X mol'
                    Result = LVGParameterCodes.MoleculeAbundanceRatio;
                case 'N/dV'
                    Result = LVGParameterCodes.ConstantNpartnerBydVdR;
                otherwise
                    ME = MException('VerifyInput:unknownLVGParameterCodes','Error in input. LVG Parameter Code [%d] is unknown', LVGParameterCode);
                    throw(ME);
            end
        end
        
        function Result = ToArrayIndexFormat (LVGParameterCode)
            switch LVGParameterCode
                case LVGParameterCodes.Temperature
                    Result = 1;
                case LVGParameterCodes.CollisionPartnerDensity
                    Result = 2;
                case LVGParameterCodes.VelocityDerivative
                    Result = 3;
                case LVGParameterCodes.MoleculeAbundanceRatio
                    Result = 4;
                case LVGParameterCodes.ConstantNpartnerBydVdR
                    Result = 5;
                otherwise
                    ME = MException('VerifyInput:unknownLVGParameterCode','Error in input. LVG Parameter Code [%d] is unknown', LVGParameterCode);
                    throw(ME);
            end
        end
        
        function Result = ToCodeFromArrayIndexFormat (LVGParameterCode)
            switch LVGParameterCode
                case 1
                    Result = LVGParameterCodes.Temperature;
                case 2
                    Result = LVGParameterCodes.CollisionPartnerDensity;
                case 3
                    Result = LVGParameterCodes.VelocityDerivative;
                case 4
                    Result = LVGParameterCodes.MoleculeAbundanceRatio;
                case 5
                    Result = LVGParameterCodes.ConstantNpartnerBydVdR;
                otherwise
                    ME = MException('VerifyInput:unknownLVGParameterCodes','Error in input. LVG Parameter Code [%d] is unknown', LVGParameterCode);
                    throw(ME);
            end
        end

    end
    
end
