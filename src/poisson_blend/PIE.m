function im_out = PIE( im_dst, im_src,im_mask)


m=0; 
c=3; 
assert(all(size(im_dst) == size(im_src)));


%convert source and target images to double for more precise computations
im_dst=double(im_dst);
im_src=double(im_src);


im_out=im_dst;

lap_mask=[0 1 0; 1 -4 1; 0 1 0];

%find the number of unknown pixels based on the mask
n=size(find(im_mask==1),1);
% construct the map
map=zeros(size(im_mask));

cnt=0;
for x=1:size(map,1)
    for y=1:size(map,2)
        if im_mask(x,y)==1 
            cnt=cnt+1;
            map(x,y)=cnt; 
        end
    end
end

% construct linear equation of poisson equation
for i=1:c
    coeff_num=5;
    A=spalloc(n,n,n*coeff_num);
    B=zeros(n,1);
    
    lap=conv2(im_src(:,:,i),lap_mask, 'same');
    cnt=0;
    for x=1:size(map,1)
        for y=1:size(map,2)
            if im_mask(x,y)==1
                cnt=cnt+1;
                A(cnt,cnt)=4;
                if im_mask(x-1,y)==0 % left
                    B(cnt)=im_dst(x-1,y,i); 
                else %unknown
                    A(cnt,map(x-1,y))=-1;
                end
                if im_mask(x+1,y)==0 %right
                    B(cnt)=B(cnt)+im_dst(x+1,y,i); 
                else %unknown 
                    A(cnt,map(x+1,y))=-1; 
                end
                if im_mask(x,y-1)==0 %bottom
                    B(cnt)=B(cnt)+im_dst(x,y-1,i); 
                else %unknown 
                    A(cnt,map(x,y-1))=-1; 
                end
                if im_mask(x,y+1)==0 % top
                    B(cnt)=B(cnt)+im_dst(x,y+1,i);
                else %unknown
                    A(cnt,map(x,y+1))=-1; 
                end   
                %update the B vector with the laplacian value
                B(cnt)=B(cnt)-lap(x,y);
                
            end
        end
    end
    
    %solve the linear system of equation
    X=A\B;
      
    for cnt=1:length(X)
        [index_x,index_y]=find(map==cnt);
        im_out(index_x,index_y,i)=X(cnt);
        
    end
end

im_out=uint8(im_out);

end

