function Output = aspen_run_sim(Aspen,Input)
Carb_Pres = Input(1);
Turb_Pres = Input(2);
Aspen.Tree.FindNode("\Data\Blocks\CARB\Input\PRES").Value = Carb_Pres;
Aspen.Tree.FindNode("\Data\Blocks\M-TURB\Input\PRES").Value = Turb_Pres;
Aspen.Reinit; % Reinit simulation
Aspen.Engine.Run2(0); %Run the simulation. (1) ---> Matlab isnt busy; (0) Matlab is Busy;
Output = Aspen.Tree.FindNode("\Data\EO Configuration\Objective\EFF\Output\FINAL_VAL1").Value;
disp(Input)
disp(Output)
end