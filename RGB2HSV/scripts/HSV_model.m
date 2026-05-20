clear all; close all; clc;

% =========================================================
% 1. FIXED-POINT REPRESENTATION PARAMETERS
% =========================================================
prec_f = 8;
word_unsigned = 1 + prec_f;       % [0:255] / 255
word_signed   = 1 + 1 + prec_f;   %

%% =========================================================
%% 2. RGB TEST VECTORS
%% =========================================================
test_cases = [
    255, 100, 190;  % Test 1: Standard color
    120, 120, 120;  % Test 2: Shades of gray (V=0, H=0)
     50, 200, 100;  % Test 3: Maximum is G
     10,  50, 250;  % Test 4: Maximum is B
    255,   0,   0   % Test 5: Pure red (H=0)
];

% Test selection (change index from 1 to 5)
for idx = 1:5
R_in = test_cases(idx, 1);
G_in = test_cases(idx, 2);
B_in = test_cases(idx, 3);

%% =========================================================
%% 3. RGB (0–255) TO (0–1) CONVERSION (UNSIGNED)
%% =========================================================
% Models IP Core Divider behavior (Unsigned)
R_norm = double(R_in) / 255;
G_norm = double(G_in) / 255;
B_norm = double(B_in) / 255;

R_ufix = fi(R_norm, 0, word_unsigned, prec_f, 'RoundingMethod', 'Floor');
G_ufix = fi(G_norm, 0, word_unsigned, prec_f, 'RoundingMethod', 'Floor');
B_ufix = fi(B_norm, 0, word_unsigned, prec_f, 'RoundingMethod', 'Floor');

%% =========================================================
%% 4. CONVERSION TO SIGNED FIXED-POINT FOR FURTHER CALCULATIONS
%% =========================================================
% Hardware equivalent: assign r_signed = {1'b0, r_ufix};
R_sfix = fi(R_ufix, 1, word_signed, prec_f, 'RoundingMethod', 'Floor');
G_sfix = fi(G_ufix, 1, word_signed, prec_f, 'RoundingMethod', 'Floor');
B_sfix = fi(B_ufix, 1, word_signed, prec_f, 'RoundingMethod', 'Floor');

%% =========================================================
%% 5. EXTREMA COMPUTATION
%% =========================================================
MAX_val = max(R_sfix, max(G_sfix, B_sfix));
MIN_val = min(R_sfix, min(G_sfix, B_sfix));
C = MAX_val - MIN_val;
delta_C = double(C);

%% =========================================================
%% 6. VALUE COMPONENT (V)
%% =========================================================
V_out = floor(double(MAX_val) * 255);

%% =========================================================
%% 7. SATURATION COMPONENT (S)
%% =========================================================
if double(MAX_val) ~= 0
    S_div = delta_C / double(MAX_val);
else
    S_div = 0;
end

S_fix = fi(S_div, 1, word_signed, prec_f, 'RoundingMethod', 'Floor');
S_out = floor(double(S_fix) * 255);

%% =========================================================
%% 8. HUE COMPONENT (H)
%% =========================================================

% MUX 1: Numerator selection based on maximum channel
if MAX_val == R_sfix
    H_num = double(G_sfix - B_sfix);
elseif MAX_val == G_sfix
    H_num = double(B_sfix - R_sfix);
else
    H_num = double(R_sfix - G_sfix);
end

% Shared hardware division
if delta_C == 0
    H_div = 0;
else
    H_div = H_num / delta_C;
end

H_div_fix = fi(H_div, 1, word_signed, prec_f, 'RoundingMethod', 'Floor');

% Shared hardware multiplication
% Representing constant 60 requires 7 integer bits (signed)
const_60 = fi(60, 1, 1 + 6 + prec_f, prec_f, 'RoundingMethod', 'Floor');
H_mul = const_60 * H_div_fix;

% Truncate result back to optimized width before addition
% Integer width = 8 bits (since max H value is ~360)
H_mul_fix = fi(H_mul, 1, 1+9+prec_f, prec_f, 'RoundingMethod', 'Floor');

% MUX 2: Offset selection
const_120 = fi(120, 1, 1+8+prec_f, prec_f, 'RoundingMethod', 'Floor');
const_240 = fi(240, 1, 1+8+prec_f, prec_f, 'RoundingMethod', 'Floor');

if delta_C == 0
    H_add = fi(0, 1, 1+9+prec_f, prec_f, 'RoundingMethod', 'Floor');
else
    if MAX_val == R_sfix
        H_add = H_mul_fix;
    elseif MAX_val == G_sfix
        H_add = H_mul_fix + const_120;
    else
        H_add = H_mul_fix + const_240;
    end
end

% Angle wrapping for negative values
const_360 = fi(360, 1, 1+9+prec_f, prec_f, 'RoundingMethod', 'Floor');

if double(H_add) < 0
    H_corr = H_add + const_360;
else
    H_corr = H_add;
end

% Final normalization of H to [0, 1]
H_norm = double(H_corr) / 360;
H_norm_fix = fi(H_norm, 1, word_signed, prec_f, 'RoundingMethod', 'Floor');
H_out = floor(double(H_norm_fix) * 255);

%% =========================================================
%% 9. COMPARISON AND RESULTS
%% =========================================================
fprintf('\n--- TEST FOR RGB VECTOR: [%d, %d, %d] ---\n', R_in, G_in, B_in);
fprintf('RGB_ufix  (hex) : R=%s, G=%s, B=%s\n', R_ufix.hex, G_ufix.hex, B_ufix.hex);
fprintf('RGB_sfix  (int) : R=%d, G=%d, B=%d\n', R_sfix.int, G_sfix.int, B_sfix.int);
fprintf('MAX_val   (int) : %d    Min_val (int) : %d\n',MAX_val.int, MIN_val.int);
fprintf('C         (int) : %d            (hex) : %s\n', C.int, C.hex);
fprintf('S_fix     (int) : %d            (hex) : %s\n', S_fix.int, S_fix.hex);
fprintf('H_div_fix (int) : %d            (hex) : %s\n', H_div_fix.int, H_div_fix.hex)

% fprintf('\nFIXED-POINT MODEL RESULTS [0-255]:\n');
% fprintf('H: %d\n', H_out);
% fprintf('S: %d\n', S_out);
% fprintf('V: %d\n', V_out);
% 
% ref_hsv = round(rgb2hsv([R_in, G_in, B_in]/255) * 255);
% fprintf('\nREFERENCE RESULTS (MATLAB rgb2hsv) [0-255]:\n');
% fprintf('H: %d\n', ref_hsv(1));
% fprintf('S: %d\n', ref_hsv(2));
% fprintf('V: %d\n\n', ref_hsv(3));
end