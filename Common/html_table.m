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

function s = html_table(table_cell, fname, varargin)

% html_table writes a cell-array to an html file for display via html browsers.  
%
% INPUTS:
% s is an optional output argument if a string of the html code is required.  
% table_cell is a 2D cell array of the table contents. This should include the row and column headers if they are needed. 
% fname is a string for the file name, e.g. 'test_html_table.html'
% Other options can be added as param-value pairs as listed in the code (esp for formatting the table). 
%
% EXAMPLE:
%     colheads = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Year'};
%     rowheads = {'Yield Budget'; 'Yield Actual'; 'Likely EOM'; 'Yield Variance'};
%     data = rand(4,12) * 2000 - 600;
%     data(:,end+1) = sum(data,2);
%     table_cell = [[{'Period'};rowheads] [colheads; num2cell(data)]]; %Add row and col heading cell-arrays onto a double data matrix
%     caption_str = 'Test of HTML Table Output';
%     html_table(table_cell, 'test_html_table.html', 'Caption',caption_str, ...
%         'DataFormatStr','%1.0f', 'BackgroundColor','#EFFFFF', 'RowBGColour',{'#000099',[],[],[],'#FFFFCC'}, 'RowFontColour',{'#FFFFB5'}, ...
%         'FirstRowIsHeading',1, 'FirstColIsHeading',1, 'NegativeCellFontColour','red');
%
% Note re colours: These can be specified as text strings of either: 
%   a) One of the html 16 color names, e.g. 'black' 
%   b) Hexadecimal, e.g. '#CCFFFF' ref: http://www.quackit.com/html/html_color_codes.cfm for colour charts.  
%   c) RGB, e.g. 'rgb(100,255,100)'
%
% AUTHOR: Roger Parkyn, roger.parkyn@hydro.com.au


%% Sort out the inputs
p = inputParser;   % Create an instance of the inputParser class.
p.addRequired('table_cell', @iscell);
p.addRequired('fname', @ischar);
p.addParamValue('WriteFileHtmlHeaders', true, @islogical); %Headers to allow the output file to look like a stand-alone html file.  
p.addParamValue('Title', [], @ischar);
p.addParamValue('FontColor', 'black', @ischar); 
p.addParamValue('FontSize', 12, @isnumeric); 
p.addParamValue('FontFace', 'arial', @ischar); 
p.addParamValue('TextAlign', 'center', @(x)any(strcmpi(x,{'left','center','right'}))); 
p.addParamValue('CellPadding', 2.5, @isnumeric); 
p.addParamValue('CellSpacing', 0, @isnumeric); 
p.addParamValue('BorderSize', 1, @isnumeric); 
p.addParamValue('BorderColor', 'black', @ischar); 
p.addParamValue('BackgroundColor', 'white', @ischar); %Background colour of the whole table
p.addParamValue('Caption', [], @ischar); %This give a caption above the table
p.addParamValue('DataFormatStr', '%1.1f', @ischar); %Format of numeric data, e.g. '%1.3f' for 3 decimal places
p.addParamValue('FirstRowIsHeading', 0, @isnumeric); %Enter 1 to make the first row a heading style row (shown in bold font)
p.addParamValue('FirstColIsHeading', 0, @isnumeric);  %Enter 1 to make the first column a heading style col (shown in bold font)
p.addParamValue('RowBGColour', {}, @iscell);  %Cell vector of background colour strings: if not empty, each i-th element of this cell-vector will over-ride the table bg colour for the i-th row.  
p.addParamValue('RowFontColour', {}, @iscell);  %Cell vector of background colour strings: if not empty, each i-th element of this cell-vector will over-ride the table bg colour for the i-th row.  
p.addParamValue('NegativeCellFontColour', [], @ischar);  %Over-ride to font colour if the cell is numeric and negative.  

p.parse(table_cell, fname, varargin{:});

%Pad RowBGColour with empty cells (in case the colours are not defined for later rows of the table)
bgc_override = p.Results.RowBGColour;
for i = 1+length(p.Results.RowBGColour):size(table_cell,1)
    bgc_override{i} = []; 
end
row_font_override = p.Results.RowFontColour;
for i = 1+length(p.Results.RowFontColour):size(table_cell,1)
    row_font_override{i} = []; 
end


%% set up an HTML table
fid = fopen(fname,'w+');
if p.Results.WriteFileHtmlHeaders
    fprintf(fid,['<html>\n\n\t<head>\n\t\t<title>',p.Results.Title, '</title>\n\t</head>\n\n\t<body>\n\n']);
end
fprintf(fid,['\t\t<table style=" color:',p.Results.FontColor,'; ',...
    'font-size:', num2str(p.Results.FontSize),'; ',...
    'font-family:', p.Results.FontFace,'; ',...
    'text-align:', p.Results.TextAlign,'; " ',...
    'cellpadding="',num2str(p.Results.CellPadding),'" ',...
    'cellspacing="',num2str(p.Results.CellSpacing),'" ',...
    'border="',num2str(p.Results.BorderSize),'" ',...
    'bordercolor="',p.Results.BorderColor,'" ',...
    'bgcolor="',p.Results.BackgroundColor,'"',...
    '>\n']);
fprintf(fid,['\t\t\t<caption>',p.Results.Caption,'</caption>\n']); %add the caption


%% Step through and print each table element
for i=1:size(table_cell,1);
    %begin a row of the table. 
    if ~isempty(bgc_override{i}) || ~isempty(row_font_override{i})
        fprintf(fid, ['\t\t\t<tr style="color:' row_font_override{i} ';background:' bgc_override{i} '">\n']);
    else
        fprintf(fid,'\t\t\t<tr>\n');
    end
    for j=1:size(table_cell,2); %step through each column in the current row
        if isnumeric(table_cell{i,j}) && ~isempty(table_cell{i,j}) && ~isnan(table_cell{i,j});
            if (table_cell{i,j}>=0.0) || isempty(p.Results.NegativeCellFontColour)
                c = [' align="right"> ' num2str(table_cell{i,j}, p.Results.DataFormatStr)]; %Convert numbers to strings and right align them
            else
                % Add the negative-cell colour over-ride
                c = [' align="right" style=" color:' p.Results.NegativeCellFontColour '; "> ' num2str(table_cell{i,j}, p.Results.DataFormatStr)]; %Convert numbers to strings and right align them
            end
        elseif ischar(table_cell{i,j})
            c = ['>' table_cell{i,j}];
        elseif iscellstr(table_cell{i,j})
            cell= table_cell{i,j};
            c = ['>' cell{1}];
        else
            c = '>&nbsp;';	%'Non Breaking White Space' - If it's not a char not a numeric, or is NaN.
        end
        if (p.Results.FirstRowIsHeading && i==1) || (p.Results.FirstColIsHeading && j==1)
            fprintf(fid,['\t\t\t\t<th',c,'</th>\n']); %write a TableData element in heading style
        else
            fprintf(fid,['\t\t\t\t<td',c,'</td>\n']); %write a TableData element - Normal style
        end
    end
    fprintf(fid,'\t\t\t</tr>\n');%close the TableRow
end


%% Close
fprintf(fid,'\t\t</table>\n\n'); %Close the table
if p.Results.WriteFileHtmlHeaders
    fprintf(fid,' \t</body>\n\n</html>');
end

%If an output string is required read it from the file
if nargout > 0
    frewind(fid);
    s = fscanf(fid, '%c', inf);
end

fclose(fid); %close the output file

