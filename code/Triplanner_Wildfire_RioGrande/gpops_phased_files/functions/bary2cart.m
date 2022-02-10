function [x] = bary2cart(tri,alpha)
x1 = tri(1,1);
x2 = tri(2,1);
x3 = tri(3,1);
y1 = tri(1,2);
y2 = tri(2,2);
y3 = tri(3,2);
x = [(alpha(1,:)*x1 + alpha(2,:)*x2 + alpha(3,:)*x3); (alpha(1,:)*y1 + alpha(2,:)*y2 + alpha(3,:)*y3)];
end