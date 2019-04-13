 %�������
close all;  
clear; 

%ͼ����Ϣ����
imgfile=dir(strcat(pwd,'\image_test\*.jpg'));

%��ȡͼ�񲢽���Ŀ��ѡ��
image_rgb = imread(imgfile(1).name);
image_hsv = rgb_to_hsv(image_rgb);
image_h = image_hsv(:,:,1);           %��ȡɫ��
image_s = image_hsv(:,:,2);           %��ȡ���Ͷ�
image_v = image_hsv(:,:,3);           %��ȡ����
%imshow(uint8(image_v));            %չʾ����
crop_size = [170,320,119,79];       %Ŀ�궨λ��
[img_crop] = imcrop(image_hsv, crop_size);
[img_height, img_width, img_z_index]=size(img_crop);

%��λĿ������
target_center(1) = img_height/2;
target_center(2) = img_width/2;

img_weight = zeros(img_height,img_height);               %��ʼ��Ŀ�������Ȩֵ����
h = target_center(1)^2 + target_center(2)^2 ;            %����

%����Ȩֵ����
for i=1:img_height
    for j=1:img_width
        dist=(i-target_center(1))^2+(j-target_center(2))^2;
        img_weight(i,j)=1-dist/h;              %epanechnikov profile
    end
end
C=1/sum(sum(img_weight));           %��ϵ�����й�һ��

%����ֱ��ͼͳ��
%rgb��ɫ�ռ�����Ϊ16*16*16 bins
hist = zeros(1,4096);
for i=1:img_height
    for j=1:img_width   
        img_h = fix(double(img_crop(i,j,1))/16);
        img_s = fix(double(img_crop(i,j,2))/16);
        img_v = fix(double(img_crop(i,j,3))/16);
        index = img_h*256 + img_s*16 + img_v;
        hist(index+1)= hist(index+1) + img_weight(i,j);
    end
end
hist = hist * C;

%�Բü������С��������ȡ��
crop_size(3)=ceil(crop_size(3));
crop_size(4)=ceil(crop_size(4));

%��ȡͼ������
lengthfile=length(imgfile);  

for img_index=1:lengthfile  
    img_temp = imread(imgfile(img_index).name);  
    img_cache = rgb_to_hsv(img_temp);
    iterator = 0;  
    center_move=[2,2];  
      
    % mean shift����  
    while((center_move(1)^2 + center_move(2)^2>0.5) && iterator<20)   %��������  
        iterator = iterator + 1;  
        iter_cache = imcrop(img_cache,crop_size);
        img_move_temp = zeros(img_height,img_height); 
        
        %�����ѡ����ֱ��ͼ  
        hist_temp = zeros(1,4096);  
        for i=1:img_height
            for j=1:img_width   
                img_h = fix(double(iter_cache(i,j,1))/16);
                img_s = fix(double(iter_cache(i,j,2))/16);
                img_v = fix(double(iter_cache(i,j,3))/16);
                index = img_h*256 + img_s*16 + img_v;
                hist_temp(index+1)= hist_temp(index+1) + img_weight(i,j);
                img_move_temp(i,j) = index;
            end
        end
        hist_temp = hist_temp * C;
        
        %figure(2);  
        %subplot(1,2,1);  
        %plot(hist_temp);  
        %hold on;  
        
        %��ѡ�е�ָ������ƥ��,����ƫ��Ȩ�ؼ���
        weight = zeros(1,4096);  
        for i=1:4096  
            if(hist_temp(i)~=0)
                weight(i) = sqrt(hist(i)/hist_temp(i));  
            else  
                weight(i)=0;  
            end  
        end  
          
        %ƫ��������  
        count = 0;  
        img_move = [0,0];  
        for i=1:img_height  
            for j=1:img_width
                count = count + weight(uint32(img_move_temp(i,j))+1);  
                img_move = img_move + weight(uint32(img_move_temp(i,j))+1) * [i-target_center(1)-0.5, j-target_center(2)-0.5];  
            end  
        end  
        center_move = img_move/count;  
        %���ĵ�λ�ø���  
        crop_size(1) = crop_size(1) + center_move(2);  
        crop_size(2) = crop_size(2) + center_move(1);  
    end  
      
    %%%���ٹ켣����%%%  
    %tic_x=[tic_x;rect(1)+rect(3)/2];  
    %tic_y=[tic_y;rect(2)+rect(4)/2];  
      
    v1=crop_size(1);  
    v2=crop_size(2);  
    v3=crop_size(3);  
    v4=crop_size(4);
    
    %%%��ʾ���ٽ��%%%  
    %subplot(1,2,2);
    pause(0.2)
    clf
    imshow(uint8(img_cache(:,:,3)));  
    %title('Ŀ����ٽ�������˶��켣');  
    hold on;  
    plot([v1,v1+v3],[v2,v2],[v1,v1],[v2,v2+v4],[v1,v1+v3],[v2+v4,v2+v4],[v1+v3,v1+v3],[v2,v2+v4],'LineWidth',2,'Color','r');  
    %plot(tic_x,tic_y,'LineWidth',2,'Color','b'); 
end 