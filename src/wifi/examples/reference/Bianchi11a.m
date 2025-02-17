% Copyright 2020 University of Washington
%
% SPDX-License-Identifier: BSD-3-Clause
%
% Co-authored by Leonardo Lanante, Hao Yin, and Sebastien Deronne

function [bianchi_result] = Bianchi11a(data_rate, ack_rate, difs)
nA = [5:5:50];
CWmin = 15;
CWmax = 1023;
L_DATA = 1500 * 8; % data size in bits
L_ACK = 14 * 8; % ACK size in bits
B = 1/(CWmin+1);
EP = L_DATA/(1-B);
T_GI = 800e-9; % guard interval in seconds
T_SYMBOL = 3.2e-6 + T_GI; % symbol duration in seconds
T_LPHY = 20e-6; % PHY preamble & header duration in seconds
L_SERVICE = 16; % service field length in bits
L_TAIL = 6; % tail length in bits
L_MAC = (24 + 4) * 8; % MAC header size in bits
L_APP_HDR = 8 * 6; % bits added by the upper layer(s)
T_SIFS = 16e-6;
T_DIFS = 34e-6;
T_SLOT = 9e-6;
delta = 1e-7;

N_DBPS = data_rate * T_SYMBOL; % number of data bits per OFDM symbol
N_SYMBOLS = ceil((L_SERVICE + L_MAC + L_DATA + L_APP_HDR + L_TAIL)/N_DBPS);
T_DATA = T_LPHY + (T_SYMBOL * N_SYMBOLS);

N_DBPS = ack_rate * T_SYMBOL; % number of data bits per OFDM symbol
N_SYMBOLS = ceil((L_SERVICE + L_ACK + L_TAIL)/N_DBPS);
T_ACK = T_LPHY + (T_SYMBOL * N_SYMBOLS);

T_s = T_DATA + T_SIFS + T_ACK + T_DIFS;
if difs == 1 %DIFS
    T_C = T_DATA + T_DIFS;
else %EIFS
    T_s = T_DATA + T_SIFS + T_ACK + T_DIFS + delta;
    T_C = T_DATA + T_DIFS + T_SIFS + T_ACK + delta;
end
T_S = T_s/(1-B) + T_SLOT;
S_bianchi = zeros(size(nA));
for j = 1:length(nA)
    n = nA(j)*1;
    W = CWmin + 1;
    m = log2((CWmax + 1)/(CWmin + 1));
    tau1 = linspace(0, 1, 1e4);
    p = 1 - (1 - tau1).^(n - 1);
    ps = p*0;

    for i = 0:m-1
        ps = ps + (2*p).^i;
    end
    taup = 2./(1 + W + p.*W.*ps);
    [a,b] = min(abs(tau1 - taup));
    tau = taup(b);

    Ptr = 1 - (1 - tau)^n;
    Ps = n*tau*(1 - tau)^(n - 1)/Ptr;

    S_bianchi(j) = Ps*Ptr*EP/((1-Ptr)*T_SLOT+Ptr*Ps*T_S+Ptr*(1-Ps)*T_C)/1e6;
end

bianchi_result = S_bianchi;
