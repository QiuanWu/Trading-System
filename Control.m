% Timer Parameters
t = timer;
t.Name = 'TradingSystem';
t.Period = 5;
t.StartDelay = 100; 

t.StartFcn = {@TradeStart, ticker};

t.TimerFcn = {@Trade, ticker};

t.StopFcn = @(~,thisEvent) disp(['The Trading System Stops at ',...
                 datestr(thisEvent.Data.time, 'dd-mmm-yyyy HH:MM:SS.FFF')]);

t.ExecutionMode = 'fixedRate';
t.TaskstoExecute = 5000;

%% Check and Start the system

checkSecType = @(x) any(validatestring(x, {'STK', 'FUT'}));
checkStrategy = @(x) any(validatestring(x, {'MA', 'FastStochastic', 'SlowStochastic', 'BollingerBand'}));

if checkSecType(TSystem.tradingobject.(ticker).SecType) && checkStrategy(TSystem.tradingobject.(ticker).strategy.Name)
    start(t);
end
