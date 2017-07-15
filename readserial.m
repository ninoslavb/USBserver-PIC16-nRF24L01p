%% Create serial object for Arduino
clc;
clear all;
s = serial('COM12','BaudRate',1200); % change the COM Port number as needed
%% Connect the serial port to Arduino
s.InputBufferSize = 4; % read only one byte every time
s.Terminator = 13;
try
    fopen(s);
catch err
    fclose(instrfind);
    error('Make sure you select the correct COM Port where the Arduino is connected.');
end
%% Create a figure window to monitor the live data
Tmax = 7200; % Total time for data collection (s)
%figure,
%grid on,
%xlabel ('Time (s)'), ylabel('Data (16-bit)'),
%axis([0 Tmax+1 0 40]),
%% Read and plot the data from Arduino
Ts = 0.05; % Sampling time (s)
i = 0;
j = 0;
tic % Start timer

while toc <= Tmax    
    %% Read buffer data
    out = fgetl(s);
    flushinput(s);
    if numel(out) == 3
        int8(out(1))
        int8(out(2))
        int8(out(3))
        if int8(out(3)) == 3                  
            i = i + 1;        
            res1 = dec2hex(int8(out(2)));
            if numel(res1) == 1
                res1 = strcat('0',res1);
            end        
            res2 = dec2hex(int8(out(1)));
            if numel(res2) == 1
                res2 = strcat('0',res2);
            end
            result = strcat(res1,res2);
            disp(result);
            temp_raw = hex2dec(result);
            temp(i) = (temp_raw/65536)*165 - 40;
            t(i) = toc;
            disp(temp(i));           
        elseif int8(out(3)) == 2
             j = j+1;
            dpir(j) = 1;
            tpir(j) = toc;
           
        end
            
           
       
    end
     
end

fclose(s);

%% plot TEMP
dp{1} = temp;
tp{1} = t;
name{1} = 'Temperatura sobe';
figname = 'temp_room';
current_vs_time = plot2D;
current_vs_time.x_data = tp;
current_vs_time.y_data = dp;
current_vs_time.x_label = 'vrijeme [s]';
current_vs_time.y_label = 'temperatura [C]';
current_vs_time.y_max = 40;
current_vs_time.y_min = 0;
current_vs_time.x_min = 0;
current_vs_time.name = name;
%current_vs_time.x_min = ;
current_vs_time.plot;

%% PLOT PIR
dpp{1} = dpir;
tpp{1} = tpir;
name{1}='PIR';
figname = 'PIR';
current_vs_time = plot2DMARK;
current_vs_time.x_data = tpp;
current_vs_time.y_data = dpp;
current_vs_time.x_label = 'vrijeme [s]';
current_vs_time.y_label = 'Detekcija pokreta = 1';
current_vs_time.y_max = 1.2;
current_vs_time.y_min = 0;
current_vs_time.x_min = 0;
current_vs_time.name = name;
%current_vs_time.x_min = ;
current_vs_time.plot;



    
    %disp(data(end));
    %% Read time stamp
    % If reading faster than sampling rate, force sampling time.
    % If reading slower than sampling rate, nothing can be done. Consider
    % decreasing the set sampling time Ts
%    t(i) = toc;
%    if i > 1
%        T = toc - t(i-1);
%        while T < Ts
%            T = toc - t(i-1);
%        end
%    end
    
    %% Plot live data
    %if i > 10
    %    line([t(i-1) t(i)],[data_rear(i-1) data_rear(i)])
    %    drawnow
    %end
%end
