function patientParameters= loadPatientParameter(patientID)

patientsFolder=fullfile('Sources','Simulation','Patients');
tmp=load(fullfile(patientsFolder,[patientID, '.mat']));
patientParameters=tmp.patientParameters;