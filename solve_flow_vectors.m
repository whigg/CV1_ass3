function [ flow_vectors ] = solve_flow_vectors(image1_regions, image2_regions)
% FOR EACH REGION, CALCULATE THE OPTICAL FLOW
[ row_regions, column_regions ] = size(image1_regions);
[ regionHeight, regionWidth ] = size(cell2mat(image1_regions(1)));

flow_vectors = zeros(row_regions * column_regions, 4);
counter = 1;
for i = 1:row_regions
    for j = 1:column_regions
        im1region = cell2mat(image1_regions(i, j));
        im2region = cell2mat(image2_regions(i, j));
       
        
        [ Gx, Gy ] = imgradientxy(im1region);  % Compute the gradients wrt x & y
        
        %Gx = imgaussfilt(Gx, 1);
        %Gy = imgaussfilt(Gy, 1);
        
        Gt = im1region - im2region;           % Compute the gradients wrt t

        [ h, w ] = size(Gx);
        
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
end