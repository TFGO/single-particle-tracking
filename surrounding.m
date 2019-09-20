function linear_indices=surrounding(xc,yc,width,size)

width=width/2;
linear_indices=[];
for i=ceil(xc-width):ceil(xc+width)
    for j=ceil(yc-width):ceil(yc+width)
        if i>0&&i<=size(1)&&j>0&&j<=size(2)
            linear_indices=[linear_indices sub2ind(size,i,j)];
        end
    end
end

end