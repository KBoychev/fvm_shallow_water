clear all;
close all;
clc;


% Mesh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% case_name='dam_coarse_lf/dam';
case_name='dam_coarse_roe/dam';
% case_name='dam_fine/dam';

grid=read_grid(sprintf('%s.stl',case_name));

% Conserative variables and simulation settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Q=zeros(3,grid.N_faces);

N_timesteps=500;
output_frequency=100;
flux='roe'; %lax or roe
t=0;
dt=0.003;
g=9.08665;


% Initial conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:grid.N_faces
    x=grid.faces_centres(i,1);
    if x <= -0.3
        Q(1,i)=1.5;
        Q(2,i)=0;
        Q(3,i)=0;
    else
        Q(1,i)=1;
        Q(2,i)=0;
        Q(3,i)=0;
    end
end

% Time loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1);
hold on;
patch('Faces',grid.faces,'Vertices',grid.vertices,'FaceVertexCData',grid.faces_type,'FaceColor','flat','EdgeColor','black','Clipping','off');
quiver3(grid.edges(9,:),grid.edges(10,:),grid.edges(11,:),grid.edges(5,:),grid.edges(6,:),grid.edges(7,:));

axis equal;
colormap jet;
colorbar;
drawnow;

figure(2);
hold on;
patch_plot=patch('Faces',grid.faces,'Vertices',grid.vertices,'FaceVertexCData',Q(1,:)','FaceColor','flat','EdgeColor','none','Clipping','off');

axis equal;
colormap jet;
colorbar;
drawnow;

for n=1:N_timesteps
    
    fprintf('Starting timestep %i\n',n);
    
    %Set cell residuals to 0
    R=zeros(3,grid.N_faces);

    % Flux calculation
    for i=1:grid.N_edges

        el=grid.edges(3,i);
        er=grid.edges(4,i);
        nx=grid.edges(5,i);
        ny=grid.edges(6,i);
        nz=grid.edges(7,i);
        l=grid.edges(8,i);

        %Left conservative variables
        Ql=Q(:,el);
        
        %Right conservative variables
        if er~=-1
            Qr=Q(:,er);
        else
           Qr=Ql;
           Qr(2)=-Qr(2);
           Qr(3)=-Qr(3);
        end
        
        delta=Qr-Ql;
         
        %Left primitive variables
        hl=Ql(1);
        ul=Ql(2)/Ql(1);
        vl=Ql(3)/Ql(1);

        %Right primitive variables
        hr=Qr(1);
        ur=Qr(2)/Qr(1);
        vr=Qr(3)/Qr(1);
        
        Fxl(1,1)=hl*ul;
        Fxl(2,1)=hl*ul^2+g/2*hl^2;
        Fxl(3,1)=hl*ul*vl;

        Fxr(1,1)=hr*ur;
        Fxr(2,1)=hr*ur^2+g/2*hr^2;
        Fxr(3,1)=hr*ur*vr;

        Fyl(1,1)=hl*vl;
        Fyl(2,1)=hl*vl*ul;
        Fyl(3,1)=hl*vl^2+g/2*hl^2;

        Fyr(1,1)=hr*vr;
        Fyr(2,1)=hr*vr*ur;
        Fyr(3,1)=hr*vr^2+g/2*hr^2;

        Fl=Fxl*nx+Fyl*ny;
        Fr=Fxr*nx+Fyr*ny;
        
        % Lax-Friedriechs flux
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if strcmp(flux,'lax')==1
            c=sqrt(g*hr);
            wl=abs(ul*nx+vl*ny)+c;
            wr=abs(ur*nx+vr*ny)+c;
            w=max(wl,wr)*delta;
            F=1/2*(Fl+Fr)+w/2;
        end
        
        % Roe flux
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if strcmp(flux,'roe')==1
            
            %Roe averages
            h=0.5*(hr+hl);
            u=(sqrt(hl)*ul+sqrt(hr)*ur)/(sqrt(hl)+sqrt(hr));
            v=(sqrt(hl)*vl+sqrt(hr)*vr)/(sqrt(hl)+sqrt(hr));
            c=sqrt(g*h);
            
            %B=dFxdQ
            %C=dFydQ
            %A=B*nx+C*ny;
            %A=[0,nx,ny;g*h*nx-u*(u*nx+v*ny),u*nx+(u*nx+v*ny), u*ny;g*h*ny-v*(u*nx+v*ny),v*nx,v*ny+(u*nx+v*ny)];
            
            %Eigenvalues of A
            lambda1=u*nx+v*ny-c;
            lambda2=u*nx+v*ny;
            lambda3=u*nx+v*ny+c;
            
            %Left eigenvectors of A
            I1(1,1)=1/2+(u*nx+v*ny)/(2*c);
            I1(2,1)=-nx/(2*c);
            I1(3,1)=-ny/(2*c);
            
            I2(1,1)=v*nx-u*ny;
            I2(2,1)=ny;
            I2(3,1)=-nx;
            
            I3(1,1)=1/2-(u*nx+v*ny)/(2*c);
            I3(2,1)=nx/(2*c);
            I3(3,1)=ny/(2*c);
            
            %Right eigenvectors of A
            r1(1,1)=1;
            r1(2,1)=u-c*nx;
            r1(3,1)=v-c*ny;
            
            r2(1,1)=0;
            r2(2,1)=ny;
            r2(3,1)=-nx;
            
            r3(1,1)=1;
            r3(2,1)=u+c*nx;
            r3(3,1)=v+c*ny;
            
            w=entropy_fix(lambda1)*dot(I1,delta)*r1+entropy_fix(lambda2)*dot(I2,delta)*r2+entropy_fix(lambda3)*dot(I3,delta)*r3;
            
            F=1/2*(Fl+Fr)+w/2;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %Subtract flux from left cell
        R(:,el)=R(:,el)-F*l; 
        
        if er~=-1 %Check if right cell exists
            %Add flux to right cell
            R(:,er)=R(:,er)+F*l;
        end
        
    end
    
    % Time integration
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for i=1:grid.N_faces
        Q(:,i)=Q(:,i)-dt/grid.faces_area(i)*R(:,i);
    end
    
    t=t+dt;
    
    % Results output
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if output_frequency>0
        if mod(n,output_frequency)==0
            write_results(grid,Q,R,n,case_name)
        end
    end
    set(patch_plot,'FaceVertexCData',Q(1,:)');
    pause(0.1);
end


function lambda_fix = entropy_fix(lambda)
    eps=2;
    if abs(lambda) >= eps
       lambda_fix=abs(lambda); 
    else
       lambda_fix=(lambda*lambda+eps*eps)/(2*eps);
    end
end


