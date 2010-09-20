% A progress dialog to notify the user of the status an ongoing operation.
% Unlike waitbar, the progress dialog is automatically closed when the
% operation is interrupted by the user or an error occurs.
%
% See also: waitdialog, waitbar

% Copyright 2009-2010 Levente Hunyadi
classdef ProgressDialog < UIControl
    properties (Dependent)
        Control;
    end
    properties
        % Completion status p with 1 >= p >= 0, or empty if indeterminate.
        FractionComplete = 0;
        ShowTimeLeft = 0;
        % Status message shown to the user.
        StatusMessage = 'Please wait...';
        % Indeterminate completion status.
        % Indeterminate status is intended for operations whose completion
        % status is unknown or cannot be computed.
        Indeterminate = false;
        Implementation = 'java';
    end
    properties (Access = private)
        Dialog;
        StartTime;
    end
    methods
        function obj = ProgressDialog(varargin)
            obj = obj@UIControl(varargin{:});
        end
        
        function obj = Instantiate(obj, parent) %#ok<INUSD>
            switch obj.Implementation
                case 'matlab'
                    impl = false;
                case 'java'
                    impl = true;
            end
            obj.Dialog = progressbar([], obj.FractionComplete, obj.StatusMessage, impl);
        end
        
        function ShowTimeLeft = get.ShowTimeLeft(obj)
            ShowTimeLeft = obj.ShowTimeLeft;
        end
        
        function set.ShowTimeLeft(obj, show)
            obj.ShowTimeLeft = show;
        end
        
        function control = get.Control(obj)
            control = obj.Dialog;
        end
                
        function set.FractionComplete(obj, x)
            if ~isempty(x)
                validateattributes(x, {'numeric'}, {'nonnegative','real','scalar'});
            end
            obj.FractionComplete = x;
            
            if obj.TestForUserInterrupt()
                callererror('gui:ProgressDialog', 'Operation terminated by user.');
            end
            
            if x==0
                obj.StartTime = clock;
                set(obj.Dialog,'Name', 'Operation in progress');                 
            elseif ~isempty(obj.StartTime) && obj.ShowTimeLeft
                runtime = etime(clock,obj.StartTime);
                timeleft = runtime/x - runtime;
                timeleftstr = ProgressDialog.sec2timestr(timeleft);
                set(obj.Dialog,'Name', sprintf(' %s remaining',timeleftstr));
            end
            
            obj.UpdateDialog();
        end
        
        function set.StatusMessage(obj, message)
            if ~isempty(message)
                validateattributes(message, {'char'}, {'nonempty','row'});
            end
            obj.StatusMessage = message;
            if obj.TestForUserInterrupt()
                callererror('gui:ProgressDialog', 'Operation terminated by user.');
            end
            obj.UpdateDialog();
        end
        
        function set.Indeterminate(obj, tf)
            validateattributes(tf, {'logical'}, {'scalar'});
            obj.Indeterminate = tf;
            obj.UpdateDialog();
        end
        
        function delete(obj)
            if ishandle(obj.Dialog)
                delete(obj.Dialog);
            end
        end
        
        function uiwait(obj)
            uiwait(obj.Dialog);
        end
        
    end
    
    methods(Static)
        
        function timestr = sec2timestr(sec)
            % Convert a time measurement from seconds into a human readable string.
            
            % Convert seconds to other units
            d = floor(sec/86400); % Days
            sec = sec - d*86400;
            h = floor(sec/3600); % Hours
            sec = sec - h*3600;
            m = floor(sec/60); % Minutes
            sec = sec - m*60;
            s = floor(sec); % Seconds
            
            % Create time string
            if d > 0
                if d > 9
                    timestr = sprintf('%d day',d);
                else
                    timestr = sprintf('%d day, %d hr',d,h);
                end
            elseif h > 0
                if h > 9
                    timestr = sprintf('%d hr',h);
                else
                    timestr = sprintf('%d hr, %d min',h,m);
                end
            elseif m > 0
                if m > 9
                    timestr = sprintf('%d min',m);
                else
                    timestr = sprintf('%d min, %d sec',m,s);
                end
            else
                timestr = sprintf('%d sec',s);
            end
            
            
        end
    end
    
    methods (Access = private)
       
        function tf = TestForUserInterrupt(obj)
            if ~ishandle(obj.Dialog)  % dialog has been closed by user
                obj.Dialog = [];
                tf = true;
            else
                tf = false;
            end
        end
        
        function UpdateDialog(obj)
            if obj.Indeterminate
                r = [];
            else
                r = obj.FractionComplete;
            end
            progressbar(obj.Dialog, r, obj.StatusMessage);
            drawnow;
        end
    end
end
