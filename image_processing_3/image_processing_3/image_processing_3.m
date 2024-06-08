%Damla Göktaş

% Load an example image and check if successful
input_image = imread('butterfly.jpg');
if isempty(input_image)
    error('Failed to load the input image.');
end

% Load a second example image for linear combination
second_image = imread('flower.jpg');
if isempty(second_image)
    error('Failed to load the second image.');
end

% Convert the input images to grayscale if they are RGB images
if ndims(input_image) == 3
    input_image = rgb2gray(input_image);
end
if ndims(second_image) == 3
    second_image = rgb2gray(second_image);
end

% Resize the second image to match the dimensions of the first image
scaling_factor = 0.5;  % Example scaling factor
second_image = scale(second_image, scaling_factor);

% Define parameters for arithmetic operation
technique = 1;  % Use technique 1 
k = 50;         % Value of k
mode = 0;       % Unsaturated and scaled mode

% Perform mirroring operation on the input images
mirrored_input_image = mirror(input_image);
mirrored_second_image = mirror(second_image);

% Perform arithmetic operation on the mirrored images
output_image_arithmetic = arithmetic_operation(mirrored_input_image, technique, k, mode);

% Perform linear combination on the mirrored images
output_image_linear_comb = mixing(mirrored_input_image, mirrored_second_image, 0.5);

% Rotate the output image from linear combination using bilinear interpolation
angle = 30;  % Example rotation angle
output_image_rotated_bilinear = rotate_bilinear(output_image_linear_comb, angle);

% Rotate the input image left by 90 degrees using affine transformation
output_image_rotated_affine = rotate_affine(input_image);

% Create a figure to display images
figure;

% Display the input images in the first subplot
subplot(2, 4, 1);
imshow(input_image);
title('Input Image');

subplot(2, 4, 2);
imshow(second_image);
title('Second Image (Resized)');

% Display the output image from arithmetic operation in the third subplot
subplot(2, 4, 3);
imshow(output_image_arithmetic);
title('Output Image (Arithmetic Operation)');

% Display the output image from linear combination in the fourth subplot
subplot(2, 4, 4);
imshow(output_image_linear_comb);
title('Output Image (Linear Combination)');

% Display the mirrored input images in the fifth subplot
subplot(2, 4, 5);
imshow(mirrored_input_image);
title('Mirrored Input Image');

% Display the mirrored second images in the sixth subplot
subplot(2, 4, 6);
imshow(mirrored_second_image);
title('Mirrored Second Image');

% Display the rotated output image from linear combination using bilinear interpolation in the seventh subplot
subplot(2, 4, 7);
imshow(output_image_rotated_bilinear);
title('Rotated Output Image (Bilinear)');

% Display the rotated input image using affine transformation in the eighth subplot
subplot(2, 4, 8);
imshow(output_image_rotated_affine);
title('Rotated Input Image (Affine)');

% Define the arithmetic_operation function
function image_out = arithmetic_operation(im, technique, k, mode)
    % Validate technique and mode
    if ~(technique == 1 || technique == 2 || technique == 3)
        error('Invalid technique specified.');
    end
    
    if ~(mode == 0 || mode == 1)
        error('Invalid mode specified.');
    end
    
    % Perform arithmetic operation based on technique
    [rows, cols] = size(im);
    image_out = zeros(rows, cols);
    
    for i = 1:rows
        for j = 1:cols
            if technique == 1
                image_out(i, j) = im(i, j) + k;
            elseif technique == 2
                image_out(i, j) = im(i, j) * k;
            elseif technique == 3
                image_out(i, j) = 20 * sqrt(im(i, j));
            end
            
            % Normalize the pixel value based on mode
            if mode == 0
                % Unsaturated and scaled
                image_out(i, j) = scale_and_clip(image_out(i, j));
            elseif mode == 1
                % Saturated to [0, 255] range
                image_out(i, j) = saturate(image_out(i, j));
            end
        end
    end
    
    % Function to scale and clip pixel values to [0, 255]
    function val = scale_and_clip(value)
        val = value;
        % Scale the value to the range [0, 255]
        val = 255 * (val - min(im(:))) / (max(im(:)) - min(im(:)));
        % Clip values outside the [0, 255] range
        val(val < 0) = 0;
        val(val > 255) = 255;
    end

    % Function to saturate pixel values to [0, 255] range
    function val = saturate(value)
        val = value;
        % Saturate values outside the [0, 255] range
        val(val < 0) = 0;
        val(val > 255) = 255;
    end
end

% Define the mixing function for linear combination
function output_image = mixing(im1, im2, k)
    % Validate k
    if k < 0 || k > 1
        error('k must be in the range [0, 1].');
    end
    
    % Resize im2 to match the size of im1
    im2_resized = imresize(im2, size(im1));
    
    % Perform linear combination of the two input images
    output_image = k * im1 + (1 - k) * im2_resized;
end

% Define the mirror function for creating mirrored images
function mirrored_image = mirror(im)
    % Validate input image
    if ~ismatrix(im) || ~isnumeric(im)
        error('Input image must be a grayscale numeric matrix.');
    end
    
    % Create a mirrored image using the specified rule
    mirrored_image = im(end:-1:1, end:-1:1);
end

% Define the scale function to resize the image by a factor of k
function resized_image = scale(im, k)
    % Validate input k
    if k <= 1/4 || k >= 4
        error('k must be in the range (1/4, 4).');
    end
    
    % Calculate the new dimensions
    new_size = round(size(im) * k);
    
    % Resize the image
    resized_image = imresize(im, k);
end

% Define the rotate_bilinear function to rotate the image by an angle using bilinear interpolation
function rotated_image = rotate_bilinear(im, angle)
    % Convert angle to radians
    angle_rad = deg2rad(angle);
    
    % Perform rotation using bilinear interpolation
    rotated_image = imrotate(im, angle, 'bilinear', 'crop');
end

% Define the rotate_affine function to rotate the image left by 90 degrees using affine transformation
function rotated_image = rotate_affine(im)
    % Create the affine transformation matrix for rotation
    A = [0 -1 0; 1 0 0; 0 0 1];
    
    % Apply the affine transformation using imwarp
    rotated_image = imwarp(im, affine2d(A));
end
