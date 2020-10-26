%% Account and Trading Parameters 
% we construct the struct object to save different part of trading information

ticker = 'ESM0';
TObject.(ticker) = struct('symbol', ticker); 
TObject.(ticker).SecType = 'FUT';
TObject.(ticker).exchange = 'Globex';
TObject.(ticker).LocalOrNot = 'localSymbol';
TObject.(ticker).PriceType = 'LMT';
if strcmp(TObject.(ticker).SecType,'FUT')
    TObject.(ticker).PricePremium = 0.25;
elseif strcmp(TObject.(ticker).SecType,'SKT')
    TObject.(ticker).PricePremium = 0.01;
end




%%  Strategy status and record
Strategy.Name = 'MA';
Strategy.ShortWindow = 4;
Strategy.LongWindow = 14;
TObject.(ticker).strategy = Strategy;
%Strategy.n = 14; % parameters for BollingerBand Strategy
%Strategy.m = 3; 

global TSystem;
TSystem.TradingType = 'Paper';
TSystem.tradingobject = TObject;
TSystem.QuotesNumber = inf;
TSystem.QuotesBufferSize = 5000; % Decide the maximum number of bar data you can save in the steam
TSystem.MaxPosition.(ticker) = 10;
TSystem.TradingShare.(ticker) = 1;

TSystem.PositionStatus.(ticker) = 0;
TSystem.CurrentTime.(ticker) = 1;
TSystem.PositionChange.(ticker)  = zeros(5000, 1); % number
TSystem.PositionValue.(ticker) = zeros(5000, 1); % value
TSystem.ExcutionValue.(ticker) = zeros(5000, 1); % 
TSystem.CashValue = 100000;
TSystem.PL.(ticker) = zeros(5000, 1);


