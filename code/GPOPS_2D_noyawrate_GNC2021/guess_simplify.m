function guessGen_red = guess_simplify(nodes,edges,guessGen)
k = 1;
edge_start(k,1) = 1;
edge_final(k,1) = 2;
while edge_final(k,1)<size(guessGen.x,1)
    given_edge = [guessGen.x(edge_start(k,1),1), guessGen.y(edge_start(k,1),1);
                  guessGen.x(edge_final(k,1),1), guessGen.y(edge_final(k,1),1)];
    if collision_check(nodes,edges,given_edge)
        edge_final(k,1) = edge_final(k,1)-1;
        if edge_start(k,1) == edge_final(k,1)
            k = k+1;
            edge_start(k,1) = edge_start(k-1,1)+1;
            edge_final(k,1) = edge_start(k-1,1)+2;
        else
            k = k+1;
            edge_start(k,1) = edge_final(k-1,1);
            edge_final(k,1) = edge_final(k-1,1)+1;
        end
    else
        edge_final(k,1) = edge_final(k,1)+1;
    end
end
guessGen_red.x = guessGen.x(unique([edge_start;edge_final]),1);
guessGen_red.y = guessGen.y(unique([edge_start;edge_final]),1);
end


function tf = collision_check(nodes,edges,given_edge)
intersect_bool = logical(zeros(size(edges,1),1));

for i = 1:size(edges,1)
    poly_edge = [nodes(edges(i,1),:); nodes(edges(i,2),:)];
    intersect_bool(i,1) = twoSegIntersect(given_edge,poly_edge);
end

tf = any(intersect_bool);
end