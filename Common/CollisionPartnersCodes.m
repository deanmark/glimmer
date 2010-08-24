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