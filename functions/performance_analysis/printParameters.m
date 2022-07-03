function printParameters(simData)
pars = fields(simData.Sweep);
for i = 1:length(pars)
    value = simData.Sweep.(pars{i});
    if isa(value,"double")
        formatter = "%g";
    elseif isa(value,"string")
        formatter = "%s";
    else
        value = value{1};
        formatter = strjoin(strcat("[",repmat("%g",[1,size(value,2)]),"]"));
    end
    
    fprintf("\t%s: ",pars{i});
    fprintf(formatter,value);
    fprintf("\n");
end

end