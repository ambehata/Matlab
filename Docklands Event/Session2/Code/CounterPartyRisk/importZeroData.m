function [Tenor,Date,Rate] = importZeroData(workbookFile,sheetName,startRow,endRow)
    %IMPORTFILE Import data from a spreadsheet
    %   [Tenor,Date,Rate] = IMPORTFILE(FILE) reads data from the first
    %   worksheet in the Microsoft Excel spreadsheet file named FILE and
    %   returns the data as column vectors.
    %
    %   [Tenor,Date,Rate] = IMPORTFILE(FILE,SHEET) reads from the specified
    %   worksheet.
    %
    %   [Tenor,Date,Rate] = IMPORTFILE(FILE,SHEET,STARTROW,ENDROW) reads from
    %   the specified worksheet for the specified row interval(s). Specify
    %   STARTROW and ENDROW as a pair of scalars or vectors of matching size
    %   for dis-contiguous row intervals. To read to the end of the file
    %   specify an ENDROW of inf.%
    % Example:
    %   [Tenor,Date,Rate] = importfile('CCR Data.xlsx','Zero',5,12);
    %
    %   See also XLSREAD.
    
    % Auto-generated by MATLAB on 2013/04/19 16:03:16
    
    %% Input handling
    
    % If no sheet is specified, read first sheet
    if nargin == 1 || isempty(sheetName)
        sheetName = 1;
    end
    
    % If row start and end points are not specified, define defaults
    if nargin <= 3
        startRow = 5;
        endRow = 12;
    end
    
    %% Import the data
    [~, ~, raw] = xlsread(workbookFile, sheetName, sprintf('A%d:C%d',startRow(1),endRow(1)));
    for block=2:length(startRow)
        [~, ~, tmpRawBlock] = xlsread(workbookFile, sheetName, sprintf('A%d:C%d',startRow(block),endRow(block)));
        raw = [raw;tmpRawBlock]; %#ok<AGROW>
    end
    raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
    cellVectors = raw(:,2);
    raw = raw(:,[1,3]);
    
    %% Create output variable
    data = reshape([raw{:}],size(raw));
    
    %% Allocate imported array to column variable names
    Tenor = data(:,1);
    Date = cellVectors(:,1);
    Date = datenum(Date, 'dd/mm/yyyy');
    Rate = data(:,2);
    
