% pgit.m: iterative control of PGtest
% Usage: [PulseGenOutputMatrix, TimeMatrix, Stimulus] = PGit
% Note: This function calls PGtest1, which is (or should be) the same as PGtest,
% except that PGtest1 is set up to get its settings from this function, whereas
% PGtest is meant to be used interactively from the model window.

function  [PGmat,tmat,stm]=PGit()

if nargout == 0
  help pgit
  return
end

% SIMULINK's simulation parameters
tstart = 0.0;
tfinal = 0.5;
minstep = 0.001;
maxstep = 0.001;
tol = 1e-3;

% input pulse parameters
stepat  = 0.1;
stepdur = 0.2;

disp(['Step at ' num2str(stepat*100) ' ms.'])
disp(['Step of ' num2str(stepdur*100) ' ms.'])

peakArray = [0.5 1 2 5 10 15 20];
PGmat = NaN*ones(500,length(peakArray));
tmat = PGmat;

for i = 1:length(peakArray)
   disp(['Testing with step of ' num2str(peakArray(i)) ' degrees.'])
   peakval = peakArray(i);
   [a,b,c]=rk45('PGtest1',[tstart,tfinal],[],[tol,minstep,maxstep]);
   PGmat(1:length(PGout),i) = PGout;
   tmat(1:length(t),i) = t;
end
disp('PGtest is done')