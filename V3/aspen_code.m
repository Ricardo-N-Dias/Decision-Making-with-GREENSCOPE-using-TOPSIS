clc
clear

%% Linking

Aspen = actxserver('Apwn.Document.37.0'); %34.0 ---> V8.8; 35.0 ---> V9.0; and 36.0 ---> V10.0
[stat,mess]=fileattrib; % get attributes of folder (Necessary to establish the location of the simulation)
Simulation_Name = 'Simulation 1';% Aspeen Plus Simulation Name
Aspen.invoke('InitFromArchive2',[mess.Name '\' Simulation_Name '.bkp']);
Aspen.Visible = 1; % 1 ---> Aspen is Visible; 0 ---> Aspen is open but not visible
Aspen.SuppressDialogs = 1; % Suppress windows dialogs.
Aspen.Tree.FindNode("\Data\Setup\Sim-Options\Input\PARADIGM").Value = "SM";
Aspen.Reinit; % Reinit simulation
Aspen.Engine.Run2(0); %Run the simulation. (1) ---> Matlab isnt busy; (0) Matlab is Busy;
Aspen.Tree.FindNode("\Data\Setup\Sim-Options\Input\PARADIGM").Value = "EO";
% Aspen.Tree.FindNode("\Data\Streams\1\Output\TEMP_OUT\MIXED").Value

streams_solid = ["FRESH" "SPURGE-1" "SPURGE-2"];
streams_mixed = ["H2O0" "GPURGE"];

equipment_strings.pump = ["P1"	"H-COMP2"	"COMP3"	"M-COMD"	"H-COMP1"	"M-COMD2"	"M-COMD1"	"COMP1"	"M-COMP2"	"H-COMP4"	"M-COMP1"	"H-COMP3"	"M-COMP"	"H-COMP"	"COMP2"	"H-TURB"	"M-TURB"	"H-TURB2"	"H-TURB1"	"ST"];
if equipment_strings.pump ~= ""
    %Pump/comp power starst at 1=E30
    for j = 1:length(equipment_strings.pump)
        call.pump(j) = "\Data\Blocks\" + equipment_strings.pump(j) + "\Output\BRAKE_POWER";
        nodes.equipmentenergy.pump(j) = Aspen.Tree.FindNode(call.pump(j)).Value/1000;
    end
end

equipment_strings.distilation = [""];
if equipment_strings.distilation ~= ""
    %Distilation columns condenser heat starts at E44, reboiler E45
    for j = 1:length(equipment_strings.distilation)
        call.distilation(j) = "\Data\Blocks\" + equipment_strings.distilation(j) + "\Output\QCALC";
        nodes.equipmentenergy.distilation(j) = Aspen.Tree.FindNode(call.distilation(j)).Value/1000;
    end
end

equipment_strings.HE = ["C-1"	"C-2"	"C-2B"	"C-3"	"CCH2O"	"CF4"	"COND"	"CSPURGE"	"H-1"	"H-COMPC1"	"H-COMPC2"	"H-COMPC3"	"H-COMPC4"	"H-TURBH1"	"H-TURBH2"	"M-COMDC1"	"M-COMDC2"	"M-COMPC1"	];
if equipment_strings.HE ~= ""
    for i = 1:length(equipment_strings.HE)
        equipment.HE(i) = equipment_strings.HE(i) + "\Output\QCALC";
    end
    %                1
    %Heat exchangers heat starts at E60
    for j = 1:length(equipment.HE)
        call.HE(j) = "\Data\Blocks\" + equipment.HE(j);
        nodes.equipmentenergy.HE(j) = Aspen.Tree.FindNode(call.HE(j)).Value/1000;
    end
end

equipment_strings.extractor = [""];
if equipment_strings.extractor ~= ""
    equipment.extractor = [""];
    %
    %Extractors, heat E75, power E76
    for j = 1:length(equipment.extractor)
        call.extractor(j) = "\Data\Blocks\" + equipment.extractor(j);
        nodes.equipmentenergy.extractor(j) = Aspen.Tree.FindNode(call.extractor(j)).Value/1000;
    end
end

equipment_strings.separator = [""];
if equipment_strings.separator ~= ""
    equipment.separator = [""]; %don't have energy consumption
    %
    %Separator, heat E90, power E91
    for j = 1:length(equipment.separator)
        call.separator(j) = "\Data\Blocks\" + equipment.separator(j);
        nodes.equipmentenergy.separator(j) = Aspen.Tree.FindNode(call.separator(j)).Value/1000;
    end
end

equipment_strings.reactor = ["CALC CARB"];
if equipment_strings.reactor ~= ""
    equipment.reactor = ["CALC\Output\QCALC"	"CARB\Output\QCALC"];
    %                    1                       2
    %Reactor, heat E105, power E106
    for j = 1:length(equipment.reactor)
        call.reactor(j) = "\Data\Blocks\" + equipment.reactor(j);
        nodes.equipmentenergy.reactor(1,j) = Aspen.Tree.FindNode(call.reactor(j)).Value/1000;
        nodes.equipmentenergy.reactor(2,1) = 1145.2*1756.59;
        nodes.equipmentenergy.reactor(2,2) = 589.663*585.53;
    end
end

equipment_strings.other = ["M-COMPC2" "M-COMPC2" "CF1"	"CF2"	"CF3"	"CONEVAP1"	"CONEVAP2"	"CONEVAP3"	"GS-HE1"	"GS-HE2"	"GS-HE3"	"HCO2"	"HF1"	"HF2"	"HF3"	"HRSG"	"HXG"	"ICOOL1"	"ICOOL2"	"ICOOL3"];
equipment.other(1) = "M-COMPC2\Output\QCALC";
equipment.other(2) = "M-COMPC2\Output\QCALC";
if equipment_strings.other ~= ""
    for i = 3:length(equipment_strings.other)
        equipment.other(i) = equipment_strings.other(i) + "\Output\QCALC";
    end
    %
    %Heat E121,Power E122
    for j = 1:length(equipment.other)
        call.other(j) = "\Data\Blocks\" + equipment.other(j);
        if j <3
            nodes.equipmentenergy.other(j) = Aspen.Tree.FindNode(call.other(j)).Value/1000;
        else
            nodes.equipmentenergy.other(j) = 0;
        end
    end
end

names_solid = ["TEMP_OUT\CISOLID" "PRES_OUT\CISOLID" "VFRAC_OUT\CISOLID" "HMX_FLOW\CISOLID" "SMX_MASS\CISOLID" "MASSFLMX\CISOLID" "VOLFLMX\CISOLID" "MASSFLOW\CISOLID\CARBO-01" "MASSFLOW\CISOLID\WATER" "MASSFLOW\CISOLID\CALCI-01" "MASSFLOW\CISOLID\CALCI-02"];
names_mixed = ["TEMP_OUT\MIXED" "PRES_OUT\MIXED" "VFRAC_OUT\MIXED" "HMX_FLOW\MIXED" "SMX_MASS\MIXED" "MASSFLMX\MIXED" "VOLFLMX\MIXED" "MASSFLOW\MIXED\CARBO-01" "MASSFLOW\MIXED\WATER" "MASSFLOW\MIXED\CALCI-01" "MASSFLOW\MIXED\CALCI-02"];
call_solids = strings(length(names_solid),length(streams_solid));
call_mixed  = strings(length(names_solid),length(streams_mixed));
% call = strings(1,length(equipment));

for j =1:length(streams_solid)
    for i = 1:length(names_solid)
        call_solids(i,j) = "\Data\Streams\" + string(streams_solid(j)) +  "\Output\" + names_solid(i);
        nodes.data(i,j)  = Aspen.Tree.FindNode(call_solids(i,j)).Value;
    end
end

for j =1:length(streams_mixed)
    for i = 1:length(names_mixed)
        call_mixed(i,j) = "\Data\Streams\" + string(streams_mixed(j)) +  "\Output\" + names_mixed(i);
        nodes.data(i,(j+length(streams_solid)))  = Aspen.Tree.FindNode(call_mixed(i,j)).Value;
    end
end

Aspen.Close;
Aspen.Quit;
clear Aspen

%% Import Economic data
filename      = "C:\Users\rikoa\OneDrive - Universidade de Lisboa\SoCaLTES_task5\Matlab\LCA analysis\V3\V3.xlsx";
[A,B]=xlsread(filename);
c=A(20:131,1:2);
e=B(21:132);
%PUMP
if equipment_strings.pump ~= ""
    for i = 1:length(equipment_strings.pump)
        logic.pump        = ismember(e,equipment_strings.pump(i));
        if sum(logic.pump) == 0
            economic.pump(1,i) = cellstr(equipment_strings.pump(i));
            economic.pump(2,i) = num2cell(0);
            economic.pump(3,i) = num2cell(0);
        else
            economic.pump(1,i) = e(logic.pump);
            economic.pump(2,i) = num2cell(c(logic.pump,1));
            economic.pump(3,i) = num2cell(c(logic.pump,2));
        end
    end
end

%Distilation
if equipment_strings.distilation ~= ""
    for i = 1:length(equipment_strings.distilation)
        logic.distilation        = ismember(e,equipment_strings.distilation(i));
        if sum(logic.distilation) == 0
            economic.distilation(1,i) = cellstr(equipment_strings.distilation(i));
            economic.distilatoin(2,i) = num2cell(0);
            economic.distilation(3,i) = num2cell(0);
        else
            economic.distilation(1,i) = e(logic.distilation);
            economic.distilation(2,i) = num2cell(c(logic.distilation,1));
            economic.distilation(3,i) = num2cell(c(logic.distilation,2));
        end
    end
end

%Heat exchangers
if equipment_strings.HE ~= ""
    for i = 1:length(equipment_strings.HE)
        logic.HE        = ismember(e,equipment_strings.HE(i));
        if sum(logic.HE) == 0
            economic.HE(1,i) = cellstr(equipment_strings.HE(i));
            economic.HE(2,i) = num2cell(0);
            economic.HE(3,i) = num2cell(0);
        else
            economic.HE(1,i) = e(logic.HE);
            economic.HE(2,i) = num2cell(c(logic.HE,1));
            economic.HE(3,i) = num2cell(c(logic.HE,2));
        end
    end
end

%Extractors
if equipment_strings.extractor ~= ""
    for i = 1:length(equipment_strings.extractor)
        logic.extractor        = ismember(e,equipment_strings.extractor(i));
        if sum(logic.extractor) == 0
            economic.extractor(1,i) = cellstr(equipment_strings.extractor(i));
            economic.extractor(2,i) = num2cell(0);
            economic.extractor(3,i) = num2cell(0);
        else
            economic.extractor(1,i) = e(logic.extractor);
            economic.extractor(2,i) = num2cell(c(logic.extractor,1));
            economic.extractor(3,i) = num2cell(c(logic.extractor,2));
        end
    end
end

%Separator
if equipment_strings.separator ~= ""
    for i = 1:length(equipment_strings.separator)
        logic.separator        = ismember(e,equipment_strings.separator(i));
        if sum(logic.separator) == 0
            economic.separator(1,i) = cellstr(equipment_strings.separator(i));
            economic.separator(2,i) = num2cell(0);
            economic.separator(3,i) = num2cell(0);
        else
            economic.separator(1,i)  = e(logic.separator);
            economic.separator(2,i)= num2cell(c(logic.separator,1));
            economic.separator(3,i)= num2cell(c(logic.separator,2));
        end
    end
end

%Reactor
if equipment_strings.reactor ~= ""
    for i = 1:length(equipment_strings.reactor)
        logic.reactor        = ismember(e,equipment_strings.reactor(i));
        if sum(logic.reactor) == 0
            economic.reactor(1,i) = cellstr(equipment_strings.reactor(i));
            economic.reactor(2,i) = num2cell(0);
            economic.reactor(3,i) = num2cell(0);
        else
            economic.reactor(1,i) = e(logic.reactor);
            economic.reactor(2,i) = num2cell(c(logic.reactor,1));
            economic.reactor(3,i) = num2cell(c(logic.reactor,2));
        end
    end
end

%Other
if equipment_strings.other ~= ""
    for i = 1:length(equipment_strings.other)
        logic.other        = ismember(e,equipment_strings.other(i));
        if sum(logic.other) == 0
            economic.other(1,i) = cellstr(equipment_strings.other(i));
            economic.other(2,i) = num2cell(0);
            economic.other(3,i) = num2cell(0);
        else
            economic.other(1,i) = e(logic.other);
            economic.other(2,i) = num2cell(c(logic.other,1));
            economic.other(3,i) = num2cell(c(logic.other,2));
        end
    end
end

clear filename
%%

nodes.data(4,:)    = nodes.data(4,:)/1000;
nodes.data(5,:)    = nodes.data(5,:).*nodes.data(6,:)/1000000;
nodes.data(4,4)    = nodes.data(4,4)*0.02;
nodes.data(7,4)    = nodes.data(7,4)*0.02;
nodes.data(8:11,4) = nodes.data(8:11,4)*0.02;
nodes.data(:,6)    = nodes.data(:,4);

Number_of_Inlet_streams  = 2;
Number_of_Outlet_streams = 4;

test = equipment_strings.pump;
test = cellstr(test);
test(2,:) = num2cell(nodes.equipmentenergy.pump);
test(3,[1,2,4,5,6,7,9,10,11,12,13,14,17,20]) = num2cell(nodes.equipmentenergy.pump([1,2,4,5,6,7,9,10,11,12,13,14,17,20]));
test(4,[9,11,13,16,17,18,19]) = num2cell(nodes.equipmentenergy.pump([9,11,13,16,17,18,19]).*2);

total_energy = sum(cell2mat(test(3,:))) + sum(cell2mat(test(4,:)));

save("V3.mat")
% filename      = "C:\Users\RDias\OneDrive - Universidade de Lisboa\SoCaLTES_task5\GREENSCOPE\CaL\GRNS SoCaLTES - V7.xlsm";
% sheets = sheetnames(filename);
% 
% writematrix(nodes.data(8:11,1),filename,'Sheet',sheets(1),'Range','H32')   %INPUT STREAM
% writematrix(nodes.data(8:11,4),filename,'Sheet',sheets(1),'Range','K32')   %INPUT STREAM
% 
% writematrix(nodes.data(1:5,1),filename,'Sheet',sheets(1),'Range','H83')    %INPUT DATA
% writematrix(nodes.data(1:5,4),filename,'Sheet',sheets(1),'Range','K83')    %INPUT DATA
% 
% writematrix(nodes.data(8:11,2 ),filename,'Sheet',sheets(1),'Range','H186') %OUTPUT STREAM
% writematrix(nodes.data(8:11,3 ),filename,'Sheet',sheets(1),'Range','K186') %OUTPUT STREAM
% writematrix(nodes.data(8:11,5 ),filename,'Sheet',sheets(1),'Range','N186') %OUTPUT STREAM
% writematrix(nodes.data(8:11,6 ),filename,'Sheet',sheets(1),'Range','Q186') %OUTPUT STREAM
% 
% writematrix(nodes.data(1:5,2 ),filename,'Sheet',sheets(1),'Range','H237')  %OUTPUT DATA
% writematrix(nodes.data(1:5,3 ),filename,'Sheet',sheets(1),'Range','K237')  %OUTPUT DATA
% writematrix(nodes.data(1:5,5 ),filename,'Sheet',sheets(1),'Range','N237')  %OUTPUT DATA
% writematrix(nodes.data(1:5,6 ),filename,'Sheet',sheets(1),'Range','Q237')  %OUTPUT DATA
% 
% writematrix(nodes.data(7,2 ),filename,'Sheet',sheets(1),'Range','H243')    %OUTPUT VOL FLOW
% writematrix(nodes.data(7,3 ),filename,'Sheet',sheets(1),'Range','K243')    %OUTPUT VOL FLOW
% writematrix(nodes.data(7,5 ),filename,'Sheet',sheets(1),'Range','N243')    %OUTPUT VOL FLOW
% writematrix(nodes.data(7,6 ),filename,'Sheet',sheets(1),'Range','Q243')    %OUTPUT VOL FLOW
% 
% 
% % writematrix(nodes.equipmentenergy(1,[8:9,16:19]),filename,'Sheet',sheets(2),'Range','E15')      %MIXERS
% writematrix(nodes.equipmentenergy.pump,filename,'Sheet',sheets(2),'Range','E30')                %PUMPS/COMPRESSORS
% writematrix(string(economic.pump(1,:)),filename,'Sheet',sheets(2),'Range','E26')                %PUMPS/COMPRESSORS - Equipment name
% writematrix(string(economic.pump(2,:)),filename,'Sheet',sheets(2),'Range','E31')                %PUMPS/COMPRESSORS - COST
% writematrix(string(economic.pump(3,:)),filename,'Sheet',sheets(2),'Range','E32')                %PUMPS/COMPRESSORS - INSTALLED COST
% %DISTILLATION
% % writematrix(nodes.equipmentenergy(1,[2,4,6]),    filename,'Sheet',sheets(2),'Range','E44')      %CONDENSERS
% % writematrix(nodes.equipmentenergy(1,[3,5,7]),    filename,'Sheet',sheets(2),'Range','E45')      %REBOILERS
% writematrix(nodes.equipmentenergy.HE,filename,'Sheet',sheets(2),'Range','E60')                  %HEAT EXHANGERS
% writematrix(string(economic.HE(1,:)),filename,'Sheet',sheets(2),'Range','E56')                  %HEAT EXHANGERS - Equipment name
% writematrix(string(economic.HE(1,:)),filename,'Sheet',sheets(2),'Range','E57')                  %HEAT EXHANGERS - Equipment name
% writematrix(string(economic.HE(2,:)),filename,'Sheet',sheets(2),'Range','E62')                  %HEAT EXHANGERS - COST
% writematrix(string(economic.HE(3,:)),filename,'Sheet',sheets(2),'Range','E63')                  %HEAT EXHANGERS - INSTALLED COST
% % writematrix(nodes.equipmentenergy(1,[1,21,22]),  filename,'Sheet',sheets(2),'Range','E75')      %EXTRACTORS(HEAT)
% % writematrix(nodes.equipmentenergy(1,[1,21,22]),  filename,'Sheet',sheets(2),'Range','E76')      %EXTRACTORS(POWER)
% % writematrix(nodes.equipmentenergy.separator(1,:),  filename,'Sheet',sheets(2),'Range','E90')    %SEPARATORS(HEAT)
% % writematrix(string(economic.separator(1,:)),     filename,'Sheet',sheets(2),'Range','E87')      %SEPARATORS - Equipment name
% % writematrix(string(economic.separator(2,:)),     filename,'Sheet',sheets(2),'Range','E92')      %SEPARATORS - COST
% % writematrix(string(economic.separator(3,:)),     filename,'Sheet',sheets(2),'Range','E93')      %SEPARATORS - INSTALLED COST
% % writematrix(nodes.equipmentenergy.separator(2,:),filename,'Sheet',sheets(2),'Range','E91')      %SEPARATORS(POWER)
% writematrix(nodes.equipmentenergy.reactor(1,:),filename,'Sheet',sheets(2),'Range','E105')       %REACTOR (HEAT)
% writematrix(nodes.equipmentenergy.reactor(2,:),filename,'Sheet',sheets(2),'Range','E107')       %REACTOR (Enthalpy)
% writematrix(string(economic.reactor(1,:)),     filename,'Sheet',sheets(2),'Range','E102')       %REACTOR - Equipment name
% writematrix(string(economic.reactor(2,:)),     filename,'Sheet',sheets(2),'Range','E108')       %REACTOR - COST
% writematrix(string(economic.reactor(3,:)),     filename,'Sheet',sheets(2),'Range','E109')       %REACTOR - INSTALLED COST
% writematrix(nodes.equipmentenergy.other(1,:),filename,'Sheet',sheets(2),'Range','E121')         %OTHER(HEAT)
% % writematrix(nodes.equipmentenergy.other(2,:),filename,'Sheet',sheets(2),'Range','E122')         %OTHER(POWER)
% writematrix(string(economic.other(1,:)),     filename,'Sheet',sheets(2),'Range','E118')       %REACTOR - Equipment name
% writematrix(string(economic.other(2,:)),     filename,'Sheet',sheets(2),'Range','E123')       %REACTOR - COST
% writematrix(string(economic.other(3,:)),     filename,'Sheet',sheets(2),'Range','E124')       %REACTOR - INSTALLED COST
