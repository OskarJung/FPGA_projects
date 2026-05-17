clear all; close all; clc
img = double(imread('hand.ppm'));
[h, w, ~] = size(img);
img_HSV_fix = zeros(h, w, 3);

prec_f = 8; 
word_unsigned = 1 + prec_f;       % [0:255] / 255
word_signed   = 1 + 1 + prec_f;   % 

for y = 1:h
    for x = 1:w
        R_in = img(y, x, 1);
        G_in = img(y, x, 2);
        B_in = img(y, x, 3);
        
        % =========================================================
        % 3. RGB (0-255) To (0-1) (Unsigned)
        % =========================================================
        R_norm = double(R_in) / 255;
        G_norm = double(G_in) / 255;
        B_norm = double(B_in) / 255;
        
        R_ufix = fi(R_norm, 0, word_unsigned, prec_f, 'RoundingMethod', 'Floor');
        G_ufix = fi(G_norm, 0, word_unsigned, prec_f, 'RoundingMethod', 'Floor');
        B_ufix = fi(B_norm, 0, word_unsigned, prec_f, 'RoundingMethod', 'Floor');
        
        % =========================================================
        % 4. change to signed numbers
        % =========================================================
        % in verilog: assign r_signed = {1'b0, r_ufix};
        R_sfix = fi(R_ufix, 1, word_signed, prec_f, 'RoundingMethod', 'Floor');
        G_sfix = fi(G_ufix, 1, word_signed, prec_f, 'RoundingMethod', 'Floor');
        B_sfix = fi(B_ufix, 1, word_signed, prec_f, 'RoundingMethod', 'Floor');
        
        % =========================================================
        % 5. Calculate max and min
        % =========================================================
        MAX_val = max(R_sfix, max(G_sfix, B_sfix));
        MIN_val = min(R_sfix, min(G_sfix, B_sfix));
        delta_C = double(MAX_val - MIN_val);
        
        % =========================================================
        % 6. calculate V (Value) component
        % =========================================================
        V_out = floor(double(MAX_val) * 255);
        
        % =========================================================
        % 7. calculate S (SATURATION) component
        % =========================================================
        if double(MAX_val) ~= 0
            S_div = delta_C / double(MAX_val);
        else
            S_div = 0;
        end
        
        S_fix = fi(S_div, 1, word_signed, prec_f, 'RoundingMethod', 'Floor');
        S_out = floor(double(S_fix) * 255);
        
        % =========================================================
        % 8. calculate H (HUE) component
        % =========================================================
        
        % MUX 1: Counter selection based on maximum
        if MAX_val == R_sfix
            H_num = double(G_sfix - B_sfix);
        elseif MAX_val == G_sfix
            H_num = double(B_sfix - R_sfix);
        else
            H_num = double(R_sfix - G_sfix);
        end
        
        % Shared Hardware division
        if delta_C == 0
            H_div = 0;
        else
            H_div = H_num / delta_C;
        end
        
        H_div_fix = fi(H_div, 1, word_signed, prec_f, 'RoundingMethod', 'Floor');
        
        % shared Hardware multiplication
        const_60 = fi(60, 1, 1 + 6 + prec_f, prec_f, 'RoundingMethod', 'Floor');
        H_mul = const_60 * H_div_fix;
        
        % Truncate the result back to the optimized width before accumulation
        % Integer part width = 8 bits (since the maximum value of H is ~360)
        H_mul_fix = fi(H_mul, 1, 1+9+prec_f, prec_f, 'RoundingMethod', 'Floor');
        
        % MUX 2: chose offset
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
        
        % Final normalization of H to the [0, 1] range
        H_norm = double(H_corr) / 360;
        H_norm_fix = fi(H_norm, 1, word_signed, prec_f, 'RoundingMethod', 'Floor');
        H_out = floor(double(H_norm_fix) * 255);


        img_HSV_fix(y, x, 1) = H_out;
        img_HSV_fix(y, x, 2) = S_out;
        img_HSV_fix(y, x, 3) = V_out;
    end 
end

%% Save the image after fixed-point conversion
imwrite(uint8(img_HSV_fix), 'matlab_HSV.ppm');

img_mat_fun = rgb2hsv(img/255);
imwrite((img_mat_fun), 'img_mat_fun.ppm');

img_mat_fun = imread('img_mat_fun.ppm'); 
img_matlab = imread('matlab_HSV.ppm');

% 2. Wyliczenie różnicy piksel po pikselu
diff = imabsdiff(img_mat_fun, img_matlab);

max_diff = max(diff(:));

if max_diff == 0
    disp('% SUCCESS! The images are identical');
else
    fprintf('Warning: differences detected! Maximum error is: %d\n', max_diff);
end