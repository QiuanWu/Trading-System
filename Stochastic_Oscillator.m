function y = Stochastic_Oscillator(Data, Window, Type)
    
    % allocate the memory
    C = zeros(length(Data.close)-Window+1,1);
    H = zeros(length(C),1);
    L = zeros(length(C),1);
    
    y = zeros(length(C),1);

    % calculate the %K
    for i = 1:length(C)
        C(i) = Data.close(Window+i-1);
        H(i) = max(Data.high(i:Window+i-1));
        L(i) = min(Data.low(i:Window+i-1));
    
        y(i) = (C(i)-H(i))/(H(i)-L(i));
    end
    
    % calculate the 3-period moving average if Type == Fast
    if (nargin == 3) && strcmp(Type, 'Fast')
        y = movmean(y, 3, 'Endpoints', 'Disgard');
    end
       
end