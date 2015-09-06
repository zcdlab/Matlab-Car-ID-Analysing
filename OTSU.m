
function J=OTSU(I)

Hi=imhist(I);           %直方图

sum1=sum(Hi);
for i=1:255
    w1=sum(Hi(1:i))/sum1;           %第一类概率
    w2=sum(Hi((i+1):256))/sum1;     %第二类概率   
      
    m1=(0:(i-1))*Hi(1:i)/sum(Hi(1:i));          %第一类平均灰度值
    m2=(i:255)*Hi((i+1):256)/sum(Hi((i+1):256));%第二类平均灰度值
    
    Jw(i)=w1*w2*(m1-m2)^2;
end

[maxm,thresh]=max(Jw);      %寻找阈值

% subplot(2,2,1);imshow(I);title('原图像');
% subplot(2,2,[3,4]);imhist(I);hold on;plot(thresh,3,'+r');title((strcat('阈值为',num2str(thresh))));

I(find(I<=thresh))=0;      
I(find(I>thresh))=256;       %二值化
J=I;
% subplot(2,2,2),imshow(I),title('二值化图像zk');



