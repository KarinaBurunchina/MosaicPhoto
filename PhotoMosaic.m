Orig = imread('check5.jpg'); %upload original photo
[r, c, rgb] = size(Orig);

%----------------------------------
%-------USER Defines---------------
fprintf('Do you want to make mosaic with circular and square patches or rectangular ones?\n');
user_patch = 'Q';
while (user_patch ~= 'C' && user_patch ~= 'R')
    user_patch = input('Type C for circular and R for rectangular\n', 's');
end

Common_divisors = intersect(find_divisors(r), find_divisors(c));
Message_circle=['The length of patches can be \n' repmat(' %1.0f',1,numel(Common_divisors))];
Message_rect_w = ['The width for rectangular patches can be \n' repmat(' %1.0f',1,numel(find_divisors(r)))];
Message_rect_l = ['The length for rectangular patches can be \n' repmat(' %1.0f',1,numel(find_divisors(c)))];

  
if user_patch == 'C'
    fprintf(Message_circle, Common_divisors);
    user_size = 0;
    while ismember(user_size, Common_divisors) == 0
        user_size = input ('\n Type one of the given values: \n');
        r_patch = user_size;
        c_patch = user_size;
    end
else
    user_size = 0;
    while ismember(user_size, find_divisors(r)) == 0
        fprintf(Message_rect_w, find_divisors(r));
        user_size = input('\n Type one of the given values: \n');
        r_patch = user_size;
    end
    user_size = 0;
    while ismember(user_size, find_divisors(c)) == 0
        fprintf(Message_rect_l, find_divisors(c));
        user_size = input('\n Type one of the given values: \n');
        c_patch = user_size;
    end
end
%-------------------------------------------    
%-------------------------------------------

Data = imageDatastore('zootopia'); %upload Dataset of photos for mosaic
Data = readall(Data);

i = 1;
while i< (numel(Data)+1)
    Data{i} = imresize(Data{i}, [r_patch c_patch]);
    i = i+1;
end

divided_orig = mat2cell(Orig, r_patch*ones(1, r/r_patch), c_patch*ones(1, c/c_patch), rgb);

if user_patch == 'C'
    Circle_divided = divided_orig;
    %mask
    circle = [r_patch/2, c_patch/2, r_patch/2];
    [xx, yy] = meshgrid((1:r_patch)-circle(1),(1:c_patch)-circle(2));
    mask = (xx.^2 +yy.^2) <= circle(3)^2;
end

r = 1;
while r < (size(divided_orig, 1) + 1)
    c = 1;
    while c < (size(divided_orig, 2) + 1)
        i = 1;
        dist_min = 2000000000;
        while i < (size (Data, 1)+1)
            D = im2double(Data{i}(:,:));
            O = im2double(divided_orig{r, c}(:,:));
            Dist = sqrt(sum((D-O)*(D-O)', 'all'));
            if dist_min > Dist
                dist_min = Dist;
                k = i;
            end
            i = i+1;
        end
        if user_patch == 'C'
            Red1 = Data{k, 1}(:,:, 1);
            Green1 = Data{k, 1}(:, :, 2);
            Blue1 = Data{k, 1} (:,:, 3);

            Red2 = divided_orig{r, c}(:,:, 1);
            Green2 = divided_orig{r, c}(:, :, 2);
            Blue2 = divided_orig{r, c}(:,:, 3);

            Red2(mask) = Red1(mask);
            Green2(mask) = Green1(mask);
            Blue2(mask) = Blue1(mask);

            Circle_divided{r,c} = cat(3, Red2, Green2, Blue2);
        end
        divided_orig{r, c} = Data{k, 1};
        c = c+1;
    end
    r = r+1;
end

result_im = cell2mat(divided_orig);
figure
imshow(result_im);

if user_patch == 'C'
    circle_result = cell2mat(Circle_divided);
    figure
    imshow(circle_result);
end
function divisors = find_divisors(K)
    fact = factor(K); %find all prime factors of K

    divisors = [1, fact(1)]; %always at least 1 and the number K itself are divisors
    %If K is prime number, size(fact) = 1, the number K itself and the
    %following loop will not start
    for i = fact(2:end)
       divisors = [1; i]* divisors;

       divisors = unique(divisors(:)'); 
    end

end
