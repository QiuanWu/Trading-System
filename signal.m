function [S] = signal(Data, Strategy, varargin)
% INPUT Data is the bar data(a struct object including close, open, high, low, volume, dateTime)
% 
% INPUT Strategy is the strategy to calculate the signal(a char object like
% 'MA', 'FastStochastic', 'SlowStochastic', 'BollingerBand')


switch Strategy

    case 'MA'
        
        ShortWindow = varargin{1};
        LongWindow = varargin{2};
        MA1 = movmean(Data.close, ShortWindow, 'Endpoints', 'discard'); 
        MA2 = movmean(Data.close, LongWindow, 'Endpoints', 'discard');
        MA1 = MA1((end-1):end); 
        MA2 = MA2((end-1):end);

        S = 0; 
        if (MA1(1) < MA2(1)) && (MA1(2) > MA2(2))
            S = 1; %up crossing
        elseif (MA1(1) > MA2(1)) && (MA1(2) < MA2(2))
            S = -1;
        end

    case 'FastStochastic'
        
        Window = varargin{1};
        Fast = Stochastic_Oscillator(Data, Window, 'Fast');

        S = 0;
        if (Fast(end-1) < 0.2) && (Fast(end) > 0.2)
            S = 1;
        elseif (Fast(end-1) > 0.8) && (Fast(end) < 0.8)
            S = -1;
        end

    case 'SlowStochastic'
        
        Window = varargin{1};
        Slow = Stochastic_Oscillator(Data, Window);

        S = 0;
        if (Slow(end-1) < 0.2) && (Slow(end) > 0.2)
            S = 1;
        elseif (Slow(end-1) > 0.8) && (Slow(end) < 0.8)
            S = -1;
        end

    case 'BollingerBand'

        TP = (Data.close+Data.high+Data.low)/3;
        n = varargin{1};
        m = varargin{2};
        BOLU = mean(TP((end-n+1):end)) + m*std(TP((end-n+1):end));
        BOLD = mean(TP((end-n+1):end)) - m*std(TP((end-n+1):end));

        S = 0;
        if (Data.close(end) > BOLU)
            S = -1;
        elseif (Data.close(end) < BOLD)
            S = 1;
        end

end
    
end