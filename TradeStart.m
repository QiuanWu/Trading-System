function [] = TradeStart(src, event, ticker)
%This function starts the trading system, display the system time
%   Detailed explanation goes here
global TSystem;
disp(['The Trading System starts at ',datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
TObject = TSystem.tradingobject.(ticker);

switch TObject.SecType
    
    case 'FUT'
        
        RequestID = IBMatlab('action', 'realtime', TObject.LocalOrNot, TObject.symbol,...
            'exchange', TObject.exchange, 'SecType', TObject.SecType, 'QuotesNumber', TSystem.QuotesNumber,...
            'QuotesBufferSize', TSystem.QuotesBufferSize);
    case 'STK'
        
        RequestID = IBMatlab('action', 'realtime', TObject.LocalOrNot, TObject.symbol,...
            'QuotesNumber', TSystem.QuotesNumber, 'QuotesBufferSize', TSystem.QuotesBufferSize);
    
end
TSystem.tradingobject.(ticker).RequestID = RequestID;

end

