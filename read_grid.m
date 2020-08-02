function grid = read_grid(grid_file)
    
    file=fopen(grid_file,'r');
    
    eps=1e-6;
    vertices=[];
   
    i=1;
    while ~feof(file)
        line = fgetl(file);
        if strcmp(line,'    outer loop')==1
            
           line = fgetl(file);
           vertex1=sscanf(line,'      vertex %f %f %f');
           line = fgetl(file);
           vertex2=sscanf(line,'      vertex %f %f %f');
           line = fgetl(file);
           vertex3=sscanf(line,'      vertex %f %f %f');
               
           if length(vertex1)==3 && length(vertex2)==3 && length(vertex3)==3

                %check if vertex already exists
                
                vertex1_exists=-1;
                
                for j=1:size(vertices,1)
                    if abs(vertices(j,1)-vertex1(1)) < eps && abs(vertices(j,2)-vertex1(2)) < eps && abs(vertices(j,3)-vertex1(3)) < eps
                        vertex1_exists=j;
                        break;
                    end
                end 
                
                if vertex1_exists~=-1
                    faces(i,1)=vertex1_exists;
                else
                    k=size(vertices,1);
                    vertices(k+1,:)=vertex1;
                    faces(i,1)=k+1;
                end
                
                %check if vertex already exists
                
                vertex2_exists=-1;
                
                for j=1:size(vertices,1)
                    if abs(vertices(j,1)-vertex2(1)) < eps && abs(vertices(j,2)-vertex2(2)) < eps && abs(vertices(j,3)-vertex2(3)) < eps
                        vertex2_exists=j;
                        break;
                    end
                end 
                
                if vertex2_exists~=-1
                    faces(i,2)=vertex2_exists;
                else
                    k=size(vertices,1);
                    vertices(k+1,:)=vertex2;
                    faces(i,2)=k+1;
                end
                
                %check if vertex already exists
                  
                vertex3_exists=-1;
                  
                for j=1:size(vertices,1)
                    if abs(vertices(j,1)-vertex3(1)) < eps && abs(vertices(j,2)-vertex3(2)) < eps && abs(vertices(j,3)-vertex3(3)) < eps
                        vertex3_exists=j;
                        break;
                    end
                end 

                if vertex3_exists~=-1
                    faces(i,3)=vertex3_exists;
                else
                    k=size(vertices,1);
                    vertices(k+1,:)=vertex3;
                    faces(i,3)=k+1;
                end

                i=i+1;
           end
        end
    end
    
    fclose(file);
    
    N_vertices=length(vertices);
    N_faces=length(faces);
    
    fprintf('N_vertices:%i\n',N_vertices);
    fprintf('N_faces:%i\n',N_faces);
    
    edges=zeros(2,3*N_faces);
    
    for i=1:N_faces
        edges(1,3*i-2)=faces(i,1);
        edges(2,3*i-2)=faces(i,2);
        edges(1,3*i-1)=faces(i,2);
        edges(2,3*i-1)=faces(i,3);
        edges(1,3*i)=faces(i,3);
        edges(2,3*i)=faces(i,1);
        edges(3,3*i-2)=i;
        edges(3,3*i-1)=i;
        edges(3,3*i)=i;
        edges(4,3*i-2)=0;
        edges(4,3*i-1)=0;
        edges(4,3*i)=0;
    end
    
    fprintf('N_edges:%i\n',size(edges,2));
    
    unique_edges=[];
    k=1;
    for i=1:size(edges,2)
        
        if edges(4,i)==0 %edge already processed
            
            i1=edges(1,i);%edge point 1
            i2=edges(2,i);%edge point 2
            i3=edges(3,i);%element ID
            edge_exists=-1;
            
            for j=1:size(edges,2)               
                j1=edges(1,j); %edge point 1
                j2=edges(2,j); %edge point 2
                j3=edges(3,j); %element ID
                if i1==j2 && i2==j1
                    edge_exists=1;
                    edges(4,j)=1; %mark edge as processed
                    break;
                end             
            end
            
            edges(4,i)=1; %mark edge as processed
           
            if edge_exists~=-1  %edge is shared by two elements  
               unique_edges(1,k)=i1; %edge point 1
               unique_edges(2,k)=i2; %edge point 2
               unique_edges(3,k)=i3; %element 1 ID
               unique_edges(4,k)=j3; %element 2 ID
               k=k+1; 
            else %edge is single
               unique_edges(1,k)=i1; %edge point 1
               unique_edges(2,k)=i2; %edge point 2
               unique_edges(3,k)=i3; %element 1 ID
               unique_edges(4,k)=-1; %no element ID
               k=k+1; 
            end
        end
    end
    
    N_unique_edges=size(unique_edges,2);
    
    fprintf('N_unique_edges:%i\n',N_unique_edges);
    
    faces_type=ones(N_faces,1);
    
    for i=1:N_unique_edges
       if unique_edges(4,i)==-1
          faces_type(unique_edges(3,i),1)=-1; 
       end
    end
    
    faces_area=zeros(N_faces,1);
    faces_centres=zeros(N_faces,3);
    for i=1:N_faces
        r1=vertices(faces(i,1),:)';
        r2=vertices(faces(i,2),:)';
        r3=vertices(faces(i,3),:)';
        d1=r2-r1;
        d2=r3-r1;
        n=cross(d1,d2);
        S=0.5*norm(n);
        faces_area(i,1)=S;
        faces_centres(i,:)=1/3*(r1+r2+r3)';
    end
    
    for i=1:N_unique_edges
        r1=vertices(unique_edges(1,i),:);
        r2=vertices(unique_edges(2,i),:);
        r=0.5*(r1+r2);
        d1=r2-r1;
        n=cross(d1,[0;0;1]);
        norm_n=norm(n);
        n=n/norm_n;
        unique_edges(5,i)=n(1);
        unique_edges(6,i)=n(2);
        unique_edges(7,i)=n(3);
        unique_edges(8,i)=norm_n;
        unique_edges(9,i)=r(1);
        unique_edges(10,i)=r(2);
        unique_edges(11,i)=r(3);
    end
 
    grid={};
    grid.N_vertices=N_vertices;
    grid.N_faces=N_faces;
    grid.vertices=vertices;
    grid.faces=faces;
    grid.N_edges=N_unique_edges;
    grid.edges=unique_edges;
    grid.faces_type=faces_type;
    grid.faces_area=faces_area;
    grid.faces_centres=faces_centres;
   
end