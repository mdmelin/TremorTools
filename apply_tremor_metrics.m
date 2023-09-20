function has_tremor = apply_tremor_metrics(peak_freqs, half_bandwidths)

MIN_TREMOR_FREQ = 3.7;
MAX_TREMOR_FREQ = 10;
MAX_HALF_BANDWIDTH = 2;

assert(length(peak_freqs) == length(half_bandwidths))

for i=1:length(peak_freqs)
    if peak_freqs(i) > MIN_TREMOR_FREQ && peak_freqs(i) < MAX_TREMOR_FREQ && half_bandwidths(i) < MAX_HALF_BANDWIDTH
        has_tremor(i) = 1;
    else
        has_tremor(i) = 0;
end
has_tremor = logical(has_tremor);
end
