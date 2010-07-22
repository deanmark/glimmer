classdef (Sealed) CollisionPartnersCodes
    %COLLISIONPARTNERS Enum of collision partners
    
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
            end            
        end
        
    end
    
end