function write_results(mesh,Q,R,iter,case_name)
    
    results_file=sprintf('%s_Ascii.%i.vtu',case_name,iter);
    file=fopen(results_file,'w');
    fprintf(file,'<VTKFile type="UnstructuredGrid" version="0.1">\n');
    fprintf(file,'\t<UnstructuredGrid>\n');
    fprintf(file,'\t\t<Piece NumberOfPoints="%i" NumberOfCells="%i">\n',mesh.N_vertices,mesh.N_faces);
    fprintf(file,'\t\t\t<CellData>\n');
    fprintf(file,'\t\t\t\t<DataArray type="Int32" Name="boundary" NumberOfComponents="1" Format="ascii">\n');
    for i=1:mesh.N_faces
        fprintf(file,'%i\n',mesh.faces_type(i));
    end
    fprintf(file,'\t\t\t\t</DataArray>\n');
    fprintf(file,'\t\t\t\t<DataArray type="Float64" Name="h" NumberOfComponents="1" Format="ascii">\n');
    for i=1:mesh.N_faces
        fprintf(file,'%0.10f\n',Q(1,i));
    end
    fprintf(file,'\t\t\t\t</DataArray>\n');
    fprintf(file,'\t\t\t\t<DataArray type="Float64" Name="u" NumberOfComponents="1" Format="ascii">\n');
    for i=1:mesh.N_faces
        fprintf(file,'%0.10f\n',Q(2,i)/Q(1,i));
    end
    fprintf(file,'\t\t\t\t</DataArray>\n');
    fprintf(file,'\t\t\t\t<DataArray type="Float64" Name="v" NumberOfComponents="1" Format="ascii">\n');
    for i=1:mesh.N_faces
        fprintf(file,'%0.10f\n',Q(3,i)/Q(1,i));
    end
    fprintf(file,'\t\t\t\t</DataArray>\n');
    fprintf(file,'\t\t\t\t<DataArray type="Float64" Name="R1" NumberOfComponents="1" Format="ascii">\n');
    for i=1:mesh.N_faces
        fprintf(file,'%0.10f\n',R(1,i));
    end
    fprintf(file,'\t\t\t\t</DataArray>\n');
    fprintf(file,'\t\t\t\t<DataArray type="Float64" Name="R2" NumberOfComponents="1" Format="ascii">\n');
    for i=1:mesh.N_faces
        fprintf(file,'%0.10f\n',R(2,i));
    end
    fprintf(file,'\t\t\t\t</DataArray>\n');
    fprintf(file,'\t\t\t\t<DataArray type="Float64" Name="R3" NumberOfComponents="1" Format="ascii">\n');
    for i=1:mesh.N_faces
        fprintf(file,'%0.10f\n',R(3,i));
    end
    fprintf(file,'\t\t\t\t</DataArray>\n');
    fprintf(file,'\t\t\t</CellData>\n');
    fprintf(file,'\t\t\t<Points>\n');
    fprintf(file,'\t\t\t\t<DataArray type="Float64" Name="position" NumberOfComponents="3" Format="ascii">\n');
    for i=1:mesh.N_vertices
        fprintf(file,'%0.10f\t%0.10f\t%0.10f\n',mesh.vertices(i,1),mesh.vertices(i,2),mesh.vertices(i,3));
    end
    fprintf(file,'\t\t\t\t</DataArray>\n');
    fprintf(file,'\t\t\t</Points>\n');
    fprintf(file,'\t\t\t<Cells>\n');
    fprintf(file,'\t\t\t\t<DataArray type="Int32" Name="connectivity" Format="ascii">\n');
    for i=1:mesh.N_faces
        fprintf(file,'%i\t%i\t%i\n',mesh.faces(i,1)-1,mesh.faces(i,2)-1,mesh.faces(i,3)-1);
    end
    fprintf(file,'\t\t\t\t</DataArray>\n');
    fprintf(file,'\t\t\t\t<DataArray type="Int32" Name="offsets" Format="ascii">\n');
    for i=1:mesh.N_faces
        fprintf(file,'%i\n',3 * i);
    end
    fprintf(file,'\t\t\t\t</DataArray>\n');
    fprintf(file,'\t\t\t\t<DataArray type="Int32" Name="types" Format="ascii">\n');
    for i=1:mesh.N_faces
        fprintf(file,'5\n');
    end
    fprintf(file,'\t\t\t\t</DataArray>\n');
    fprintf(file,'\t\t\t</Cells>\n');
    fprintf(file,'\t\t</Piece>\n');
    fprintf(file,'\t</UnstructuredGrid>\n');
    fprintf(file,'</VTKFile>\n');
    fclose(file);
end