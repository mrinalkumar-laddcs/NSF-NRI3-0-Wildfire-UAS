function [tf,xI,yI] = twoSegIntersect(edge1,edge2)
if all(size(edge1) == [2,2]) && all(size(edge2) == [2,2])
    
    xI = [];
    yI = [];
    
    x1 = edge1(1,1);
    x2 = edge1(2,1);
    y1 = edge1(1,2);
    y2 = edge1(2,2);
    
    x3 = edge2(1,1);
    x4 = edge2(2,1);
    y3 = edge2(1,2);
    y4 = edge2(2,2);
    
    A = [y1-y2 x2-x1;
        y3-y4 x4-x3];
    B = [x2*y1-x1*y2;
        x4*y3-x3*y4];
    
    if abs(det(A)) >= 1e-8
        x = A\B;
        
        xR = x(1,1);
        yR = x(2,1);
        
        % Check if the intersection lies within the line segements
        if pdist2([xR,yR],[x1,y1])<= pdist2([x2,y2],[x1,y1])...
                && pdist2([xR,yR],[x2,y2])<= pdist2([x2,y2],[x1,y1])
            seg1 = true;
        else
            seg1 = false;
        end
        
        if pdist2([xR,yR],[x3,y3])<= pdist2([x4,y4],[x3,y3])...
                && pdist2([xR,yR],[x4,y4])<= pdist2([x4,y4],[x3,y3])       
            seg2 = true;
        else
            seg2 = false;
        end
        
        if seg1 && seg2
            tf = true;
            xI = xR;
            yI = yR;
        else
            tf = false;
        end
    else
        tf = false;
    end
    
else
    disp('Wrong input! Both input arguments should be 2-by-2 matrices');
end
end