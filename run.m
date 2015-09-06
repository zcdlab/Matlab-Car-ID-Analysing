clc
clear
close all

I=imread('chepai.jpg');
subplot(3,2,1);imshow(I), title('原始图像');
I_gray=rgb2gray(I);
subplot(3,2,2),imshow(I_gray),title('灰度图像');

%======================   形态学预处理 ======================
I_edge=edge(I_gray,'sobel');
subplot(3,2,3),imshow(I_edge),title('边缘检测后图像');
se=[1;1;1]; 
I_erode=imerode(I_edge,se);   
subplot(3,2,4),imshow(I_erode),title('腐蚀后边缘图像');
se=strel('rectangle',[25,25]);  
I_close=imclose(I_erode,se);            %图像闭合、填充图像
subplot(3,2,5),imshow(I_close),title('填充后图像');
I_final=bwareaopen(I_close,2000);       %去除聚团灰度值小于2000的部分
subplot(3,2,6),imshow(I_final),title('形态滤波后图像');


%==========================   车牌分割    =============================
I_new=zeros(size(I_final,1),size(I_final,2));
location_of_1=[];
for i=1:size(I_final,1)                 %寻找二值图像中白的点的位置
    for j=1:size(I_final,2)
        if I_final(i,j)==1;
            newlocation=[i,j];
            location_of_1=[location_of_1;newlocation];   
        end
    end
end
mini=inf;maxi=0;
for i=1:size(location_of_1,1)
%寻找所有白点中，x坐标与y坐标的和最大，最小的两个点的位置
    temp=location_of_1(i,1)+location_of_1(i,2);
    if temp<mini
        mini=temp;
        a=i;
    end
    if temp>maxi
        maxi=temp;
        b=i;
    end
end
first_point=location_of_1(a,:);        %和最小的点为车牌的左上角
last_point=location_of_1(b,:);         %和最大的点为车牌的右下角
x1=first_point(1)+4;                %坐标值修正
x2=last_point(1)-4;
y1=first_point(2)+4;
y2=last_point(2)-4;
I_plate=I(x1:x2,y1:y2);
I_plate=OTSU(I_plate);              %以OTSU算法对分割出的车牌进行自适应二值化处理
I_plate=bwareaopen(I_plate,50);
figure,imshow(I_plate),title('车牌提取')          %画出最终车牌


%=========================   字符分割   ============================
X=[];                               %用来存放水平分割线的横坐标
flag=0;
for j=1:size(I_plate,2)    
    sum_y=sum(I_plate(:,j));
    if logical(sum_y)~=flag         %列和有变化时，记录下此列
        X=[X j];
        flag=logical(sum_y);
    end
end
figure
for n=1:7                          
    char=I_plate(:,X(2*n-1):X(2*n)-1); %进行粗分割
    for i=1:size(char,1)            %这两个for循环对分割字符的上下进行裁剪
        if sum(char(i,:))~=0
            top=i;
            break
        end
    end
    for i=1:size(char,1)
        if sum(char(size(char,1)-i,:))~=0
            bottom=size(char,1)-i;
            break
        end
    end
    char=char(top:bottom,:);
    subplot(2,4,n);imshow(char);
    char=imresize(char,[32,16],'nearest'); %归一化为32*16的大小，以便模板匹配
    eval(strcat('Char_',num2str(n),'=char;'));  %将分割的字符放入Char_i中
end


%==========================  字符识别   =============================
char=[];
store1=strcat('京','津','沪','渝','冀','晋','辽','吉','黑','苏','浙'...  %汉字识别
    ,'皖','闽','赣','鲁','豫','鄂','湘','粤','琼','川','贵','云','陕'...
    ,'甘','青','藏','桂','皖','新','宁','港','鲁','蒙');
 for j=1:34
        Im=Char_1;
        Template=imread(strcat('chinese\',num2str(j),'.bmp')); %chinese文件附在最后
        Template=im2bw(Template);
        Differ=Im-Template;
        Compare(j)=sum(sum(abs(Differ)));
 end
 index=find(Compare==(min(Compare)));
 char=[char store1(index)];

store2=strcat('9','8','7','6','5','4','3','2','1','0','Z','Y','X','W','V','U','T'...
    ,'S','R','Q','P','N','M','M','L','K','J','H','G','F','E','D','C','B','A');
for i=2:7                                                %字母数字识别
    for j=1:35
        Im=eval(strcat('Char_',num2str(i)));
        Template=imread(strcat('cha&num\',num2str(j),'.bmp'));  %cha&num文件附在最后
        Template=im2bw(Template);
        Differ=Im-Template;
        Compare(j)=sum(sum(abs(Differ)));
    end
    index=find(Compare==(min(Compare)));
    char=[char store2(index)];
end
figure,imshow(I),title(strcat('车牌为:',char))
