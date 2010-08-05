classdef (Sealed) Constants < handle
    % Contains all the physical constants used in the program
    
    properties (Constant = true)
        % Plank constant [erg * s]
        h = 6.62606896*10^-27; 
        % Boltzmann constant [erg / K]
        k = 1.3806504*10^-16; 
        % Speed of light [cm / s]
        c = 29979245800; 
        % PI
        pi = 3.141592653589;
        % Velocity gradient conversion factor from [km / s pc] to [1/s]
        dVdRConversionFactor = 10^5 / (3.08568025 * 10^18); 
    end
    
    methods (Access = private)
        function out = Constants ()
            % Private so that you can't instatiate.
        end
    end
end