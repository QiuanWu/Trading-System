function [] = Trade(src, event, ticker)
%This function finish the main part of the trading system
%Including signal, position check, trade, update the account
global TSystem;
disp(['Retrieve steam bar data from TWS at ',datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);

%  Retrieve steam bar data from TWS 
TObject = TSystem.tradingobject.(ticker);
switch TObject.SecType
    
    case 'FUT'
        
        Data = IBMatlab('action', 'realtime', TObject.LocalOrNot, TObject.symbol,...
            'exchange', TObject.exchange, 'SecType', TObject.SecType, 'QuotesNumber', TObject.RequestID);
        data = IBMatlab('action','query', 'exchange',TObject.exchange, ...
            'secType',TObject.SecType, 'localSymbol',TObject.symbol);
    case 'STK'
        
        Data = IBMatlab('action', 'realtime', TObject.LocalOrNot, TObject.symbol, 'QuotesNumber', TObject.RequestID);
        data = IBMatlab('action','query', 'symbol',TObject.symbol);
end

%  Signal function
Strategy = struct2cell(TObject.strategy);
S = signal(Data.data, Strategy{1}, Strategy{2:end});
    
% position check and trade 
% record the average fill price, fill price, P&L
PriceType = TObject.PriceType;
PricePremium = TObject.PricePremium;
current = TSystem.CurrentTime.(ticker);


%data = IBMatlab('action','query', 'exchange',TObject.exchange, ...
%'secType',TObject.SecType, 'localSymbol',TObject.symbol);
%data = IBMatlab('action','query', 'exchange',TObject.exchange, ...
%TObject.SecType,'FUT', 'localSymbol',TObject.symbol)
midPrice = (data.askPrice + data.bidPrice) / 2;
disp(['the signal is', num2str(S)])

switch S

    case 1

        if (TSystem.PositionStatus.(ticker) < TSystem.MaxPosition.(ticker))
            shares = min(TSystem.MaxPosition.(ticker) - TSystem.PositionStatus.(ticker), TSystem.TradingShare.(ticker));
            if data.bidPrice~=-1
                if strcmp(PriceType, 'LMT')
                    price = data.bidPrice+PricePremium;
                    if strcmp(TSystem.TradingType, 'Real')
                        switch TObject.SecType
                            case 'FUT'
                                orderId = IBMatlab('action','BUY',TObject.LocalOrNot, TObject.symbol,...
                                  'exchange', TObject.exchange, 'SecType', TObject.SecType,...
                                 'quantity', shares, 'type','LMT', 'limitPrice', price);
                            case 'STK'
                                orderId = IBMatlab('action','BUY','symbol',TObject.symbol,...
                                 'quantity', shares, 'type','LMT', 'limitPrice', price);
                        end
                    end
                     disp('LMT')
                elseif strcmp(PriceType, 'MKT')
                    if strcmp(TSystem.TradingType, 'Real')
                        switch TObject.SecType
                            case 'FUT'
                                orderId = IBMatlab('action','BUY',TObject.LocalOrNot, TObject.symbol,...
                                  'exchange', TObject.exchange, 'SecType', TObject.SecType,...
                                 'quantity', shares, 'type','MKT');
                            case 'STK'
                                orderId = IBMatlab('action','BUY','symbol',TObject.symbol,...
                                 'quantity', shares, 'type','MKT');
                        end
                        temp = IBMatlab('action','query','type','executions','OrderId',orderId);
                        price = temp.price;
                    elseif strcmp(TSystem.TradingType, 'Paper')
                        price = data.askPrice;
                    end
                    disp('MKT')
                end
                disp(['Buy ', num2str(shares), ' ', TObject.symbol, ' ', TObject.SecType,...
                    ' at ', num2str(price)]);
                TSystem.PositionStatus.(ticker) = TSystem.PositionStatus.(ticker) + shares;
                TSystem.PositionChange.(ticker)(current) = shares;
                TSystem.PositionValue.(ticker)(current) = TSystem.PositionStatus.(ticker) * midPrice;
                TSystem.CashValue = TSystem.CashValue - shares * price;
                TSystem.ExcutionValue.(ticker)(current) = TSystem.ExcutionValue.(ticker)(max(current-1, 1)) - shares*price;
                TSystem.PL.(ticker)(current) = TSystem.ExcutionValue.(ticker)(current) + TSystem.PositionValue.(ticker)(current);
                TSystem.CurrentTime.(ticker) = TSystem.CurrentTime.(ticker) + 1;
            end
        else
            TSystem.PositionChange.(ticker)(current) = 0;
            TSystem.PositionValue.(ticker)(current) = TSystem.PositionStatus.(ticker) * midPrice;
            TSystem.ExcutionValue.(ticker)(current) = TSystem.ExcutionValue.(ticker)(max(current-1, 1));
            TSystem.PL.(ticker)(current) = TSystem.ExcutionValue.(ticker)(current) + TSystem.PositionValue.(ticker)(current);
            TSystem.CurrentTime.(ticker) = TSystem.CurrentTime.(ticker) + 1;
            disp('Take no action');
        end
             % Record Position and Indicator Position;
    case -1 

        if (TSystem.PositionStatus.(ticker) > -TSystem.MaxPosition.(ticker))
            shares = min(TSystem.MaxPosition.(ticker) + TSystem.PositionStatus.(ticker), TSystem.TradingShare.(ticker));
            if data.askPrice~=-1
                if strcmp(PriceType, 'LMT')
                    price = data.askPrice-PricePremium;
                    if strcmp(TSystem.TradingType, 'Real')
                        switch TObject.SecType
                            case 'FUT'
                                orderId = IBMatlab('action','SELL',TObject.LocalOrNot, TObject.symbol,...
                                  'exchange', TObject.exchange, 'SecType', TObject.SecType,...
                                 'quantity', shares, 'type','LMT', 'limitPrice', price);
                            case 'STK'
                                orderId = IBMatlab('action','SELL','symbol',TObject.symbol,...
                                 'quantity', shares, 'type','LMT', 'limitPrice', price);
                        end
                    end
                     
                elseif strcmp(PriceType, 'MKT')
                    if strcmp(TSystem.TradingType, 'Real')
                        switch TObject.SecType
                            case 'FUT'
                                orderId = IBMatlab('action','SELL',TObject.LocalOrNot, TObject.symbol,...
                                  'exchange', TObject.exchange, 'SecType', TObject.SecType,...
                                 'quantity', shares, 'type','MKT');
                            case 'STK'
                                orderId = IBMatlab('action','SELL','symbol',TObject.symbol,...
                                 'quantity', shares, 'type','MKT');
                        end
                        temp = IBMatlab('action','query','type','executions','OrderId',orderId);
                        price = temp.price;
                    elseif strcmp(TSystem.TradingType, 'Paper')
                        price = data.bidPrice;
                    end
                end
                disp(['Sell ', num2str(shares), ' ', TObject.symbol, ' ', TObject.SecType,...
                    ' at ', num2str(price)]);
                TSystem.PositionStatus.(ticker) = TSystem.PositionStatus.(ticker) - shares;
                TSystem.PositionChange.(ticker)(current) = -shares;
                TSystem.PositionValue.(ticker)(current) = TSystem.PositionStatus.(ticker) * midPrice;
                TSystem.ExcutionValue.(ticker)(current) = TSystem.ExcutionValue.(ticker)(max(current-1, 1)) + shares * price;
                TSystem.CashValue = TSystem.CashValue + shares*price;
                TSystem.PL.(ticker)(current) = TSystem.ExcutionValue.(ticker)(current) + TSystem.PositionValue.(ticker)(current);
                TSystem.CurrentTime.(ticker) = TSystem.CurrentTime.(ticker) + 1;
            end
        else
            TSystem.PositionChange.(ticker)(current) = 0;
            TSystem.PositionValue.(ticker)(current) = TSystem.PositionStatus.(ticker) * midPrice;
            TSystem.ExcutionValue.(ticker)(current) = TSystem.ExcutionValue.(ticker)(max(current-1, 1));
            TSystem.PL.(ticker)(current) = TSystem.ExcutionValue.(ticker)(current) + TSystem.PositionValue.(ticker)(current);
            TSystem.CurrentTime.(ticker) = TSystem.CurrentTime.(ticker) + 1;
            disp('Take no action');
        end
    
    case 0
        TSystem.PositionChange.(ticker)(current) = 0;
        TSystem.PositionValue.(ticker)(current) = TSystem.PositionStatus.(ticker) * midPrice;
        TSystem.ExcutionValue.(ticker)(current) = TSystem.ExcutionValue.(ticker)(max(current-1, 1));
        TSystem.PL.(ticker)(current) = TSystem.ExcutionValue.(ticker)(current) + TSystem.PositionValue.(ticker)(current);
        TSystem.CurrentTime.(ticker) = TSystem.CurrentTime.(ticker) + 1;
        disp('Take no action');
end