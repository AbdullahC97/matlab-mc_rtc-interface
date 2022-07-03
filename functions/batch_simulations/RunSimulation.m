function status = RunSimulation(simSettings)

if nargin < 1
	simSettings.verbose = true;
	simSettings.logController = false;
end



%% Starting Commands
ctlcommand1 = "cd ; cd devel/time-invariant-dual-arm-panda-controller/build/";
ctlcommand2 = "sudo make install; mc_click";
ctlcommand = strcat(ctlcommand1,"&& ",ctlcommand2);

agxcommand1 = "cd ; cd devel/urdf-application/PythonApplication/";
agxcommand2 = "sudo ../run-in-docker.sh examples/agx.sh models/DualPandaFootGrab.yml:DualPandaGrabBoxClick &";
agxcommand = strcat(agxcommand1,"; ",agxcommand2);

killcommand = "sudo kill $(pgrep containerd-shim)";

%% Start Simulation
try
    [returncode, output] = system(killcommand); % Kill AGX first if it was still active
    if simSettings.verbose
        fprintf("Starting AGX + CONTROLLER:\n")
        fprintf("\tStarting AGX:")
        [returncode, output] = system(agxcommand);
        fprintf(" --> DONE\n")

        fprintf("\tStarting Controller:")
        if simSettings.logController
            [returncode, output] = system(ctlcommand);
            fprintf("\n\tController --> FINISHED\n")
        else
            [returncode, output] = system(ctlcommand);
            fprintf(" --> DONE\n")
        end
        
        fprintf("\tTerminating AGX:")
        [returncode, output] = system(killcommand);
        fprintf(" --> DONE\n")

        fprintf("Simulation DONE!\n")

    else
        [returncode, output] = system(agxcommand);
        [returncode, output] = system(ctlcommand);
        [returncode, output] = system(killcommand);

    end

    status = true;
catch
    fprintf("Simulation FAILED!\n")
    status = false;
end


end

