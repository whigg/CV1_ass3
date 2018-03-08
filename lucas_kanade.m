% TODO: Fix skere gauss naar fspecial foshizzle
% TODO: Misschien 1 functie icm tracking.m?

function lucas_kanade(image1, image2, regionWidth, regionHeight)
% LUCAS_KANADE  Find optical flow between two images.
% Input parameters:
%   image1          A rgb or grayscale image.
%   image2          A rgb or grayscale image (equal size as image1).
%   regionWidth     The width of regions used to calculate
%                   optical flow (default: 15).
%   regionHeight    The height of regions used to calculate
%                   optical flow (default: 15).
[ height, width, channels ] = size(image1); % Get the image1 size (equal to image2)



if channels == 3
   image1 = rgb2gray(image1);            % Convert to grayscale
   image2 = rgb2gray(image2);            % Convert to grayscale
end

% synth1.pgm and synth2.pgm    % 128x128
% sphere1.ppm and sphere2.ppm  % 200x200x3
%figure, imshow(image1)
%figure, imshow(image2)

if nargin == 2
    regionWidth = 15; % default
    regionHeight= 15; % default
end

% 1. Divide input images on non-overlapping (15x15) regions.

% determine the amount of rows and columns
columnAmount = floor(width / regionWidth);
rowAmount = floor(height / regionHeight);

% determine the amount of rows and columns per region
columnDivision = [regionWidth * ones(1, columnAmount), mod(width, regionWidth)];
rowDivision = [regionHeight * ones(1, rowAmount), mod(height, regionHeight)];

% divide the image into regions of the determined dimensions
image1_regions = mat2cell(image1, rowDivision, columnDivision);
image2_regions = mat2cell(image2, rowDivision, columnDivision);

% 2. For each region compute A, AT and b. 
% Then, estimate optical flow as given in Equation 20.

% FOR EACH REGION, CALCULATE THE OPTICAL FLOW
% FOR EACH REGION, CALCULATE THE OPTICAL FLOW
[ row_regions, column_regions ] = size(image1_regions);

[ regionHeight, regionWidth ] = size(cell2mat(image1_regions(1)));

flow_vectors = zeros(row_regions * column_regions, 4);
counter = 1;
for i = 1:row_regions
    for j = 1:column_regions
        im1region = cell2mat(image1_regions(i, j));
        im2region = cell2mat(image2_regions(i, j));

        [ h, w ] = size(im1region);
        
        % Incoming fugly piece of code to apply that Gauss
        G = gauss2D(20 , max(regionHeight, regionWidth));

        % Make matching dimensions
        if regionHeight ~= h
            b = floor((regionHeight - h)/2);
            G = G( b:b+h - 1 ,:);
        end
        
        if regionWidth ~= w
            b = floor((regionWidth - w)/2);
            G = G(:, b:b+w-1 );
        end        
       
        im1region = G .* double(im1region); % Apply
        im2region = G .* double(im2region); % Apply
        
        [ Gx, Gy ] = imgradientxy(im1region);  % Compute the gradients wrt x & y
        Gt = im1region - im2region;           % Compute the gradients wrt t
        
        A(:, 1) = double(reshape(Gx, h*w, 1));
        A(:, 2) = double(reshape(Gy, h*w, 1)); 
        b       = double(reshape(Gt, h*w, 1));
        v = (transpose(A) * A) \ (transpose(A) * b);
        
        A = [];  % reset to prevent dimension error
        
        avg_y_pixel = i*regionHeight-0.5*h;
        avg_x_pixel = j*regionWidth-0.5*w;
        
        flow_vectors(counter, :) = [avg_x_pixel, avg_y_pixel, v(1), v(2)];
        counter = counter + 1;
    end
end


% 3. When you have estimation for optical flow (Vx,Vy) of each region, 
% you should display the results. 
% There is a MATLAB function quiver which plots a set of 
% two-dimensional vectors as arrows on the screen. 
% Try to figure out how to use this to plot your optical flow results.
figure, imshow(image1)
hold on;
quiver(flow_vectors(:, 1), flow_vectors(:, 2), flow_vectors(:, 3), flow_vectors(:, 4), 'linewidth', 1, 'color', 'g', 'MaxHeadSize', 2)

end