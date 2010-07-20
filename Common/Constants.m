classdef Constants
    %Contains all the physical constants used in the program
    
    properties (Constant = true)
        h = 6.62606896*10^-27; %plank constant - erg*s
        k = 1.3806504*10^-16; %Boltzmann constant - erg / K
        c = 29979245800; %Speed of light - cm/s
        pi = 3.141592653589;
        dVdRConversionFactor = 10^5 / (3.08568025 * 10^18); % convert from km*s-1*pc-1 to cm*s-1
    end
end

