function [alpha] = cart2bary(tri,point)
alpha = zeros(3,size(point,1));

x1 = tri(1,1);
x2 = tri(2,1);
x3 = tri(3,1);
y1 = tri(1,2);
y2 = tri(2,2);
y3 = tri(3,2);

x  = point(:,1);
y  = point(:,2);

T = [x1-x3, x2-x3;
     y1-y3, y2-y3];

alpha(1:2,:) = T\[x'-x3; y'-y3];
alpha(3,:) = 1-alpha(1,:)-alpha(2,:);
end