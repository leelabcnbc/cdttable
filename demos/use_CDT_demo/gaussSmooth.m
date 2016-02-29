function g = gaussSmooth(v,sigma)
 
v = v(:); 

len = 2*round(sigma*4)+1; % filter of 4std width

f = gausswin(len,len/sigma); %create the filter
f = f/sum(f); %normalization so that the filter elements sum to 1

g = conv(v,f); %convolve the vector with the filter
c = cumsum(f); 
% deal with the ends. after padding with zero, need to normalize
g(1:length(c)) = g(1:length(c))./c;
g(end-length(c)+1:end) = g(end-length(c)+1:end) ./ flipud(c);

g = g((len-1)/2+1:end-(len-1)/2); % same length as the passing vector v