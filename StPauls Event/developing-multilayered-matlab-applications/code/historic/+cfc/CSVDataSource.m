classdef CSVDataSource < cfc.DataSource
    
    %  Copyright 2014 The MathWorks, Inc.
    %  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $
    
    properties( SetAccess = private )
        Folder % folder containing files
    end
    
    methods
        
        function obj = CSVDataSource( folder )
            %cfc.CSVDataSource  Data source backed by CSV files
            %
            %  s = cfc.CSVDataSource(f) creates a data source backed by CSV
            %  files in the folder f.
            
            % Check
            assert( exist( folder, 'dir' ) ~= 0, 'cfc:ItemNotFound', ...
                'Folder ''%s'' not found.', folder )
            
            % Store properties
            obj.Folder = folder;
            
        end % constructor
        
        function [times, values] = getData( obj, startTime, finishTime )
            %getData  Get data
            %
            %  [t,v] = s.getData(ts,tf) gets times t and values v from the
            %  data source s from time ts to time tf.
            
            times = zeros( [0 1] ); % initialize
            values = zeros( [0 1] ); % initialize
            if isnan( startTime ) || isnan( finishTime ), return, end
            for filedate = floor( startTime ):ceil( finishTime - 1 ) % loop
                filename = fullfile( obj.Folder, sprintf( 'data_%s.csv', ...
                    datestr( filedate, 'yyyymmdd' ) ) );
                fprintf( 1, 'Loading %s...', filename );
                try
                    data = obj.load( filename ); % load
                    fprintf( 1, ' done.\n' );
                catch % file not found
                    fprintf( 1, ' failed.\n' );
                    continue
                end
                tf = data.t >= startTime & data.t <= finishTime; % mask
                times = [times; data.t(tf)]; %#ok<AGROW>
                values = [values; data.v(tf)]; %#ok<AGROW>
            end
            
        end % getData
        
        function time = getStartTime( obj )
            %getStartTime  Get start time
            %
            %  ts = s.getStartTime() returns the start time ts for the data
            %  source s.
            
            listings = dir( fullfile( obj.Folder, 'data_*.csv' ) );
            if isempty( listings )
                time = NaN;
                return
            end
            filenames = vertcat( listings.name );
            filedates = datenum( filenames(:,6:13), 'yyyymmdd' );
            [~, i] = min( filedates );
            data = obj.load( fullfile( obj.Folder, filenames(i,:) ) );
            time = min( data.t );
            
        end % getStartTime
        
        function time = getFinishTime( obj )
            %getFinishTime  Get finish time
            %
            %  ts = s.getFinishTime() returns the finish time tf for the
            %  data source s.
            
            listings = dir( fullfile( obj.Folder, 'data_*.csv' ) );
            if isempty( listings )
                time = NaN;
                return
            end
            filenames = vertcat( listings.name );
            filedates = datenum( filenames(:,6:13), 'yyyymmdd' );
            [~, i] = max( filedates );
            data = obj.load( fullfile( obj.Folder, filenames(i,:) ) );
            time = max( data.t );
            
        end % getFinishTime
        
    end % methods
    
    methods( Access = private )
        
        function data = load( ~, filename )
            %load  Load data
            %
            %  d = s.load(f) loads data from the filename f and returns a
            %  structure with fields t and v.
            
            f = fopen( filename, 'r' );
            o = textscan( f, '%4f%2f%2f%2f%2f%2f%f', 'Delimiter', ',T' );
            data = struct( 't', datenum( [o{1:6}] ), 'v', o{7} );
            fclose( f );
            
        end % load
        
    end % helpers
    
end % classdef