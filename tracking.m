function tracking(image, regionWidth, regionHeight)
[ h, w, ~ ] = size(image);
[ ~, r, c ] = harris_corner_detector(image, 26, 0.02);

if nargin == 1
    regionWidth = 15;
    regionHeight = 15;
end

x_region_bound = floor(regionWidth / 2);
y_region_bound = floor(regionHeight / 2);

%regions = mat2cell()


left_bound = max(1, c-x_region_bound);
right_bound = min(w, c+x_region_bound);
upper_bound = max(1, r-y_region_bound);
lower_bound = min(h, r+y_region_bound);

image = rgb2gray(image);
regions = image(upper_bound:lower_bound, left_bound:right_bound)


end